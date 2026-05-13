-- AuraHub — WeakAuras.lua
-- Reads live data from the WeakAuras addon.
-- Namespace: AuraHub.WA
--
-- Supports multiple WA database layouts used by different WotLK builds:
--   1. WeakAuras.db.profile.displays  (WA2 with AceDB, profile scope)
--   2. WeakAuras.db.global.displays   (WA2 with AceDB, global scope)
--   3. WeakAurasData                  (older/forked versions, direct global)

AuraHub.WA = {}

local WA = AuraHub.WA

-- GetDisplaysTable
-- Tries each known DB layout and returns the displays table, or nil.

local function GetDisplaysTable()  -- also exposed as WA.GetDisplaysTable below
    -- Layout 1: AceDB profile scope (WA2 standard)
    if WeakAuras
    and WeakAuras.db
    and WeakAuras.db.profile
    and type(WeakAuras.db.profile.displays) == "table" then
        return WeakAuras.db.profile.displays
    end

    -- Layout 2: AceDB global scope
    if WeakAuras
    and WeakAuras.db
    and WeakAuras.db.global
    and type(WeakAuras.db.global.displays) == "table" then
        return WeakAuras.db.global.displays
    end

    -- Layout 3: WeakAurasSaved (WA2 WotLK port — db is set up late or skipped)
    if type(WeakAurasSaved) == "table" then
        if type(WeakAurasSaved.displays) == "table" then
            return WeakAurasSaved.displays
        end
    end

    -- Layout 4: WeakAurasData direct global
    if type(WeakAurasData) == "table" then
        if type(WeakAurasData.displays) == "table" then
            return WeakAurasData.displays
        end
        local first = next(WeakAurasData)
        if first and type(WeakAurasData[first]) == "table"
        and WeakAurasData[first].regionType ~= nil then
            return WeakAurasData
        end
    end

    return nil
end

-- IsReady

WA.GetDisplaysTable = GetDisplaysTable

function WA.IsReady()
    return WeakAuras ~= nil and GetDisplaysTable() ~= nil
end

-- GetAllDisplays
-- Returns a sorted array of top-level WA displays (groups and standalone).
-- Each entry: { id, name, regionType, childCount }

function WA.GetAllDisplays()
    local all = GetDisplaysTable()
    if not all then return {} end

    local childCount = {}
    for _, data in pairs(all) do
        if type(data) == "table" and data.parent then
            childCount[data.parent] = (childCount[data.parent] or 0) + 1
        end
    end

    local result = {}
    for id, data in pairs(all) do
        if type(data) == "table" and not data.parent then
            result[#result + 1] = {
                id         = id,
                name       = data.id or id,
                regionType = data.regionType or "unknown",
                childCount = childCount[id] or 0,
            }
        end
    end

    table.sort(result, function(a, b)
        return (a.name or "") < (b.name or "")
    end)

    return result
end

-- CaptureDisplay
-- Returns: array of display tables (root at [1], children at [2..n])
--          nil, errMsg  on failure

function WA.CaptureDisplay(id)
    local all = GetDisplaysTable()
    if not all then
        return nil, "WeakAuras is not loaded or database not ready."
    end

    local root = all[id]
    if not root then
        return nil, "Display '" .. tostring(id) .. "' not found."
    end

    local DC = AuraHub.Helpers.DeepCopy

    -- Build a parent→children map for the entire DB (one pass)
    local childrenOf = {}
    for _, data in pairs(all) do
        if type(data) == "table" and data.parent then
            local p = data.parent
            childrenOf[p] = childrenOf[p] or {}
            childrenOf[p][#childrenOf[p] + 1] = data
        end
    end

    local displays = {}

    -- Recursive DFS: respects controlledChildren order when present
    local function Collect(node)
        displays[#displays + 1] = DC(node)
        local nid = node.id
        if not nid then return end

        local kids = childrenOf[nid]
        if not kids then return end

        if node.controlledChildren and type(node.controlledChildren) == "table" then
            -- ordered pass
            local indexed = {}
            for _, child in ipairs(kids) do indexed[child.id or ""] = child end
            for _, childId in ipairs(node.controlledChildren) do
                if indexed[childId] then
                    Collect(indexed[childId])
                    indexed[childId] = nil
                end
            end
            -- any leftover not listed in controlledChildren
            for _, child in pairs(indexed) do Collect(child) end
        else
            table.sort(kids, function(a, b) return (a.id or "") < (b.id or "") end)
            for _, child in ipairs(kids) do Collect(child) end
        end
    end

    Collect(root)
    return displays, nil
end

-- DebugDB — prints detected DB layout to chat (use /aurahub debug)

function WA.DebugDB()
    local H = AuraHub.Helpers
    if not WeakAuras then
        H.Print("WeakAuras global: NIL", "ff4444")
        return
    end
    H.Print("WeakAuras global: OK", "44ff44")

    -- Print top-level keys of WeakAuras to find where data lives
    local keys = {}
    for k, v in pairs(WeakAuras) do
        keys[#keys + 1] = k .. "(" .. type(v) .. ")"
    end
    table.sort(keys)
    -- Print in chunks of 6 to avoid overflow
    for i = 1, #keys, 6 do
        local chunk = {}
        for j = i, math.min(i + 5, #keys) do chunk[#chunk + 1] = keys[j] end
        H.Print("WA keys: " .. table.concat(chunk, "  "), "888888")
    end

    if WeakAuras.db then
        H.Print("WeakAuras.db: OK", "44ff44")
    else
        H.Print("WeakAuras.db: NIL", "ff4444")
    end

    if WeakAurasSaved ~= nil then
        local n = 0
        if type(WeakAurasSaved.displays) == "table" then
            for _ in pairs(WeakAurasSaved.displays) do n = n + 1 end
            H.Print("WeakAurasSaved.displays: " .. n .. " entries", "44ff44")
        else
            H.Print("WeakAurasSaved: exists but .displays=" .. type(WeakAurasSaved.displays), "ff8844")
        end
    else
        H.Print("WeakAurasSaved: NIL", "ff8844")
    end

    if WeakAurasData ~= nil then
        H.Print("WeakAurasData: " .. type(WeakAurasData), "44ff44")
    else
        H.Print("WeakAurasData: NIL", "ff8844")
    end

    local tbl = GetDisplaysTable()
    if tbl then
        local n = 0
        for _ in pairs(tbl) do n = n + 1 end
        H.Print("Active path found: " .. n .. " display(s)", "44ff44")
    else
        H.Print("No valid displays table found!", "ff4444")
    end
end
