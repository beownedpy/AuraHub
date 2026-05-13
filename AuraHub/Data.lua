-- AuraHub — Data.lua
-- CRUD interface for AuraHubDB (SavedVariables).

AuraHub.Data = {}

local D = AuraHub.Data

local DEFAULTS = {
    WeakAuras    = {},
    ElvUI        = {},
    Skada        = {},
    Binds        = {},
    Macros       = {},
    ActionBars   = {},
    _deleted     = {},
    minimapAngle = 220,
}

local function Tombstone(section, name)
    if not name or name == "" then return end
    AuraHubDB._deleted = AuraHubDB._deleted or {}
    AuraHubDB._deleted[section] = AuraHubDB._deleted[section] or {}
    AuraHubDB._deleted[section][name] = time()
end

local function ClearTombstone(section, name)
    if not name or name == "" then return end
    if AuraHubDB._deleted and AuraHubDB._deleted[section] then
        AuraHubDB._deleted[section][name] = nil
    end
end

-- Shared file: inside the addon folder, same path for every WoW account
local SHARED_PATH = "Interface\\AddOns\\AuraHub\\SharedData.lua"
local DATA_KEYS   = { "WeakAuras", "ElvUI", "Skada", "_t" }

-- File I/O helpers — tries every method the client might expose

local function TryWrite(path, content)
    -- 1. Standard Lua io
    if type(io) == "table" and type(io.open) == "function" then
        local ok, f = pcall(io.open, path, "w")
        if ok and f then
            f:write(content)
            f:close()
            return "io"
        end
    end
    -- 2. WriteFile (some private-server clients)
    if type(WriteFile) == "function" then
        local ok = pcall(WriteFile, path, content)
        if ok then return "WriteFile" end
    end
    -- 3. FileWrite (alternate naming)
    if type(FileWrite) == "function" then
        local ok = pcall(FileWrite, path, content)
        if ok then return "FileWrite" end
    end
    -- 4. C_FileUtils (some custom clients)
    if type(C_FileUtils) == "table" and type(C_FileUtils.WriteFile) == "function" then
        local ok = pcall(C_FileUtils.WriteFile, path, content)
        if ok then return "C_FileUtils" end
    end
    -- 5. LibFile shim (some custom Ace3 forks)
    if type(LibFile) == "table" and type(LibFile.Write) == "function" then
        local ok = pcall(LibFile.Write, path, content)
        if ok then return "LibFile" end
    end
    return nil
end

local function TryRead(path)
    if type(io) == "table" and type(io.open) == "function" then
        local ok, f = pcall(io.open, path, "r")
        if ok and f then
            local content = f:read("*a")
            f:close()
            return content
        end
    end
    if type(ReadFile) == "function" then
        local ok, result = pcall(ReadFile, path)
        if ok and result then return result end
    end
    if type(FileRead) == "function" then
        local ok, result = pcall(FileRead, path)
        if ok and result then return result end
    end
    if type(C_FileUtils) == "table" and type(C_FileUtils.ReadFile) == "function" then
        local ok, result = pcall(C_FileUtils.ReadFile, path)
        if ok and result then return result end
    end
    if type(LibFile) == "table" and type(LibFile.Read) == "function" then
        local ok, result = pcall(LibFile.Read, path)
        if ok and result then return result end
    end
    return nil
end

-- Parse a SavedVariables file content and extract AuraHubDB from it safely
local function ParseSavedVars(content)
    if not content or content == "" then return nil end
    local fn = loadstring(content)
    if not fn then return nil end
    -- Run in isolated environment so it doesn't touch real globals
    local env = setmetatable({}, { __index = _G })
    local ok, setOk = pcall(setfenv, fn, env)
    if not ok or not setOk then
        -- setfenv unavailable: run in global scope with a temp global
        local oldDB = AuraHubDB
        AuraHubDB = nil
        pcall(fn)
        local result = AuraHubDB
        AuraHubDB = oldDB
        return result
    end
    pcall(fn)
    return env.AuraHubDB
