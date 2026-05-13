-- AuraHub — Pages\WeakAuras.lua
-- Save and restore WeakAura displays from/to WeakAuras.db.

AuraHub.Pages = AuraHub.Pages or {}
AuraHub.Pages.WeakAuras = {}

local P  = AuraHub.Pages.WeakAuras
local UI = AuraHub.UI
local C  -- set after UI loads, assigned inside Build()

local _cards    = {}
local _sf, _sc
local _emptyMsg

local _selected      = {}
local _selCount      = 0
local _restoreSelBtn
local _clearSelBtn
local _clearBtn
local _restoreAllBtn
local _pg
local _searchFilter  = ""
local _searchEB

local CARD_H    = 52
local CARD_GAP  = 4
local PAD_Y     = 8
local PAD_X     = 8

local function UpdateSelButton()
    if not _restoreSelBtn or not _clearSelBtn or not _clearBtn or not _restoreAllBtn then return end
    local L = AuraHub.L
    if _selCount > 0 then
        _restoreSelBtn.label:SetText(L["WA_BTN_RESTORE_SEL"]:format(_selCount))
        _restoreSelBtn:Show()
        _clearSelBtn:Show()
        _clearBtn:ClearAllPoints()
        _clearBtn:SetPoint("RIGHT", _clearSelBtn, "LEFT", -6, 0)
        _clearBtn:SetPoint("TOP",   _pg, "TOP", 0, -7)
    else
        _restoreSelBtn:Hide()
        _clearSelBtn:Hide()
        _clearBtn:ClearAllPoints()
        _clearBtn:SetPoint("RIGHT", _restoreAllBtn, "LEFT", -6, 0)
        _clearBtn:SetPoint("TOP",   _pg, "TOP", 0, -7)
    end
end

-- Rebuild card list from AuraHubDB.WeakAuras

