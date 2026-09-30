--@client
local registry = ...
local commands = registry.commands

local function trim(value)
    return (value or ""):match("^%s*(.-)%s*$")
end

local function hasFindPermission()
    local ok, allowed, reason = pcall(hasPermission, "find")
    if ok and allowed then return true end

    if ok then
        print("Access denied: player lookup needs the StarfallEx 'find' permission. " .. tostring(reason or ""))
    else
        print("Player lookup permission check failed: " .. tostring(allowed))
    end
    return false
end

local function findTarget(name)
    name = trim(name)
    if name == "" then
        print("A player name is required")
        return
    end
    if not hasFindPermission() then return end

    local players = find.playersByName(name, false, false)
    if #players == 0 then
        print("Player not found: " .. name)
        return
    end
    if #players > 1 then
        print("More than one player matches '" .. name .. "'; enter a longer name")
        return
    end

    return players[1]
end

local function sendCommand(name, target)
    net.start(registry.channel)
    net.writeTable({ command = name, target = target })
    net.send()
end

local function showHelp(argument)
    argument = trim(argument):lower()
    if argument ~= "" then
        local definition = commands[argument]
        if not definition then
            print("Unknown command: !!" .. argument)
            return
        end
        print(definition.usage .. " - " .. definition.description)
        return
    end

    local names = {}
    for name in pairs(commands) do
        names[#names + 1] = name
    end
    table.sort(names)

    print("Available commands (chip owner only):")
    for _, name in ipairs(names) do
        local definition = commands[name]
        print(definition.usage .. " - " .. definition.description)
    end
    print("Use !!help <command> for details. Player names use partial, case-insensitive matching.")
end

local function runCommand(name, argument)
    if name == "help" then
        showHelp(argument)
        return
    end

    local definition = commands[name]
    if not definition then
        print("Unknown command: !!" .. name .. ". Use !!help to list commands.")
        return
    end

    argument = trim(argument)
    local target
    if definition.target == "required" or argument ~= "" then
        target = findTarget(argument)
        if not target then return end
    end

    sendCommand(name, target)
end

hook.add("PlayerChat", "[COMMANDS] chat command parser", function(playerEntity, message)
    if playerEntity ~= owner() then return end

    local name, argument = message:match("^!!([%a]+)(.*)$")
    if not name then return end
    if argument ~= "" and not argument:match("^%s") then return end

    local ok, err = pcall(runCommand, name:lower(), trim(argument))
    if not ok then
        print("Command could not be prepared: " .. tostring(err))
    end

    return false
end)
