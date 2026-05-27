
-- AuraHub — Pages\Main.lua

AuraHub.Pages = AuraHub.Pages or {}
AuraHub.Pages.Main = {}

local function Build(parent)
    local UI = AuraHub.UI
    local C  = UI.C
    local L  = AuraHub.L

    local pg = CreateFrame("Frame", nil, parent)
    pg:SetAllPoints(parent)
    UI.AB(pg, C.bg, { 0, 0, 0, 0 })

    local logo = pg:CreateFontString(nil, "OVERLAY")
    logo:SetPoint("CENTER", pg, "CENTER", 0, 90)
    logo:SetFont(UI.FONT, 30, "OUTLINE")
    logo:SetText("|cff4db8ffAura|r|cffe0e0e0Hub|r")

    -- Help link above logo
    local helpLink = UI.CreateMenuButton(pg, L["NAV_HELP"], 110, 24, function()
        AuraHub.UI.ShowPage("Help")
    end)
    helpLink:SetPoint("BOTTOM", logo, "TOP", 0, 10)

    local sub = pg:CreateFontString(nil, "OVERLAY")
    sub:SetPoint("TOP", logo, "BOTTOM", 0, -6)
    UI.SetFont(sub, 13)
    sub:SetText(L["MAIN_SUBTITLE"])

    local div = pg:CreateTexture(nil, "ARTWORK")
    div:SetPoint("TOP", sub, "BOTTOM", 0, -18)
    div:SetSize(280, 1)
    div:SetTexture("Interface\\Buttons\\WHITE8X8")
    div:SetVertexColor(C.border[1], C.border[2], C.border[3], C.border[4])

    local howToLines = {
        L["MAIN_HOW_WA"],
        L["MAIN_HOW_ELVUI"],
        L["MAIN_HOW_SKADA"],
        L["MAIN_HOW_DBM"],
    }
    local prevAnchor = div
    for _, lineText in ipairs(howToLines) do
        local ln = pg:CreateFontString(nil, "OVERLAY")
        ln:SetPoint("TOP", prevAnchor, "BOTTOM", 0, -12)
        UI.SetFont(ln, 16)
        ln:SetText(lineText)
        ln:SetJustifyH("LEFT")
        prevAnchor = ln
    end

    local summaryItems = {
        { label = L["MAIN_SUM_WA"],       page = "WeakAuras",  fn = AuraHub.Data.CountWAs        },
        { label = L["MAIN_SUM_ELVUI"],    page = "ElvUI",      fn = AuraHub.Data.CountElvUIs     },
        { label = L["MAIN_SUM_SKADA"],    page = "Skada",      fn = AuraHub.Data.CountSkadas     },
        { label = L["MAIN_SUM_DBM"],      page = "DBM",        fn = AuraHub.Data.CountDBMs       },
        { label = L["MAIN_SUM_KEYBINDS"], page = "Binds",      fn = AuraHub.Data.CountBinds      },
        { label = L["MAIN_SUM_MACROS"],   page = "Macros",     fn = AuraHub.Data.CountMacros     },
        { label = L["MAIN_SUM_BARS"],     page = "ActionBars", fn = AuraHub.Data.CountActionBars },
    }

    local cardW  = 120
    local cardH  = 66
    local gap    = 8
    local totalW = #summaryItems * cardW + (#summaryItems - 1) * gap
    local startX = math.floor((UI.CONTENT_W - totalW) / 2)
    local summaryCards = {}

    for i, item in ipairs(summaryItems) do
        local card = CreateFrame("Button", nil, pg)
        card:SetSize(cardW, cardH)
        card:SetPoint("BOTTOMLEFT", pg, "BOTTOMLEFT",
            startX + (i - 1) * (cardW + gap), 52)
        UI.AB(card, C.card, C.border)

        local countFs = card:CreateFontString(nil, "OVERLAY")
        countFs:SetPoint("CENTER", card, "CENTER", 0, 12)
        countFs:SetFont(UI.FONT, 24, "OUTLINE")
        countFs:SetText("|cff4db8ff0|r")
        card._countFs = countFs

        local labelFs = card:CreateFontString(nil, "OVERLAY")
        labelFs:SetPoint("CENTER", card, "CENTER", 0, -14)
        UI.SetFont(labelFs, 13)
        labelFs:SetText("|cff505060" .. item.label .. "|r")

        local arrow = card:CreateFontString(nil, "OVERLAY")
        arrow:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -6, 6)
        UI.SetFont(arrow, 12)
        arrow:SetText("|cff2a2a35→|r")
        arrow:Hide()
        card._arrow = arrow

        local pageName  = item.page
        local itemLabel = item.label
        card:SetScript("OnEnter", function(self)
            self:SetBackdropColor(C.cardHover[1], C.cardHover[2], C.cardHover[3])
            self:SetBackdropBorderColor(C.accent[1], C.accent[2], C.accent[3], 0.5)
            labelFs:SetTextColor(C.textBright[1], C.textBright[2], C.textBright[3])
            arrow:SetText("|cff4db8ff→|r")
            arrow:Show()
        end)
        card:SetScript("OnLeave", function(self)
            self:SetBackdropColor(C.card[1], C.card[2], C.card[3])
            self:SetBackdropBorderColor(C.border[1], C.border[2], C.border[3], C.border[4])
            labelFs:SetText("|cff505060" .. itemLabel .. "|r")
            labelFs:SetTextColor(1, 1, 1)
            arrow:Hide()
        end)
        card:SetScript("OnClick", function()
            PlaySound(882)
            AuraHub.UI.ShowPage(pageName)
        end)

        summaryCards[i] = { card = card, item = item }
    end

    local function RefreshCounts()
        for _, sc in ipairs(summaryCards) do
            local n = sc.item.fn()
            sc.card._countFs:SetText(
                n > 0 and ("|cff4db8ff" .. n .. "|r") or "|cff333340—|r"
            )
        end
    end

    local hint = pg:CreateFontString(nil, "OVERLAY")
    hint:SetPoint("BOTTOM", pg, "BOTTOM", 0, 16)
    UI.SetFont(hint, 12)
    hint:SetText(L["MAIN_HINT"])

    pg:SetScript("OnShow", RefreshCounts)
    AuraHub.UI.pages["Main"] = pg
    pg:Hide()
end

AuraHub.Pages.Main.Build = Build
