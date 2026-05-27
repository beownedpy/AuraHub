-- AuraHub — Pages\DBM.lua
-- Save and restore Deadly Boss Mods profile snapshots.

AuraHub.Pages = AuraHub.Pages or {}
AuraHub.Pages.DBM = {}

local P  = AuraHub.Pages.DBM
local L  = AuraHub.L
local H  = AuraHub.Helpers

local _cards  = {}
local _sf, _sc
local _emptyMsg

local CARD_H  = 52
local CARD_GAP = 4
local PAD_Y   = 8

function P.Refresh()
    for _, c in ipairs(_cards) do c:Hide() end
    _cards = {}

    local UI      = AuraHub.UI
    local C       = UI.C
    local entries = AuraHub.Data.GetDBMs()

    if _emptyMsg then
        if #entries == 0 then _emptyMsg:Show() else _emptyMsg:Hide() end
    end

    if #entries == 0 then
        _sc:SetHeight(UI.CONTENT_H - 52)
        return
    end

    local totalH = PAD_Y + #entries * (CARD_H + CARD_GAP)
    _sc:SetHeight(math.max(totalH, AuraHub.UI.CONTENT_H - 52))

    local prevCard = nil
    for i, entry in ipairs(entries) do
        local card = CreateFrame("Frame", nil, _sc)
        if prevCard then
            card:SetPoint("TOPLEFT", prevCard, "BOTTOMLEFT", 0, -CARD_GAP)
        else
            card:SetPoint("TOPLEFT", _sc, "TOPLEFT", 14, -PAD_Y)
        end
        card:SetWidth(AuraHub.UI.CONTENT_W - 28)
        card:SetHeight(CARD_H)
        local bgCol = (i % 2 == 0) and C.card or C.cardAlt
        UI.AB(card, bgCol, C.border)
        card:EnableMouse(true)

        local nameFs = card:CreateFontString(nil, "OVERLAY")
        nameFs:SetPoint("TOPLEFT",  card, "TOPLEFT",  10, -9)
        nameFs:SetPoint("TOPRIGHT", card, "TOPRIGHT", -174, -9)
        UI.SetFont(nameFs, 16)
        nameFs:SetText(entry.name or "Unnamed")
        nameFs:SetTextColor(C.text[1], C.text[2], C.text[3])
        nameFs:SetJustifyH("LEFT")

        local metaFs = card:CreateFontString(nil, "OVERLAY")
        metaFs:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 10, 9)
        UI.SetFont(metaFs, 13)
        metaFs:SetText(L["DBM_META"]:format(H.TimeAgo(entry.savedAt)))

        local restoreBtn = UI.CreateMenuButton(card, L["BTN_RESTORE"], 88, 28, function()
            AuraHub.Importer.RestoreDBM(entry)
        end)
        restoreBtn:SetPoint("RIGHT", card, "RIGHT", -80, 0)

        local queueBtn = UI.CreateQueueButton(card, function()
            AuraHub.Queue.Add("DBM", entry, entry.name or "DBM")
        end)
        queueBtn:SetPoint("RIGHT", card, "RIGHT", -42, 0)

        local delBtn = UI.CreateDeleteButton(card, L["BTN_DELETE"], 28, 28, function()
            AuraHub.Core._deletePending = function()
                AuraHub.Data.DeleteDBM(i)
                P.Refresh()
            end
            StaticPopup_Show("AURAHUB_DELETE_CONFIRM", entry.name or "this entry")
        end)
        delBtn:SetPoint("RIGHT", card, "RIGHT", -8, 0)

        card:SetScript("OnEnter", function(self)
            self:SetBackdropColor(C.cardHover[1], C.cardHover[2], C.cardHover[3])
            self:SetBackdropBorderColor(C.accent[1], C.accent[2], C.accent[3], 0.5)
            nameFs:SetTextColor(C.textBright[1], C.textBright[2], C.textBright[3])
        end)
        card:SetScript("OnLeave", function(self)
            self:SetBackdropColor(bgCol[1], bgCol[2], bgCol[3])
            self:SetBackdropBorderColor(C.border[1], C.border[2], C.border[3], C.border[4] or 1)
            nameFs:SetTextColor(C.text[1], C.text[2], C.text[3])
        end)

        card:Show()
        _cards[#_cards + 1] = card
        prevCard = card
    end

    _sf:SetVerticalScroll(0)
    if _sf._sb then _sf._sb:SetValue(0) end
end

-- Addon names (LoadOnDemand: 1, need explicit loading).
-- DBM-Battlegrounds and DBM-PvP are excluded: DBM-Core pre-loads them via its
-- own X-DBM-Mod-LoadZone mechanism, so calling LoadAddOn on them causes
-- "duplicate mod" errors. Their SavedVars are captured via KNOWN_VARS anyway.
local DBM_ADDONS = {
    "DBM-Icecrown", "DBM-Coliseum", "DBM-Ulduar", "DBM-Naxx",
    "DBM-VoA", "DBM-EyeOfEternity", "DBM-ChamberOfAspects",
    "DBM-Onyxia", "DBM-Hyjal", "DBM-Sunwell", "DBM-TheEye",
    "DBM-WorldEvents", "DBM-Party-WotLK",
}

-- Force-load all LoadOnDemand DBM modules so their SavedVariables are in _G.
-- Suppresses errors during loading: DBM-Core on WoW Circle pre-loads some
-- modules via its own mechanism (X-DBM-Mod-LoadZone) without setting the
-- IsAddOnLoaded flag, so a second LoadAddOn call produces "duplicate mod"
-- errors. seterrorhandler silences those while we force-load remaining ones.
local _modulesLoaded = false
function P.LoadAllDBMModules()
    if _modulesLoaded then return end
    _modulesLoaded = true
    local prev = geterrorhandler()
    seterrorhandler(function() end)
    for _, name in ipairs(DBM_ADDONS) do
        if not IsAddOnLoaded(name) then
            pcall(LoadAddOn, name)
        end
    end
    seterrorhandler(prev)
end
local LoadAllDBMModules = P.LoadAllDBMModules

local function SaveCurrentProfile()
    if not DBM then
        H.Err(L["DBM_ERR_NOT_LOADED"])
        return
    end

    local profileName = DBM_UsedProfile or UnitName("player") or "Default"

    for _, entry in ipairs(AuraHub.Data.GetDBMs()) do
        if entry.name == profileName then
            H.Err(L["DBM_ERR_DUPLICATE"]:format(profileName))
            return
        end
    end

    -- Force-load all LoadOnDemand DBM boss modules so their SavedVariables
    -- (DBMIcecrown_AllSavedVars etc.) are populated in _G before we scan.
    LoadAllDBMModules()

    -- Capture specific known DBM SavedVariables from _G.
    -- After LoadAllDBMModules(), all module vars are populated and ready.
    local KNOWN_VARS = {
        "DBM_AllSavedOptions", "DBM_UsedProfile", "DBM_UseDualProfile",
        "DBT_AllPersistentOptions", "DBT_PersistentOptions",
        "DBM_SpellTimers_Settings", "DBM_AutoInvite_Settings",
        "DBM_RaidLead_Settings", "DBM_BidBot_Settings", "DBM_DKP_System_Settings",
        "DBM_Standby_Settings", "DBM_MinimapIcon",
        -- Boss module vars (populated after LoadAllDBMModules)
        "DBMIcecrown_AllSavedVars",  "DBMNaxx_AllSavedVars",
        "DBMUlduar_AllSavedVars",    "DBMColiseum_AllSavedVars",
        "DBMVoA_AllSavedVars",       "DBMOnyxia_AllSavedVars",
        "DBMEyeOfEternity_AllSavedVars", "DBMChamberOfAspects_AllSavedVars",
        "DBMHyjal_AllSavedVars",     "DBMSunwell_AllSavedVars",
        "DBMTheEye_AllSavedVars",    "DBMBattlegrounds_AllSavedVars",
        "DBMPartyWotLK_AllSavedVars","DBMPvP_AllSavedVars",
        "DBMWorldEvents_AllSavedVars","DBMInterrupts_AllSavedVars",
        "DBMBurningCrusade_SavedModOptions",
    }
    local liveVars = {}
    for _, varName in ipairs(KNOWN_VARS) do
        local v = _G[varName]
        if v ~= nil then
            liveVars[varName] = type(v) == "table" and H.DeepCopy(v) or v
        end
    end

    if not next(liveVars) then
        H.Err(L["DBM_ERR_NO_DATA"])
        return
    end

    AuraHub.Data.SaveDBM({
        name     = profileName,
        savedAt  = time(),
        liveVars = next(liveVars) and liveVars or nil,
    })
    P.Refresh()
    H.Print(L["DBM_PRINT_SAVED"]:format(profileName))
end

function P.Build(parent)
    local UI = AuraHub.UI
    local C  = UI.C

    local pg = CreateFrame("Frame", nil, parent)
    pg:SetAllPoints(parent)
    UI.AB(pg, C.bg, { 0, 0, 0, 0 })

    local titleFs = pg:CreateFontString(nil, "OVERLAY")
    titleFs:SetPoint("TOPLEFT", pg, "TOPLEFT", 14, -13)
    UI.SetFont(titleFs, 18)
    titleFs:SetText(L["DBM_TITLE"])
    titleFs:SetTextColor(C.textBright[1], C.textBright[2], C.textBright[3])

    local saveBtn = UI.CreateSaveButton(pg, L["DBM_BTN_SAVE"], L["DBM_BTN_W"] or 190, 30, SaveCurrentProfile)
    saveBtn:SetPoint("RIGHT", pg, "RIGHT", -14, 0)
    saveBtn:SetPoint("TOP",   pg, "TOP",   0,  -7)

    local sep = pg:CreateTexture(nil, "ARTWORK")
    sep:SetPoint("TOPLEFT",  pg, "TOPLEFT",  0, -44)
    sep:SetPoint("TOPRIGHT", pg, "TOPRIGHT", 0, -44)
    sep:SetHeight(1)
    sep:SetTexture("Interface\\Buttons\\WHITE8X8")
    sep:SetVertexColor(C.border[1], C.border[2], C.border[3], C.border[4])

    local scrollH = UI.CONTENT_H - 48
    _sf, _sc = UI.CreateScrollArea(pg, 0, 46, UI.CONTENT_W, scrollH)

    _emptyMsg = pg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    _emptyMsg:SetPoint("CENTER", pg, "CENTER", 0, -20)
    _emptyMsg:SetText(L["DBM_EMPTY"])
    _emptyMsg:SetJustifyH("CENTER")
    _emptyMsg:Hide()

    pg:SetScript("OnShow", function(self)
        self:SetScript("OnUpdate", function(s) s:SetScript("OnUpdate", nil); P.Refresh() end)
    end)

    AuraHub.UI.pages["DBM"] = pg
    pg:Hide()
end
