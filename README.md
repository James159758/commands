# SF Commands

A chat-command chip for [StarfallEx](https://github.com/thegrb93/StarfallEx) in Garry's Mod. Only the chip owner can run commands.

## Commands

| Command | Usage | Description |
|---|---|---|
| `!!help` | `!!help [command]` | List commands or show one command's usage. |
| `!!god` | `!!god [player]` | Toggle damage blocking; defaults to the chip owner. |
| `!!bring` | `!!bring <player>` | Bring a player to the chip owner. |
| `!!tp` | `!!tp <player>` | Teleport the chip owner to a player. |
| `!!kill` | `!!kill <player>` | Damage the target with the chip owner as attacker. |
| `!!hkill` | `!!hkill <player>` | Damage the target with a random third player as attacker. |
| `!!wkill` | `!!wkill <player>` | Damage the target with the world as attacker. |
| `!!mute` | `!!mute <player>` | Toggle removal of owned entities and the target's current or respawned weapons. With `entities.setHealth`, enabling it and noclip attempts also kill the target. It does not mute voice or chat. |

Names are matched partially and without case sensitivity. Use a longer name if multiple players match.

## StarfallEx permissions

Grant the chip `find` for player lookup and for `hkill` and `mute`. The server checks action permissions against the affected entity:

- `entities.blockDamage` for enabling god mode.
- `entities.setPos` for `bring` and `tp`.
- `entities.applyDamage` for `kill`, `hkill`, and `wkill`.
- `entities.setHealth` for the fallback kill after damage and for the kill effect of `mute`.
- `entities.remove` for entities and weapons removed by `mute`.

When a command cannot run, the chip prints the missing permission or the reason it rejected the request. Errors while dispatching a command are caught so one bad request does not stop the chip.

## Installation

Copy this project folder into `garrysmod/data/starfall/commands/`. Open `starfall/commands/main.lua` in the StarfallEx editor and upload the chip.

```text
commands/
|-- main.lua
|-- CLIENT/cl_client.lua
|-- SERVER/sv_server.lua
`-- SHARED/commands.lua
```

## Behavior notes

- `mute` can permanently remove props and other entities owned by its target. It checks removal permission for all current entities and weapons before enabling. Future owned entities are removed when possible; weapons are removed on activation and spawn. StarfallEx restricts the weapon-pickup hook so a chip can only block pickup by its owner; this project does not claim to block pickups by other targets, who may pick up weapons again afterward. There is no per-tick weapon scan.
- `hkill` needs at least one other online player besides the owner and target. The server selects the attacker.
- God and mute state last only while this chip instance is running.

## Architecture

`SHARED/commands.lua` is the command registry for usage, target requirements, routing, and permissions. The client parses chat and resolves player names from this registry. The server validates ownership, command name, target, and permissions, then dispatches to action handlers. Attacker selection and permission enforcement stay on the server.

## License

MIT.
