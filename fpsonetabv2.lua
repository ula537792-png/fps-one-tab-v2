-- === НАСТРОЙКА СЕРВЕРА ===
local SERVER_URL = "https://fps-one-tab-v2-production.up.railway.app"

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InveriumLoader"
screenGui.DisplayOrder = 999
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

-- === ЭКРАН ВВОДА КЛЮЧА ===
local keyFrame = Instance.new("Frame", screenGui)
keyFrame.Size = UDim2.new(0.35, 0, 0.25, 0)
keyFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
keyFrame.AnchorPoint = Vector2.new(0.5, 0.5)
keyFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
keyFrame.BorderSizePixel = 0
keyFrame.Active = true
keyFrame.Draggable = true
keyFrame.ZIndex = 2
keyFrame.ClipsDescendants = true

Instance.new("UICorner", keyFrame).CornerRadius = UDim.new(0, 16)

local keyAspect = Instance.new("UIAspectRatioConstraint", keyFrame)
keyAspect.AspectRatio = 2.1
keyAspect.DominantAxis = Enum.DominantAxis.Height

local keyStroke = Instance.new("UIStroke", keyFrame)
keyStroke.Color = Color3.fromRGB(255, 100, 150)
keyStroke.Thickness = 1.5

local keyTitle = Instance.new("TextLabel", keyFrame)
keyTitle.Size = UDim2.new(1, 0, 0.25, 0)
keyTitle.Position = UDim2.new(0, 0, 0.05, 0)
keyTitle.Text = "Enter Access Key"
keyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
keyTitle.Font = Enum.Font.GothamBold
keyTitle.TextSize = 15
keyTitle.BackgroundTransparency = 1
keyTitle.ZIndex = 4

local textBox = Instance.new("TextBox", keyFrame)
textBox.Size = UDim2.new(0.8, 0, 0.3, 0)
textBox.Position = UDim2.new(0.1, 0, 0.38, 0)
textBox.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
textBox.PlaceholderText = "Paste your key here..."
textBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
textBox.Text = ""
textBox.Font = Enum.Font.Gotham
textBox.TextSize = 14
textBox.ZIndex = 4
Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 10)

local submitBtn = Instance.new("TextButton", keyFrame)
submitBtn.Size = UDim2.new(0.8, 0, 0.25, 0)
submitBtn.Position = UDim2.new(0.1, 0, 0.72, 0)
submitBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 150)
submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
submitBtn.Text = "Verify Key"
submitBtn.Font = Enum.Font.GothamBold
submitBtn.TextSize = 14
submitBtn.ZIndex = 4
Instance.new("UICorner", submitBtn).CornerRadius = UDim.new(0, 10)

-- === ОСНОВНОЕ МЕНЮ (скрыто до ввода ключа) ===
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0.35, 0, 0.23, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.BackgroundTransparency = 1
mainFrame.Visible = false
mainFrame.ZIndex = 2
mainFrame.ClipsDescendants = true

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)

local mainAspect = Instance.new("UIAspectRatioConstraint", mainFrame)
mainAspect.AspectRatio = 2.1
mainAspect.DominantAxis = Enum.DominantAxis.Height

local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(255, 100, 150)
mainStroke.Transparency = 1
mainStroke.Thickness = 1.5

local bgContainer = Instance.new("Frame", mainFrame)
bgContainer.Size = UDim2.new(1, 0, 1, 0)
bgContainer.BackgroundTransparency = 1
bgContainer.ZIndex = 3

local function spawnParticle()
    if not mainFrame.Parent then return end
    local p = Instance.new("Frame", bgContainer)
    local size = math.random(4, 7)
    p.Size = UDim2.new(0, size, 0, size)
    local startX = math.random()
    p.Position = UDim2.new(startX, 0, 1.1, 0)
    p.BackgroundColor3 = Color3.fromRGB(255, 100, 150)
    p.BackgroundTransparency = math.random(2, 6) / 10
    p.BorderSizePixel = 0
    p.ZIndex = 3
    Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
    
    local duration = math.random(3, 5)
    local endX = startX + (math.random() - 0.5) * 0.2
    
    local tween = TweenService:Create(p, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Position = UDim2.new(endX, 0, -0.1, 0),
        BackgroundTransparency = 1
    })
    
    tween:Play()
    tween.Completed:Connect(function()
        p:Destroy()
        spawnParticle()
    end)
