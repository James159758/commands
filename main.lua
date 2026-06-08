--@name commands
--@shared
--@author github.com/James159758

print("[COMMANDS] initialized")

--@includedir commands/SHARED/
dodir("commands/SHARED")

if SERVER then
    --@includedir commands/SERVER/
    dodir("commands/SERVER", {})
else
    --@includedir commands/CLIENT/
    dodir("commands/CLIENT", {})
end

