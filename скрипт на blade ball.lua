local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer

print("KRYPTON BALL ACTIVATED")

local autoParryEnabled = false
local antiRushEnabled = true
local parryKey = Enum.KeyCode.F
local toggleUiKey = Enum.KeyCode.RightControl
local isBinding = false
local isParrying = false
local isMinimized = false
local frameColorIndex = 1
local previousBallPosition = nil
local previousBallTime = 0
local previousBallSpeed = nil

local frameColors = {
    {Name = "Dark", Color = Color3.fromRGB(20, 20, 25)},
    {Name = "Blue", Color = Color3.fromRGB(20, 45, 75)},
    {Name = "Red", Color = Color3.fromRGB(75, 25, 25)},
    {Name = "Green", Color = Color3.fromRGB(20, 65, 40)},
    {Name = "Purple", Color = Color3.fromRGB(50, 25, 75)},
    {Name = "Pink", Color = Color3.fromRGB(75, 30, 55)},
    {Name = "Orange", Color = Color3.fromRGB(85, 45, 20)}
}

local ScreenGuiName = "KryptonBallUI"
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

pcall(function()
    local oldCoreGui = game:GetService("CoreGui"):FindFirstChild(ScreenGuiName)
    if oldCoreGui then oldCoreGui:Destroy() end
end)

local oldPlayerGui = PlayerGui:FindFirstChild(ScreenGuiName)
if oldPlayerGui then oldPlayerGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = ScreenGuiName
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 100

pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)

if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local ButtonSound = Instance.new("Sound")
ButtonSound.Name = "ButtonSound"
ButtonSound.SoundId = "rbxassetid://9083627113"
ButtonSound.Volume = 1
ButtonSound.Parent = ScreenGui

local function playButtonSound()
    ButtonSound:Stop()
    ButtonSound.TimePosition = 0
    ButtonSound:Play()
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 200, 0, 238)
MainFrame.Position = UDim2.new(0.5, -100, 0.2, 0)
MainFrame.BackgroundColor3 = frameColors[frameColorIndex].Color
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local openTween = TweenService:Create(
    MainFrame,
    TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    {
        Size = UDim2.new(0, 200, 0, 238),
        Position = UDim2.new(0.5, -100, 0.2, 0)
    }
)
openTween:Play()

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(50, 50, 60)
UIStroke.Thickness = 1
UIStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 0, 28)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "KRYPTON BALL"
Title.TextColor3 = Color3.fromRGB(220, 220, 230)
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local MinBtn = Instance.new("TextButton")
MinBtn.Name = "MinBtn"
MinBtn.Size = UDim2.new(0, 22, 0, 22)
MinBtn.Position = UDim2.new(1, -50, 0, 3)
MinBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
MinBtn.TextSize = 14
MinBtn.AutoButtonColor = false
MinBtn.Parent = MainFrame

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 4)
MinCorner.Parent = MinBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(1, -25, 0, 3)
CloseBtn.BackgroundColor3 = Color3.fromRGB(45, 25, 25)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(220, 80, 80)
CloseBtn.TextSize = 11
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseBtn

local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, 0, 0, 210)
ContentContainer.Position = UDim2.new(0, 0, 0, 28)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Size = UDim2.new(1, -20, 0, 32)
ToggleBtn.Position = UDim2.new(0, 10, 0, 4)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
ToggleBtn.Font = Enum.Font.GothamMedium
ToggleBtn.Text = "Auto Parry: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(200, 70, 70)
ToggleBtn.TextSize = 12
ToggleBtn.AutoButtonColor = false
ToggleBtn.Parent = ContentContainer

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleBtn

local KeybindBtn = Instance.new("TextButton")
KeybindBtn.Name = "KeybindBtn"
KeybindBtn.Size = UDim2.new(1, -20, 0, 32)
KeybindBtn.Position = UDim2.new(0, 10, 0, 42)
KeybindBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
KeybindBtn.Font = Enum.Font.Gotham
KeybindBtn.Text = "Parry Key: [" .. parryKey.Name .. "]"
KeybindBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
KeybindBtn.TextSize = 12
KeybindBtn.AutoButtonColor = false
KeybindBtn.Parent = ContentContainer

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 6)
KeyCorner.Parent = KeybindBtn

local FrameColorBtn = Instance.new("TextButton")
FrameColorBtn.Name = "FrameColorBtn"
FrameColorBtn.Size = UDim2.new(1, -20, 0, 32)
FrameColorBtn.Position = UDim2.new(0, 10, 0, 80)
FrameColorBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
FrameColorBtn.Font = Enum.Font.GothamMedium
FrameColorBtn.Text = "Window: " .. frameColors[frameColorIndex].Name
FrameColorBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
FrameColorBtn.TextSize = 12
FrameColorBtn.AutoButtonColor = false
FrameColorBtn.Parent = ContentContainer

