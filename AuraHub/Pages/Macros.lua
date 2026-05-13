-- AuraHub — Pages\Macros.lua
-- Save and restore macro profiles.

AuraHub.Pages = AuraHub.Pages or {}
AuraHub.Pages.Macros = {}

local P = AuraHub.Pages.Macros
local L = AuraHub.L
local H = AuraHub.Helpers

local _cards  = {}
local _sf, _sc
local _emptyMsg

local _selected      = {}
local _selCount      = 0
local _restoreSelBtn
local _clearSelBtn
local _saveBtnChar
local _pg

local CARD_H  = 52
local CARD_GAP = 4
local PAD_Y   = 8
local PAD_X   = 8

local function UpdateSelButton()
    if not _restoreSelBtn or not _clearSelBtn or not _saveBtnChar then return end
    if _selCount > 0 then
        _restoreSelBtn.label:SetText(L["MACROS_BTN_RESTORE_SEL"]:format(_selCount))
        _restoreSelBtn:Show()
        _clearSelBtn:Show()
    else
        _restoreSelBtn:Hide()
        _clearSelBtn:Hide()
    end
end

-- Rebuild card list

function P.Refresh()
    for _, c in ipairs(_cards) do c:Hide() end
    _cards   = {}
    _selected = {}
    _selCount = 0
    UpdateSelButton()

    local UI      = AuraHub.UI
    local C       = UI.C
    local entries = AuraHub.Data.GetMacros()

    if _emptyMsg then
        if #entries == 0 then _emptyMsg:Show() else _emptyMsg:Hide() end
    end

    if #entries == 0 then
        _sc:SetHeight(UI.CONTENT_H - 52)
        return
    end

    for i, entry in ipairs(entries) do
        local y = PAD_Y + (i - 1) * (CARD_H + CARD_GAP)

        local card = CreateFrame("Frame", nil, _sc)
        card:SetPoint("TOPLEFT", _sc, "TOPLEFT", 14, -y)
        card:SetWidth(AuraHub.UI.CONTENT_W - 28)
        card:SetHeight(CARD_H)
        local bgCol = (i % 2 == 0) and C.card or C.cardAlt
        UI.AB(card, bgCol, C.border)
        card:EnableMouse(true)

        local nameFs = card:CreateFontString(nil, "OVERLAY")
        nameFs:SetPoint("TOPLEFT",  card, "TOPLEFT",  10, -9)
        nameFs:SetPoint("TOPRIGHT", card, "TOPRIGHT", -140, -9)
        UI.SetFont(nameFs, 16)
        nameFs:SetText(entry.name or "Unnamed")
        nameFs:SetTextColor(C.text[1], C.text[2], C.text[3])
        nameFs:SetJustifyH("LEFT")

        local count = entry.data and #entry.data or 0
        local metaFs = card:CreateFontString(nil, "OVERLAY")
        metaFs:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 10, 9)
        UI.SetFont(metaFs, 13)
        metaFs:SetText(L["MACROS_META"]:format(
            count,
            H.Plural(count, L["WORD_MACRO"], L["WORD_MACRO_FEW"], L["WORD_MACROS"]),
            H.TimeAgo(entry.savedAt)
        ))

        local restoreBtn = UI.CreateMenuButton(card, L["BTN_RESTORE"], 88, 28, function()
            AuraHub.Core._restorePending = function()
                AuraHub.Importer.RestoreMacros(entry)
            end
            StaticPopup_Show("AURAHUB_RESTORE_CONFIRM", entry.name or "?")
        end)
        restoreBtn:SetPoint("RIGHT", card, "RIGHT", -44, 0)

        local delBtn = UI.CreateDeleteButton(card, L["BTN_DELETE"], 28, 28, function()
            AuraHub.Core._deletePending = function()
                AuraHub.Data.DeleteMacro(i)
                P.Refresh()
            end
            StaticPopup_Show("AURAHUB_DELETE_CONFIRM", entry.name or "this entry")
        end)
        delBtn:SetPoint("RIGHT", card, "RIGHT", -8, 0)

        local sel = false

        local function SetCardVisual(hovering)
            if sel then
                card:SetBackdropColor(0.06, 0.18, 0.30, 1)
                card:SetBackdropBorderColor(C.accent[1], C.accent[2], C.accent[3], 1)
                nameFs:SetTextColor(C.textBright[1], C.textBright[2], C.textBright[3])
            elseif hovering then
                card:SetBackdropColor(C.cardHover[1], C.cardHover[2], C.cardHover[3])
                card:SetBackdropBorderColor(C.accent[1], C.accent[2], C.accent[3], 0.5)
                nameFs:SetTextColor(C.textBright[1], C.textBright[2], C.textBright[3])
            else
                card:SetBackdropColor(bgCol[1], bgCol[2], bgCol[3])
                card:SetBackdropBorderColor(C.border[1], C.border[2], C.border[3], C.border[4])
                nameFs:SetTextColor(C.text[1], C.text[2], C.text[3])
            end
        end

        local selZone = CreateFrame("Button", nil, card)
        selZone:SetPoint("TOPLEFT",     card, "TOPLEFT",     0,    0)
        selZone:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -138, 0)
        selZone:RegisterForClicks("LeftButtonUp")
        selZone:SetScript("OnClick", function()
            sel = not sel
            if sel then
                _selected[i] = entry
                _selCount = _selCount + 1
            else
                _selected[i] = nil
                _selCount = _selCount - 1
            end
            SetCardVisual(false)
            UpdateSelButton()
        end)
        selZone:SetScript("OnEnter", function() SetCardVisual(true)  end)
        selZone:SetScript("OnLeave", function() SetCardVisual(false) end)

        card:Show()
        _cards[#_cards + 1] = card
    end

    local totalH = PAD_Y + #entries * (CARD_H + CARD_GAP)
    _sc:SetHeight(math.max(totalH, AuraHub.UI.CONTENT_H - 52))
    _sf:SetVerticalScroll(0)
    if _sf._sb then _sf._sb:SetValue(0) end
end

-- Helpers

local function CheckDuplicate(name)
    for _, entry in ipairs(AuraHub.Data.GetMacros()) do
        if entry.name == name then
            H.Err(L["MACROS_ERR_DUPLICATE"]:format(name))
            return true
        end
    end
    return false
end

local function DoSave(name, macros)
    AuraHub.Data.SaveMacro({
        name    = name,
        savedAt = time(),
        data    = macros,
    })
    P.Refresh()
    H.Print(L["MACROS_PRINT_SAVED"]:format(name, #macros))
end

-- Save only current character's macros

local function SaveCharMacros()
    AuraHub.Core._savePending = function(name)
        if CheckDuplicate(name) then return end

        local macros = {}
        local _, numChar = GetNumMacros()
        for slot = 37, 36 + numChar do
            local mName, mIcon, mBody = GetMacroInfo(slot)
            if mName then
                macros[#macros + 1] = { scope = "char", name = mName, icon = mIcon or 1, body = mBody or "" }
            end
        end

        DoSave(name, macros)
    end
    StaticPopup_Show("AURAHUB_SAVE_NAME", L["MACROS_POPUP_CHAR"])
end

-- Save only account-wide macros

local function SaveAccountMacros()
    AuraHub.Core._savePending = function(name)
        if CheckDuplicate(name) then return end

        local macros = {}
        local numAccount = GetNumMacros()
        for slot = 1, numAccount do
            local mName, mIcon, mBody = GetMacroInfo(slot)
            if mName then
                macros[#macros + 1] = { scope = "account", name = mName, icon = mIcon or 1, body = mBody or "" }
            end
        end

        DoSave(name, macros)
    end
    StaticPopup_Show("AURAHUB_SAVE_NAME", L["MACROS_POPUP_ALL"])
end

-- Build

function P.Build(parent)
    local UI = AuraHub.UI
    local C  = UI.C

    local pg = CreateFrame("Frame", nil, parent)
    pg:SetAllPoints(parent)
    UI.AB(pg, C.bg, { 0, 0, 0, 0 })
    _pg = pg

    local titleFs = pg:CreateFontString(nil, "OVERLAY")
    titleFs:SetPoint("TOPLEFT", pg, "TOPLEFT", 14, -13)
    UI.SetFont(titleFs, 18)
    titleFs:SetText(L["MACROS_TITLE"])
    titleFs:SetTextColor(C.textBright[1], C.textBright[2], C.textBright[3])

    _saveBtnChar = UI.CreateSaveButton(pg, L["MACROS_BTN_CHAR"], 158, 30, SaveCharMacros)
    _saveBtnChar:SetPoint("RIGHT", pg, "RIGHT", -14, 0)
    _saveBtnChar:SetPoint("TOP",   pg, "TOP",   0,  -7)

    local saveBtnAll = UI.CreateMenuButton(pg, L["MACROS_BTN_ALL"], 116, 30, SaveAccountMacros)
    saveBtnAll:SetPoint("RIGHT", _saveBtnChar, "LEFT", -6, 0)
    saveBtnAll:SetPoint("TOP",   pg, "TOP",   0,  -7)

    _restoreSelBtn = UI.CreateSaveButton(pg, "", 100, 30, function()
        if _selCount == 0 then return end
        local entries = {}
        for _, e in pairs(_selected) do entries[#entries + 1] = e end
        AuraHub.Core._restorePending = function()
            for _, e in ipairs(entries) do
                AuraHub.Importer.RestoreMacros(e)
            end
            _selected = {}
            _selCount = 0
            UpdateSelButton()
            P.Refresh()
        end
        local name = _selCount .. " " .. H.Plural(_selCount, L["WORD_MACRO"], L["WORD_MACRO_FEW"], L["WORD_MACROS"])
        StaticPopup_Show("AURAHUB_RESTORE_CONFIRM", name)
    end)
    _restoreSelBtn:SetPoint("RIGHT", saveBtnAll, "LEFT", -6, 0)
    _restoreSelBtn:SetPoint("TOP",   pg, "TOP",   0,  -7)
    _restoreSelBtn:Hide()

    _clearSelBtn = UI.CreateMenuButton(pg, L["MACROS_BTN_CLEAR_SEL"], 82, 30, function()
        _selected = {}
        _selCount = 0
        UpdateSelButton()
        P.Refresh()
    end)
    _clearSelBtn:SetPoint("RIGHT", _restoreSelBtn, "LEFT", -6, 0)
    _clearSelBtn:SetPoint("TOP",   pg, "TOP",   0,  -7)
    _clearSelBtn:Hide()

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
    _emptyMsg:SetText(L["MACROS_EMPTY"])
    _emptyMsg:SetJustifyH("CENTER")
    _emptyMsg:Hide()

    pg:SetScript("OnShow", function(self)
        self:SetScript("OnUpdate", function(s) s:SetScript("OnUpdate", nil); P.Refresh() end)
    end)

    AuraHub.UI.pages["Macros"] = pg
    pg:Hide()
end
