-- AuraHub — localization\localization.en.lua
-- English strings (default locale, always loaded first)

AuraHub    = AuraHub    or {}
AuraHub.L  = AuraHub.L  or {}

local L = AuraHub.L

-- Core / static popups 
L["RELOAD_BODY"]        = "|cff4db8ffAuraHub|r\n\n%s\n\n|cffaaaaaaReload UI to apply changes?|r"
L["RELOAD_NOW"]         = "Reload Now"
L["RELOAD_LATER"]       = "Later"
L["SAVE_NAME_BODY"]     = "%s\n|cff888888Enter a name for this backup:|r"
L["SAVE_NAME_DEFAULT"]  = "Backup %Y-%m-%d"
L["BTN_SAVE"]           = "Save"
L["BTN_CANCEL"]         = "Cancel"
L["BTN_RESTORE"]        = "Restore"
L["BTN_DELETE"]         = "X"
L["BTN_GOT_IT"]         = "Got it"
L["DELETE_BODY"]          = "Delete |cffcccccc'%s'|r from AuraHub backups?\n|cff888888This cannot be undone.|r"
L["BTN_DELETE_CONFIRM"]   = "Delete"
L["RESTORE_MACROS_BODY"]  = "Load macro profile |cffcccccc'%s'|r?\n|cff888888All current macros will be replaced.|r"
L["BTN_RESTORE_CONFIRM"]  = "Load"
L["ADDON_LOADED_MSG"]   = "v%s  •  /aurahub to open"
L["RESET_MSG"]          = "All saved data cleared. Reload to apply."

-- Time ago ─
L["TIME_JUST_NOW"]  = "just now"
L["TIME_AGO_MIN"]   = "%dm ago"
L["TIME_AGO_HOUR"]  = "%dh ago"
L["TIME_AGO_DAY"]   = "%dd ago"
L["TIME_UNKNOWN"]   = "unknown"

-- Plural word forms (singular / few / many) 
-- English only uses [1] singular and [3] plural (few = plural)
L["WORD_DISPLAY"]       = "display"
L["WORD_DISPLAY_FEW"]   = "displays"
L["WORD_DISPLAYS"]      = "displays"

L["WORD_BACKUP"]        = "backup"
L["WORD_BACKUP_FEW"]    = "backups"
L["WORD_BACKUPS"]       = "backups"

L["WORD_AURA"]          = "aura"
L["WORD_AURA_FEW"]      = "auras"
L["WORD_AURAS"]         = "auras"

L["WORD_MACRO"]         = "macro"
L["WORD_MACRO_FEW"]     = "macros"
L["WORD_MACROS"]        = "macros"

L["WORD_SLOT"]          = "slot"
L["WORD_SLOT_FEW"]      = "slots"
L["WORD_SLOTS"]         = "slots"

-- WeakAuras page 
L["WA_TITLE"]            = "|cff4db8ffWeakAuras|r  — Backups"
L["WA_BTN_SAVE"]         = "+ Save WeakAura"
L["WA_BTN_SAVE_ALL"]     = "+ Save All"
L["WA_BTN_RESTORE_ALL"]  = "Restore All"
L["WA_BTN_CLEAR_ALL"]    = "Clear All"
L["WA_BTN_RESTORE_SEL"]  = "Restore (%d)"
L["WA_BTN_CLEAR_SEL"]    = "Clear"
L["WA_EMPTY"]            = "|cff333340No WeakAura backups saved yet.\n\n|r" ..
                           "|cff404050Click  |r|cff4db8ff+ Save WeakAura|r" ..
                           "|cff404050  above to backup a display from your current setup.|r"
L["WA_META"]             = "|cff353545%d %s  ·  %s|r"
L["WA_SEARCH_HINT"]      = "Search..."
-- Picker dialog
L["WA_PICKER_TITLE"]         = "|cff4db8ffSave WeakAura|r"
L["WA_PICKER_NAME_LBL"]      = "|cff606065Name:|r"
L["WA_PICKER_BTN_SAVE"]      = "Save"
L["WA_PICKER_BTN_SAVE_ALL"]  = "Save All"
L["WA_PICKER_BTN_CANCEL"]    = "Cancel"
L["WA_STATUS_NO_WA"]         = "|cff663333No WeakAuras found in your database.|r"
L["WA_STATUS_ALL_SAVED"]     = "|cff44aa44All WeakAuras are already saved in AuraHub.|r"
L["WA_STATUS_FOUND"]         = "|cff404050%d %s found — click to select|r"
-- Errors & messages
L["WA_ERR_NOT_READY"]    = "WeakAuras is not loaded or database not ready."
L["WA_ERR_SELECT_FIRST"] = "Select a WeakAura from the list first."
L["WA_ERR_ALREADY_SAVED"]= "'%s' is already saved."
L["WA_ERR_ENTER_NAME"]   = "Enter a name for this backup."
L["WA_ERR_CAPTURE_FAIL"] = "Capture failed."
L["WA_ERR_NO_WA"]        = "No WeakAuras found."
L["WA_ERR_NO_CAPTURES"]  = "No displays captured."
L["WA_PRINT_SAVED"]      = "'%s' saved."
L["WA_PRINT_ALL_SAVED"]  = "Saved %d WeakAura(s)."