end

-- Merge two entry lists by name: keeps newest version of same-named entries
-- and accumulates entries unique to each side.
local function MergeList(local_list, other_list)
    local result  = {}
    local byName  = {}
    for _, e in ipairs(local_list or {}) do
        result[#result + 1] = e
        byName[e.name or ""] = #result
    end
    for _, e in ipairs(other_list or {}) do
        local n   = e.name or ""
        local idx = byName[n]
        if idx then
            if (e.savedAt or 0) > (result[idx].savedAt or 0) then
                result[idx] = e
            end
        else
            result[#result + 1] = e
            byName[n] = #result
        end
    end
    return result
end

-- /aurahub pathtest AccountName — tries every known path variant
function D.PathTest(accountName)
    local H    = AuraHub.Helpers
    local name = H.Trim(accountName or "folly32")
    H.Print("=== PathTest: " .. name .. " ===", "aaaaaa")

    -- 1. Разные варианты пути к файлу другого аккаунта
    local paths = {
        "WTF\\Account\\" .. name .. "\\SavedVariables\\AuraHub.lua",
        "WTF/Account/"  .. name .. "/SavedVariables/AuraHub.lua",
        "../WTF/Account/" .. name .. "/SavedVariables/AuraHub.lua",
        "Interface\\AddOns\\AuraHub\\AuraHub.toc",
        "Interface/AddOns/AuraHub/AuraHub.toc",
    }
    for _, path in ipairs(paths) do
        local ok, result = pcall(ReadFile, path)
        local got = ok and result and #result > 0
        H.Print((got and "OK " or "NO ") .. path, got and "44ff44" or "ff4444")
    end

    -- 2. loadfile
    H.Print("--- loadfile ---", "aaaaaa")
    local lf = type(loadfile)
    H.Print("loadfile: " .. lf, lf == "function" and "44ff44" or "ff4444")
    if lf == "function" then
        local ok2, r2 = pcall(loadfile, "Interface/AddOns/AuraHub/AuraHub.toc")
        H.Print("loadfile toc: " .. tostring(ok2) .. " / " .. tostring(type(r2)), "cccccc")
    end

    -- 3. debug library
    H.Print("--- debug ---", "aaaaaa")
    H.Print("debug: " .. tostring(type(debug)), "cccccc")
    if type(debug) == "table" then
        local keys = {}
        for k in pairs(debug) do keys[#keys+1] = k end
        H.Print("debug keys: " .. table.concat(keys, ", "), "cccccc")
    end

    -- 4. Другие экзотические функции
    H.Print("--- misc ---", "aaaaaa")
    local checks = {
        "GetFileLines", "openfile", "readfile", "FileLoad",
        "C_System", "C_IO", "WoWAPI_FileRead",
    }
    for _, fn in ipairs(checks) do
        local v = _G[fn]
        if v ~= nil then
            H.Print(fn .. ": " .. type(v), "44ff44")
        end
    end

    -- 5. Попробовать GetCVar для пути аккаунта
    H.Print("--- CVars ---", "aaaaaa")
    local cvars = { "accountName", "accounttype", "portal", "realmName", "realmList" }
    for _, cv in ipairs(cvars) do
        local ok3, val = pcall(GetCVar, cv)
        if ok3 and val then H.Print(cv .. " = " .. val, "cccccc") end
    end
end

-- Expose for the /aurahub iotest command
function D.IOTest()
    local H = AuraHub.Helpers
    H.Print("=== IO Test ===", "aaaaaa")
    H.Print("io: "              .. tostring(type(io)),                      "cccccc")
    H.Print("io.open: "         .. tostring(io and type(io.open)),          "cccccc")
    H.Print("WriteFile: "       .. tostring(type(WriteFile)),               "cccccc")
    H.Print("FileWrite: "       .. tostring(type(FileWrite)),               "cccccc")
    H.Print("ReadFile: "        .. tostring(type(ReadFile)),                "cccccc")
    H.Print("FileRead: "        .. tostring(type(FileRead)),                "cccccc")
    H.Print("C_FileUtils: "     .. tostring(type(C_FileUtils)),             "cccccc")
    H.Print("LibFile: "         .. tostring(type(LibFile)),                 "cccccc")
    H.Print("ffi: "             .. tostring(type(ffi)),                     "cccccc")

    local testContent = "AuraHubIOTest=true\n"
    local method = TryWrite(SHARED_PATH, testContent)
    if method then
        H.Print("Write OK via: " .. method, "44ff44")
        local content = TryRead(SHARED_PATH)
        if content then
            H.Print("Read OK (" .. #content .. " bytes)", "44ff44")
        else
            H.Print("Write OK but Read FAILED", "ff8844")
        end
    else
        H.Print("All write methods FAILED", "ff4444")
        H.Print("Кастыль не поддерживается этим клиентом.", "ff8844")
    end
end

-- Sync from another account's SavedVariables (ReadFile костыль)

local function SyncOne(name)
    local H = AuraHub.Helpers
    local path = "WTF\\Account\\" .. name .. "\\SavedVariables\\AuraHub.lua"
    local content = TryRead(path)
    if not content then
        path    = "WTF/Account/" .. name .. "/SavedVariables/AuraHub.lua"
        content = TryRead(path)
    end
    if not content then
        H.Err("[" .. name .. "] файл не найден.")
        return 0
    end
    local otherDB = ParseSavedVars(content)
    if type(otherDB) ~= "table" then
        H.Err("[" .. name .. "] не удалось прочитать данные.")
        return 0
    end
    local merged = 0
    for _, key in ipairs({ "WeakAuras", "ElvUI", "Skada", "Binds", "Macros", "ActionBars" }) do
        if type(otherDB[key]) == "table" then
            local before = #(AuraHubDB[key] or {})
            AuraHubDB[key] = MergeList(AuraHubDB[key], otherDB[key])
            merged = merged + (#AuraHubDB[key] - before)
        end
    end
    return merged
end

-- /aurahub sync add Name   — добавить аккаунт
-- /aurahub sync remove Name — убрать аккаунт
-- /aurahub sync list        — список
-- /aurahub sync             — синкнуть все сейчас
function D.SyncCmd(arg)
    local H = AuraHub.Helpers
    AuraHubDB._syncAccounts = AuraHubDB._syncAccounts or {}
    local accounts = AuraHubDB._syncAccounts

    local cmd, rest = arg:match("^(%S+)%s*(.*)$")
    cmd = cmd or ""

    if cmd == "add" then
        local name = H.Trim(rest)
        if name == "" then H.Err("Usage: /aurahub sync add AccountName") return end
        for _, v in ipairs(accounts) do
            if v == name then H.Print("'" .. name .. "' уже в списке.") return end
        end
        accounts[#accounts + 1] = name
        H.Print("Добавлен аккаунт для синка: " .. name, "44ff44")

    elseif cmd == "remove" then
        local name = H.Trim(rest)
        for i, v in ipairs(accounts) do
            if v == name then
                table.remove(accounts, i)
                H.Print("Убран аккаунт: " .. name, "ff8844")
                return
            end
        end
        H.Err("'" .. name .. "' не найден в списке.")

    elseif cmd == "list" then
        if #accounts == 0 then
            H.Print("Список пуст. Добавь: /aurahub sync add AccountName")
        else
            H.Print("Аккаунты для синка (" .. #accounts .. "):", "aaaaaa")
            for i, v in ipairs(accounts) do
                H.Print("  " .. i .. ". " .. v, "cccccc")
            end
        end

    else
        -- синк всех прямо сейчас
        if #accounts == 0 then
            H.Err("Нет аккаунтов. Добавь: /aurahub sync add AccountName")
            return
        end
        local total = 0
        for _, name in ipairs(accounts) do
            total = total + SyncOne(name)
        end
        H.Print("Синк завершён. Новых записей: " .. total, "44ff44")
    end
end

local function AutoSync()
    AuraHubDB._syncAccounts = AuraHubDB._syncAccounts or {}
    if #AuraHubDB._syncAccounts == 0 then return end
    for _, name in ipairs(AuraHubDB._syncAccounts) do
        SyncOne(name)
    end
end

-- WriteShared — best-effort, silent if unavailable
local function WriteShared()
    AuraHubDB._t = time()
    local content = "AuraHubSharedDB=" .. AuraHub.Helpers.Serialize(AuraHubDB) .. "\n"
    TryWrite(SHARED_PATH, content)
end

-- Init

function D.Init()
    AuraHubDB = AuraHubDB or {}
    for k, v in pairs(DEFAULTS) do
        if AuraHubDB[k] == nil then
            AuraHubDB[k] = AuraHub.Helpers.DeepCopy(v)
        end
    end
    AutoSync()
end

-- WeakAuras

function D.GetWAs()    return AuraHubDB.WeakAuras end
function D.CountWAs()  return #AuraHubDB.WeakAuras end
function D.Flush()     WriteShared() end

function D.SaveWA(entry)
    table.insert(AuraHubDB.WeakAuras, entry)
    WriteShared()
end

function D.DeleteWA(index)
    table.remove(AuraHubDB.WeakAuras, index)
    WriteShared()
end

-- ElvUI

function D.GetElvUIs()   return AuraHubDB.ElvUI end
function D.CountElvUIs() return #AuraHubDB.ElvUI end

function D.SaveElvUI(entry)
    ClearTombstone("ElvUI", entry.name)
    table.insert(AuraHubDB.ElvUI, entry)
    WriteShared()
end

function D.DeleteElvUI(index)
    local e = AuraHubDB.ElvUI[index]
    if e then Tombstone("ElvUI", e.name) end
    table.remove(AuraHubDB.ElvUI, index)
    WriteShared()
end

-- Skada

function D.GetSkadas()   return AuraHubDB.Skada end
function D.CountSkadas() return #AuraHubDB.Skada end

function D.SaveSkada(entry)
    ClearTombstone("Skada", entry.name)
    table.insert(AuraHubDB.Skada, entry)
    WriteShared()
end

function D.DeleteSkada(index)
    local e = AuraHubDB.Skada[index]
    if e then Tombstone("Skada", e.name) end
    table.remove(AuraHubDB.Skada, index)
    WriteShared()
end

-- Binds

function D.GetBinds()   return AuraHubDB.Binds end
function D.CountBinds() return #AuraHubDB.Binds end

function D.SaveBind(entry)
    ClearTombstone("Binds", entry.name)
    table.insert(AuraHubDB.Binds, entry)
end

function D.DeleteBind(index)
    local e = AuraHubDB.Binds[index]
    if e then Tombstone("Binds", e.name) end
    table.remove(AuraHubDB.Binds, index)
end

-- Macros

function D.GetMacros()   return AuraHubDB.Macros end
function D.CountMacros() return #AuraHubDB.Macros end

function D.SaveMacro(entry)
    ClearTombstone("Macros", entry.name)
    table.insert(AuraHubDB.Macros, entry)
end

function D.DeleteMacro(index)
    local e = AuraHubDB.Macros[index]
    if e then Tombstone("Macros", e.name) end
    table.remove(AuraHubDB.Macros, index)
end

-- ActionBars

function D.GetActionBars()   return AuraHubDB.ActionBars end
function D.CountActionBars() return #AuraHubDB.ActionBars end

function D.SaveActionBar(entry)
    ClearTombstone("ActionBars", entry.name)
    table.insert(AuraHubDB.ActionBars, entry)
end

function D.DeleteActionBar(index)
    local e = AuraHubDB.ActionBars[index]
    if e then Tombstone("ActionBars", e.name) end
    table.remove(AuraHubDB.ActionBars, index)
end
