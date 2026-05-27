-- AuraHub — UI.lua
-- Main frame, navigation system, shared widget factories.
AuraHub.UI = {}

local UI = AuraHub.UI
-- Layout constants
local FW = 913
local FH = 640
local HH = 52   -- header height
local NH = 38   -- nav bar height

UI.FRAME_W   = FW
UI.FRAME_H   = FH
UI.CONTENT_W = FW
UI.CONTENT_H = FH - HH - NH   -- 550 (640-52-38)

-- Arial Narrow — built into every WoW 3.3.5a client, narrow sans-serif.
-- Swap to PTSansNarrow.ttf path when that file is available.
UI.FONT = "Fonts\\ARIALN.TTF"
-- Color palette
UI.C = {
    bg         = { 0.07, 0.07, 0.08, 0.97 },
    header     = { 0.04, 0.04, 0.05, 1.00 },
    nav        = { 0.09, 0.09, 0.10, 1.00 },
    navActive  = { 0.12, 0.38, 0.72, 1.00 },
    navHover   = { 0.15, 0.15, 0.17, 1.00 },
    border     = { 0.20, 0.20, 0.22, 1.00 },
    borderDim  = { 0.12, 0.12, 0.14, 1.00 },
    card       = { 0.11, 0.11, 0.13, 1.00 },
    cardAlt    = { 0.09, 0.09, 0.11, 1.00 },
    cardHover  = { 0.18, 0.18, 0.22, 1.00 },
    btn        = { 0.13, 0.13, 0.15, 1.00 },
    btnHover   = { 0.22, 0.22, 0.26, 1.00 },
    btnSave    = { 0.12, 0.35, 0.12, 1.00 },
    btnSaveHov = { 0.18, 0.50, 0.18, 1.00 },
    btnRed     = { 0.35, 0.08, 0.08, 1.00 },
    btnRedHov  = { 0.55, 0.10, 0.10, 1.00 },
    text       = { 0.82, 0.82, 0.84, 1.00 },
    textBright = { 1.00, 1.00, 1.00, 1.00 },
    textDim    = { 0.44, 0.44, 0.48, 1.00 },
    accent     = { 0.36, 0.66, 1.00, 1.00 },
    scrollBar  = { 0.30, 0.55, 0.90, 0.65 },
}

local C = UI.C
-- Backdrop helper
local _BD = {
    bgFile   = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
}

function UI.AB(frame, bg, border)
    frame:SetBackdrop(_BD)
    bg = bg or C.bg
    frame:SetBackdropColor(bg[1], bg[2], bg[3], bg[4] or 1)
    border = border or C.border
    frame:SetBackdropBorderColor(border[1], border[2], border[3], border[4] or 1)
end

local AB = UI.AB
-- Font helper — applies UI.FONT to any font string
function UI.SetFont(fs, size, flags)
    fs:SetFont(UI.FONT, size or 15, flags or "")
end
-- CreateButton
function UI.CreateButton(parent, text, w, h, bg, bgHover, onClick)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(w or 120, h or 30)
    AB(btn, bg or C.btn, C.border)

    local lbl = btn:CreateFontString(nil, "OVERLAY")
    lbl:SetAllPoints()
    UI.SetFont(lbl, 15)
    lbl:SetText(text or "")
    lbl:SetTextColor(C.text[1], C.text[2], C.text[3])
    btn.label = lbl

    local _bg    = bg    or C.btn
    local _bgHov = bgHover or C.btnHover

    btn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(_bgHov[1], _bgHov[2], _bgHov[3], _bgHov[4] or 1)
        lbl:SetTextColor(C.textBright[1], C.textBright[2], C.textBright[3])
    end)
    btn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(_bg[1], _bg[2], _bg[3], _bg[4] or 1)
        lbl:SetTextColor(C.text[1], C.text[2], C.text[3])
    end)
    btn:SetScript("OnClick", function(self)
        PlaySound(882)
        if onClick then onClick(self) end
    end)

    return btn
end