-- ElvUI page 
L["ELVUI_TITLE"]          = "|cff4db8ffElvUI|r  — Backups"
L["ELVUI_BTN_SAVE"]       = "+ Save ElvUI Profile"
L["ELVUI_EMPTY"]          = "|cff333340No ElvUI backups saved yet.\n\n|r" ..
                            "|cff404050Configure your UI, then click  |r|cff4db8ff+ Save Current Profile|r" ..
                            "|cff404050  above.|r"
L["ELVUI_META"]           = "|cff353545ElvUI profile  ·  %s|r"
L["ELVUI_ERR_NOT_LOADED"] = "ElvUI is not loaded."
L["ELVUI_ERR_DB"]         = "ElvUI database not ready."
L["ELVUI_ERR_DUPLICATE"]  = "Profile '%s' is already saved."
L["ELVUI_PRINT_SAVED"]    = "ElvUI profile '%s' saved."

-- Skada page 
L["SKADA_TITLE"]          = "|cff4db8ffSkada|r  — Backups"
L["SKADA_BTN_SAVE"]       = "+ Save Skada Profile"
L["SKADA_EMPTY"]          = "|cff333340No Skada backups saved yet.\n\n|r" ..
                            "|cff404050Configure your Skada layout, then click  |r|cff4db8ff+ Save Current Layout|r" ..
                            "|cff404050  above.|r"
L["SKADA_META"]           = "|cff353545Skada layout  ·  %s|r"
L["SKADA_ERR_NOT_LOADED"] = "Skada is not loaded."
L["SKADA_ERR_DB"]         = "Skada database not ready."
L["SKADA_ERR_DUPLICATE"]  = "Profile '%s' is already saved."
L["SKADA_PRINT_SAVED"]    = "Skada profile '%s' saved."

-- Binds page 
L["BINDS_TITLE"]          = "|cff4db8ffKeybinds|r  — Profiles"
L["BINDS_BTN_SAVE"]       = "+ Save Keybinds"
L["BINDS_EMPTY"]          = "|cff333340No keybind profiles saved yet.\n\n|r" ..
                            "|cff404050Set up your keybinds, then click  |r|cff4db8ff+ Save Keybinds|r" ..
                            "|cff404050  above.|r"
L["BINDS_META"]           = "|cff353545Keybinds  ·  %s|r"
L["BINDS_POPUP_TITLE"]    = "Keybind Profile Name"
L["BINDS_ERR_DUPLICATE"]  = "Profile '%s' is already saved."
L["BINDS_PRINT_SAVED"]    = "Keybinds '%s' saved."

-- Macros page 
L["MACROS_TITLE"]         = "|cff4db8ffMacros|r  — Profiles"
L["MACROS_BTN_CHAR"]      = "+ Character Macros"
L["MACROS_BTN_ALL"]       = "+ All Macros"
L["MACROS_EMPTY"]         = "|cff333340No macro profiles saved yet.\n\n|r" ..
                            "|cff404050Click  |r|cff4db8ff+ Character Macros|r|cff404050  or  |r" ..
                            "|cff4db8ff+ All Macros|r|cff404050  above.|r"
L["MACROS_META"]          = "|cff353545%d %s  ·  %s|r"
L["MACROS_POPUP_CHAR"]    = "Character Macros — Profile Name"
L["MACROS_POPUP_ALL"]     = "All Macros — Profile Name"
L["MACROS_ERR_DUPLICATE"] = "Profile '%s' is already saved."
L["MACROS_PRINT_SAVED"]      = "Macros '%s' saved (%d)."
L["MACROS_BTN_RESTORE_SEL"] = "Restore (%d)"
L["MACROS_BTN_CLEAR_SEL"]   = "Clear"

-- ActionBars page
L["BARS_TITLE"]          = "|cff4db8ffBars|r  — Profiles"
L["BARS_BTN_SAVE"]       = "+ Save Bar Layout"
L["BARS_EMPTY"]          = "|cff333340No bar layout profiles saved yet.\n\n|r" ..
                           "|cff404050Set up your action bars, then click  |r|cff4db8ff+ Save Bar Layout|r" ..
                           "|cff404050  above.|r"