local FrameColorCorner = Instance.new("UICorner")
FrameColorCorner.CornerRadius = UDim.new(0, 6)
FrameColorCorner.Parent = FrameColorBtn

local StatsToggleBtn = Instance.new("TextButton")
StatsToggleBtn.Name = "StatsToggleBtn"
StatsToggleBtn.Size = UDim2.new(1, -20, 0, 32)
StatsToggleBtn.Position = UDim2.new(0, 10, 0, 118)
StatsToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
StatsToggleBtn.Font = Enum.Font.GothamMedium
StatsToggleBtn.Text = "Ping / FPS: OFF"
StatsToggleBtn.TextColor3 = Color3.fromRGB(200, 70, 70)
StatsToggleBtn.TextSize = 12
StatsToggleBtn.AutoButtonColor = false
StatsToggleBtn.Parent = ContentContainer

local StatsToggleCorner = Instance.new("UICorner")
StatsToggleCorner.CornerRadius = UDim.new(0, 6)
StatsToggleCorner.Parent = StatsToggleBtn

local AntiRushBtn = Instance.new("TextButton")
AntiRushBtn.Name = "AntiRushBtn"
AntiRushBtn.Size = UDim2.new(1, -20, 0, 32)
AntiRushBtn.Position = UDim2.new(0, 10, 0, 156)
AntiRushBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
AntiRushBtn.Font = Enum.Font.GothamMedium
AntiRushBtn.Text = "Anti-Rush: ON"
AntiRushBtn.TextColor3 = Color3.fromRGB(70, 200, 120)
AntiRushBtn.TextSize = 12
AntiRushBtn.AutoButtonColor = false
AntiRushBtn.Parent = ContentContainer

local AntiRushCorner = Instance.new("UICorner")
AntiRushCorner.CornerRadius = UDim.new(0, 6)
AntiRushCorner.Parent = AntiRushBtn

AntiRushBtn.Activated:Connect(function()
    antiRushEnabled = not antiRushEnabled
    if antiRushEnabled then
        AntiRushBtn.Text = "Anti-Rush: ON"
        AntiRushBtn.TextColor3 = Color3.fromRGB(70, 200, 120)
    else
        AntiRushBtn.Text = "Anti-Rush: OFF"
        AntiRushBtn.TextColor3 = Color3.fromRGB(200, 70, 70)
    end
end)

local statsEnabled = false
local StatsFrame = Instance.new("Frame")
StatsFrame.Name = "PingFPSFrame"
StatsFrame.Size = UDim2.new(0, 155, 0, 62)
StatsFrame.Position = UDim2.new(0.5, 110, 0.2, 0)
StatsFrame.BackgroundColor3 = frameColors[frameColorIndex].Color
StatsFrame.BorderSizePixel = 0
StatsFrame.Active = true
StatsFrame.Visible = false
StatsFrame.Parent = ScreenGui

local StatsCorner = Instance.new("UICorner")
StatsCorner.CornerRadius = UDim.new(0, 8)
StatsCorner.Parent = StatsFrame

local StatsStroke = Instance.new("UIStroke")
StatsStroke.Color = Color3.fromRGB(50, 50, 60)
StatsStroke.Thickness = 1
StatsStroke.Parent = StatsFrame

local StatsTitle = Instance.new("TextLabel")
StatsTitle.Name = "StatsTitle"
StatsTitle.Size = UDim2.new(1, -12, 0, 18)
StatsTitle.Position = UDim2.new(0, 6, 0, 3)
StatsTitle.BackgroundTransparency = 1
StatsTitle.Font = Enum.Font.GothamBold
StatsTitle.Text = "PERFORMANCE"
StatsTitle.TextColor3 = Color3.fromRGB(220, 220, 230)
StatsTitle.TextSize = 10
StatsTitle.TextXAlignment = Enum.TextXAlignment.Left
StatsTitle.Active = true
StatsTitle.Parent = StatsFrame

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Name = "StatsLabel"
StatsLabel.Size = UDim2.new(1, -12, 0, 34)
StatsLabel.Position = UDim2.new(0, 6, 0, 23)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Font = Enum.Font.GothamMedium
StatsLabel.Text = "Ping: -- ms\nFPS: --"
StatsLabel.TextColor3 = Color3.fromRGB(100, 220, 150)
StatsLabel.TextSize = 12
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.TextYAlignment = Enum.TextYAlignment.Center
StatsLabel.Parent = StatsFrame

