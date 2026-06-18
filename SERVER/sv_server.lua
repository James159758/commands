--@server
local rawPrint = print
print = function(args)
    args = tostring(args)
    rawPrint("[COMMANDS server] " .. args)
end

print("initialized")

local Server = {}
Server.handlers = {}
Server.config = {
    god = {},
    mute = {}
}
function Server:register(flag, handler)
    self.handlers[flag] = handler
end

function Server:init()
    self:register("god", function(data)
        local index = data.target:getUserID()
        if self.config.god[index] ~= nil then
            print("GOD mode DEACTIVATED for " .. tostring(data.target))
            self.config.god[index] = nil
            return
        end
        self.config.god[index] = data.target
        print("GOD mode ACTIVATED for " .. tostring(data.target))
    end)
    self:register("bring", function(data) data.ply:setPos(owner():getPos() + Vector(0, 50, 0)) end)
    self:register("tp", function(data) owner():setPos(data.ply:getPos() + Vector(0, 50, 0)) end)
    self:register("kill", function(data) 
        data.target:applyDamage(math.huge, data.attacker, chip()) 
        if data.target:isAlive() then 
            data.target:kill()
        end
    end)
    self:register("mute", function(data)
        local index = data.target:getUserID()
        if self.config.mute[index] ~= nil then
            print(tostring(data.target) .. " removed from mute list")
            self.config.mute[index] = nil
            data.target:kill()
            return 
        end
        print(tostring(data.target) .. " added in mute list")
        self.config.mute[index] = data.target
        local entities = find.all(function(entity) return entity:getOwner() == data.target end)

        for _, entity in ipairs(entities) do
            if (not entity:isValid() and not entity:isPlayer()) then continue end
            //if entity:getClass() == "starfall_processor" then continue end
            entity:remove()
        end

        data.target:kill()
    end)

    net.receive("connection", function(len, ply)
        if ply ~= owner() then return end
        local data = net.readTable()
        local handler = self.handlers[data.flag]
        if handler then handler(data) end
    end)

    hook.add("EntityTakeDamage", "[COMMANDS server hook] EntityTakeDamage", function(target, attacker, inflictor, amount, type, position, force)
        if not target:isValid() or not target:isPlayer() then return end
        //print(target, attacker, inflictor)

        local index = target:getUserID()
        local boolean = not not self.config.god[index]
        return boolean
    end)
    hook.add("OnEntityCreated", "[COMMANDS server hook] OnEntityCreated", function(entity)
        if not entity:isValid() then return end
        local ownerEntity = entity:getOwner()
        if ownerEntity == nil or !ownerEntity:isValid() then return end
        local index = ownerEntity:getUserID()
        if self.config.mute[index] ~= nil then entity:remove() end
    end)
    hook.add("PlayerCanPickupWeapon", "[COMMANDS server hook] PlayerCanPickupWeapon", function(ply, wep)
        local index = ply:getUserID()
        local boolean = not not self.config.mute[index]
        return not boolean
    end)
    hook.add("PlayerNoClip", "[COMMANDS server hook] PlayerNoClip", function(ply, state)
        local index = ply:getUserID()
        if self.config.mute[index] ~= nil then ply:kill() end
    end)
    hook.add("PlayerSpawn", "[COMMANDS server hook] PlayerSpawn", function(ply)
        local index = ply:getUserID()
        if self.config.mute[index] then
            timer.simple(0, function()
            local allWeapons = ply:getWeapons()
            for _, wep in ipairs(allWeapons) do
                wep:remove()

            end
            end)
        end

    end)
    hook.add("tick", "", function()
        for plyid, _ in pairs(self.config.mute) do
            local ply = player(plyid)
            local allWeapons = ply:getWeapons()
            for _, wep in ipairs(allWeapons) do
                wep:remove()
            end
        end
    end)
    --we can remove all wpeaons by getting list of weapons ply:getweapons()

end


Server:init()