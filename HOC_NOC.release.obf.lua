-- HOC_NOC release (compat mode)
-- Gerado por obfuscate.js sem wrapper base64 para evitar runtime nil em executores
local __HOC_MODULES = {
  ["Modules/Config.lua"] = [[local M = {}

M.ANTI_AFK_INTERVAL = 30

return M
]],
  ["Modules/State.lua"] = [[local M = {}

M.Stored = {
    ScreenGui = nil,
}

return M
]],
  ["Modules/Services.lua"] = [[local Players = game:GetService("Players")

local M = {
    Players = Players,
    LocalPlayer = Players.LocalPlayer,
}

return M
]],
  ["Modules/AutoLike.lua"] = [[local M = {}

function M.Init(_ctx)
    -- Placeholder module
end

return M
]],
  ["Modules/AntiAFK.lua"] = [[local M = {}

function M.Init(_ctx)
end

function M.Ping()
    -- Lightweight anti-idle pulse placeholder.
end

return M
]],
  ["Modules/ESP.lua"] = [[local M = {}

function M.Init(_ctx)
end

return M
]],
  ["Modules/Movement.lua"] = [[local M = {}

function M.Init(_ctx)
end

function M.ApplyToCharacter(_char)
end

return M
]],
  ["Modules/Fly.lua"] = [[local M = {}

function M.Init(_ctx)
end

return M
]],
  ["Modules/AutoFish.lua"] = [[local M = {}

function M.Init(_ctx)
end

return M
]],
  ["Modules/AutoBuy.lua"] = [[local M = {}

function M.Init(_ctx)
end

return M
]],
  ["Modules/BigPetFeed.lua"] = [[local M = {}

function M.Init(_ctx)
end

return M
]],
  ["Modules/ServerHop.lua"] = [[local M = {}

function M.Init(_ctx)
end

return M
]],
  ["Modules/Teleport.lua"] = [[local M = {}

function M.Init(_ctx)
end

return M
]],
  ["Modules/Emotes.lua"] = [[local M = {}

function M.Init(_ctx)
end

return M
]],
  ["Modules/CollectCoin.lua"] = [[local M = {}

function M.Init(_ctx)
end

return M
]],
  ["Modules/GUI/Toggles.lua"] = [[local M = {}

function M.Bind(_ctx)
end

return M
]],
  ["Modules/GUI/Buttons.lua"] = [[local M = {}

function M.Bind(_ctx)
end

return M
]],
  ["Modules/GUI/FruitMenu.lua"] = [[local M = {}

function M.Bind(_ctx)
end

return M
]],
  ["Modules/GUI/Core.lua"] = [[local M = {}

function M.Build(ctx)
    local player = ctx.Services and ctx.Services.LocalPlayer
    if not player then
        return
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "HOC_NOC_GUI"
    gui.ResetOnSpawn = false

    local ok = pcall(function()
        gui.Parent = game:GetService("CoreGui")
    end)

    if not ok then
        local playerGui = player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui")
        gui.Parent = playerGui
    end

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 260, 0, 64)
    frame.Position = UDim2.new(0, 20, 0, 80)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -12, 1, -12)
    label.Position = UDim2.new(0, 6, 0, 6)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(235, 235, 235)
    label.Text = "HOC NOC BuildZoo Loaded"
    label.Parent = frame

    if ctx.State and ctx.State.Stored then
        ctx.State.Stored.ScreenGui = gui
    end
end

return M
]],
}
--[[
    HOC NOC Zoo — v1.0.3 | Modular Edition
    Main.lua — Ponto de entrada. Carrega todos os módulos, inicializa as
               features, constrói a GUI e mantém o loop monitor.

    ─ Requisitos de executor ────────────────────────────────────────────────────
    • Script distribuido como bundle standalone (modulos embutidos em memoria).
    • Execucao recomendada via HttpGet + loadstring.

    ─ Persistência após teleporte cross-place ───────────────────────────────────
    Use queue_on_teleport do executor para recarregar apos teleportes:
        queue_on_teleport([[loadstring(game:HttpGet("SUA_URL_RAW"))()]])
]]