local statsDragging = false
local statsDragStart
local statsStartPos

StatsTitle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        statsDragging = true
        statsDragStart = input.Position
        statsStartPos = StatsFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                statsDragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if statsDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - statsDragStart
        StatsFrame.Position = UDim2.new(
            statsStartPos.X.Scale,
            statsStartPos.X.Offset + delta.X,
            statsStartPos.Y.Scale,
            statsStartPos.Y.Offset + delta.Y
        )
    end
end)

StatsToggleBtn.Activated:Connect(function()
    statsEnabled = not statsEnabled
    StatsFrame.Visible = statsEnabled
    if statsEnabled then
        StatsToggleBtn.Text = "Ping / FPS: ON"
        StatsToggleBtn.TextColor3 = Color3.fromRGB(70, 200, 120)
    else
        StatsToggleBtn.Text = "Ping / FPS: OFF"
        StatsToggleBtn.TextColor3 = Color3.fromRGB(200, 70, 70)
    end
end)

local fpsFrames = 0
local fpsElapsed = 0
local currentFPS = 0

RunService.RenderStepped:Connect(function(deltaTime)
    fpsFrames = fpsFrames + 1
    fpsElapsed = fpsElapsed + deltaTime
    if fpsElapsed >= 0.5 then
        currentFPS = math.floor(fpsFrames / fpsElapsed + 0.5)
        fpsFrames = 0
        fpsElapsed = 0

        if statsEnabled then
            local pingText = "--"
            pcall(function()
                local stats = game:GetService("Stats")
                local network = stats.Network
                local serverStats = network:FindFirstChild("ServerStatsItem")
                local dataPing = serverStats and serverStats:FindFirstChild("Data Ping")
                if dataPing then
                    pingText = tostring(math.floor(dataPing:GetValue() + 0.5))
                end
            end)
            StatsLabel.Text = "Ping: " .. pingText .. " ms\nFPS: " .. tostring(currentFPS)
        end
    end
end)

for _, button in ipairs({
    MinBtn,
    CloseBtn,
    ToggleBtn,
    KeybindBtn,
    FrameColorBtn,
    StatsToggleBtn,
    AntiRushBtn
}) do
    button.Activated:Connect(playButtonSound)
end

FrameColorBtn.MouseButton1Click:Connect(function()
    frameColorIndex = frameColorIndex % #frameColors + 1
    local selectedColor = frameColors[frameColorIndex]

    MainFrame.BackgroundColor3 = selectedColor.Color
    StatsFrame.BackgroundColor3 = selectedColor.Color
    FrameColorBtn.Text = "Window: " .. selectedColor.Name
end)

local function resetParryAura()
    previousBallPosition = nil
    previousBallTime = 0
end

local function connectCharacter(character)
    resetParryAura()

    local humanoid = character:WaitForChild("Humanoid")

    humanoid.Died:Connect(function()
        isParrying = false
        resetParryAura()
    end)
end

LocalPlayer.CharacterAdded:Connect(connectCharacter)

if LocalPlayer.Character then
    task.spawn(connectCharacter, LocalPlayer.Character)
end

local function connectPlayer(player)
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")

        humanoid.Died:Connect(function()
            resetParryAura()
        end)
    end)

    if player.Character then
        task.spawn(function()
            local humanoid = player.Character:WaitForChild("Humanoid")

            humanoid.Died:Connect(function()
                resetParryAura()
            end)
        end)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        connectPlayer(player)
    end
end

Players.PlayerAdded:Connect(connectPlayer)

local dragging, dragStart, startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart

        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized

    if isMinimized then
        MainFrame.Size = UDim2.new(0, 200, 0, 28)
        ContentContainer.Visible = false
        MinBtn.Text = "+"
    else
        MainFrame.Size = UDim2.new(0, 200, 0, 238)
        ContentContainer.Visible = true
        MinBtn.Text = "-"
    end
end)

local mainLoopConnection

CloseBtn.MouseButton1Click:Connect(function()
    autoParryEnabled = false

    if mainLoopConnection then
        mainLoopConnection:Disconnect()
    end

    ScreenGui:Destroy()
end)

ToggleBtn.MouseButton1Click:Connect(function()
    autoParryEnabled = not autoParryEnabled

    if autoParryEnabled then
        ToggleBtn.Text = "Auto Parry: ON"
        ToggleBtn.TextColor3 = Color3.fromRGB(70, 200, 120)
    else
        ToggleBtn.Text = "Auto Parry: OFF"
        ToggleBtn.TextColor3 = Color3.fromRGB(200, 70, 70)
    end
end)