L["BARS_META"]           = "|cff353545%d %s  ·  %s|r"
L["BARS_POPUP_TITLE"]    = "Bar Layout — Profile Name"
L["BARS_ERR_DUPLICATE"]  = "Profile '%s' is already saved."
L["BARS_PRINT_SAVED"]    = "Bar layout '%s' saved (%d slots)."

-- Importer ─
L["IMP_WA_ERR_NOT_READY"]    = "WeakAuras is not loaded or database not ready."
L["IMP_WA_ERR_NO_DISPLAYS"]  = "Entry has no display data."
L["IMP_WA_ERR_NO_IDS"]       = "No displays were restored (missing id field)."
L["IMP_WA_RESTORED"]         = "'%s' written to DB (%d %s). Reload to activate."
L["IMP_WA_RESTORED_PROMPT"]  = "'%s' restored."
L["IMP_WA_SEL_RESTORED"]     = "%d %s restored (%d %s). Reload to activate."
L["IMP_WA_SEL_PROMPT"]       = "%d WeakAura %s restored."
L["IMP_WA_ALL_RESTORED"]     = "All %d %s restored (%d %s). Reload to activate."
L["IMP_WA_ALL_PROMPT"]       = "All WeakAura backups restored."
L["IMP_WA_NO_BACKUPS"]       = "No WeakAura backups to restore."
L["IMP_ELVUI_ERR_NOT_LOADED"]= "ElvUI is not loaded."
L["IMP_ELVUI_ERR_DB"]        = "ElvUI database not ready."
L["IMP_ELVUI_ERR_NO_DATA"]   = "No data to restore."
L["IMP_ELVUI_RESTORED"]      = "ElvUI profile '%s' restored."
L["IMP_ELVUI_PROMPT"]        = "ElvUI '%s' restored. Reload UI to apply changes."
L["IMP_SKADA_ERR_NOT_LOADED"]= "Skada is not loaded."
L["IMP_SKADA_ERR_NO_DATA"]   = "No data to restore."
L["IMP_SKADA_RESTORED"]      = "Skada profile '%s' restored."
L["IMP_SKADA_PROMPT"]        = "Skada '%s' restored. Reload UI to apply changes."
L["IMP_BINDS_ERR_NO_DATA"]   = "No data to restore."
L["IMP_BINDS_RESTORED"]      = "Keybinds '%s' restored."
L["IMP_MACROS_ERR_NO_DATA"]  = "No data to restore."
L["IMP_MACROS_RESTORED"]     = "Macros '%s' restored."
L["IMP_BARS_ERR_NO_DATA"]    = "No data to restore."
L["IMP_BARS_ERR_COMBAT"]     = "Cannot restore action bars while in combat."
L["IMP_BARS_RESTORED"]       = "Bar layout '%s' restored (%d slots)."

-- Main page ─
L["MAIN_SUBTITLE"]     = "|cff404050Personal UI Backup & Restore Manager  ·  WoW 3.3.5a|r"
L["MAIN_HOW_WA"]       = "|cff4db8ff•|r |cffaaaaaa WeakAuras|r |cff505060— browse & save auras; restore with one click|r"
L["MAIN_HOW_ELVUI"]    = "|cff4db8ff•|r |cffaaaaaa ElvUI|r     |cff505060— snapshot your current profile; restore with one click|r"
L["MAIN_HOW_SKADA"]    = "|cff4db8ff•|r |cffaaaaaa Skada|r     |cff505060— snapshot your layout; restore with one click|r"
L["MAIN_HINT"]         = "|cff2a2a35Use the navigation tabs above to save or restore your profiles.  " ..
                         "Press |r|cff4db8ffESC|r|cff2a2a35 to close.|r"
L["MAIN_BTN_MULTI"]    = "Multi-Account"
-- Summary card labels
L["MAIN_SUM_WA"]       = "WeakAuras"
L["MAIN_SUM_ELVUI"]    = "ElvUI"
L["MAIN_SUM_SKADA"]    = "Skada"
L["MAIN_SUM_KEYBINDS"] = "Keybinds"
L["MAIN_SUM_MACROS"]   = "Macros"
L["MAIN_SUM_BARS"]     = "Bars"
-- Sync dialog
L["SYNC_TITLE"]     = "|cff4db8ffMulti-Account|r  —  Data Sync"
L["SYNC_HOW_TITLE"] = "|cff4db8ffHow it works|r"
L["SYNC_HOW_TEXT"]  = "SyncAuraHub.bat copies only the AuraHub.lua file\n" ..
                      "from one account to all others.\n" ..
                      "No other addons are affected."
L["SYNC_S1_TITLE"]  = "|cffe0e060Step 1|r  — Save your data in-game"
L["SYNC_S1_TEXT"]   = "Log into the account with your WeakAuras / profiles.\n" ..
                      "Make sure everything is saved in AuraHub."
