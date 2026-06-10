--@client
local rawPrint = print
print = function(args)
    args = tostring(args)
    rawPrint("[COMMANDS client] " .. args)
end

print("initialized")

local Client = {}
Client.commands = {}


local function sendData(data)
    net.start("connection")
    net.writeTable(data)
    net.send()
end

local function parseTarget(input)
    print(input)
    local results = find.playersByName(input, true, true)
    printTable(results)
    if #results == 0 then print("Player is not found: " .. input) return end
    if #results > 1 then print("not correct name") return end

    return results[1]
end

function Client:register(name, options)
    self.commands[name] = options
end

function Client:init()
    self:register("!!god", {execute = function(args)
        local target = parseTarget(args) 
        if not target then 
            target = owner() 
        end
        sendData({flag = "god", target = target}) 
    end})
    self:register("!!mute", {execute = function(args)
        local target = parseTarget(args) if not target then return end
        sendData({flag = "mute", target = target})
    end})
    self:register("!!bring", {execute = function(args)
        local target = parseTarget(args) if not target then return end
        sendData({flag = "bring", ply = target})
    end})
    self:register("!!tp", {execute = function(args)
        local target = parseTarget(args) if not target then return end
        sendData({flag = "tp", ply = target})
    end})
    self:register("!!kill", {execute = function(args)
        local target = parseTarget(args) if not target then return end
        sendData({flag = "kill", target = target, attacker = owner()})
    end})
    self:register("!!hkill", {execute = function(args)
        local target = parseTarget(args) if not target then return end
        local attacker = table.random(find.allPlayers(function(ply) return ply ~= owner() and ply ~= target end))
        if not attacker then print("Use !!kill to kill someone by your hands") return end
        sendData({flag = "kill", target = target, attacker = attacker})
    end})
    self:register("!!wkill", {execute = function(args)
        local target = parseTarget(args) if not target then return end
        sendData({flag = "kill", target = target, attacker = game.getWorld()})
    end})

    hook.add("PlayerChat", "", function(ply, message)
        if ply ~= owner() then return end

        local cmdName = message:match("^(!![A-Za-z]+)")
        if not cmdName then return end
        local cmd = self.commands[cmdName]
        if not cmd then return end

        local rest = message:sub(#cmdName + 2)
        cmd.execute(rest)
        
        return false
    end)
end

Client:init()