-- ── Whitelist Security Check ──────────────────────────────────────────────────
do
    local ALLOWED_USERS = { ["kchaos97"] = true, ["ckhaos79"] = true }
    -- UserIds oficiais autorizados (dupla validacao: nome + id)
    local ALLOWED_USER_IDS = {
        [2242060908] = true,
        [5019856388] = true,
    }
    local Players = game:GetService("Players")
    local player  = Players.LocalPlayer
    local name    = player and player.Name or ""
    local userId  = player and player.UserId or 0
    local normalizedName = string.lower(tostring(name))

    local function showAccessNotification(granted)
        local sg = Instance.new("ScreenGui")
        sg.Name = "HOC_NOC_Access"
        sg.ResetOnSpawn = false
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        pcall(function() sg.Parent = game:GetService("CoreGui") end)
        if not sg.Parent then sg.Parent = player:WaitForChild("PlayerGui") end

        local frame = Instance.new("Frame", sg)
        frame.AnchorPoint = Vector2.new(0.5, 0)
        frame.Position = UDim2.new(0.5, 0, 0.05, 0)
        frame.Size = UDim2.new(0, 480, 0, 60)
        frame.BackgroundColor3 = granted and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(40, 10, 10)
        frame.BackgroundTransparency = 0.15
        frame.BorderSizePixel = 0
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

        local stroke = Instance.new("UIStroke", frame)
        stroke.Color = Color3.fromRGB(255, 0, 0)
        stroke.Thickness = 2

        -- RGB cycling border
        local rgbRunning = true
        task.spawn(function()
            local t = 0
            while rgbRunning do
                t = t + task.wait()
                local r = math.floor(math.sin(t * 2) * 127 + 128)
                local g = math.floor(math.sin(t * 2 + 2.094) * 127 + 128)
                local b = math.floor(math.sin(t * 2 + 4.189) * 127 + 128)
                stroke.Color = Color3.fromRGB(r, g, b)
            end
        end)

        local lbl = Instance.new("TextLabel", frame)
        lbl.Size = UDim2.new(1, -40, 1, 0)
        lbl.Position = UDim2.new(0, 20, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 18
        lbl.TextColor3 = granted and Color3.fromRGB(0, 220, 90) or Color3.fromRGB(255, 60, 60)
        lbl.Text = granted
            and ("[HOC NOC] Access GRANTED — Welcome, " .. name)
            or  ("[HOC NOC] Access DENIED — Unauthorized user: " .. name)
        lbl.TextXAlignment = Enum.TextXAlignment.Center

        task.delay(granted and 4 or 6, function()
            rgbRunning = false
            pcall(function()
                local tw = game:GetService("TweenService")
                local ti = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                tw:Create(frame, ti, {BackgroundTransparency = 1}):Play()
                tw:Create(lbl,   ti, {TextTransparency = 1}):Play()
                tw:Create(stroke, ti, {Transparency = 1}):Play()
                task.wait(1.1)
                sg:Destroy()
            end)
        end)
    end

    local hasNameRules = next(ALLOWED_USERS) ~= nil
    local hasIdRules = next(ALLOWED_USER_IDS) ~= nil
    local nameAllowed = (not hasNameRules) or (ALLOWED_USERS[normalizedName] == true)
    local idAllowed = (not hasIdRules) or (ALLOWED_USER_IDS[userId] == true)

    if not (nameAllowed and idAllowed) then
        showAccessNotification(false)
        return
    end

    showAccessNotification(true)
end

-- ── Loader de módulos ─────────────────────────────────────────────────────────
-- Loader de modulos embutidos em memoria (sem readfile)
local function loadModule(relPath)
    local source = __HOC_MODULES[relPath]
    if type(source) ~= "string" then
        warn("[HOC NOC] Modulo ausente no bundle: " .. tostring(relPath))
        return {}
    end

    local _L = loadstring or load
    if type(_L) ~= "function" then
        warn("[HOC NOC] Executor sem loadstring/load para modulo: " .. tostring(relPath))
        return {}
    end

    local chunk, compileErr = _L(source)
    if type(chunk) ~= "function" then
        warn("[HOC NOC] Erro de compilacao no modulo " .. tostring(relPath) .. ": " .. tostring(compileErr))
        return {}
    end

    local ok, result = pcall(chunk)
    if not ok then
        warn("[HOC NOC] Erro ao executar modulo " .. tostring(relPath) .. ": " .. tostring(result))
        return {}
    end
    return result
end

    return result
end

local function safeInvoke(label, fn)
    if type(fn) ~= "function" then
        warn("[HOC NOC] Etapa ausente: " .. tostring(label))
        return false
    end

    local ok, err = pcall(fn)
    if not ok then
        warn("[HOC NOC] Falha em " .. tostring(label) .. ": " .. tostring(err))
        return false
    end

    return true
end

-- ── Módulos base (ordem importa) ──────────────────────────────────────────────
local ctx = {}
ctx.Config   = loadModule("Modules/Config.lua")
ctx.State    = loadModule("Modules/State.lua")
ctx.Services = loadModule("Modules/Services.lua")

-- ── Módulos de feature ────────────────────────────────────────────────────────
ctx.AntiAFK   = loadModule("Modules/AntiAFK.lua")
ctx.ESP       = loadModule("Modules/ESP.lua")
ctx.Movement  = loadModule("Modules/Movement.lua")
ctx.Fly       = loadModule("Modules/Fly.lua")
ctx.AutoFish  = loadModule("Modules/AutoFish.lua")
ctx.AutoBuy   = loadModule("Modules/AutoBuy.lua")
ctx.BigPetFeed = loadModule("Modules/BigPetFeed.lua")
ctx.ServerHop = loadModule("Modules/ServerHop.lua")
ctx.Teleport  = loadModule("Modules/Teleport.lua")
ctx.Emotes    = loadModule("Modules/Emotes.lua")

-- ── Módulos de GUI ────────────────────────────────────────────────────────────
ctx.GUI = {
    Toggles  = loadModule("Modules/GUI/Toggles.lua"),
    Buttons  = loadModule("Modules/GUI/Buttons.lua"),
    FruitMenu = loadModule("Modules/GUI/FruitMenu.lua"),
    Core     = loadModule("Modules/GUI/Core.lua"),
}

-- ── Inicialização das features (conecta eventos, inicia loops) ────────────────
safeInvoke("AntiAFK.Init", function() ctx.AntiAFK.Init(ctx) end)
safeInvoke("ESP.Init", function() ctx.ESP.Init(ctx) end)
safeInvoke("Movement.Init", function() ctx.Movement.Init(ctx) end)
safeInvoke("Fly.Init", function() ctx.Fly.Init(ctx) end)
safeInvoke("AutoFish.Init", function() ctx.AutoFish.Init(ctx) end)
safeInvoke("AutoBuy.Init", function() ctx.AutoBuy.Init(ctx) end)
safeInvoke("BigPetFeed.Init", function() ctx.BigPetFeed.Init(ctx) end)
safeInvoke("ServerHop.Init", function() ctx.ServerHop.Init(ctx) end)
safeInvoke("Teleport.Init", function() ctx.Teleport.Init(ctx) end)
safeInvoke("Emotes.Init",   function() ctx.Emotes.Init(ctx) end)

-- ── Construção inicial da GUI ─────────────────────────────────────────────────
safeInvoke("GUI.Core.Build", function() ctx.GUI.Core.Build(ctx) end)

-- ── Loop monitor ──────────────────────────────────────────────────────────────
-- Reconstrói a GUI caso seja removida externamente e envia pings Anti-AFK
-- periódicos enquanto _G_Running for true.
task.spawn(function()
    while _G_Running do
        local stored = ctx.State.Stored
        if not (stored.ScreenGui and stored.ScreenGui.Parent) then
            safeInvoke("GUI.Core.Build (monitor)", function() ctx.GUI.Core.Build(ctx) end)
        end

        safeInvoke("AntiAFK.Ping", function() ctx.AntiAFK.Ping() end)

        task.wait(ctx.Config.ANTI_AFK_INTERVAL)
    end
end)

-- ── Eventos de personagem ─────────────────────────────────────────────────────
local LocalPlayer = ctx.Services.LocalPlayer

LocalPlayer.CharacterAdded:Connect(function(char)
    safeInvoke("Movement.ApplyToCharacter(CharacterAdded)", function()
        ctx.Movement.ApplyToCharacter(char)
    end)
end)

-- Aplica ao personagem já existente (caso o script rode após o spawn)
if LocalPlayer.Character then
    safeInvoke("Movement.ApplyToCharacter(Current)", function()
        ctx.Movement.ApplyToCharacter(LocalPlayer.Character)
    end)
end

-- Fim de Main.lua


print("[HOC_NOC] Script carregado com sucesso!")
