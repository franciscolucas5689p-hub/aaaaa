-- ORELHA HUB
-- Roblox Studio | LocalScript
-- Recursos para NPCs do seu proprio jogo.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("ORELHA_HUB")
if old then old:Destroy() end

local settings = {
    ESP = false,
    Aim = false,
    FOV = 150,
    AimNPCsOnly = true
}

local gui = Instance.new("ScreenGui")
gui.Name = "ORELHA_HUB"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(245, 250)
panel.Position = UDim2.new(0.05, 0, 0.3, 0)
panel.BackgroundColor3 = Color3.fromRGB(24, 21, 33)
panel.BorderSizePixel = 0
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 42)
title.BackgroundColor3 = Color3.fromRGB(112, 58, 190)
title.BorderSizePixel = 0
title.Text = "ORELHA HUB"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 19
title.Parent = panel
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 12)

-- Arrastar o painel pela barra de titulo
local dragging, dragStart, startPos
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = panel.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        panel.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

local function makeButton(label, y, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.86, 0, 0, 36)
    b.Position = UDim2.new(0.07, 0, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(65, 48, 88)
    b.BorderSizePixel = 0
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Text = label
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 14
    b.Parent = panel
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.Activated:Connect(callback)
    return b
end

local espButton, aimButton, fovButton

espButton = makeButton("ESP NPCs: OFF", 55, function()
    settings.ESP = not settings.ESP
    espButton.Text = "ESP NPCs: " .. (settings.ESP and "ON" or "OFF")
end)

aimButton = makeButton("MIRA ASSISTIDA: OFF", 99, function()
    settings.Aim = not settings.Aim
    aimButton.Text = "MIRA ASSISTIDA: " .. (settings.Aim and "ON" or "OFF")
end)

fovButton = makeButton("FOV: 150 (+25)", 143, function()
    settings.FOV += 25
    if settings.FOV > 400 then settings.FOV = 50 end
    fovButton.Text = "FOV: " .. settings.FOV .. " (+25)"
end)

makeButton("FECHAR HUB", 187, function()
    gui:Destroy()
end)

-- Circulo de FOV: apenas indicador visual da area de mira.
local circle = Instance.new("Frame")
circle.Name = "FOVCircle"
circle.AnchorPoint = Vector2.new(0.5, 0.5)
circle.Position = UDim2.fromScale(0.5, 0.5)
circle.Size = UDim2.fromOffset(settings.FOV * 2, settings.FOV * 2)
circle.BackgroundTransparency = 1
circle.Parent = gui

local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(1, 0)
circleCorner.Parent = circle

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(180, 105, 255)
stroke.Thickness = 2
stroke.Parent = circle

local highlights = {}

local function isNPC(model)
    if not model:IsA("Model") or model == player.Character then
        return false
    end
    if Players:GetPlayerFromCharacter(model) then
        return false
    end
    local hum = model:FindFirstChildOfClass("Humanoid")
    local root = model:FindFirstChild("HumanoidRootPart")
    return hum ~= nil and root ~= nil and hum.Health > 0
end

local function updateESP()
    for model, highlight in pairs(highlights) do
        if not model.Parent or not settings.ESP or not isNPC(model) then
            highlight:Destroy()
            highlights[model] = nil
        end
    end

    if not settings.ESP then return end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if isNPC(obj) and not highlights[obj] then
            local h = Instance.new("Highlight")
            h.Name = "OrelhaHubESP"
            h.FillColor = Color3.fromRGB(165, 85, 255)
            h.OutlineColor = Color3.new(1, 1, 1)
            h.DepthMode = Enum.HighlightDepthMode.Occluded
            h.Parent = obj
            highlights[obj] = h
        end
    end
end

local function updateAim()
    if not settings.Aim then return end

    local center = camera.ViewportSize / 2
    local bestPart, bestDistance = nil, settings.FOV

    for _, obj in ipairs(workspace:GetDescendants()) do
        if isNPC(obj) then
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            local targetPart = obj:FindFirstChild("UpperTorso")
                or obj:FindFirstChild("Torso")
                or obj:FindFirstChild("HumanoidRootPart")

            if humanoid and humanoid.Health > 0 and targetPart then
                local screenPos, visible = camera:WorldToViewportPoint(targetPart.Position)
                if visible then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if distance < bestDistance then
                        bestDistance = distance
                        bestPart = targetPart
                    end
                end
            end
        end
    end

    -- Assistencia suave, apenas contra NPCs do proprio jogo.
    if bestPart then
        local targetCFrame = CFrame.lookAt(camera.CFrame.Position, bestPart.Position)
        camera.CFrame = camera.CFrame:Lerp(targetCFrame, 0.12)
    end
end

local accumulator = 0
local connection
connection = RunService.RenderStepped:Connect(function(dt)
    if not gui.Parent then
        connection:Disconnect()
        return
    end

    circle.Size = UDim2.fromOffset(settings.FOV * 2, settings.FOV * 2)
    circle.Visible = settings.Aim
    accumulator += dt

    if accumulator >= 0.25 then
        accumulator = 0
        updateESP()
    end

    updateAim()
end)

print("ORELHA HUB carregado!")
