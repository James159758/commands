--@server
local rawPrint = print
print = function(args)
    rawPrint("[COMMANDS server] " .. args)
end

print("initialized")

local Server = {}
Server.handlers = {}
Server.config = {
    god = false
}
function Server:register(flag, handler)
    self.handlers[flag] = handler
end

function Server:init()
    self:register("god", function()
        self.config.god = not self.config.god 
        print(self.config.god and "GOD mode ACTIVATED" or "GOD mode DEACTIVATED")
    end)
    self:register("bring", function(data) data.ply:setPos(owner():getPos() + Vector(0, 50, 0)) end)
    self:register("tp", function(data) owner():setPos(data.ply:getPos() + Vector(0, 50, 0)) end)
    self:register("kill", function(data) data.target:applyDamage(math.huge, data.attacker, chip()) end)

    net.receive("connection", function(len, ply)
        if ply ~= owner() then return end
        local data = net.readTable()
        local handler = self.handlers[data.flag]
        if handler then handler(data) end
    end)

    hook.add("EntityTakeDamage", "[COMMANDS server hook] EntityTakeDamage", function(target, attacker, inflictor, amount, type, position, force)
        if target ~= owner() then return end
        return self.config.god
    end)
end


Server:init()