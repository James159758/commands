--@server
local registry = ...
local commands = registry.commands
local state = {
    god = {},
    muted = {},
    invalidCommands = {}
}

local function checkPermission(permission, entity, silent)
    local ok, allowed, reason = pcall(hasPermission, permission, entity)
    if ok and allowed then return true end

    if not silent then
        if ok then
            print("Access denied: required StarfallEx permission '" .. permission .. "'. " .. tostring(reason or ""))
        else
            print("Permission check failed safely for '" .. permission .. "': " .. tostring(allowed))
        end
    end
    return false
end

local function isValidPlayer(candidate)
    local ok, valid = pcall(function()
        return candidate and candidate:isValid() and candidate:isPlayer()
    end)
    return ok and valid
end

local function playerKey(playerEntity)
    return playerEntity:getUserID()
end

local function isGodEnabled(playerEntity)
    return state.god[playerKey(playerEntity)] == playerEntity
end

local function isMuted(playerEntity)
    return state.muted[playerKey(playerEntity)] == playerEntity
end

local function canRemoveAll(entities, reportFailure)
    for _, entity in ipairs(entities) do
        if !checkPermission("entities.remove", entity, not reportFailure) then
            return false
        end
    end
    return true
end

local function removeWithPermission(entities, reportFailure)
    if !canRemoveAll(entities, reportFailure) then return false end
    for _, entity in ipairs(entities) do
        entity:remove()
    end
    return true
end

local function protectHook(name, callback)
    return function(...)
        local ok, result = pcall(callback, ...)
        if not ok then
            print(name .. " failed safely: " .. tostring(result))
            return
        end
        return result
    end
end

local handlers = {}

handlers.god = function(context)
    local target = context.target
    local index = playerKey(target)
    if state.god[index] and state.god[index] ~= target then
        state.god[index] = nil
    end

    if state.god[index] == target then
        state.god[index] = nil
        print("God mode disabled for " .. tostring(target))
        return
    end

    state.god[index] = target
    print("God mode enabled for " .. tostring(target))
end

handlers.bring = function(context)
    context.target:setPos(context.owner:getPos() + Vector(0, 50, 0))
    print("Brought " .. tostring(context.target))
end

handlers.tp = function(context)
    context.owner:setPos(context.target:getPos() + Vector(0, 50, 0))
    print("Teleported to " .. tostring(context.target))
end

handlers.kill = function(context, definition)
    local attacker
    if definition.attacker == "owner" then
        attacker = context.owner
    elseif definition.attacker == "world" then
        attacker = game.getWorld()
    elseif definition.attacker == "randomOther" then
        local candidates = find.allPlayers(function(candidate)
            return candidate ~= context.owner and candidate ~= context.target
        end)
        attacker = table.random(candidates)
        if not attacker then
            print("hkill needs another online player besides you and the target")
            return
        end
    end

    if not attacker or !attacker:isValid() then
        print("Command rejected: could not select a valid attacker")
        return
    end

    context.target:applyDamage(math.huge, attacker, chip())
    if context.target:isAlive() and checkPermission("entities.setHealth", context.target) then
        context.target:kill()
    end
end

handlers.mute = function(context)
    local target = context.target
    local index = playerKey(target)
    if state.muted[index] and state.muted[index] ~= target then
        state.muted[index] = nil
    end

    if state.muted[index] == target then
        state.muted[index] = nil
        print("Mute restrictions disabled for " .. tostring(target))
        return
    end

    local ownedEntities = find.all(function(entity)
        return entity:isValid()
            and entity ~= chip()
            and !entity:isPlayer()
            and entity:getOwner() == target
    end)
    local weapons = target:getWeapons()

    if !canRemoveAll(ownedEntities, false) then
        print("Mute cancelled: chip lacks 'entities.remove' permission for an owned entity")
        return
    end
    if !canRemoveAll(weapons, false) then
        print("Mute cancelled: chip lacks 'entities.remove' permission for a weapon")
        return
    end

    state.muted[index] = target
    for _, entity in ipairs(ownedEntities) do entity:remove() end
    for _, weapon in ipairs(weapons) do weapon:remove() end

    print("Mute restrictions enabled for " .. tostring(target))
    if checkPermission("entities.setHealth", target, true) then
        target:kill()
    else
        print("Target was not killed: missing 'entities.setHealth' permission")
    end
