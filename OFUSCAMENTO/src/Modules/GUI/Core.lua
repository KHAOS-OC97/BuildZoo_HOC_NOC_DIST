local M = {}

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
