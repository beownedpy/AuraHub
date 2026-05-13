
-- AuraHub — Helpers.lua
-- Shared utility functions. Loaded first — no addon dependencies.

AuraHub = AuraHub or {}
AuraHub.Helpers = {}

local H = AuraHub.Helpers

-- Deep copy a value (table-safe, no metatable inheritance)

function H.DeepCopy(orig)
    if type(orig) ~= "table" then return orig end
    local copy = {}
    for k, v in pairs(orig) do
        copy[H.DeepCopy(k)] = H.DeepCopy(v)
    end
    return copy
end

-- Trim leading/trailing whitespace from a string

function H.Trim(s)
    return (s or ""):match("^%s*(.-)%s*$")
end

-- Format a Unix timestamp → "YYYY-MM-DD HH:MM"

function H.FormatTime(ts)
    if not ts then return "—" end
    return date("%Y-%m-%d  %H:%M", ts)
end

-- Human-readable "time ago" from a Unix timestamp

function H.TimeAgo(ts)
    local L = AuraHub.L
    if not ts then return L["TIME_UNKNOWN"] end
    local d = time() - ts
    if d < 60    then return L["TIME_JUST_NOW"]
    elseif d < 3600  then return L["TIME_AGO_MIN"]:format(math.floor(d / 60))
    elseif d < 86400 then return L["TIME_AGO_HOUR"]:format(math.floor(d / 3600))
    else return L["TIME_AGO_DAY"]:format(math.floor(d / 86400))
    end
end

-- Slavic-aware plural selector.
-- Pass two forms for English (one, many), three for Russian (one, few, many).

function H.Plural(n, one, few, many)
    if not many then
        return n == 1 and one or few
    end
    local m    = n % 10
    local m100 = n % 100
    if m == 1 and m100 ~= 11 then return one
    elseif m >= 2 and m <= 4 and (m100 < 10 or m100 >= 20) then return few
    else return many
    end
end

-- Count entries in any table (pairs)

function H.Count(t)
    local n = 0
    for _ in pairs(t or {}) do n = n + 1 end
    return n
end

-- Print to default chat frame with AuraHub prefix

function H.Print(msg, color)
    color = color or "cccccc"
    DEFAULT_CHAT_FRAME:AddMessage(
        "|cff4db8ffAuraHub|r |c" .. "ff" .. color .. msg .. "|r"
    )
end

function H.Err(msg)
    H.Print(msg, "ff4444")
end

-- Serialize — converts a table to a Lua-literal string (for file writing)

function H.Serialize(val)
    local function s(v, seen)
        local t = type(v)
        if t == "string" then
            return string.format("%q", v)
        elseif t == "number" then
            if v ~= v          then return "(0/0)"  end
            if v ==  math.huge then return "(1/0)"  end
            if v == -math.huge then return "(-1/0)" end
            return tostring(v)
        elseif t == "boolean" then
            return v and "true" or "false"
        elseif t == "table" then
            if seen[v] then return "nil" end
            seen[v] = true
            local parts = {}
            local n, count = #v, 0
            for _ in pairs(v) do count = count + 1 end
            if count == n and n > 0 then
                for i = 1, n do parts[i] = s(v[i], seen) end
            else
                for k, v2 in pairs(v) do
                    local key = (type(k) == "string" and k:match("^[%a_][%w_]*$"))
                        and (k .. "=")
                        or ("[" .. s(k, seen) .. "]=")
                    parts[#parts + 1] = key .. s(v2, seen)
                end
            end
            seen[v] = nil
            return "{" .. table.concat(parts, ",") .. "}"
        else
            return "nil"
        end
    end
    return s(val, {})
end
