-- AuraHub — Importer.lua
-- Restores saved profiles directly into their target addons.

AuraHub.Importer = {}

local I  = AuraHub.Importer
local DC = function(t) return AuraHub.Helpers.DeepCopy(t) end

-- Reload prompt

function I.Prompt(msg)
    StaticPopup_Show("AURAHUB_RELOAD", msg or "Done.")
end

-- WeakAuras — restore all displays in an entry (root + children)

local function WriteEntryToDB(entry, db)
    local displays = entry and entry.displays
    if type(displays) ~= "table" then return 0 end
    local n = 0
    for _, displayData in ipairs(displays) do
        local copy = DC(displayData)
        if copy.id then
            db[copy.id] = copy
            n = n + 1
            pcall(function()
                if WeakAuras.Add          then WeakAuras.Add(copy)                   end
                if WeakAuras.ScanEvents   then WeakAuras.ScanEvents(copy.id)         end
                if WeakAuras.UpdatedFrame then WeakAuras.UpdatedFrame(copy.id, copy) end
            end)
        end
    end
    return n
end

function I.RestoreWA(entry, silent)
    local L = AuraHub.L
    local H = AuraHub.Helpers
    if not AuraHub.WA.IsReady() then
        H.Err(L["IMP_WA_ERR_NOT_READY"])
        return
    end

    if type(entry and entry.displays) ~= "table" or #entry.displays == 0 then
        H.Err(L["IMP_WA_ERR_NO_DISPLAYS"])
        return
    end

    local n = WriteEntryToDB(entry, AuraHub.WA.GetDisplaysTable())
    if n == 0 then
        H.Err(L["IMP_WA_ERR_NO_IDS"])
        return
    end

    H.Print(L["IMP_WA_RESTORED"]:format(
        entry.name or "?", n,
        H.Plural(n, L["WORD_DISPLAY"], L["WORD_DISPLAY_FEW"], L["WORD_DISPLAYS"])
    ))
    if not silent then I.Prompt(L["IMP_WA_RESTORED_PROMPT"]:format(entry.name or "?")) end
end

function I.RestoreSelectedWAs(entries)
    local L = AuraHub.L
    local H = AuraHub.Helpers
    if not AuraHub.WA.IsReady() then
        H.Err(L["IMP_WA_ERR_NOT_READY"])
        return
    end
    if not entries or #entries == 0 then return end

    local db    = AuraHub.WA.GetDisplaysTable()
    local total = 0
    for _, entry in ipairs(entries) do
        total = total + WriteEntryToDB(entry, db)
    end

    if total == 0 then
        H.Err(L["IMP_WA_ERR_NO_IDS"])
        return
    end

    H.Print(L["IMP_WA_SEL_RESTORED"]:format(
        #entries, H.Plural(#entries, L["WORD_BACKUP"], L["WORD_BACKUP_FEW"], L["WORD_BACKUPS"]),
        total,    H.Plural(total,    L["WORD_DISPLAY"], L["WORD_DISPLAY_FEW"], L["WORD_DISPLAYS"])
    ))
    I.Prompt(L["IMP_WA_SEL_PROMPT"]:format(
        #entries, H.Plural(#entries, L["WORD_BACKUP"], L["WORD_BACKUP_FEW"], L["WORD_BACKUPS"])
    ))
end

function I.RestoreAllWAs()
    local L = AuraHub.L
    local H = AuraHub.Helpers
    if not AuraHub.WA.IsReady() then
        H.Err(L["IMP_WA_ERR_NOT_READY"])
        return
    end

    local entries = AuraHub.Data.GetWAs()
    if #entries == 0 then
        H.Err(L["IMP_WA_NO_BACKUPS"])
        return
    end

    local db    = AuraHub.WA.GetDisplaysTable()
    local total = 0
    for _, entry in ipairs(entries) do
        total = total + WriteEntryToDB(entry, db)
    end

    if total == 0 then
        H.Err(L["IMP_WA_ERR_NO_IDS"])
        return
    end

    H.Print(L["IMP_WA_ALL_RESTORED"]:format(
        #entries, H.Plural(#entries, L["WORD_BACKUP"], L["WORD_BACKUP_FEW"], L["WORD_BACKUPS"]),
        total,    H.Plural(total,    L["WORD_DISPLAY"], L["WORD_DISPLAY_FEW"], L["WORD_DISPLAYS"])
    ))
    I.Prompt(L["IMP_WA_ALL_PROMPT"])
end

-- ElvUI — merge saved profile data into the active ElvUI profile

function I.RestoreElvUI(entry, silent)
    local L = AuraHub.L
    local H = AuraHub.Helpers
    if not ElvUI then
        H.Err(L["IMP_ELVUI_ERR_NOT_LOADED"])
        return
    end

    local E = unpack(ElvUI)
    if not E or not E.db then
        H.Err(L["IMP_ELVUI_ERR_DB"])
        return
    end

    if type(entry.data) ~= "table" then
        H.Err(L["IMP_ELVUI_ERR_NO_DATA"])
        return
    end

    for k, v in pairs(DC(entry.data)) do
        E.db[k] = v
    end

    if E.UpdateAll   then E:UpdateAll()   end
    if E.UpdateMedia then E:UpdateMedia() end

    H.Print(L["IMP_ELVUI_RESTORED"]:format(entry.name or "?"))
    if not silent then I.Prompt(L["IMP_ELVUI_PROMPT"]:format(entry.name or "?")) end