L["SYNC_S2_TITLE"]  = "|cffe0e060Step 2|r  — Exit the game"
L["SYNC_S2_TEXT"]   = "Fully close WoW (not just character select).\n" ..
                      "WoW writes SavedVariables only on full exit."
L["SYNC_S3_TITLE"]  = "|cffe0e060Step 3|r  — Run the sync script"
L["SYNC_S3_TEXT"]   = "Find this file in your WoW folder and double-click it:"
L["SYNC_S3_TEXT2"]  = "The script will detect all accounts and ask you\n" ..
                      "which one is the source (to copy from)."
L["SYNC_S3_BOX"]    = "SyncAuraHub.bat"
L["SYNC_S4_TITLE"]  = "|cffe0e060Step 4|r  — Log into any account"
L["SYNC_S4_TEXT"]   = "All your WeakAuras, ElvUI and Skada backups\n" ..
                      "are now available on every account."
L["SYNC_REPEAT"]    = "|cff404050Repeat steps 1–3 each time you switch accounts.|r"
L["SYNC_GOT_IT"]    = "Got it"

-- Nav labels
L["NAV_HOME"]      = "Home"
L["NAV_WEAKAURAS"] = "WeakAuras"
L["NAV_ELVUI"]     = "ElvUI"
L["NAV_SKADA"]     = "Skada"
L["NAV_BINDS"]     = "Keybinds"
L["NAV_MACROS"]    = "Macros"
L["NAV_BARS"]      = "Bars"
L["NAV_HELP"]      = "Help"

-- Button widths (numeric; overridden in ru.lua for longer words)
L["ELVUI_BTN_W"]    = 170
L["SKADA_BTN_W"]    = 170
L["WA_SAVE_BTN_W"]  = 148
L["WA_CLEAR_BTN_W"] = 90

-- Help page ─
L["HELP_BUG_REPORT"]         = "If something isn't working correctly (for example, a profile won't load or import), please describe in detail what you were doing when the issue occurred and what exactly happened. For all questions and bug reports, contact us on Discord."
L["HELP_TITLE"]              = "|cff4db8ffAuraHub|r  — Help & About"
L["HELP_FEAT_TITLE"]         = "|cff4db8ffFeatures|r"
L["HELP_FEAT_WA"]            = "WeakAuras"
L["HELP_FEAT_WA_DESC"]       = "Save named backups of your WeakAuras. On the WeakAuras page you can click " ..
                               "individual aura cards to select them (highlighted in blue), then use " ..
                               "Restore Selected to load only the ones you need — useful when switching specs."
L["HELP_FEAT_ELVUI"]         = "ElvUI"
L["HELP_FEAT_ELVUI_DESC"]    = "Snapshot your entire ElvUI profile. The profile name is pulled automatically " ..
                               "from ElvUI. Delete the old entry first if you want to re-save after changes."
L["HELP_FEAT_SKADA"]         = "Skada"
L["HELP_FEAT_SKADA_DESC"]    = "Save your Skada window layout and damage meter settings. Profile name is " ..
                               "pulled automatically."
L["HELP_FEAT_KEYBINDS"]      = "Keybinds"
L["HELP_FEAT_KEYBINDS_DESC"] = "Save your current keybind layout under a custom name (e.g. Tank, Healer, DPS). " ..
                               "Restore applies all bindings and saves them to the current binding set immediately."
L["HELP_FEAT_MACROS"]        = "Macros"
L["HELP_FEAT_MACROS_DESC"]   = "Save character macros or all macros (account + character). Restore recreates " ..
                               "missing macros and updates existing ones by name."
L["HELP_FEAT_BARS"]          = "Bars"
L["HELP_FEAT_BARS_DESC"]     = "Save your current action bar layout (bars 1–6, slots 1–72). Restore places " ..
                               "spells and macros back by ID/name. Items are best-effort (must be in bags). " ..
                               "Cannot restore during combat."
L["HELP_FEAT_MULTI"]         = "Multi-Account"
L["HELP_FEAT_MULTI_DESC"]    = "Run SyncAuraHub.bat (in your WoW folder) to copy AuraHub data between all " ..
                               "your game accounts in one step."
L["HELP_QUEUE_TITLE"]        = "|cff4db8ffLoad Queue — Apply Everything at Once|r"
L["HELP_QUEUE_DESC"]         = "Instead of restoring each profile one by one (and reloading each time), " ..
                               "you can stage multiple items into the Load Queue and apply them all with a single reload.\n\n" ..
                               "|cffe0e060How to use:|r\n" ..
                               "1. Go to WeakAuras, ElvUI or Skada pages.\n" ..
                               "2. Click the |cff3a78cc+Q|r button on each backup card you want to load.\n" ..
                               "3. A blue bar appears at the bottom showing what's queued.\n" ..
                               "4. Click |cff2a7a2aApply & Reload|r — all profiles are restored and the UI reloads once."
