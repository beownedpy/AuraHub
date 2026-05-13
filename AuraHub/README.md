# AuraHub

**Personal UI Backup & Restore Manager for WoW 3.3.5a (Wrath of the Lich King)**

AuraHub lets you save and restore your entire UI setup — WeakAuras, ElvUI profile, Skada layout, keybinds, macros, and action bar layouts — with a single click. It also ships a sync script that copies your backups across multiple WoW accounts automatically.

---

## Features

| Feature | What it saves |
|---|---|
| **WeakAuras** | Named backups of individual displays or your entire WA setup |
| **ElvUI** | Full ElvUI profile snapshot |
| **Skada** | Window layout and damage-meter settings |
| **Keybinds** | Complete keybind set, saved under a custom name |
| **Macros** | Character macros, account macros, or both |
| **Action Bars** | Slot layout for bars 1–6 (slots 1–72): spells, macros, items |
| **Multi-Account** | PowerShell script that merges data across all WoW accounts |

---

## Requirements

- World of Warcraft **3.3.5a** client (interface version 30300)
- **WeakAuras** addon — only needed for the WeakAuras tab
- **ElvUI** addon — only needed for the ElvUI tab
- **Skada** addon — only needed for the Skada tab
- PowerShell 5.1+ (built into Windows 10/11) — only for multi-account sync

---

## Installation

### 1 — Install the addon

Copy the **`AuraHub`** folder into your WoW addons directory:

```
World of Warcraft\
└── Interface\
    └── AddOns\
        └── AuraHub\        ← put the folder here
            ├── AuraHub.toc
            ├── Core.lua
            ├── SyncAuraHub.bat
            ├── SyncAuraHub.ps1
            └── ...
```

Enable **AuraHub** on the character select screen under AddOns.

### 2 — Set up multi-account sync (optional)