end

local function startParticles()
    for i = 1, 12 do
        task.delay(math.random() * 2, spawnParticle)
    end
end

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0.25, 0)
title.Position = UDim2.new(0, 0, 0.05, 0)
title.Text = "Select your platform"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.BackgroundTransparency = 1
title.TextTransparency = 1
title.ZIndex = 4

local isClosing = false
local function fadeOutAndLoad(url)
    if isClosing then return end
    isClosing = true

    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    TweenService:Create(mainFrame, tweenInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(mainStroke, tweenInfo, {Transparency = 1}):Play()
    TweenService:Create(title, tweenInfo, {TextTransparency = 1}):Play()
    TweenService:Create(bgContainer, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()

    for _, child in pairs(mainFrame:GetChildren()) do
        if child:IsA("TextButton") then
            TweenService:Create(child, tweenInfo, {BackgroundTransparency = 1, TextTransparency = 1}):Play()
            local stroke = child:FindFirstChildOfClass("UIStroke")
            if stroke then
                TweenService:Create(stroke, tweenInfo, {Transparency = 1}):Play()
            end
        end
    end

    task.wait(0.6)
    screenGui:Destroy()
    loadstring(game:HttpGet(url))()
end

local function createButton(name, posX, targetUrl)
    local btn = Instance.new("TextButton", mainFrame)
    btn.Size = UDim2.new(0.42, 0, 0.52, 0)
    btn.Position = UDim2.new(posX, 0, 0.36, 0)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 15
    btn.ZIndex = 4
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(40, 40, 40)
    stroke.Thickness = 1
    
    btn.MouseButton1Click:Connect(function()
        fadeOutAndLoad(targetUrl)
    end)
    
    return btn
end

local mobileBtn = createButton("Mobile", 0.05, "https://raw.githubusercontent.com/ula537792-png/mobile-fps-one-tab/refs/heads/main/fps%20one%20tab%20mobile.lua")
local pcBtn = createButton("PC", 0.53, "https://raw.githubusercontent.com/ula537792-png/one-tab/refs/heads/main/%5BFPS%5D%20One%20Tab.lua")

-- Обработка нажатия на кнопку проверки ключа
submitBtn.MouseButton1Click:Connect(function()
    local enteredKey = textBox.Text
    if enteredKey == "" then
        keyTitle.Text = "Enter a valid key!"
        return
    end

    submitBtn.Text = "Checking..."
    
    local success, response = pcall(function()
        return HttpService:PostAsync(SERVER_URL .. "/redeem-key", HttpService:JSONEncode({
            key = enteredKey,
            userId = LocalPlayer.UserId
        }), Enum.HttpContentType.ApplicationJson)
    end)

    if success then
        local data = HttpService:JSONDecode(response)
        if data.success then
            -- Плавное скрытие окна ключа и показ главного меню
            local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            TweenService:Create(keyFrame, tweenInfo, {BackgroundTransparency = 1}):Play()
            TweenService:Create(keyStroke, tweenInfo, {Transparency = 1}):Play()
            for _, child in pairs(keyFrame:GetChildren()) do
                if child:IsA("GuiObject") then
                    TweenService:Create(child, tweenInfo, {BackgroundTransparency = 1, TextTransparency = 1}):Play()
                    local stroke = child:FindFirstChildOfClass("UIStroke")
                    if stroke then TweenService:Create(stroke, tweenInfo, {Transparency = 1}):Play() end
                end
            end
            task.wait(0.4)
            keyFrame:Destroy()

            -- Показываем меню выбора платформы
            mainFrame.Visible = true
            startParticles()
            TweenService:Create(mainFrame, tweenInfo, {BackgroundTransparency = 0.05}):Play()
            TweenService:Create(mainStroke, tweenInfo, {Transparency = 0.4}):Play()
            TweenService:Create(title, tweenInfo, {TextTransparency = 0}):Play()
        else
            keyTitle.Text = data.message or "Invalid key!"
            submitBtn.Text = "Verify Key"
        end
    else
        keyTitle.Text = "Connection error!"
        submitBtn.Text = "Verify Key"
    end
end)
