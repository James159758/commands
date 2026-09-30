--@name commands
--@shared
--@author github.com/James159758

--@include commands/SHARED/commands.lua
--@include commands/CLIENT/cl_client.lua
--@include commands/SERVER/sv_server.lua

local rawPrint = print
print = function(...)
    local parts = {}
    for index = 1, select("#", ...) do
        parts[index] = tostring(select(index, ...))
    end
    rawPrint("[COMMANDS] " .. table.concat(parts, " "))
end

local commandRegistry = dofile("commands/SHARED/commands.lua")

if SERVER then
    dofile("commands/SERVER/sv_server.lua", commandRegistry)
else
    dofile("commands/CLIENT/cl_client.lua", commandRegistry)
end

print("initialized")