The sync scripts are included inside the addon folder. **No extra files need to be placed anywhere** — they work from their location inside `AuraHub\`.

```
World of Warcraft\Interface\AddOns\AuraHub\
├── SyncAuraHub.bat    ← double-click this to run the sync
└── SyncAuraHub.ps1    ← the actual merge logic (called by the .bat)
```

> **Both files must stay in the same folder.** The `.bat` calls the `.ps1` automatically. Do not move them separately.

---

## Opening AuraHub

Type `/aurahub` in chat, or click the **minimap icon**.

Press **ESC** or click **X** to close.

---

## How to Use Each Tab

### WeakAuras

1. Go to the **WeakAuras** tab.
2. Click **+ Save WeakAura** — a picker lists all displays from your WeakAuras database.
3. Select a display and click **Save**, or click **Save All** to back up everything at once.
4. To restore: click **Restore** on any saved card → confirm → **Reload Now**.

**Selective restore:** Click individual cards to select them (highlighted in blue), then click **Restore (N)**. Useful when switching specs — restore only what you need.

**Load Queue:** Click **+Q** on multiple cards to stage them, then click **Apply & Reload** on the bottom bar. All selected backups are restored in a single UI reload.

---

### ElvUI

1. Configure ElvUI to the desired state.
2. Go to the **ElvUI** tab → click **+ Save ElvUI Profile**.
3. The profile name is read automatically from ElvUI.
4. To restore: click **Load** → confirm → **Reload Now**.

> To update a backup, delete the old entry first, then save again.

---

### Skada

1. Arrange your Skada windows and settings.
2. Go to the **Skada** tab → click **+ Save Skada Profile**.
3. To restore: click **Load** → confirm → **Reload Now**.

---

### Keybinds

1. Set up keybindings in the WoW key bindings menu.
2. Go to the **Keybinds** tab → click **+ Save Keybinds** → enter a profile name (e.g. `Tank`, `DPS`, `PvP`).
3. To restore: click **Load** — bindings are applied and saved immediately, no reload needed.

---

### Macros

1. Go to the **Macros** tab.
2. Choose what to save:
   - **+ Character Macros** — saves only macros specific to the current character.
   - **+ All Macros** — saves both account-wide and character macros.
3. Enter a profile name and click **Save**.
4. To restore: click **Load** — missing macros are created, existing ones updated by name.

---

### Action Bars (Bars)

1. Set up your action bars (spells, macros, items in slots 1–72).
2. Go to the **Bars** tab → click **+ Save Bar Layout** → enter a name.
3. To restore: click **Load**.
   - Spells are found by name — if your current character doesn't know a spell, its slot is left empty rather than filled with a wrong ability.
   - Macros are matched by name and body text (handles same-named macros in different scopes).
   - Items are placed if present in your bags.
   - **Cannot restore during combat.**

> **Cross-spec / cross-class safety:** Save a layout on one spec, restore on another — unknown spells are silently skipped.

---

## Multi-Account Sync

AuraHub data is stored per WoW account. The sync script reads every account's `AuraHub.lua`, merges all backups (keeping the newest version of each entry), and writes the result back to every account.

### How to sync — step by step

> **Follow the sequence exactly. Skipping steps will cause the sync to use stale data.**

**Step 1 — Save your data in-game**

Log into the account that has the profiles you want to share. Make sure everything is saved in AuraHub (visible on the respective tabs).

**Step 2 — Exit WoW completely**

Fully close WoW — not just to the character select screen. WoW only writes `SavedVariables` files on a full exit.

**Step 3 — Run the sync**

Open File Explorer, navigate to:
```
World of Warcraft\Interface\AddOns\AuraHub\
```
Double-click **`SyncAuraHub.bat`**.

The script will:
- List all accounts found under `WTF\Account\` with their file sizes.
- Ask for confirmation before making any changes.
- Back up each account's `AuraHub.lua` as `AuraHub.lua.bak` before writing.

**Step 4 — Log into any account**

All your WeakAuras, ElvUI, Skada, Keybinds, Macros, and Bar layouts are now available on every account.

Repeat steps 1–3 whenever you update your profiles and want them synced.

---

### How the merge works

| Section | Deduplication key | Conflict resolution |
|---|---|---|
| WeakAuras | `uid` (WA's internal stable ID) | Newer `savedAt` wins |
| ElvUI, Skada, Keybinds, Macros, Bars | `name` | Newer `savedAt` wins |

### Deletion sync (tombstones)

When you delete an entry inside AuraHub (via the **×** button), a tombstone is recorded with a timestamp. The sync script reads tombstones from **all** accounts and removes the matching entry everywhere — it will not come back after syncing.

If you later re-save an entry with the same name, the tombstone is cleared and the new entry survives future syncs normally.

---

## Slash Commands

| Command | Description |
|---|---|
| `/aurahub` | Toggle the AuraHub window |
| `/aurahub reset` | **Danger:** Wipes all saved data and reloads the UI |
| `/aurahub sync add AccountName` | Register an account for in-game live sync |
| `/aurahub sync remove AccountName` | Remove an account from live sync |
| `/aurahub sync list` | List registered sync accounts |
| `/aurahub sync` | Pull data from all registered accounts now |
| `/aurahub iotest` | Test file I/O capabilities of the current client |
| `/aurahub pathtest AccountName` | Test which file paths are accessible |

---

## File Structure

```
AuraHub/
├── AuraHub.toc                  — Addon manifest (interface 30300)
├── SyncAuraHub.bat              — Double-click to run the multi-account sync
├── SyncAuraHub.ps1              — Merge logic (PowerShell 5.1+)
├── Core.lua                     — Initialization, events, slash commands
├── Data.lua                     — SavedVariables CRUD and tombstone system
├── Helpers.lua                  — Utility functions (serialize, time, plurals)
├── Importer.lua                 — Restores profiles into their target addons
├── Minimap.lua                  — Minimap button
├── Queue.lua                    — Load Queue (stage multiple restores)
├── UI.lua                       — Main frame, nav bar, widget factory
├── WeakAuras.lua                — WeakAuras database interface
├── localization/
│   ├── localization.en.lua      — English strings (default, always loaded)
│   └── localization.ru.lua      — Russian overrides (ruRU clients)
└── Pages/
    ├── Main.lua                 — Home page (summary + multi-account dialog)
    ├── WeakAuras.lua            — WeakAuras tab
    ├── ElvUI.lua                — ElvUI tab
    ├── Skada.lua                — Skada tab
    ├── Binds.lua                — Keybinds tab
    ├── Macros.lua               — Macros tab
    ├── ActionBars.lua           — Bars tab
    └── Help.lua                 — Help & About tab
```

---

## Saved Data Location

```
WTF\Account\<YOUR_ACCOUNT>\SavedVariables\AuraHub.lua
```

All backups live in this single file per account. The sync script reads and writes this file for every account found under `WTF\Account\`.

---

## Localization

Ships with **English** (default) and **Russian** locale support.

- `localization.en.lua` — base file, always loaded, defines every string.
- `localization.ru.lua` — overrides for `ruRU` clients, loaded after EN.

To add another language: copy `localization.en.lua`, rename it, change the `GetLocale()` guard at the top, and translate the strings you need. Untranslated keys fall back to English automatically.

---

## License

Free to use, fork, and modify. Credit appreciated but not required.
