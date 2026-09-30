-- Command metadata shared by the client parser and server dispatcher.
return {
    channel = "sf_commands_v1",
    commands = {
        god = {
            usage = "!!god [player]",
            description = "Toggle damage blocking; defaults to you.",
            target = "optional",
            action = "god",
            permission = { id = "entities.blockDamage", subject = "target" }
        },
        bring = {
            usage = "!!bring <player>",
            description = "Bring a player to you.",
            target = "required",
            action = "bring",
            permission = { id = "entities.setPos", subject = "target" }
        },
        tp = {
            usage = "!!tp <player>",
            description = "Teleport to a player.",
            target = "required",
            action = "tp",
            permission = { id = "entities.setPos", subject = "owner" }
        },
        kill = {
            usage = "!!kill <player>",
            description = "Damage a player; you are the attacker.",
            target = "required",
            action = "kill",
            attacker = "owner",
            permission = { id = "entities.applyDamage", subject = "target" }
        },
        hkill = {
            usage = "!!hkill <player>",
            description = "Damage a player with another player as attacker.",
            target = "required",
            action = "kill",
            attacker = "randomOther",
            permission = { id = "entities.applyDamage", subject = "target" },
            serverFind = true
        },
        wkill = {
            usage = "!!wkill <player>",
            description = "Damage a player with the world as attacker.",
            target = "required",
            action = "kill",
            attacker = "world",
            permission = { id = "entities.applyDamage", subject = "target" }
        },
        mute = {
            usage = "!!mute <player>",
            description = "Toggle entity and weapon restrictions for a player.",
            target = "required",
            action = "mute",
            serverFind = true
        }
    }
}
