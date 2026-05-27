-- AuraHub — Pages\Help.lua
-- About & contact information.

AuraHub.Pages = AuraHub.Pages or {}
AuraHub.Pages.Help = {}

-- Multi-account sync dialog (moved from Main.lua)

local _syncDlg

local function BuildSyncDialog(C, UI)
    local L   = AuraHub.L
    local DW, DH = 520, 460
    local PAD = 14
    local BTNH = 46

    local d = CreateFrame("Frame", "AuraHubSyncDlg", UIParent)
    d:SetSize(DW, DH)
    d:SetPoint("CENTER")
    d:SetFrameStrata("DIALOG")
    d:SetMovable(true); d:EnableMouse(true); d:SetClampedToScreen(true)
    UI.AB(d, { 0.06, 0.06, 0.07, 0.98 }, { 0.28, 0.28, 0.32, 1 })
    table.insert(UISpecialFrames, "AuraHubSyncDlg")

    local hdr = CreateFrame("Frame", nil, d)
    hdr:SetPoint("TOPLEFT"); hdr:SetPoint("TOPRIGHT"); hdr:SetHeight(40)
    UI.AB(hdr, { 0.04, 0.04, 0.05, 1 }, { 0.28, 0.28, 0.32, 1 })
    hdr:EnableMouse(true)
    hdr:SetScript("OnMouseDown", function(_, b) if b == "LeftButton" then d:StartMoving() end end)
    hdr:SetScript("OnMouseUp",   function() d:StopMovingOrSizing() end)

    local titleFs = hdr:CreateFontString(nil, "OVERLAY")
    titleFs:SetPoint("LEFT", hdr, "LEFT", 14, 0)
    UI.SetFont(titleFs, 16)
    titleFs:SetText(L["SYNC_TITLE"])

    local closeBtn = CreateFrame("Button", nil, hdr)
    closeBtn:SetSize(20, 20); closeBtn:SetPoint("RIGHT", hdr, "RIGHT", -8, 0)
    UI.AB(closeBtn, { 0.28, 0.07, 0.07, 1 }, { 0.45, 0.10, 0.10, 1 })
    local cX = closeBtn:CreateFontString(nil, "OVERLAY")
    cX:SetAllPoints()
    UI.SetFont(cX, 14)
    cX:SetText("X")
    cX:SetTextColor(0.85, 0.35, 0.35)
    closeBtn:SetScript("OnClick",  function()     d:Hide() end)
    closeBtn:SetScript("OnEnter",  function(self) self:SetBackdropColor(0.55, 0.10, 0.10, 1); cX:SetTextColor(1, 0.55, 0.55) end)
    closeBtn:SetScript("OnLeave",  function(self) self:SetBackdropColor(0.28, 0.07, 0.07, 1); cX:SetTextColor(0.85, 0.35, 0.35) end)

    local sfH = DH - 40 - BTNH
    local sf, sc = UI.CreateScrollArea(d, 0, 40, DW, sfH)
    sc:SetWidth(DW - 20)

    local cy = PAD

    local function Row(text, size, color, extraPad)
        local fs = sc:CreateFontString(nil, "OVERLAY")
        fs:SetPoint("TOPLEFT",  sc, "TOPLEFT",  PAD, -cy)
        fs:SetPoint("TOPRIGHT", sc, "TOPRIGHT", -PAD, -cy)
        fs:SetJustifyH("LEFT")
        fs:SetNonSpaceWrap(true)
        UI.SetFont(fs, size == "GameFontNormal" and 15 or 13)
        if color then fs:SetTextColor(color[1], color[2], color[3]) end
        fs:SetText(text)
        local lines = 1
        for _ in text:gmatch("\n") do lines = lines + 1 end
        cy = cy + lines * 14 + (extraPad or 6)
        return fs
    end

    local function Divider()
        local t = sc:CreateTexture(nil, "ARTWORK")
        t:SetPoint("TOPLEFT",  sc, "TOPLEFT",  PAD, -cy)
        t:SetPoint("TOPRIGHT", sc, "TOPRIGHT", -PAD, -cy)
        t:SetHeight(1)
        t:SetTexture("Interface\\Buttons\\WHITE8X8")
        t:SetVertexColor(C.border[1], C.border[2], C.border[3], 0.4)
        cy = cy + 10
    end

    local function Box(text)
        local bg = CreateFrame("Frame", nil, sc)
        bg:SetPoint("TOPLEFT",  sc, "TOPLEFT",  PAD,  -cy)
        bg:SetPoint("TOPRIGHT", sc, "TOPRIGHT", -PAD, -cy)
        UI.AB(bg, { 0.04, 0.04, 0.06, 1 }, { 0.20, 0.20, 0.25, 1 })

        local fs = bg:CreateFontString(nil, "OVERLAY")
        fs:SetPoint("TOPLEFT",  bg, "TOPLEFT",  8, -6)
        fs:SetPoint("TOPRIGHT", bg, "TOPRIGHT", -8, -6)
        fs:SetJustifyH("LEFT")
        fs:SetNonSpaceWrap(true)
        UI.SetFont(fs, 13)
        fs:SetTextColor(0.4, 0.75, 1)
        fs:SetText(text)

        local lines = 1
        for _ in text:gmatch("\n") do lines = lines + 1 end
        local bh = lines * 16 + 14
        bg:SetHeight(bh)
        cy = cy + bh + 8
    end

    Row(L["SYNC_HOW_TITLE"], "GameFontNormal", nil, 4)
    Row(L["SYNC_HOW_TEXT"], nil, { 0.6, 0.6, 0.6 }, 10)
    Divider()
    Row(L["SYNC_S1_TITLE"], "GameFontNormal", nil, 4)
    Row(L["SYNC_S1_TEXT"], nil, { 0.6, 0.6, 0.6 }, 10)
    Divider()
    Row(L["SYNC_S2_TITLE"], "GameFontNormal", nil, 4)
    Row(L["SYNC_S2_TEXT"], nil, { 0.6, 0.6, 0.6 }, 10)
    Divider()
    Row(L["SYNC_S3_TITLE"], "GameFontNormal", nil, 4)
    Row(L["SYNC_S3_TEXT"], nil, { 0.6, 0.6, 0.6 }, 6)
    Box(L["SYNC_S3_BOX"])
    Row(L["SYNC_S3_TEXT2"], nil, { 0.6, 0.6, 0.6 }, 10)
    Divider()
    Row(L["SYNC_S4_TITLE"], "GameFontNormal", nil, 4)
    Row(L["SYNC_S4_TEXT"], nil, { 0.6, 0.6, 0.6 }, 10)
    Divider()
    Row(L["SYNC_REPEAT"], nil, nil, 8)

    sc:SetHeight(cy + PAD)

    local okBtn = UI.CreateMenuButton(d, L["SYNC_GOT_IT"], 90, 30, function() d:Hide() end)
    okBtn:SetPoint("BOTTOMRIGHT", d, "BOTTOMRIGHT", -12, 8)

    d:Hide()
    return d
