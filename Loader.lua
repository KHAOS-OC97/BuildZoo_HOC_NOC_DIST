print("HNk TTF HUB v9.4.3 - Remote Loader iniciando...")

local Players    = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local player     = Players.LocalPlayer

local ALLOWED_USERS = {
    KChaos97  = true,
    CKhaos79  = true,
}

local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title    = title,
            Text     = text,
            Duration = 5,
        })
    end)
end

if not ALLOWED_USERS[player.Name] then
    notify("ACCESS DENIED", "This script is restricted.")
    warn("HNk TTF HUB - ACCESS DENIED for user: " .. player.Name)
    return
else
    notify("ACCESS GRANTED", "Welcome, " .. player.Name .. "!")
end

if _G.__HNkHubInstance and _G.__HNkHubInstance.shutdown then
    pcall(function()
        _G.__HNkHubInstance.shutdown()
    end)
end

local BASE_URL = "https://raw.githubusercontent.com/KHAOS-OC97/HOC_NOC_TTF/main2/HNkHub/modules/"

local function httpGet(url)
    local ok, result = pcall(function()
        return game:HttpGet(url, true)
    end)
    return ok, result
end

local function isInvalidRemoteResponse(source)
    if type(source) ~= "string" then
        return true
    end

    local trimmed = source:match("^%s*(.-)%s*$") or source
    local lower = trimmed:lower()

    return trimmed:match("^404")
        or lower:find("not found")
        or lower:find("404:")
        or lower:find("<html")
        or lower:find("<!doctype html")
end

local function fetch(path)
    local url = BASE_URL .. path
    local ok, source = httpGet(url)
    if not ok then
        error("Falha ao baixar " .. path .. ": " .. tostring(source))
    end
    if type(source) ~= "string" or source == "" then
        error("Conteúdo vazio para " .. path)
    end
    if isInvalidRemoteResponse(source) then
        error("Arquivo não encontrado ou resposta inválida do repositório remoto: " .. path .. ". Verifique o BASE_URL e o nome do arquivo.")
    end
    return source
end

local function loadRemoteModule(path)
    local source = fetch(path)
    local chunk, err = loadstring(source)
    assert(chunk, "Falha ao compilar modulo " .. path .. ": " .. tostring(err))

    local ok, result = pcall(chunk)
    assert(ok, "Falha ao executar modulo " .. path .. ": " .. tostring(result))
    return result
end

local remoteModuleCache = {}
_G.__HNkLoadRemoteModule = function(path)
    if remoteModuleCache[path] ~= nil then
        return remoteModuleCache[path]
    end

    local module = loadRemoteModule(path)
    remoteModuleCache[path] = module
    return module
end

local Language = _G.__HNkLoadRemoteModule("Language.lua")
local Config   = _G.__HNkLoadRemoteModule("Config.lua")
local Utils    = _G.__HNkLoadRemoteModule("Utils.lua")
local Session  = _G.__HNkLoadRemoteModule("Session.lua")
local Systems  = _G.__HNkLoadRemoteModule("Systems.lua")
local Features = _G.__HNkLoadRemoteModule("Features.lua")
local Emotes   = _G.__HNkLoadRemoteModule("Emotes.lua")
local GUI      = _G.__HNkLoadRemoteModule("GUI.lua")

Language.load()
Config.load()

local function stubPopup()
    -- placeholder para inicialização antes do GUI final estar pronto
end

Systems.init({
    Session = Session,
    Config = Config,
    Language = Language,
    ShowPopup = stubPopup,
})

Systems.loadAllies()
Systems.loadBlockedServers()
Systems.loadProfiles()

Features.init({
    Config = Config,
    Session = Session,
    Systems = Systems,
    Utils = Utils,
    ShowPopup = stubPopup,
    Language = Language,
})

Emotes.Init({
    Config   = Config,
    Services = {
        Players          = game:GetService("Players"),
        RunService       = game:GetService("RunService"),
        UserInputService = game:GetService("UserInputService"),
        TweenService     = game:GetService("TweenService"),
        HttpService      = game:GetService("HttpService"),
        CoreGui          = game:GetService("CoreGui"),
    }
})

GUI.init({
    Config   = Config,
    Session  = Session,
    Systems  = Systems,
    Features = Features,
    Language = Language,
    Utils    = Utils,
    Emotes   = Emotes,
})

GUI.start()
local realShowPopup = GUI.showPopup

Systems.init({
    Session = Session,
    Config = Config,
    Language = Language,
    ShowPopup = realShowPopup,
})

Features.init({
    Config    = Config,
    Session   = Session,
    Systems   = Systems,
    Utils      = Utils,
    ShowPopup = realShowPopup,
    Language  = Language,
})

Features.initAllToggles()
Features.startMainLoop()
Features.startInfiniteJump()
Features.startFOVMouseControl()
Features.startAutoHopLoop()
Features.startESPCacheLoop()
Features.startESPLoop()

_G.__HNkHubInstance = {
    shutdown = function()
        pcall(function() Features.shutdown() end)
        pcall(function() GUI.shutdown() end)
    end,
}

Systems.startAdminDetection()
Session.startUptimeTracker()
Session.bindDisconnect()

Session.sendDiscord(
    Language.get("hubstarted"),
    Language.get("player") .. "**" .. player.Name .. "**\n" ..
    Language.get("server") .. game.JobId .. "\n" ..
    "⏰ " .. os.date("%H:%M:%S"),
    3066993
)

print("HNk TTF HUB v9.4.3 carregado via Loader remoto.")
