local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InveriumLoader"
screenGui.DisplayOrder = 999
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

-- === ЭКРАН ПРИВЕТСТВИЯ (INTRO) ===
local introFrame = Instance.new("Frame", screenGui)
introFrame.Size = UDim2.new(0.3, 0, 0.12, 0)
introFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
introFrame.AnchorPoint = Vector2.new(0.5, 0.5)
introFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
introFrame.BorderSizePixel = 0
introFrame.BackgroundTransparency = 1
introFrame.ZIndex = 2
Instance.new("UICorner", introFrame).CornerRadius = UDim.new(0, 14)

-- Ограничитель пропорций для интро, чтобы оно всегда выглядело аккуратно
local introAspect = Instance.new("UIAspectRatioConstraint", introFrame)
introAspect.AspectRatio = 3.6
introAspect.DominantAxis = Enum.DominantAxis.Height

local introStroke = Instance.new("UIStroke", introFrame)
introStroke.Color = Color3.fromRGB(255, 100, 150)
introStroke.Transparency = 1
introStroke.Thickness = 1.5

local introText = Instance.new("TextLabel", introFrame)
introText.Size = UDim2.new(1, 0, 1, 0)
introText.Text = "Welcome to Inverium"
introText.TextColor3 = Color3.fromRGB(255, 255, 255)
introText.Font = Enum.Font.GothamBold
introText.TextSize = 16
introText.BackgroundTransparency = 1
introText.TextTransparency = 1
introText.ZIndex = 3

-- === ОСНОВНОЕ МЕНЮ ВЫБОРА УСТРОЙСТВА ===
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

-- Главный ограничитель пропорций (держит идеальный размер карточки как на скриншоте везде)
local mainAspect = Instance.new("UIAspectRatioConstraint", mainFrame)
mainAspect.AspectRatio = 2.1
mainAspect.DominantAxis = Enum.DominantAxis.Height

local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(255, 100, 150)
mainStroke.Transparency = 1
mainStroke.Thickness = 1.5

-- === ФОНОВЫЕ АНИМИРОВАННЫЕ ЧАСТИЦЫ (ВНУТРИ МЕНЮ) ===
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

local particlesStarted = false
local function startParticles()
    if particlesStarted then return end
    particlesStarted = true
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

-- Плавное закрытие и запуск скрипта
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

-- Создание кнопок через Scale
local function createButton(name, posX, targetUrl)
    local btn = Instance.new("TextButton", mainFrame)
    btn.Size = UDim2.new(0.42, 0, 0.52, 0)
    btn.Position = UDim2.new(posX, 0, 0.36, 0)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 15
    btn.TextTransparency = 1
    btn.BackgroundTransparency = 1
    btn.ZIndex = 4
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(40, 40, 40)
    stroke.Transparency = 1
    stroke.Thickness = 1
    
    btn.MouseEnter:Connect(function()
        if isClosing then return end
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 100, 150)}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Color3 = Color3.fromRGB(255, 255, 255)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        if isClosing then return end
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 22, 22)}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Color3 = Color3.fromRGB(40, 40, 40)}):Play()
    end)
    
    btn.MouseButton1Click:Connect(function()
        fadeOutAndLoad(targetUrl)
    end)
    
    return btn
end

local mobileBtn = createButton("Mobile", 0.05, "https://raw.githubusercontent.com/ula537792-png/mobile-fps-one-tab/refs/heads/main/fps%20one%20tab%20mobile.lua")
local pcBtn = createButton("PC", 0.53, "https://raw.githubusercontent.com/ula537792-png/one-tab/refs/heads/main/%5BFPS%5D%20One%20Tab.lua")

-- === АНИМАЦИЯ ПЕРЕХОДОВ ===
task.spawn(function()
    -- Появление интро
    TweenService:Create(introFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 0.05}):Play()
    TweenService:Create(introStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Transparency = 0.5}):Play()
    TweenService:Create(introText, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
    
    task.wait(2.2)
    
    -- Исчезновение интро
    TweenService:Create(introFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
    TweenService:Create(introStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Transparency = 1}):Play()
    TweenService:Create(introText, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
    
    task.wait(0.5)
    introFrame:Destroy()
    
    -- Плавное появление основного меню
    mainFrame.Visible = true
    startParticles()
    
    TweenService:Create(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 0.05}):Play()
    TweenService:Create(mainStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Transparency = 0.4}):Play()
    TweenService:Create(title, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
    
    -- Появление кнопок
    TweenService:Create(mobileBtn, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
    TweenService:Create(mobileBtn:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Transparency = 0}):Play()
    
    TweenService:Create(pcBtn, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
    TweenService:Create(pcBtn:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Transparency = 0}):Play()
end)