end

-- Skada — merge saved profile data into the active Skada profile

function I.RestoreSkada(entry, silent)
    local L = AuraHub.L
    local H = AuraHub.Helpers
    if not Skada or not Skada.db then
        H.Err(L["IMP_SKADA_ERR_NOT_LOADED"])
        return
    end

    if type(entry.data) ~= "table" then
        H.Err(L["IMP_SKADA_ERR_NO_DATA"])
        return
    end

    for k, v in pairs(DC(entry.data)) do
        Skada.db.profile[k] = v
    end

    if Skada.Reset         then Skada:Reset()         end
    if Skada.ApplySettings then Skada:ApplySettings() end

    H.Print(L["IMP_SKADA_RESTORED"]:format(entry.name or "?"))
    if not silent then I.Prompt(L["IMP_SKADA_PROMPT"]:format(entry.name or "?")) end
end

-- DBM — restore saved profile globals

function I.RestoreDBM(entry, silent)
    local L = AuraHub.L
    local H = AuraHub.Helpers
    if not DBM then
        H.Err(L["IMP_DBM_ERR_NOT_LOADED"])
        return
    end

    local hasLiveVars = type(entry.liveVars) == "table" and next(entry.liveVars)
    local hasLegacy   = type(entry.data)     == "table" and next(entry.data)

    if not hasLiveVars and not hasLegacy then
        H.Err(L["IMP_DBM_ERR_NO_DATA"])
        return
    end

    local currentProfile = DBM_UsedProfile

    -- Force-load all LoadOnDemand DBM boss modules so WoW will persist
    -- their SavedVariables (DBMIcecrown_AllSavedVars etc.) on ReloadUI.
    if AuraHub.Pages and AuraHub.Pages.DBM and AuraHub.Pages.DBM.LoadAllDBMModules then
        AuraHub.Pages.DBM.LoadAllDBMModules()
    end

    -- 1. Apply live vars
    if hasLiveVars then
        for varName, varData in pairs(entry.liveVars) do
            _G[varName] = type(varData) == "table" and DC(varData) or varData
        end
    end

    -- 2. Legacy format (entry.data)
    if hasLegacy and not hasLiveVars then
        for varName, varData in pairs(entry.data) do
            _G[varName] = type(varData) == "table" and DC(varData) or varData
        end
    end

    -- After applying all vars, read srcProfile from _G.
    local srcProfile = _G["DBM_UsedProfile"]
                    or (hasLiveVars and entry.liveVars and entry.liveVars.DBM_UsedProfile)
                    or (hasLegacy   and entry.data     and entry.data.DBM_UsedProfile)
                    or "Default"
    if currentProfile and currentProfile ~= srcProfile and DBM_AllSavedOptions then
        local srcData = DBM_AllSavedOptions[srcProfile]
        if srcData then
            DBM_AllSavedOptions[currentProfile] = DC(srcData)
            _G["DBM_UsedProfile"] = currentProfile
        end
    end

    -- Apply the active profile immediately
    local applyProfile = _G["DBM_UsedProfile"] or srcProfile
    if applyProfile and DBM_AllSavedOptions and DBM_AllSavedOptions[applyProfile] then
        if DBM.ApplyProfile then
            pcall(function() DBM:ApplyProfile(applyProfile) end)
        end
    end

    if DBT and DBT.ApplyProfile then
        pcall(function() DBT:ApplyProfile("DBM") end)
    end

    H.Print(L["IMP_DBM_RESTORED"]:format(entry.name or "?"))
    if not silent then I.Prompt(L["IMP_DBM_PROMPT"]:format(entry.name or "?")) end
end

-- Binds — restore saved keybindings
-- Clears existing bindings for each action before applying saved ones so that
-- the first action bar (and all others) transfers cleanly to new characters.

function I.RestoreBinds(entry)
    local L = AuraHub.L
    local H = AuraHub.Helpers
    if type(entry.data) ~= "table" then
        H.Err(L["IMP_BINDS_ERR_NO_DATA"])
        return
    end

    -- Collect keys currently bound to actions we are about to restore
    local toUnbind = {}
    for _, b in ipairs(entry.data) do
        if b.action then
            for i = 1, GetNumBindings() do
                local act, k1, k2 = GetBinding(i)
                if act == b.action then
                    if k1 and k1 ~= "" then toUnbind[k1] = true end
                    if k2 and k2 ~= "" then toUnbind[k2] = true end
                    break
                end
            end
        end
    end

    -- Unbind them first so no ghost bindings survive
    for key in pairs(toUnbind) do
        SetBinding(key)
    end

    -- Apply saved bindings
    for _, b in ipairs(entry.data) do
        if b.action then
            if b.key1 and b.key1 ~= "" then SetBinding(b.key1, b.action) end
            if b.key2 and b.key2 ~= "" then SetBinding(b.key2, b.action) end
        end
    end
    SaveBindings(GetCurrentBindingSet())

    H.Print(L["IMP_BINDS_RESTORED"]:format(entry.name or "?"))
