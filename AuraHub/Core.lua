-- AuraHub — Core.lua
-- Initialization, events, slash command.
-- Slash: /aurahub

AuraHub = AuraHub or {}

AuraHub.VERSION = "1.2.0"
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
