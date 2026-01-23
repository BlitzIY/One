--[[
    🌌 QUANTUM ROTATION SYSTEM v10.2 (Visual Match Edition)
    
    Update: Tamanho calibrado com base na print do usuário (110px).
]]

--------------------------------------------------------------------------------
--// 1. SERVIÇOS & OTIMIZAÇÃO
--------------------------------------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Cache de funções matemáticas
local v3_new = Vector3.new
local cf_new = CFrame.new
local math_rad = math.rad

--------------------------------------------------------------------------------
--// 2. CONFIGURAÇÕES (MASTER SETTINGS)
--------------------------------------------------------------------------------
local CONFIG = {
    RotationSpeed = 0.9, 
    -- [MUDANÇA AQUI] Tamanho ajustado para 110 (igual ao botão da imagem)
    SensorDefaultSize = UDim2.new(0, 110, 0, 110),
    
    Colors = {
        Primary = Color3.fromHex("#00FFAA"),
        Secondary = Color3.fromHex("#1A1A1A"),
        Danger = Color3.fromHex("#FF4444")
    }
}

--------------------------------------------------------------------------------
--// 3. ESTADO GLOBAL
--------------------------------------------------------------------------------
local State = {
    IsSetup = true,
    IsActive = false,
    CurrentTouch = nil,
    SensorAbsPos = Vector2.zero,
    SensorAbsSize = Vector2.zero
}

--------------------------------------------------------------------------------
--// 4. INTERFACE GRÁFICA (UI)
--------------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "QuantumUI"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 10000
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Sensor Frame
local SensorFrame = Instance.new("Frame")
SensorFrame.Name = "QuantumSensor"
SensorFrame.Size = CONFIG.SensorDefaultSize
-- Centralizado com o novo offset (-55 é a metade de 110)
SensorFrame.Position = UDim2.new(0.8, -55, 0.6, -55)
SensorFrame.BackgroundColor3 = CONFIG.Colors.Danger
SensorFrame.BackgroundTransparency = 0.4 -- Um pouco mais transparente para ver o jogo
SensorFrame.BorderSizePixel = 2
SensorFrame.BorderColor3 = Color3.new(1,1,1)
SensorFrame.Active = true 
SensorFrame.Parent = ScreenGui

-- UI de Texto
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, 0, 1, 0)
InfoLabel.Position = UDim2.new(0, 0, 0, 0)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "JUMP" 
InfoLabel.TextColor3 = Color3.new(1,1,1)
InfoLabel.Font = Enum.Font.GothamBlack
InfoLabel.TextScaled = true
InfoLabel.Parent = SensorFrame

-- Deixa o texto circular também para ficar bonito
local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(1, 0) -- Torna o botão perfeitamente redondo
ButtonCorner.Parent = SensorFrame

-- Botão de Confirmação
local ConfirmBtn = Instance.new("TextButton")
ConfirmBtn.Name = "ConfirmSetup"
ConfirmBtn.Size = UDim2.new(0, 220, 0, 50)
ConfirmBtn.Position = UDim2.new(0.5, -110, 0.15, 0)
ConfirmBtn.BackgroundColor3 = CONFIG.Colors.Primary
ConfirmBtn.Text = "ATIVAR QUANTUM MODE"
ConfirmBtn.Font = Enum.Font.GothamBold
ConfirmBtn.TextColor3 = CONFIG.Colors.Secondary
ConfirmBtn.TextSize = 18
ConfirmBtn.AutoButtonColor = true
ConfirmBtn.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = ConfirmBtn

--------------------------------------------------------------------------------
--// 5. LÓGICA DE ROTAÇÃO
--------------------------------------------------------------------------------

local function UpdateCharacterRotation(deltaTime)
    local char = LocalPlayer.Character
    if not char then return end
    
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    
    if rootPart and humanoid and humanoid.Health > 0 then
        humanoid.AutoRotate = false
        
        local camLook = Camera.CFrame.LookVector
        local targetDir = v3_new(camLook.X, 0, camLook.Z).Unit
        local targetCFrame = cf_new(rootPart.Position, rootPart.Position + targetDir)
        
        rootPart.CFrame = rootPart.CFrame:Lerp(targetCFrame, CONFIG.RotationSpeed)
    end
end

--------------------------------------------------------------------------------
--// 6. GERENCIAMENTO DE ESTADO
--------------------------------------------------------------------------------

local RotationConnection = nil

local function StartAction()
    if State.IsActive then return end
    State.IsActive = true
    
    RotationConnection = RunService.RenderStepped:Connect(UpdateCharacterRotation)
    
    if not UserInputService.TouchEnabled then
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    end
    
    local Glow = Instance.new("UIStroke")
    Glow.Name = "ActiveGlow"
    Glow.Color = CONFIG.Colors.Primary
    Glow.Thickness = 3
    Glow.Transparency = 0.5
    Glow.Parent = SensorFrame
end

local function StopAction()
    if not State.IsActive then return end
    State.IsActive = false
    
    if RotationConnection then
        RotationConnection:Disconnect()
        RotationConnection = nil
    end
    
    if not UserInputService.TouchEnabled then
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
    
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.AutoRotate = true end
    end
    
    if SensorFrame:FindFirstChild("ActiveGlow") then
        SensorFrame.ActiveGlow:Destroy()
    end
end

--------------------------------------------------------------------------------
--// 7. SISTEMA DE INPUT GLOBAL
--------------------------------------------------------------------------------

local function IsPointInSensor(inputPos)
    -- Lógica simples de caixa para performance máxima
    -- (Mesmo sendo visualmente redondo, o sensor é quadrado para garantir que não falhe o clique)
    local x, y = inputPos.X, inputPos.Y
    local sx, sy = State.SensorAbsPos.X, State.SensorAbsPos.Y
    local w, h = State.SensorAbsSize.X, State.SensorAbsSize.Y
    
    return x >= sx and x <= (sx + w) and y >= sy and y <= (sy + h)
end

UserInputService.TouchStarted:Connect(function(input, gpe)
    if State.IsSetup then return end
    
    if IsPointInSensor(input.Position) then
        State.CurrentTouch = input 
        StartAction()
    end
end)

UserInputService.TouchEnded:Connect(function(input)
    if input == State.CurrentTouch then
        State.CurrentTouch = nil
        StopAction()
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.Space then StartAction() end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then StopAction() end
end)

--------------------------------------------------------------------------------
--// 8. SETUP INTERATIVO
--------------------------------------------------------------------------------

local dragging, dragStart, startPos

SensorFrame.InputBegan:Connect(function(input)
    if State.IsSetup and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragging = true
        dragStart = input.Position
        startPos = SensorFrame.Position
    end
end)

SensorFrame.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        SensorFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

ConfirmBtn.MouseButton1Click:Connect(function()
    State.IsSetup = false
    ConfirmBtn.Visible = false
    InfoLabel.Visible = false
    
    State.SensorAbsPos = SensorFrame.AbsolutePosition
    State.SensorAbsSize = SensorFrame.AbsoluteSize
    
    SensorFrame.Active = false
    SensorFrame.BackgroundTransparency = 1
    SensorFrame.BorderSizePixel = 0
    
    -- Borda fantasma circular
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.new(1,1,1)
    stroke.Transparency = 0.8
    stroke.Thickness = 1
    stroke.Parent = SensorFrame
    
    SensorFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
        State.SensorAbsPos = SensorFrame.AbsolutePosition
        State.SensorAbsSize = SensorFrame.AbsoluteSize
    end)
end)

LocalPlayer.CharacterAdded:Connect(function()
    StopAction()
    State.CurrentTouch = nil
end)
