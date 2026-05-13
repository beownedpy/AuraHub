-- AuraHub — Core.lua
-- Initialization, events, slash command.
-- Slash: /aurahub

AuraHub = AuraHub or {}

AuraHub.VERSION = "2.0.0"
AuraHub.AUTHOR  = "beowned"
AuraHub.TITLE   = "AuraHub"

AuraHub.Pages = AuraHub.Pages or {}

AuraHub.Core = {}

-- Static popups (defined once, used across all modules)

local _L = AuraHub.L

StaticPopupDialogs["AURAHUB_RELOAD"] = {
    text          = _L["RELOAD_BODY"],
    button1       = _L["RELOAD_NOW"],
    button2       = _L["RELOAD_LATER"],
    OnAccept      = function() ReloadUI() end,
    timeout       = 0,
    whileDead     = true,
    hideOnEscape  = true,
    preferredIndex = 3,
}

StaticPopupDialogs["AURAHUB_SAVE_NAME"] = {
    text          = _L["SAVE_NAME_BODY"],
    hasEditBox    = true,
    editBoxWidth  = 230,
    button1       = _L["BTN_SAVE"],
    button2       = _L["BTN_CANCEL"],
    OnShow        = function(self)
        self.editBox:SetText(date(_L["SAVE_NAME_DEFAULT"]))
        self.editBox:HighlightText()
        self.editBox:SetFocus()
    end,
    OnAccept      = function(self)
        local name = AuraHub.Helpers.Trim(self.editBox:GetText())
        if name == "" then name = date(_L["SAVE_NAME_DEFAULT"]) end
        if AuraHub.Core._savePending then
            AuraHub.Core._savePending(name)
            AuraHub.Core._savePending = nil
        end
    end,
    OnCancel      = function()
        AuraHub.Core._savePending = nil
    end,
    timeout       = 0,
    whileDead     = true,
    hideOnEscape  = true,
    preferredIndex = 3,
}

StaticPopupDialogs["AURAHUB_DELETE_CONFIRM"] = {
    text          = _L["DELETE_BODY"],
    button1       = _L["BTN_DELETE_CONFIRM"],
    button2       = _L["BTN_CANCEL"],
    OnAccept      = function()
        if AuraHub.Core._deletePending then
            AuraHub.Core._deletePending()
            AuraHub.Core._deletePending = nil
        end
    end,
    OnCancel      = function()
        AuraHub.Core._deletePending = nil
    end,
    timeout       = 0,
    whileDead     = true,
    hideOnEscape  = true,
    preferredIndex = 3,
}

StaticPopupDialogs["AURAHUB_RESTORE_CONFIRM"] = {
    text          = _L["RESTORE_MACROS_BODY"],
    button1       = _L["BTN_RESTORE_CONFIRM"],
    button2       = _L["BTN_CANCEL"],
    OnAccept      = function()
        if AuraHub.Core._restorePending then
            AuraHub.Core._restorePending()
            AuraHub.Core._restorePending = nil
        end
    end,
    OnCancel      = function()
        AuraHub.Core._restorePending = nil
    end,
    timeout       = 0,
    whileDead     = true,
    hideOnEscape  = true,
    preferredIndex = 3,
}

-- Shared callback slots
AuraHub.Core._savePending    = nil
AuraHub.Core._deletePending  = nil
AuraHub.Core._restorePending = nil

-- Loader
-- Data is initialised on ADDON_LOADED (SavedVariables are ready).
-- UI is built on PLAYER_LOGIN so ElvUI has finished its own init
-- and E.media.normFont is available for the font override.

local _loader = CreateFrame("Frame")
_loader:RegisterEvent("ADDON_LOADED")
_loader:RegisterEvent("PLAYER_LOGIN")
_loader:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == "AuraHub" then
        AuraHub.Data.Init()
        self:UnregisterEvent("ADDON_LOADED")
    elseif event == "PLAYER_LOGIN" then
        AuraHub.Core.Init()
        self:UnregisterEvent("PLAYER_LOGIN")
    end
end)

-- Init

