# ⚡ SF Commands

A lightweight admin command system for [StarfallEx](https://github.com/thegrb93/StarfallEx) — Garry's Mod's Lua scripting addon.  
Trigger powerful server-side actions directly from the in-game chat using `!!` prefixed commands.

---

## 📋 Commands

| Command | Arguments | Description |
|---|---|---|
| `!!god` | `<name>` or `<skip` | Toggle god mode (immune to all damage) |
| `!!bring` | `<name>` | Teleport a player to you |
| `!!tp` | `<name>` | Teleport yourself to a player |
| `!!kill` | `<name>` | Kill a player (you appear as attacker) |
| `!!hkill` | `<name>` | Kill a player via a random third-party attacker |
| `!!wkill` | `<name>` | Kill a player via world damage |
| `!!mute` | `<name>`  | Remove all player's entities and strip their weapons |

> **Note:** Only the chip owner can execute commands.

---

## 🔧 Requirements

- **Garry's Mod** — [Steam](https://store.steampowered.com/app/4000/)
- **StarfallEx** — [Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=1135165779)

---

## 📦 Installation

### Step 1 — Download the project

**Option A — Git clone**
```bash
git clone https://github.com/James159758/commands.git
```

**Option B — Download ZIP**

1. Click the green **`<> Code`** button at the top of this page
2. Select **Download ZIP**
3. Extract the archive somewhere convenient

---

### Step 2 — Place files into StarfallEx directory

Copy the entire `commands` folder into your StarfallEx data directory:

```
GarrysMod/
└── garrysmod/
    └── data/
        └── starfall/
            └── commands/        ← place it here
                ├── main.lua
                ├── CLIENT/
                │   └── cl_client.lua
                ├── SERVER/
                │   └── sv_server.lua
                └── SHARED/
```

> **Where is my GarrysMod folder?**  
> In Steam → right-click **Garry's Mod** → **Manage** → **Browse local files**

---

### Step 3 — Create and upload the chip in-game

1. Launch **Garry's Mod** and load into a server or singleplayer
2. Open the **StarfallEx** tool from the spawnmenu
3. Place a **Starfall Chip** entity in the world
4. Open the **SF Editor** (press `E` on the chip or use the tool menu)
5. In the editor, click **File → Open** and navigate to:
   ```
   starfall/commands/main.lua
   ```
6. Click **Upload** (or press `Ctrl+U`)
7. The chip is now active ✅

---

## 🚀 Usage

Once the chip is running, type commands directly in the in-game chat:

```
!!god
!!bring PlayerName
!!tp PlayerName
!!kill PlayerName
!!hkill PlayerName
!!wkill PlayerName
```

Player name matching is **partial and case-insensitive** — `!!bring jim` will find `Jimmy` if he's the only match.

---

## 📁 Project Structure

```
commands/
├── main.lua              # Entry point — loads all modules
├── CLIENT/
│   └── cl_client.lua     # Chat hook, command registration, net sends
├── SERVER/
│   └── sv_server.lua     # Net receiver, action handlers, god mode hook
└── SHARED/               # Shared utilities (reserved for future use)
```

---

## ⚠️ Troubleshooting

**"Player not found"**  
→ Make sure the name you typed matches at least part of the player's name, and that only one player matches.

**"Use !!kill to kill someone by your hands" (on !!hkill)**  
→ There are no other players on the server besides you and the target. `!!hkill` requires a third party.

**Commands not responding**  
→ Confirm the chip is uploaded and you are the chip **owner**. Commands are restricted to the owner only.

---

## 📄 License

MIT — free to use, modify, and distribute.