end

-- Macros — restore saved macros

function I.RestoreMacros(entry)
    local L = AuraHub.L
    local H = AuraHub.Helpers
    if type(entry.data) ~= "table" then
        H.Err(L["IMP_MACROS_ERR_NO_DATA"])
        return
    end

    -- Determine which scopes the backup contains
    local hasAccount, hasChar = false, false
    for _, m in ipairs(entry.data) do
        if m.scope == "account" then hasAccount = true end
        if m.scope == "char"    then hasChar    = true end
    end

    -- Delete existing macros of matching scopes (high→low to avoid index shift)
    local numAccount, numChar = GetNumMacros()
    if hasChar then
        for slot = 36 + numChar, 37, -1 do
            if GetMacroInfo(slot) then DeleteMacro(slot) end
        end
    end
    if hasAccount then
        for slot = numAccount, 1, -1 do
            if GetMacroInfo(slot) then DeleteMacro(slot) end
        end
    end

    -- Build texture→index lookup from the macro icon picker list (built once per restore)
    local _iconCache = {}
    if GetNumMacroIcons then
        for i = 1, GetNumMacroIcons() do
            local t = GetMacroIconInfo(i)
            if t then
                local key = tostring(t):lower():match("([^\\]+)$"):gsub("%.blp$", "")
                if key and key ~= "" then _iconCache[key] = i end
            end
        end
    end

    local function ResolveIcon(raw)
        local n = tonumber(raw)
        if n then return n end
        local key = tostring(raw):lower():match("([^\\]+)$"):gsub("%.blp$", "")
        return _iconCache[key] or 1
    end

    -- Create macros from backup
    for _, m in ipairs(entry.data) do
        if m.name and m.body then
            local isChar = (m.scope == "char") and 1 or nil
            CreateMacro(m.name, ResolveIcon(m.icon), m.body, isChar)
        end
    end

    H.Print(L["IMP_MACROS_RESTORED"]:format(entry.name or "?"))
end

-- ActionBars — restore saved action bar slot layout

local function _ApplyActionBars(entry)
    local L = AuraHub.L
    local H = AuraHub.Helpers

    local restored = 0
    local skipped  = 0
    H.Print("Restore '" .. (entry.name or "?") .. "': " .. #entry.data .. " slots", "aaaaaa")
    for _, s in ipairs(entry.data) do
        pcall(ClearCursor)
        pcall(function()
            if s.type == "spell" then
                -- Primary: by name — only picks up if this character knows the spell.
                -- Naturally handles cross-spec/cross-class restores: unknown spells
                -- leave cursor empty and the slot gets skipped below.
                if s.name and s.name ~= "" then
                    if s.rank and s.rank ~= "" then pcall(PickupSpell, s.name, s.rank) end
                    if not GetCursorInfo()       then pcall(PickupSpell, s.name)        end
                end
                -- Fallback: by spellbook slot (same character, same session)
                if not GetCursorInfo() then
                    pcall(PickupSpell, s.id, "spell")
                    -- Verify it's actually the right spell, not a different one at that slot
                    if GetCursorInfo() and s.name and s.name ~= "" and GetSpellInfo then
                        local foundName = GetSpellInfo(s.id, "spell")
                        if foundName ~= s.name then pcall(ClearCursor) end
                    end
                end
            elseif s.type == "item" then
                if PickupItem then pcall(PickupItem, s.id) end
            elseif s.type == "macro" then
                local numA, numC = GetNumMacros()
                local placed = false
                local function searchRange(from, to)
                    local nameFallback = nil
                    for mi = from, to do
                        local mName, _, mBody = GetMacroInfo(mi)
                        if mName == s.name then
                            if s.body and s.body ~= "" and mBody == s.body then
                                PickupMacro(mi); placed = true; return
                            elseif not nameFallback then
                                nameFallback = mi
                            end
                        end
                    end
                    if nameFallback then
                        PickupMacro(nameFallback); placed = true
                    end
                end
                if (s.id or 0) <= 36 then
                    searchRange(1, numA)
                    if not placed then searchRange(37, 36 + numC) end
                else
                    searchRange(37, 36 + numC)
                    if not placed then searchRange(1, numA) end
                end
                if not placed then pcall(PickupMacro, s.id) end
            end
            local cType = GetCursorInfo()
            if cType then
                PlaceAction(s.slot)
                restored = restored + 1
            else
                skipped = skipped + 1
            end
        end)
    end
    pcall(ClearCursor)
    H.Print(L["IMP_BARS_RESTORED"]:format(entry.name or "?", restored))
end

function I.RestoreActionBars(entry)
    local L = AuraHub.L
    local H = AuraHub.Helpers
    if type(entry.data) ~= "table" then
        H.Err(L["IMP_BARS_ERR_NO_DATA"])
        return
    end
    if InCombatLockdown() then
        H.Err(L["IMP_BARS_ERR_COMBAT"])
        return
    end
    _ApplyActionBars(entry)
end
