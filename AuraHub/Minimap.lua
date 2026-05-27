-- AuraHub — Minimap.lua
-- Minimap button created at file-load time (same pattern as TrufiGCD).

local minimapShapes = {
    ["ROUND"]                 = {true,  true,  true,  true },
    ["SQUARE"]                = {false, false, false, false},
    ["CORNER-TOPLEFT"]        = {true,  false, false, false},
    ["CORNER-TOPRIGHT"]       = {false, false, true,  false},
    ["CORNER-BOTTOMLEFT"]     = {false, true,  false, false},
    ["CORNER-BOTTOMRIGHT"]    = {false, false, false, true },
    ["TRICORNER-TOPLEFT"]     = {true,  true,  true,  false},
    ["TRICORNER-TOPRIGHT"]    = {false, true,  true,  true },
    ["TRICORNER-BOTTOMLEFT"]  = {true,  true,  false, true },
    ["TRICORNER-BOTTOMRIGHT"] = {false, true,  true,  true },
}

local MMBtn = CreateFrame("Button", "AuraHubMinimapBtn", Minimap)
MMBtn:SetWidth(31)
MMBtn:SetHeight(31)
MMBtn:SetFrameStrata("MEDIUM")
MMBtn:SetFrameLevel(8)
MMBtn:RegisterForClicks("anyUp")
MMBtn:RegisterForDrag("LeftButton")
MMBtn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

-- Circular border ring (identical to TrufiGCD)
local mmBorder = MMBtn:CreateTexture(nil, "OVERLAY")
mmBorder:SetSize(53, 53)
mmBorder:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
mmBorder:SetPoint("TOPLEFT")

-- Dark background circle
local mmBg = MMBtn:CreateTexture(nil, "BACKGROUND")
mmBg:SetSize(20, 20)
mmBg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
mmBg:SetPoint("TOPLEFT", 7, -5)

-- Blue icon fill
local mmIcon = MMBtn:CreateTexture(nil, "ARTWORK")
mmIcon:SetSize(20, 20)
mmIcon:SetTexture("Interface\\Buttons\\WHITE8X8")
mmIcon:SetVertexColor(0.12, 0.38, 0.72, 1)
mmIcon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
mmIcon:SetPoint("TOPLEFT", 7, -5)
MMBtn.icon = mmIcon

-- "AH" label
local mmLbl = MMBtn:CreateFontString(nil, "OVERLAY")
mmLbl:SetSize(20, 20)
mmLbl:SetPoint("TOPLEFT", 7, -5)
mmLbl:SetFont("Fonts\\ARIALN.TTF", 8, "OUTLINE")
mmLbl:SetText("|cffe0e0e0AH|r")
mmLbl:SetJustifyH("CENTER")

-- Angle → position on minimap edge (handles round/square/corner shapes)
local function MMBtnSetAngle(angle)
    if AuraHubDB then AuraHubDB.minimapAngle = math.deg(angle) end
    local x, y = math.cos(angle), math.sin(angle)
    local q = 1
    if x < 0 then q = q + 1 end
    if y > 0 then q = q + 2 end
    local shape = GetMinimapShape and GetMinimapShape() or "ROUND"
    local quad  = minimapShapes[shape]
    if quad and quad[q] then
        x, y = x * 80, y * 80
    else
        local r = 103.13708498985
        x = math.max(-80, math.min(x * r, 80))
        y = math.max(-80, math.min(y * r, 80))
    end
    MMBtn:ClearAllPoints()
    MMBtn:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

-- Drag to reposition
MMBtn:SetScript("OnDragStart", function(self)
    self:LockHighlight()
    mmIcon:SetTexCoord(0, 1, 0, 1)
    self:SetScript("OnUpdate", function()
        local mx, my = Minimap:GetCenter()
        local cx, cy = GetCursorPosition()
        local s      = Minimap:GetEffectiveScale()
        MMBtnSetAngle(math.atan2(cy / s - my, cx / s - mx))
    end)
end)
MMBtn:SetScript("OnDragStop", function(self)
    self:SetScript("OnUpdate", nil)
    mmIcon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
    self:UnlockHighlight()
end)

MMBtn:SetScript("OnMouseDown", function() mmIcon:SetTexCoord(0, 1, 0, 1) end)
MMBtn:SetScript("OnMouseUp",   function() mmIcon:SetTexCoord(0.05, 0.95, 0.05, 0.95) end)

MMBtn:SetScript("OnClick", function(self, button)
    if button == "LeftButton" then
        AuraHub.UI.Toggle()
    end
end)

MMBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText("|cff4db8ffAuraHub|r", 1, 1, 1)
    GameTooltip:AddLine("Click to open/close", 0.7, 0.7, 0.7)
    GameTooltip:AddLine("Drag to reposition", 0.7, 0.7, 0.7)
    GameTooltip:Show()
end)
MMBtn:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- Default position; Core.Init() will override with the saved angle
MMBtnSetAngle(math.pi * 1.25)

-- Expose setter so Core.Init() can restore saved angle after AuraHubDB loads
AuraHub.Minimap = { SetAngle = function(deg) MMBtnSetAngle(math.rad(deg)) end }
