-- AuraHub — Pages\ActionBars.lua
-- Save and restore action bar slot layouts.

AuraHub.Pages = AuraHub.Pages or {}
AuraHub.Pages.ActionBars = {}

local P = AuraHub.Pages.ActionBars
local L = AuraHub.L
local H = AuraHub.Helpers

local _cards = {}
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
    local entries = AuraHub.Data.GetActionBars()

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
        metaFs:SetText(L["BARS_META"]:format(
            count,
            H.Plural(count, L["WORD_SLOT"], L["WORD_SLOT_FEW"], L["WORD_SLOTS"]),
            H.TimeAgo(entry.savedAt)
        ))

        local restoreBtn = UI.CreateMenuButton(card, L["BTN_RESTORE"], 88, 28, function()
            AuraHub.Core._restorePending = function()
                AuraHub.Importer.RestoreActionBars(entry)
            end
            StaticPopup_Show("AURAHUB_RESTORE_CONFIRM", entry.name or "?")
        end)
        restoreBtn:SetPoint("RIGHT", card, "RIGHT", -44, 0)

        local delBtn = UI.CreateDeleteButton(card, L["BTN_DELETE"], 28, 28, function()
            AuraHub.Core._deletePending = function()
                AuraHub.Data.DeleteActionBar(i)
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
            self:SetBackdropBorderColor(C.border[1], C.border[2], C.border[3], C.border[4])
            nameFs:SetTextColor(C.text[1], C.text[2], C.text[3])
        end)

        card:Show()
        _cards[#_cards + 1] = card
    end

    local totalH = PAD_Y + #entries * (CARD_H + CARD_GAP)
    _sc:SetHeight(math.max(totalH, AuraHub.UI.CONTENT_H - 52))
    _sf:SetVerticalScroll(0)
    if _sf._sb then _sf._sb:SetValue(0) end
end

local function SaveCurrentBars()
    AuraHub.Core._savePending = function(name)
        for _, entry in ipairs(AuraHub.Data.GetActionBars()) do
            if entry.name == name then
                H.Err(L["BARS_ERR_DUPLICATE"]:format(name))
                return
            end
        end

        local slots = {}
        for slot = 1, 72 do
            local aType, aId = GetActionInfo(slot)
            if aType == "spell" then
                local sName, sRank = "", ""
                if GetSpellInfo then
                    -- aId from GetActionInfo is a spellbook slot, not a spell ID
                    sName, sRank = GetSpellInfo(aId, "spell")
                    sName = sName or ""
                    sRank = sRank or ""
                end
                slots[#slots + 1] = { slot = slot, type = "spell", id = aId, name = sName, rank = sRank }
            elseif aType == "item" then
                local iName = GetItemInfo and GetItemInfo(aId) or ""
                slots[#slots + 1] = { slot = slot, type = "item", id = aId, name = iName or "" }
            elseif aType == "macro" then
                local mName, _, mBody = GetMacroInfo(aId)
                slots[#slots + 1] = { slot = slot, type = "macro", id = aId, name = mName or "", body = mBody or "" }
            end
        end

        AuraHub.Data.SaveActionBar({
            name    = name,
            savedAt = time(),
            data    = slots,
        })
        P.Refresh()
        H.Print(L["BARS_PRINT_SAVED"]:format(name, #slots))
    end
    StaticPopup_Show("AURAHUB_SAVE_NAME", L["BARS_POPUP_TITLE"])
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
    titleFs:SetText(L["BARS_TITLE"])
    titleFs:SetTextColor(C.textBright[1], C.textBright[2], C.textBright[3])

    local saveBtn = UI.CreateSaveButton(pg, L["BARS_BTN_SAVE"], 162, 30, SaveCurrentBars)
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
    _emptyMsg:SetText(L["BARS_EMPTY"])
    _emptyMsg:SetJustifyH("CENTER")
    _emptyMsg:Hide()

    pg:SetScript("OnShow", function(self)
        self:SetScript("OnUpdate", function(s) s:SetScript("OnUpdate", nil); P.Refresh() end)
    end)

    AuraHub.UI.pages["ActionBars"] = pg
    pg:Hide()
end