KeybindBtn.MouseButton1Click:Connect(function()
    if isBinding then
        return
    end

    isBinding = true
    KeybindBtn.Text = "Press a key..."
    KeybindBtn.TextColor3 = Color3.fromRGB(255, 200, 80)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == toggleUiKey then
        MainFrame.Visible = not MainFrame.Visible
        return
    end

    if isBinding and input.UserInputType == Enum.UserInputType.Keyboard then
        parryKey = input.KeyCode
        isBinding = false
        KeybindBtn.Text = "Parry Key: [" .. parryKey.Name .. "]"
        KeybindBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
        return
    end
end)

local function getActiveBall()
    local ballsFolder = workspace:FindFirstChild("Balls")

    if ballsFolder then
        for _, obj in ipairs(ballsFolder:GetChildren()) do
            if obj:IsA("BasePart") or obj:IsA("Model") then
                return obj
            end
        end
    end

    return nil
end

mainLoopConnection = RunService.PostSimulation:Connect(function()
    if not autoParryEnabled then
        return
    end

    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if not hrp or not humanoid or humanoid.Health <= 0 or isParrying then
        return
    end

    local ball = getActiveBall()
    if not ball then
        previousBallPosition = nil
        previousBallSpeed = nil
        return
    end

    local ballPart = ball:IsA("BasePart") and ball or ball:FindFirstChildWhichIsA("BasePart")
    if not ballPart then
        previousBallPosition = nil
        previousBallSpeed = nil
        return
    end

    local ballPosition = ballPart.Position
    local velocity = ballPart.AssemblyLinearVelocity
    local speed = velocity.Magnitude
    local offsetToPlayer = hrp.Position - ballPosition
    local distance = offsetToPlayer.Magnitude
    local closingSpeed = 0

    if distance > 0.001 and speed > 0.001 then
        closingSpeed = velocity:Dot(offsetToPlayer.Unit)
    end

    local timeToClosest = math.huge
    local closestDistance = math.huge
    if speed > 1 then
        timeToClosest = math.max(0, offsetToPlayer:Dot(velocity) / velocity:Dot(velocity))
        local predictedOffset = ballPosition + velocity * timeToClosest - hrp.Position
        closestDistance = predictedOffset.Magnitude
    end

    local now = os.clock()
    local deltaTime = now - previousBallTime
    local wasNearlyStopped = false
    local acceleration = 0

    if previousBallPosition and deltaTime > 0 and deltaTime <= 0.3 then
        wasNearlyStopped = (ballPosition - previousBallPosition).Magnitude < 0.6
        if previousBallSpeed then
            acceleration = (speed - previousBallSpeed) / deltaTime
        end
    end

    previousBallPosition = ballPosition
    previousBallTime = now
    previousBallSpeed = speed

    local accelerationBoost = math.max(0, acceleration)
    local reactionLead = math.clamp(
        0.24 + speed * 0.0035 + accelerationBoost * 0.00045,
        0.24,
        1.35
    )

    local rushLead = math.clamp(
        0.38 + speed * 0.0038 + accelerationBoost * 0.0004,
        0.38,
        1.65
    )

    local targetAttribute = ball:GetAttribute("target") or ballPart:GetAttribute("target")
    local isTargetingMe = targetAttribute == LocalPlayer.Name
        or targetAttribute == LocalPlayer.UserId
        or (closingSpeed > 0 and closestDistance <= 7 and timeToClosest <= reactionLead)

    local predictedThreat = closingSpeed > 0
        and timeToClosest <= reactionLead
        and closestDistance <= 7

    local closeThreat = closingSpeed > 0 and distance <= 7
    local speedDistanceLimit = math.clamp(speed * rushLead, 35, 140)

    local antiRushThreat = antiRushEnabled
        and closingSpeed > 0
        and distance <= speedDistanceLimit
        and (timeToClosest <= rushLead or speed >= 90 or (wasNearlyStopped and speed >= 25))
        and (isTargetingMe or closestDistance <= 9)

    if (isTargetingMe and (predictedThreat or closeThreat)) or antiRushThreat then
        isParrying = true

        VirtualInputManager:SendKeyEvent(true, parryKey, false, game)

        task.delay(0.04, function()
            VirtualInputManager:SendKeyEvent(false, parryKey, false, game)
        end)

        task.delay(0.35, function()
            isParrying = false
        end)
    end
end)