function AuraHub.Core.Init()
    -- AuraHub.Data.Init() already called on ADDON_LOADED
    if AuraHubDB.minimapAngle and AuraHub.Minimap then
        AuraHub.Minimap.SetAngle(AuraHubDB.minimapAngle)
    end
    if ElvUI then
        local E = unpack(ElvUI)
        if E and E.media and E.media.normFont then
            AuraHub.UI.FONT = E.media.normFont
        end
    end
    AuraHub.UI.Build()

    SLASH_AURAHUB1 = "/aurahub"
    SlashCmdList["AURAHUB"] = function(msg)
        msg = msg and msg:match("^%s*(.-)%s*$") or ""
        if msg == "debug" then
            AuraHub.WA.DebugDB()
        elseif msg == "iotest" then
            AuraHub.Data.IOTest()
        elseif msg == "sync" or msg:sub(1, 5) == "sync " then
            AuraHub.Data.SyncCmd(msg:sub(6))
        elseif msg:sub(1, 9) == "pathtest " or msg == "pathtest" then
            AuraHub.Data.PathTest(msg:sub(10))
        elseif msg == "bartest" then
            local H = AuraHub.Helpers
            H.Print("=== bartest ===", "aaaaaa")
            H.Print("GetSpellBookItemInfo: " .. type(GetSpellBookItemInfo), "cccccc")
            H.Print("PickupSpellBookItem: "  .. type(PickupSpellBookItem),  "cccccc")
            H.Print("PickupSpell: "          .. type(PickupSpell),          "cccccc")
            H.Print("GetNumSpellTabs: "      .. type(GetNumSpellTabs),      "cccccc")
            -- Dump first 5 occupied action bar slots
            H.Print("--- slots 1-72 (first 5 occupied) ---", "aaaaaa")
            local found = 0
            for slot = 1, 72 do
                local aType, aId, aSubType = GetActionInfo(slot)
                if aType then
                    H.Print(string.format("slot %d: type=%s id=%s sub=%s", slot, tostring(aType), tostring(aId), tostring(aSubType)), "cccccc")
                    found = found + 1
                    if found >= 5 then break end
                end
            end
            -- Try spellbook lookup for first spell slot
            H.Print("--- spellbook tab 1 ---", "aaaaaa")
            if GetNumSpellTabs and GetSpellTabInfo and GetSpellBookItemInfo then
                local numTabs = GetNumSpellTabs()
                H.Print("tabs: " .. tostring(numTabs), "cccccc")
                if numTabs and numTabs >= 1 then
                    local tName, tTex, offset, numSpells = GetSpellTabInfo(1)
                    H.Print(string.format("tab1: name=%s offset=%s count=%s", tostring(tName), tostring(offset), tostring(numSpells)), "cccccc")
                    for i = 1, math.min(numSpells or 0, 3) do
                        local bookSlot = offset + i
                        local bType, bId = GetSpellBookItemInfo(bookSlot, "spell")
                        local sName = GetSpellInfo and GetSpellInfo(bId or 0) or "?"
                        H.Print(string.format("  bookSlot %d: bType=%s bId=%s name=%s", bookSlot, tostring(bType), tostring(bId), tostring(sName)), "cccccc")
                    end
                end
            else
                H.Print("spellbook API missing", "ff4444")
            end
            -- Test PickupSpell with actual IDs from the first spell slot
            H.Print("--- pickup test ---", "aaaaaa")
            local firstSpellId = nil
            local firstSpellSlot = nil
            for slot = 1, 72 do
                local aType, aId = GetActionInfo(slot)
                if aType == "spell" then firstSpellId = aId; firstSpellSlot = slot; break end
            end
            if firstSpellId then
                H.Print("testing spellbook id=" .. firstSpellId .. " (from action slot " .. firstSpellSlot .. ")", "cccccc")
                -- Test A: PickupSpell(id, "spell")
                pcall(ClearCursor)
                pcall(PickupSpell, firstSpellId, "spell")
                local cType, cId = GetCursorInfo()
                H.Print("PickupSpell(id,'spell'): cursor=" .. tostring(cType) .. " / " .. tostring(cId), cType and "44ff44" or "ff4444")
                pcall(ClearCursor)
                -- Test B: PickupSpell(id) no book arg
                pcall(PickupSpell, firstSpellId)
                local cType2, cId2 = GetCursorInfo()
                H.Print("PickupSpell(id): cursor=" .. tostring(cType2) .. " / " .. tostring(cId2), cType2 and "44ff44" or "ff4444")
                pcall(ClearCursor)
                -- Test C: GetSpellInfo with "spell" booktype
                if GetSpellInfo then
                    local n, r = GetSpellInfo(firstSpellId, "spell")
                    H.Print("GetSpellInfo(id,'spell'): name=" .. tostring(n) .. " rank=" .. tostring(r), n and "44ff44" or "ff4444")
                    -- Test D: PickupSpell by name
                    if n and n ~= "" then
                        pcall(PickupSpell, n)
                        local cType3, cId3 = GetCursorInfo()
                        H.Print("PickupSpell(name): cursor=" .. tostring(cType3) .. " / " .. tostring(cId3), cType3 and "44ff44" or "ff4444")
                        pcall(ClearCursor)
                    end
                end
            else
                H.Print("no spell slots found in bars 1-72", "ff4444")
            end
        elseif msg == "reset" then
            AuraHubDB = { WeakAuras = {}, ElvUI = {}, Skada = {} }
            AuraHub.Helpers.Print(AuraHub.L["RESET_MSG"], "ff8844")
            ReloadUI()
        else
            AuraHub.UI.Toggle()
        end
    end

    AuraHub.Helpers.Print(
        AuraHub.L["ADDON_LOADED_MSG"]:format(AuraHub.VERSION), "555555"
    )
end