function P.Refresh()
    for _, c in ipairs(_cards) do c:Hide() end
    _cards    = {}
    _selected = {}
    _selCount = 0
    UpdateSelButton()

    local L       = AuraHub.L
    local H       = AuraHub.Helpers
    local entries = AuraHub.Data.GetWAs()

    if _emptyMsg then
        if #entries == 0 then _emptyMsg:Show() else _emptyMsg:Hide() end
    end

    if #entries == 0 then
        _sc:SetHeight(UI.CONTENT_H - 52)
        return
    end

    local query = _searchFilter:lower()
    local visIdx = 0

    for i, entry in ipairs(entries) do
        local name = entry.name or ""
        if query ~= "" and not name:lower():find(query, 1, true) then
            -- filtered out by search
        else

        visIdx = visIdx + 1
        local y = PAD_Y + (visIdx - 1) * (CARD_H + CARD_GAP)

        local card = CreateFrame("Frame", nil, _sc)
        card:SetPoint("TOPLEFT", _sc, "TOPLEFT", 14, -y)
        card:SetWidth(AuraHub.UI.CONTENT_W - 28)
        card:SetHeight(CARD_H)
        local bgCol = (visIdx % 2 == 0) and C.card or C.cardAlt
        UI.AB(card, bgCol, C.border)

        local nameFs = card:CreateFontString(nil, "OVERLAY")
        nameFs:SetPoint("TOPLEFT",  card, "TOPLEFT",  10, -9)
        nameFs:SetPoint("TOPRIGHT", card, "TOPRIGHT", -174, -9)
        UI.SetFont(nameFs, 16)
        nameFs:SetText(entry.name or "Unnamed")
        nameFs:SetTextColor(C.text[1], C.text[2], C.text[3])
        nameFs:SetJustifyH("LEFT")

        local dispN = entry.displays and #entry.displays or 0
        local metaFs = card:CreateFontString(nil, "OVERLAY")
        metaFs:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 10, 9)
        UI.SetFont(metaFs, 13)
        metaFs:SetText(L["WA_META"]:format(
            dispN,
            H.Plural(dispN, L["WORD_DISPLAY"], L["WORD_DISPLAY_FEW"], L["WORD_DISPLAYS"]),
            H.TimeAgo(entry.savedAt)
        ))

        local delBtn = UI.CreateDeleteButton(card, L["BTN_DELETE"], 28, 28, function()
            AuraHub.Core._deletePending = function()
                AuraHub.Data.DeleteWA(i)
                P.Refresh()
            end
            StaticPopup_Show("AURAHUB_DELETE_CONFIRM", entry.name or "this entry")
        end)
        delBtn:SetPoint("RIGHT", card, "RIGHT", -8, 0)

        local queueBtn = UI.CreateQueueButton(card, function()
            AuraHub.Queue.Add("WA", entry, entry.name or "WA")
        end)
        queueBtn:SetPoint("RIGHT", card, "RIGHT", -42, 0)

        local restoreBtn = UI.CreateMenuButton(card, L["BTN_RESTORE"], 88, 28, function()
            AuraHub.Importer.RestoreWA(entry)
        end)
        restoreBtn:SetPoint("RIGHT", card, "RIGHT", -80, 0)

        local sel      = false
        local cardIdx  = i

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
                card:SetBackdropBorderColor(C.border[1], C.border[2], C.border[3], C.border[4] or 1)
                nameFs:SetTextColor(C.text[1], C.text[2], C.text[3])
            end
        end

        local selZone = CreateFrame("Button", nil, card)
        selZone:SetPoint("TOPLEFT",     card, "TOPLEFT",     0, 0)
        selZone:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -174, 0)
        selZone:RegisterForClicks("LeftButtonUp")
        selZone:SetScript("OnClick", function()
            sel = not sel
            if sel then
                _selected[cardIdx] = entry
                _selCount = _selCount + 1
            else
                _selected[cardIdx] = nil
                _selCount = _selCount - 1
            end
            SetCardVisual(false)
            UpdateSelButton()
        end)
        selZone:SetScript("OnEnter", function() SetCardVisual(true)  end)
        selZone:SetScript("OnLeave", function() SetCardVisual(false) end)

        card:Show()
        _cards[#_cards + 1] = card
        end -- search filter
    end

    local totalH = PAD_Y + visIdx * (CARD_H + CARD_GAP)
    _sc:SetHeight(math.max(totalH, UI.CONTENT_H - 52))
    _sf:SetVerticalScroll(0)
    if _sf._sb then _sf._sb:SetValue(0) end
end

-- Picker dialog

local _picker
local _pickerSelected
local _pickerRows = {}

local function BuildPicker()
    local L = AuraHub.L
    local PW, PH = 520, 400
    local d = CreateFrame("Frame", "AuraHubWAPicker", UIParent)
    d:SetSize(PW, PH)
    d:SetPoint("CENTER")
    d:SetFrameStrata("DIALOG")
    d:SetMovable(true)
    d:EnableMouse(true)
    d:SetClampedToScreen(true)
    UI.AB(d, { 0.06, 0.06, 0.07, 0.98 }, { 0.28, 0.28, 0.32, 1 })
    table.insert(UISpecialFrames, "AuraHubWAPicker")

    local headerF = CreateFrame("Frame", nil, d)
    headerF:SetPoint("TOPLEFT"); headerF:SetPoint("TOPRIGHT"); headerF:SetHeight(40)
    UI.AB(headerF, { 0.04, 0.04, 0.05, 1 }, C.border)
    headerF:EnableMouse(true)
    headerF:SetScript("OnMouseDown", function(_, b) if b == "LeftButton" then d:StartMoving() end end)
    headerF:SetScript("OnMouseUp",   function()     d:StopMovingOrSizing() end)

    local titleFs = headerF:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleFs:SetPoint("LEFT", headerF, "LEFT", 14, 0)
    titleFs:SetText(L["WA_PICKER_TITLE"])

    local closeBtn = CreateFrame("Button", nil, headerF)
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("RIGHT", headerF, "RIGHT", -8, 0)
    UI.AB(closeBtn, { 0.28, 0.07, 0.07, 1 }, { 0.45, 0.10, 0.10, 1 })
    local cX = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    cX:SetAllPoints(); cX:SetText("X"); cX:SetTextColor(0.85, 0.35, 0.35)
    closeBtn:SetScript("OnClick", function() d:Hide() end)

    local statusFs = d:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    statusFs:SetPoint("TOPLEFT", headerF, "BOTTOMLEFT", 10, -6)
    d._statusFs = statusFs

    local listH = PH - 40 - 22 - 48 - 46
    local lsf, lsc = UI.CreateScrollArea(d, 0, 40 + 22, PW, listH)
    d._lsc = lsc
    d._listH = listH

    local nameRowY = 40 + 22 + listH + 6
    local nameLbl = d:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nameLbl:SetPoint("TOPLEFT", d, "TOPLEFT", 10, -nameRowY)
    nameLbl:SetText(L["WA_PICKER_NAME_LBL"])

    local nameEB = CreateFrame("EditBox", nil, d)
    nameEB:SetPoint("TOPLEFT",  d, "TOPLEFT",  52, -nameRowY + 2)
    nameEB:SetPoint("TOPRIGHT", d, "TOPRIGHT", -10, -nameRowY + 2)
    nameEB:SetHeight(26)
    nameEB:SetAutoFocus(false)
    nameEB:SetMaxLetters(80)
    nameEB:SetFontObject("ChatFontNormal")
    nameEB:SetTextColor(0.9, 0.9, 0.9)
    UI.AB(nameEB, { 0.08, 0.08, 0.10, 1 }, C.border)
    nameEB:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    d._nameEB = nameEB

    local function GetName()
        local H    = AuraHub.Helpers
        local name = H.Trim(nameEB:GetText())
        if name == "" then
            H.Err(L["WA_ERR_ENTER_NAME"])
            return nil
        end
        for _, entry in ipairs(AuraHub.Data.GetWAs()) do
            if entry.name == name then
                H.Err(L["WA_ERR_ALREADY_SAVED"]:format(name))
                return nil
            end
        end
        return name
    end

    local saveBtn = UI.CreateSaveButton(d, L["WA_PICKER_BTN_SAVE"], 96, 32, function()
        if not _pickerSelected then
            AuraHub.Helpers.Err(L["WA_ERR_SELECT_FIRST"])
            return
        end
        local name = GetName()
        if not name then return end

        local displays, err = AuraHub.WA.CaptureDisplay(_pickerSelected)
        if not displays then
            AuraHub.Helpers.Err(err or L["WA_ERR_CAPTURE_FAIL"])
            return
        end
        AuraHub.Data.SaveWA({ name = name, savedAt = time(), displays = displays })
        d:Hide()
        P.Refresh()
        AuraHub.Helpers.Print(L["WA_PRINT_SAVED"]:format(name))
    end)
    saveBtn:SetPoint("BOTTOMRIGHT", d, "BOTTOMRIGHT", -10, 10)

    local saveAllBtn = UI.CreateSaveButton(d, L["WA_PICKER_BTN_SAVE_ALL"], 96, 32, function()
        local H = AuraHub.Helpers
        if not AuraHub.WA.IsReady() then H.Err(L["WA_ERR_NOT_READY"]); return end

        local allDisplays = AuraHub.WA.GetAllDisplays()
        if #allDisplays == 0 then H.Err(L["WA_ERR_NO_WA"]); return end

        local savedNames = {}
        for _, entry in ipairs(AuraHub.Data.GetWAs()) do
            savedNames[entry.name] = true
        end

        local savedCount = 0
        for _, disp in ipairs(allDisplays) do
            if not savedNames[disp.name] then
                local captures = AuraHub.WA.CaptureDisplay(disp.id)
                if captures and #captures > 0 then
                    AuraHub.Data.SaveWA({ name = disp.name, savedAt = time(), displays = captures })
                    savedCount = savedCount + 1
                end
            end
        end

        if savedCount == 0 then
            H.Err(L["WA_STATUS_ALL_SAVED"])
            return
        end
        d:Hide()
        P.Refresh()
        H.Print(L["WA_PRINT_ALL_SAVED"]:format(savedCount))
    end)
    saveAllBtn:SetPoint("RIGHT", saveBtn, "LEFT", -8, 0)

    local cancelBtn = UI.CreateMenuButton(d, L["WA_PICKER_BTN_CANCEL"], 80, 32, function() d:Hide() end)
    cancelBtn:SetPoint("RIGHT", saveAllBtn, "LEFT", -8, 0)

    d:Hide()
    return d
end

local function ShowPicker()
    local L = AuraHub.L
    local H = AuraHub.Helpers
    if not AuraHub.WA.IsReady() then
        H.Err(L["WA_ERR_NOT_READY"])
        return
    end

    if not _picker then _picker = BuildPicker() end

    _pickerSelected = nil
    _picker._nameEB:SetText("")

    for _, r in ipairs(_pickerRows) do r:Hide() end
    _pickerRows = {}

    local displays = AuraHub.WA.GetAllDisplays()
    local lsc  = _picker._lsc
    local rowH = 28
    local rowG = 2

    if #displays == 0 then
        _picker._statusFs:SetText(L["WA_STATUS_NO_WA"])
        lsc:SetHeight(_picker._listH)
        _picker:Show()
        return
    end

    local savedIds = {}
    for _, entry in ipairs(AuraHub.Data.GetWAs()) do
        if entry.displays and entry.displays[1] and entry.displays[1].id then
            savedIds[entry.displays[1].id] = true
        end
    end

    local visible = {}
    for _, disp in ipairs(displays) do
        if not savedIds[disp.id] then
            visible[#visible + 1] = disp
        end
    end

    if #visible == 0 then
        _picker._statusFs:SetText(L["WA_STATUS_ALL_SAVED"])
        lsc:SetHeight(_picker._listH)
        _picker:Show()
        return
    end

    _picker._statusFs:SetText(L["WA_STATUS_FOUND"]:format(
        #visible,
        H.Plural(#visible, L["WORD_AURA"], L["WORD_AURA_FEW"], L["WORD_AURAS"])
    ))

    for i, disp in ipairs(visible) do
        local y = (i - 1) * (rowH + rowG)

        local row = CreateFrame("Button", nil, lsc)
        row:SetPoint("TOPLEFT",  lsc, "TOPLEFT",  0, -y)
        row:SetPoint("TOPRIGHT", lsc, "TOPRIGHT", 0, -y)
        row:SetHeight(rowH)
        UI.AB(row, (i % 2 == 0) and C.card or C.cardAlt, { 0, 0, 0, 0 })

        local nameLbl = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        nameLbl:SetPoint("LEFT",  row, "LEFT",  10, 0)
        nameLbl:SetPoint("RIGHT", row, "RIGHT", -80, 0)
        nameLbl:SetText(disp.name)
        nameLbl:SetTextColor(C.text[1], C.text[2], C.text[3])
        nameLbl:SetJustifyH("LEFT")

        local typeFs = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        typeFs:SetPoint("RIGHT", row, "RIGHT", -8, 0)
        typeFs:SetText(
            "|cff353545" .. disp.regionType ..
            (disp.childCount > 0 and " +" .. disp.childCount .. "c" or "") .. "|r"
        )

        local dispId   = disp.id
        local dispName = disp.name

        local function Deselect()
            UI.AB(row, (i % 2 == 0) and C.card or C.cardAlt, { 0, 0, 0, 0 })
            nameLbl:SetTextColor(C.text[1], C.text[2], C.text[3])
        end
        local function Select()
            row:SetBackdropColor(C.navActive[1], C.navActive[2], C.navActive[3])
            row:SetBackdropBorderColor(C.accent[1], C.accent[2], C.accent[3], 0.6)
            nameLbl:SetTextColor(C.textBright[1], C.textBright[2], C.textBright[3])
        end

        row:SetScript("OnClick", function()
            for _, r in ipairs(_pickerRows) do
                if r._deselect then r._deselect() end
            end
            Select()
            _pickerSelected = dispId
            _picker._nameEB:SetText(dispName)
        end)
        row:SetScript("OnEnter", function(self)
            if _pickerSelected ~= dispId then
                self:SetBackdropColor(C.cardHover[1], C.cardHover[2], C.cardHover[3])
            end
        end)
        row:SetScript("OnLeave", function(self)
            if _pickerSelected ~= dispId then Deselect() end
        end)

        row._deselect = Deselect
        row:Show()
        _pickerRows[#_pickerRows + 1] = row
    end

    local totalH = #visible * (rowH + rowG)
    lsc:SetHeight(math.max(totalH, _picker._listH))
    _picker:Show()
end

-- Build

function P.Build(parent)
    C  = AuraHub.UI.C
    local L = AuraHub.L

    local pg = CreateFrame("Frame", nil, parent)
    pg:SetAllPoints(parent)
    UI.AB(pg, C.bg, { 0, 0, 0, 0 })
    _pg = pg

    local titleFs = pg:CreateFontString(nil, "OVERLAY")
    titleFs:SetPoint("TOPLEFT", pg, "TOPLEFT", 14, -13)
    UI.SetFont(titleFs, 17)
    titleFs:SetText(L["WA_TITLE"])

    local saveBtn = UI.CreateSaveButton(pg, L["WA_BTN_SAVE"], L["WA_SAVE_BTN_W"] or 148, 30, ShowPicker)
    saveBtn:SetPoint("RIGHT", pg, "RIGHT", -14, 0)
    saveBtn:SetPoint("TOP",   pg, "TOP",   0,  -7)

    _restoreAllBtn = UI.CreateSaveButton(pg, L["WA_BTN_RESTORE_ALL"], 100, 30, function()
        AuraHub.Importer.RestoreAllWAs()
    end)
    _restoreAllBtn:SetPoint("RIGHT", saveBtn, "LEFT", -6, 0)
    _restoreAllBtn:SetPoint("TOP",   pg, "TOP", 0, -7)

    -- hidden by default; shown when cards are selected
    _restoreSelBtn = UI.CreateSaveButton(pg, L["WA_BTN_RESTORE_SEL"]:format(0), 112, 30, function()
        local toRestore = {}
        for _, e in pairs(_selected) do toRestore[#toRestore + 1] = e end
        if #toRestore == 0 then return end
        AuraHub.Importer.RestoreSelectedWAs(toRestore)
        _selected = {}
        _selCount = 0
        P.Refresh()
    end)
    _restoreSelBtn:SetPoint("RIGHT", _restoreAllBtn, "LEFT", -6, 0)
    _restoreSelBtn:SetPoint("TOP",   pg, "TOP", 0, -7)
    _restoreSelBtn:Hide()

    _clearSelBtn = UI.CreateMenuButton(pg, L["WA_BTN_CLEAR_SEL"], 82, 30, function()
        _selected = {}
        _selCount = 0
        UpdateSelButton()
        P.Refresh()
    end)
    _clearSelBtn:SetPoint("RIGHT", _restoreSelBtn, "LEFT", -6, 0)
    _clearSelBtn:SetPoint("TOP",   pg, "TOP", 0, -7)
    _clearSelBtn:Hide()

    -- always visible; repositions left when selection is active
    _clearBtn = UI.CreateDeleteButton(pg, L["WA_BTN_CLEAR_ALL"], L["WA_CLEAR_BTN_W"] or 90, 30, function()
        if #AuraHub.Data.GetWAs() == 0 then return end
        AuraHub.Core._deletePending = function()
            AuraHubDB.WeakAuras = {}
            AuraHub.Data.Flush()
            P.Refresh()
            AuraHub.Helpers.Print("All WeakAura backups cleared.")
        end
        StaticPopup_Show("AURAHUB_DELETE_CONFIRM", "ALL WeakAura backups")
    end)
    _clearBtn:SetPoint("RIGHT", _restoreAllBtn, "LEFT", -6, 0)
    _clearBtn:SetPoint("TOP",   pg, "TOP", 0, -7)

    UI.CreateDivider(pg, 0, 0)
    local sep = pg:CreateTexture(nil, "ARTWORK")
    sep:SetPoint("TOPLEFT",  pg, "TOPLEFT",  0, -44)
    sep:SetPoint("TOPRIGHT", pg, "TOPRIGHT", 0, -44)
    sep:SetHeight(1)
    sep:SetTexture("Interface\\Buttons\\WHITE8X8")
    sep:SetVertexColor(C.border[1], C.border[2], C.border[3], C.border[4])

    -- Search box: full width above cards, same padding as card container
    _searchEB = CreateFrame("EditBox", nil, pg)
    _searchEB:SetPoint("TOPLEFT", pg, "TOPLEFT", 14, -53)
    _searchEB:SetWidth(AuraHub.UI.CONTENT_W - 28)
    _searchEB:SetHeight(26)
    _searchEB:SetAutoFocus(false)
    _searchEB:SetMaxLetters(80)
    _searchEB:SetTextInsets(8, 6, 0, 0)
    UI.SetFont(_searchEB, 14)
    _searchEB:SetTextColor(0.80, 0.80, 0.82)
    UI.AB(_searchEB, { 0.08, 0.08, 0.10, 1 }, C.border)
    _searchEB:SetScript("OnEscapePressed", function(self)
        self:SetText("")
        self:ClearFocus()
    end)
    _searchEB:SetScript("OnTextChanged", function(self)
        _searchFilter = self:GetText()
        P.Refresh()
    end)

    local searchHint = _searchEB:CreateFontString(nil, "OVERLAY")
    UI.SetFont(searchHint, 13)
    searchHint:SetPoint("LEFT", _searchEB, "LEFT", 8, 0)
    searchHint:SetText(L["WA_SEARCH_HINT"])
    searchHint:SetTextColor(0.35, 0.35, 0.38)
    _searchEB:SetScript("OnEditFocusGained", function() searchHint:Hide() end)
    _searchEB:SetScript("OnEditFocusLost",   function(self)
        if self:GetText() == "" then searchHint:Show() end
    end)

    -- Scroll area: 53 (search top) + 26 (search h) + 8 (PAD_Y gap) = 87; same 8px gap as PAD_Y above search
    local scrollH = UI.CONTENT_H - 89
    _sf, _sc = UI.CreateScrollArea(pg, 0, 87, UI.CONTENT_W, scrollH)

    _emptyMsg = pg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    _emptyMsg:SetPoint("CENTER", pg, "CENTER", 0, -20)
    _emptyMsg:SetText(L["WA_EMPTY"])
    _emptyMsg:SetJustifyH("CENTER")
    _emptyMsg:Hide()

    pg:SetScript("OnShow", function(self)
        if _searchEB then
            _searchFilter = ""
            _searchEB:SetText("")
        end
        self:SetScript("OnUpdate", function(s)
            s:SetScript("OnUpdate", nil)
            P.Refresh()
        end)
    end)

    AuraHub.UI.pages["WeakAuras"] = pg
    pg:Hide()
end