function UI.CreateMenuButton(parent, text, w, h, onClick)
    return UI.CreateButton(parent, text, w, h, C.btn, C.btnHover, onClick)
end

function UI.CreateSaveButton(parent, text, w, h, onClick)
    return UI.CreateButton(parent, text, w, h, C.btnSave, C.btnSaveHov, onClick)
end

function UI.CreateDeleteButton(parent, text, w, h, onClick)
    return UI.CreateButton(parent, text, w, h, C.btnRed, C.btnRedHov, onClick)
end

function UI.CreateQueueButton(parent, onClick)
    return UI.CreateButton(parent, "+Q", 32, 28,
        { 0.08, 0.22, 0.42, 1 }, { 0.14, 0.34, 0.62, 1 }, onClick)
end
-- CreateScrollArea — full-width content, invisible scrollbar (wheel-only)
function UI.CreateScrollArea(parent, x, y, w, h)
    local sf = CreateFrame("ScrollFrame", nil, parent)
    sf:SetPoint("TOPLEFT", parent, "TOPLEFT", x, -y)
    sf:SetSize(w, h)
    sf:EnableMouseWheel(true)

    local sc = CreateFrame("Frame", nil, sf)
    sc:SetSize(w, 1)
    sf:SetScrollChild(sc)
    sf:SetVerticalScroll(0)

    sf:SetScript("OnMouseWheel", function(self, delta)
        local cur = self:GetVerticalScroll()
        local max = self:GetVerticalScrollRange()
        self:SetVerticalScroll(math.max(0, math.min(max, cur - delta * 32)))
        if max > 0 and self._sb then
            self._sb:SetValue(self:GetVerticalScroll() / max)
        end
    end)

    -- Functional but invisible slider: required for scroll sync, no visual track
    local sbF = CreateFrame("Frame", nil, sf)
    sbF:SetPoint("TOPRIGHT",    sf, "TOPRIGHT",    0, 0)
    sbF:SetPoint("BOTTOMRIGHT", sf, "BOTTOMRIGHT", 0, 0)
    sbF:SetWidth(1)

    local sb = CreateFrame("Slider", nil, sbF)
    sb:SetOrientation("VERTICAL")
    sb:SetAllPoints(sbF)
    sb:SetMinMaxValues(0, 1)
    sb:SetValue(0)
    sb:SetValueStep(0.001)

    local thumb = sb:CreateTexture(nil, "OVERLAY")
    thumb:SetSize(1, 1)
    thumb:SetAlpha(0)
    sb:SetThumbTexture(thumb)

    sb:SetScript("OnValueChanged", function(self, val)
        local max = sf:GetVerticalScrollRange()
        if max > 0 then sf:SetVerticalScroll(val * max) end
    end)
    sf:SetScript("OnVerticalScroll", function(self, offset)
        local max = self:GetVerticalScrollRange()
        if max > 0 then sb:SetValue(offset / max) end
    end)

    sbF:EnableMouseWheel(true)
    sbF:SetScript("OnMouseWheel", function(_, d) sf:GetScript("OnMouseWheel")(sf, d) end)

    sf._sb = sb
    return sf, sc
end
-- Divider line
function UI.CreateDivider(parent, yOffset, alpha)
    local t = parent:CreateTexture(nil, "ARTWORK")
    t:SetPoint("TOPLEFT",  parent, "TOPLEFT",  0, -yOffset)
    t:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, -yOffset)
    t:SetHeight(1)
    t:SetTexture("Interface\\Buttons\\WHITE8X8")
    t:SetVertexColor(C.border[1], C.border[2], C.border[3], alpha or C.border[4])
    return t
end
-- Navigation
UI.pages     = {}
UI.navBtns   = {}
UI.navBtnMap = {}

function UI.ShowPage(name)
    for _, pg in pairs(UI.pages)    do pg:Hide() end
    for _, nb in ipairs(UI.navBtns) do nb:_setActive(false) end
    if UI.pages[name]     then UI.pages[name]:Show()               end
    if UI.navBtnMap[name] then UI.navBtnMap[name]:_setActive(true) end
    UI.currentPage = name