end

for name, definition in pairs(commands) do
    local invalid = type(definition) ~= "table"
        or type(definition.action) ~= "string"
        or type(handlers[definition.action]) ~= "function"
        or (definition.target ~= nil and definition.target ~= "required" and definition.target ~= "optional")

    if not invalid and definition.permission ~= nil then
        local permission = definition.permission
        invalid = type(permission) ~= "table"
        if not invalid then
            invalid = type(permission.id) ~= "string"
                or (permission.subject ~= "owner" and permission.subject ~= "target")
        end
    end

    if invalid then
        state.invalidCommands[name] = true
        print("Invalid command registry entry: " .. tostring(name))
    end
end

local function dispatch(sender, request)
    if sender ~= owner() then
        print("Access denied: only the chip owner can run commands")
        return
    end
    if type(request) ~= "table" or type(request.command) ~= "string" then
        print("Command rejected: invalid request data")
        return
    end

    local name = string.lower(request.command)
    if state.invalidCommands[name] then
        print("Command unavailable due to an invalid server registry entry: !!" .. name)
        return
    end
    local definition = commands[name]
    local handler = definition and handlers[definition.action]
    if not definition or not handler then
        print("Command rejected: unknown command")
        return
    end

    local context = { owner = owner(), target = request.target }
    if definition.target == "optional" and not context.target then
        context.target = context.owner
    end
    if definition.target and not isValidPlayer(context.target) then
        print("Command rejected: target is not a valid player")
        return
    end
    if not isValidPlayer(context.owner) then
        print("Command rejected: chip owner is not a valid player")
        return
    end

    if definition.serverFind and !checkPermission("find") then return end

    local permission = definition.permission
    if permission then
        local subject = context[permission.subject]
        local togglingOff = definition.action == "god" and isGodEnabled(context.target)
        if not togglingOff and !checkPermission(permission.id, subject) then return end
    end

    handler(context, definition)
end

net.receive(registry.channel, function(_, sender)
    local ok, err = pcall(function()
        local request = net.readTable()
        dispatch(sender, request)
    end)
    if not ok then
        print("Command failed safely: " .. tostring(err))
    end
end)

hook.add("EntityTakeDamage", "[COMMANDS] god mode", protectHook("God mode hook", function(target)
    if !target:isValid() or !target:isPlayer() or !isGodEnabled(target) then return end
    if checkPermission("entities.blockDamage", target, true) then return true end
end))

hook.add("OnEntityCreated", "[COMMANDS] muted owner entities", function(entity)
    local ok, err = pcall(function()
        if !entity:isValid() then return end
        local entityOwner = entity:getOwner()
        if !isValidPlayer(entityOwner) or !isMuted(entityOwner) then return end
        if checkPermission("entities.remove", entity, true) then
            entity:remove()
        end
    end)
    if not ok then print("Entity cleanup failed safely: " .. tostring(err)) end
end)

hook.add("PlayerNoClip", "[COMMANDS] mute noclip", protectHook("Mute noclip hook", function(playerEntity)
    if isMuted(playerEntity) and checkPermission("entities.setHealth", playerEntity, true) then
        playerEntity:kill()
    end
end))

hook.add("PlayerSpawn", "[COMMANDS] mute spawn weapons", function(playerEntity)
    if !isMuted(playerEntity) then return end
    timer.simple(0, function()
        local ok, err = pcall(function()
            if !isValidPlayer(playerEntity) or !isMuted(playerEntity) then return end
            removeWithPermission(playerEntity:getWeapons(), true)
        end)
        if not ok then print("Weapon cleanup failed safely: " .. tostring(err)) end
    end)
end)

hook.add("PlayerDisconnected", "[COMMANDS] clear player state", function(playerEntity)
    local ok, err = pcall(function()
        local index = playerKey(playerEntity)
        if state.god[index] == playerEntity then state.god[index] = nil end
        if state.muted[index] == playerEntity then state.muted[index] = nil end
    end)
    if not ok then print("Player state cleanup failed safely: " .. tostring(err)) end
end)
