-- AuraHub — Pages\Skada.lua
-- Save and restore Skada profile snapshots.

AuraHub.Pages = AuraHub.Pages or {}
AuraHub.Pages.Skada = {}

local P  = AuraHub.Pages.Skada
local L  = AuraHub.L
local H  = AuraHub.Helpers

local _cards  = {}
local _sf, _sc
local _emptyMsg

local CARD_H  = 52
local CARD_GAP = 4
local PAD_Y   = 8
local PAD_X   = 8

-- Rebuild card list from AuraHubDB.Skada

function P.Refresh()
    for _, c in ipairs(_cards) do c:Hide() end
    _cards = {}

    local UI      = AuraHub.UI
    local C       = UI.C
    local entries = AuraHub.Data.GetSkadas()

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
        metaFs:SetText(L["SKADA_META"]:format(H.TimeAgo(entry.savedAt)))

        local restoreBtn = UI.CreateMenuButton(card, L["BTN_RESTORE"], 88, 28, function()
            AuraHub.Importer.RestoreSkada(entry)
        end)
        restoreBtn:SetPoint("RIGHT", card, "RIGHT", -80, 0)

        local queueBtn = UI.CreateQueueButton(card, function()
            AuraHub.Queue.Add("Skada", entry, entry.name or "Skada")
        end)
        queueBtn:SetPoint("RIGHT", card, "RIGHT", -42, 0)

        local delBtn = UI.CreateDeleteButton(card, L["BTN_DELETE"], 28, 28, function()
            AuraHub.Core._deletePending = function()
                AuraHub.Data.DeleteSkada(i)
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

-- Capture current Skada profile and save with a user-provided name

local function SaveCurrentLayout()
    if not Skada then
        H.Err(L["SKADA_ERR_NOT_LOADED"])
        return
    end
    if not Skada.db or not Skada.db.profile then
        H.Err(L["SKADA_ERR_DB"])
        return
    end

    local profileName
    if Skada.db.GetCurrentProfile then
        profileName = Skada.db:GetCurrentProfile()
    end
    if not profileName or profileName == "" then
        profileName = Skada.db.keys and Skada.db.keys[UnitName("player")] or "Default"
    end

    for _, entry in ipairs(AuraHub.Data.GetSkadas()) do
        if entry.name == profileName then
            H.Err(L["SKADA_ERR_DUPLICATE"]:format(profileName))
            return
        end
    end

    AuraHub.Data.SaveSkada({
        name    = profileName,
        savedAt = time(),
        data    = H.DeepCopy(Skada.db.profile),
    })
    P.Refresh()
    H.Print(L["SKADA_PRINT_SAVED"]:format(profileName))
end

-- Build

function P.Build(parent)
    local UI = AuraHub.UI
    local C  = UI.C

    local pg = CreateFrame("Frame", nil, parent)
    pg:SetAllPoints(parent)
    UI.AB(pg, C.bg, { 0, 0, 0, 0 })

    local titleFs = pg:CreateFontString(nil, "OVERLAY")
    titleFs:SetPoint("TOPLEFT", pg, "TOPLEFT", 14, -13)
    UI.SetFont(titleFs, 18)
    titleFs:SetText(L["SKADA_TITLE"])
    titleFs:SetTextColor(C.textBright[1], C.textBright[2], C.textBright[3])

    local saveBtn = UI.CreateSaveButton(pg, L["SKADA_BTN_SAVE"], L["SKADA_BTN_W"] or 170, 30, SaveCurrentLayout)
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
    _emptyMsg:SetText(L["SKADA_EMPTY"])
    _emptyMsg:SetJustifyH("CENTER")
    _emptyMsg:Hide()

    pg:SetScript("OnShow", function(self)
        self:SetScript("OnUpdate", function(s) s:SetScript("OnUpdate", nil); P.Refresh() end)
    end)

    AuraHub.UI.pages["Skada"] = pg
    pg:Hide()
end