end
-- Build
function UI.Build()
    -- Root frame
    local f = CreateFrame("Frame", "AuraHubFrame", UIParent)
    f:SetSize(FW, FH)
    f:SetPoint("CENTER")
    f:SetFrameStrata("HIGH")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:SetClampedToScreen(true)
    AB(f, C.bg, C.border)
    table.insert(UISpecialFrames, "AuraHubFrame")
    UI.mainFrame = f

    -- Header
    local header = CreateFrame("Frame", nil, f)
    header:SetPoint("TOPLEFT"); header:SetPoint("TOPRIGHT"); header:SetHeight(HH)
    AB(header, C.header, C.border)
    header:EnableMouse(true)
    header:SetScript("OnMouseDown", function(_, b) if b == "LeftButton" then f:StartMoving() end end)
    header:SetScript("OnMouseUp",   function()     f:StopMovingOrSizing() end)

    local titleFs = header:CreateFontString(nil, "OVERLAY")
    titleFs:SetPoint("LEFT", header, "LEFT", 14, 2)
    titleFs:SetFont(UI.FONT, 22, "OUTLINE")
    titleFs:SetText("|cff4db8ffAura|r|cffe0e0e0Hub|r")

    local metaFs = header:CreateFontString(nil, "OVERLAY")
    metaFs:SetPoint("LEFT", titleFs, "RIGHT", 10, -1)
    UI.SetFont(metaFs, 13)
    metaFs:SetText("|cff353540v" .. AuraHub.VERSION .. "  ·  Personal UI Backup & Restore|r")

    -- Close button
    local cBtn = CreateFrame("Button", nil, header)
    cBtn:SetSize(22, 22)
    cBtn:SetPoint("RIGHT", header, "RIGHT", -10, 0)
    AB(cBtn, { 0.28, 0.07, 0.07, 1 }, { 0.45, 0.10, 0.10, 1 })
    local cX = cBtn:CreateFontString(nil, "OVERLAY")
    cX:SetAllPoints()
    UI.SetFont(cX, 14)
    cX:SetText("X")
    cX:SetTextColor(0.85, 0.35, 0.35)
    cBtn:SetScript("OnClick",  function()     f:Hide() end)
    cBtn:SetScript("OnEnter",  function(self) self:SetBackdropColor(0.55, 0.10, 0.10, 1); cX:SetTextColor(1, 0.55, 0.55) end)
    cBtn:SetScript("OnLeave",  function(self) self:SetBackdropColor(0.28, 0.07, 0.07, 1); cX:SetTextColor(0.85, 0.35, 0.35) end)

    -- Nav bar
    local nav = CreateFrame("Frame", nil, f)
    nav:SetPoint("TOPLEFT",  header, "BOTTOMLEFT")
    nav:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT")
    nav:SetHeight(NH)
    AB(nav, C.nav, C.border)

    local navAcc = nav:CreateTexture(nil, "ARTWORK")
    navAcc:SetPoint("BOTTOMLEFT",  nav, "BOTTOMLEFT",  0, 0)
    navAcc:SetPoint("BOTTOMRIGHT", nav, "BOTTOMRIGHT", 0, 0)
    navAcc:SetHeight(1)
    navAcc:SetTexture("Interface\\Buttons\\WHITE8X8")
    navAcc:SetVertexColor(C.accent[1], C.accent[2], C.accent[3], 0.20)

    local L = AuraHub.L
    local navDefs = {
        { id = "Main",       label = L["NAV_HOME"]      },
        { id = "WeakAuras",  label = L["NAV_WEAKAURAS"] },
        { id = "ElvUI",      label = L["NAV_ELVUI"]     },
        { id = "Skada",      label = L["NAV_SKADA"]     },
        { id = "DBM",        label = L["NAV_DBM"]       },
        { id = "Binds",      label = L["NAV_BINDS"]     },
        { id = "Macros",     label = L["NAV_MACROS"]    },
        { id = "ActionBars", label = L["NAV_BARS"]      },
        { id = "Help",       label = L["NAV_HELP"]      },
    }

    local BTN_GAP  = 6
    local BTN_W    = math.floor((FW - 28 - (#navDefs - 1) * BTN_GAP) / #navDefs)
    local actualW  = #navDefs * BTN_W + (#navDefs - 1) * BTN_GAP
    local navX     = math.floor((FW - actualW) / 2)

    for _, def in ipairs(navDefs) do
        local nb = CreateFrame("Button", nil, nav)
        nb:SetSize(BTN_W, NH - 4)
        nb:SetPoint("LEFT", nav, "LEFT", navX, 0)
        AB(nb, C.nav, { 0, 0, 0, 0 })

        local nlbl = nb:CreateFontString(nil, "OVERLAY")
        nlbl:SetAllPoints()
        UI.SetFont(nlbl, 15)
        nlbl:SetText(def.label)
        nlbl:SetTextColor(C.text[1], C.text[2], C.text[3])
        nb.label  = nlbl
        nb.pageId = def.id

        local bar = nb:CreateTexture(nil, "OVERLAY")
        bar:SetPoint("BOTTOMLEFT",  nb, "BOTTOMLEFT",  2, 0)
        bar:SetPoint("BOTTOMRIGHT", nb, "BOTTOMRIGHT", -2, 0)
        bar:SetHeight(2)
        bar:SetTexture("Interface\\Buttons\\WHITE8X8")
        bar:SetVertexColor(C.accent[1], C.accent[2], C.accent[3], 1)
        bar:Hide()

        function nb:_setActive(v)
            self._active = v
            if v then
                self:SetBackdropColor(C.navActive[1], C.navActive[2], C.navActive[3])
                nlbl:SetTextColor(C.textBright[1], C.textBright[2], C.textBright[3])
                bar:Show()
            else
                self:SetBackdropColor(C.nav[1], C.nav[2], C.nav[3])
                nlbl:SetTextColor(C.text[1], C.text[2], C.text[3])
                bar:Hide()
            end
        end

        nb:SetScript("OnEnter", function(self)
            if not self._active then
                self:SetBackdropColor(C.navHover[1], C.navHover[2], C.navHover[3])
                nlbl:SetTextColor(C.textBright[1], C.textBright[2], C.textBright[3])
            end
        end)
        nb:SetScript("OnLeave", function(self)
            if not self._active then
                self:SetBackdropColor(C.nav[1], C.nav[2], C.nav[3])
                nlbl:SetTextColor(C.text[1], C.text[2], C.text[3])
            end
        end)
        nb:SetScript("OnClick", function() UI.ShowPage(def.id) end)

        table.insert(UI.navBtns, nb)
        UI.navBtnMap[def.id] = nb
        navX = navX + BTN_W + BTN_GAP
    end

    -- Content area
    local content = CreateFrame("Frame", nil, f)
    content:SetPoint("TOPLEFT",     nav, "BOTTOMLEFT")
    content:SetPoint("BOTTOMRIGHT", f,   "BOTTOMRIGHT")
    AB(content, C.bg, { 0, 0, 0, 0 })
    UI.contentFrame = content

    -- Build all pages
    AuraHub.Pages.Main.Build(content)
    AuraHub.Pages.WeakAuras.Build(content)
    AuraHub.Pages.ElvUI.Build(content)
    AuraHub.Pages.Skada.Build(content)
    AuraHub.Pages.DBM.Build(content)
    AuraHub.Pages.Binds.Build(content)
    AuraHub.Pages.Macros.Build(content)
    AuraHub.Pages.ActionBars.Build(content)
    AuraHub.Pages.Help.Build(content)

    AuraHub.Queue.BuildBar(content)

    UI.ShowPage("Main")
    f:Hide()
end

function UI.Toggle()
    if UI.mainFrame then
        if UI.mainFrame:IsShown() then UI.mainFrame:Hide() else UI.mainFrame:Show() end
    end
end
