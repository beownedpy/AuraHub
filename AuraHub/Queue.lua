-- AuraHub — Queue.lua
-- Stage multiple restore items from different pages, apply all with one reload.

AuraHub.Queue = {}
local Q = AuraHub.Queue

Q._items = {}
Q._bar   = nil

-- Data

function Q.Add(itemType, entry, label)
    for _, item in ipairs(Q._items) do
        if item.type == itemType and item.entry == entry then
            AuraHub.Helpers.Err("'" .. label .. "' is already in the queue.")
            return false
        end
    end
    table.insert(Q._items, { type = itemType, entry = entry, label = label })
    Q._UpdateBar()
    AuraHub.Helpers.Print("'" .. label .. "' added to load queue  (" .. #Q._items .. " total).")
    return true
end

function Q.Remove(index)
    table.remove(Q._items, index)
    Q._UpdateBar()
end

function Q.Clear()
    Q._items = {}
    Q._UpdateBar()
end

function Q.Count()
    return #Q._items
end

function Q.ApplyAll()
    if #Q._items == 0 then return end

    for _, item in ipairs(Q._items) do
        if item.type == "WA" then
            AuraHub.Importer.RestoreWA(item.entry, true)
        elseif item.type == "ElvUI" then
            AuraHub.Importer.RestoreElvUI(item.entry, true)
        elseif item.type == "Skada" then
            AuraHub.Importer.RestoreSkada(item.entry, true)
        elseif item.type == "Binds" then
            AuraHub.Importer.RestoreBinds(item.entry)
        elseif item.type == "Macros" then
            AuraHub.Importer.RestoreMacros(item.entry)
        end
    end

    local n = #Q._items
    Q._items = {}
    Q._UpdateBar()
    AuraHub.Helpers.Print(n .. " item(s) applied. Reloading UI...")
    ReloadUI()
end

-- Queue bar UI

function Q._UpdateBar()
    if not Q._bar then return end
    local n = #Q._items
    if n == 0 then
        Q._bar:Hide()
        return
    end
    Q._bar:Show()
    local labels = {}
    for _, item in ipairs(Q._items) do
        labels[#labels + 1] = item.label
    end
    Q._bar._text:SetText(
        "|cff4db8ff" .. n .. " queued:|r  |cffaaaaaa" ..
        table.concat(labels, "  |cff404050·|r  |cffaaaaaa") .. "|r"
    )
end

function Q.BuildBar(parent)
    local UI = AuraHub.UI
    local C  = UI.C
    local mainF = UI.mainFrame

    local bar = CreateFrame("Frame", nil, UIParent)
    bar:SetPoint("TOPLEFT",  mainF, "BOTTOMLEFT",  1, -2)
    bar:SetPoint("TOPRIGHT", mainF, "BOTTOMRIGHT", -1, -2)
    bar:SetHeight(42)
    bar:SetFrameStrata("HIGH")
    UI.AB(bar, { 0.04, 0.09, 0.17, 0.97 }, { 0.20, 0.42, 0.72, 1 })

    local applyBtn = UI.CreateSaveButton(bar, "Apply & Reload", 138, 30, Q.ApplyAll)
    applyBtn:SetPoint("RIGHT", bar, "RIGHT", -8, 0)

    local clearBtn = UI.CreateDeleteButton(bar, "Clear", 60, 30, Q.Clear)
    clearBtn:SetPoint("RIGHT", applyBtn, "LEFT", -6, 0)

    local text = bar:CreateFontString(nil, "OVERLAY")
    text:SetPoint("LEFT",  bar, "LEFT",  12, 0)
    text:SetPoint("RIGHT", clearBtn, "LEFT", -10, 0)
    UI.SetFont(text, 13)
    text:SetJustifyH("LEFT")

    Q._bar       = bar
    Q._bar._text = text
    bar:Hide()
    return bar
end