end

local function ShowSyncDlg(C, UI)
    if not _syncDlg then _syncDlg = BuildSyncDialog(C, UI) end
    _syncDlg:Show()
end

-- Build

local function Build(parent)
    local UI = AuraHub.UI
    local C  = UI.C
    local L  = AuraHub.L

    local pg = CreateFrame("Frame", nil, parent)
    pg:SetAllPoints(parent)
    UI.AB(pg, C.bg, { 0, 0, 0, 0 })

    local title = pg:CreateFontString(nil, "OVERLAY")
    title:SetPoint("TOPLEFT", pg, "TOPLEFT", 14, -24)
    UI.SetFont(title, 20)
    title:SetText(L["HELP_TITLE"])
    title:SetTextColor(C.textBright[1], C.textBright[2], C.textBright[3])

    local sep = pg:CreateTexture(nil, "ARTWORK")
    sep:SetPoint("TOPLEFT",  pg, "TOPLEFT",  0, -52)
    sep:SetPoint("TOPRIGHT", pg, "TOPRIGHT", 0, -52)
    sep:SetHeight(1)
    sep:SetTexture("Interface\\Buttons\\WHITE8X8")
    sep:SetVertexColor(C.border[1], C.border[2], C.border[3], C.border[4])

    local scrollH = UI.CONTENT_H - 56
    local sf, sc = UI.CreateScrollArea(pg, 0, 54, UI.CONTENT_W, scrollH)

    local PAD = 14
    local cy  = 12

    -- Author card
    local authorCard = CreateFrame("Frame", nil, sc)
    authorCard:SetPoint("TOPLEFT",  sc, "TOPLEFT",  PAD, -cy)
    authorCard:SetPoint("TOPRIGHT", sc, "TOPRIGHT", -14, -cy)
    authorCard:SetHeight(112)
    UI.AB(authorCard, C.card, C.border)

    local bugText = authorCard:CreateFontString(nil, "OVERLAY")
    bugText:SetPoint("TOPLEFT",     authorCard, "TOPLEFT",     18, -12)
    bugText:SetPoint("BOTTOMRIGHT", authorCard, "BOTTOMRIGHT", -18, 36)
    UI.SetFont(bugText, 13)
    bugText:SetJustifyH("LEFT")
    bugText:SetNonSpaceWrap(true)
    bugText:SetWordWrap(true)
    bugText:SetText(L["HELP_BUG_REPORT"])
    bugText:SetTextColor(C.text[1], C.text[2], C.text[3])

    local discordRow = authorCard:CreateFontString(nil, "OVERLAY")
    discordRow:SetPoint("BOTTOMLEFT", authorCard, "BOTTOMLEFT", 18, 14)
    UI.SetFont(discordRow, 14)
    discordRow:SetText("|cff5865f2Discord:|r  |cffe0e0e0beowned|r")

    cy = cy + 112 + 16

    -- Features title
    local featTitle = sc:CreateFontString(nil, "OVERLAY")
    featTitle:SetPoint("TOPLEFT", sc, "TOPLEFT", PAD, -cy)
    UI.SetFont(featTitle, 16)
    featTitle:SetText(L["HELP_FEAT_TITLE"])
    cy = cy + 22

    local features = {
        { icon = L["HELP_FEAT_WA"],       desc = L["HELP_FEAT_WA_DESC"]       },
        { icon = L["HELP_FEAT_ELVUI"],    desc = L["HELP_FEAT_ELVUI_DESC"]    },
        { icon = L["HELP_FEAT_SKADA"],    desc = L["HELP_FEAT_SKADA_DESC"]    },
        { icon = L["HELP_FEAT_DBM"],      desc = L["HELP_FEAT_DBM_DESC"]      },
        { icon = L["HELP_FEAT_KEYBINDS"], desc = L["HELP_FEAT_KEYBINDS_DESC"] },
        { icon = L["HELP_FEAT_MACROS"],   desc = L["HELP_FEAT_MACROS_DESC"]   },
        { icon = L["HELP_FEAT_BARS"],     desc = L["HELP_FEAT_BARS_DESC"]     },
        { icon = L["HELP_FEAT_MULTI"],    desc = L["HELP_FEAT_MULTI_DESC"]    },
    }

    for _, feat in ipairs(features) do
        local row = CreateFrame("Frame", nil, sc)
        row:SetPoint("TOPLEFT",  sc, "TOPLEFT",  PAD, -cy)
        row:SetPoint("TOPRIGHT", sc, "TOPRIGHT", -14, -cy)
        row:SetHeight(90)
        UI.AB(row, C.cardAlt, C.borderDim)

        local dot = row:CreateFontString(nil, "OVERLAY")
        dot:SetPoint("TOPLEFT", row, "TOPLEFT", 12, -10)
        UI.SetFont(dot, 16)
        dot:SetText("|cff4db8ff•|r")

        local label = row:CreateFontString(nil, "OVERLAY")
        label:SetPoint("TOPLEFT", row, "TOPLEFT", 30, -8)
        UI.SetFont(label, 15)
        label:SetText(feat.icon)
        label:SetTextColor(C.textBright[1], C.textBright[2], C.textBright[3])

        local desc = row:CreateFontString(nil, "OVERLAY")
        desc:SetPoint("TOPLEFT",  row, "TOPLEFT",  30, -28)
        desc:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -10, 8)
        UI.SetFont(desc, 12)
        desc:SetText(feat.desc)
        desc:SetTextColor(C.textDim[1], C.textDim[2], C.textDim[3])
        desc:SetJustifyH("LEFT")
        desc:SetNonSpaceWrap(true)
        desc:SetWordWrap(true)

        cy = cy + 90 + 6
    end

    -- Load Queue section
    cy = cy + 14
    local mlTitle = sc:CreateFontString(nil, "OVERLAY")
    mlTitle:SetPoint("TOPLEFT", sc, "TOPLEFT", PAD, -cy)
    UI.SetFont(mlTitle, 16)
    mlTitle:SetText(L["HELP_QUEUE_TITLE"])
    cy = cy + 24

    local mlDesc = sc:CreateFontString(nil, "OVERLAY")
    mlDesc:SetPoint("TOPLEFT",  sc, "TOPLEFT",  PAD, -cy)
    mlDesc:SetPoint("TOPRIGHT", sc, "TOPRIGHT", -PAD, -cy)
    UI.SetFont(mlDesc, 13)
    mlDesc:SetText(L["HELP_QUEUE_DESC"])
    mlDesc:SetTextColor(C.text[1], C.text[2], C.text[3])
    mlDesc:SetJustifyH("LEFT")
    mlDesc:SetNonSpaceWrap(true)
    cy = cy + 110

    -- Multi-Account button
    cy = cy + 14
    local syncOpenBtn = UI.CreateMenuButton(sc, L["MAIN_BTN_MULTI"], 140, 28, function()
        ShowSyncDlg(C, UI)
    end)
    syncOpenBtn:SetPoint("TOPLEFT", sc, "TOPLEFT", PAD, -cy)
    cy = cy + 40

    -- Version footer
    cy = cy + 10
    local ver = sc:CreateFontString(nil, "OVERLAY")
    ver:SetPoint("TOPLEFT", sc, "TOPLEFT", PAD, -cy)
    UI.SetFont(ver, 12)
    ver:SetText("|cff303040AuraHub v" .. AuraHub.VERSION .. "  ·  WoW 3.3.5a|r")
    cy = cy + 20

    sc:SetHeight(math.max(cy + 12, scrollH))

    AuraHub.UI.pages["Help"] = pg
    pg:Hide()
end

AuraHub.Pages.Help.Build = Build
