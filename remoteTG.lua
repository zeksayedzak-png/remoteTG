-- =====================================================
-- 🕵️ SILENT OBSERVER - مراقب الريموتات والمسارات
-- ⚡ يعرض كل RemoteEvent/RemoteFunction يتم استدعاؤه
-- 📋 مع زر نسخ لكل مسار
-- 📱 واجهة سوداء قابلة للسحب
-- =====================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- =====================================================
-- الواجهة الرئيسية
-- =====================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SilentObserver"
screenGui.Parent = LocalPlayer.PlayerGui
screenGui.ResetOnSpawn = false

-- الإطار الرئيسي (أسود، مربع، قابل للسحب)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 380, 0, 450)
mainFrame.Position = UDim2.new(0.5, -190, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

-- شريط العنوان (للسحب)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 38)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

-- أيقونة السحب
local dragIcon = Instance.new("TextLabel")
dragIcon.Size = UDim2.new(0, 35, 1, 0)
dragIcon.Position = UDim2.new(0, 5, 0, 0)
dragIcon.BackgroundTransparency = 1
dragIcon.Text = "☰"
dragIcon.TextColor3 = Color3.fromRGB(150, 150, 150)
dragIcon.Font = Enum.Font.Gotham
dragIcon.TextSize = 20
dragIcon.Parent = titleBar

-- العنوان
local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.7, 0, 1, 0)
title.Position = UDim2.new(0, 45, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🕵️ Silent Observer"
title.TextColor3 = Color3.fromRGB(0, 200, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- زر التصغير (X)
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 32, 0, 32)
minimizeBtn.Position = UDim2.new(1, -38, 0, 3)
minimizeBtn.Text = "✕"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 16
minimizeBtn.Parent = titleBar

-- زر مسح (Clear)
local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(0, 40, 0, 28)
clearBtn.Position = UDim2.new(1, -85, 0, 5)
clearBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
clearBtn.Text = "🧹"
clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clearBtn.Font = Enum.Font.GothamBold
clearBtn.TextSize = 14
clearBtn.Parent = titleBar
Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 6)

-- منطقة التمرير (ScrollingFrame)
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -10, 1, -55)
scrollFrame.Position = UDim2.new(0, 5, 0, 45)
scrollFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
scrollFrame.ScrollBarThickness = 4
scrollFrame.Parent = mainFrame
Instance.new("UICorner", scrollFrame).CornerRadius = UDim.new(0, 10)

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 4)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scrollFrame

-- =====================================================
-- المتغيرات
-- =====================================================
local detectedItems = {}
local itemCount = 0
local connections = {}

-- =====================================================
-- إضافة حدث إلى القائمة
-- =====================================================
local function addItem(name, path, className, action)
    itemCount = itemCount + 1
    
    -- بطاقة الحدث
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -10, 0, 70)
    card.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    card.Parent = scrollFrame
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    
    -- أيقونة النوع
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 28, 0, 28)
    icon.Position = UDim2.new(0, 6, 0, 6)
    icon.BackgroundTransparency = 1
    icon.Text = className == "RemoteEvent" and "📡" or "⚙️"
    icon.TextColor3 = Color3.fromRGB(255, 200, 100)
    icon.Font = Enum.Font.Gotham
    icon.TextSize = 16
    icon.Parent = card
    
    -- اسم الـ Remote / المسار
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -90, 0, 22)
    nameLabel.Position = UDim2.new(0, 40, 0, 4)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name .. " (" .. className .. ")"
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 200)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 11
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = card
    
    -- المسار الكامل
    local pathLabel = Instance.new("TextLabel")
    pathLabel.Size = UDim2.new(1, -90, 0, 28)
    pathLabel.Position = UDim2.new(0, 40, 0, 26)
    pathLabel.BackgroundTransparency = 1
    pathLabel.Text = path
    pathLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
    pathLabel.Font = Enum.Font.Gotham
    pathLabel.TextSize = 9
    pathLabel.TextWrapped = true
    pathLabel.TextXAlignment = Enum.TextXAlignment.Left
    pathLabel.Parent = card
    
    -- زر النسخ
    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0, 45, 0, 28)
    copyBtn.Position = UDim2.new(1, -52, 0, 22)
    copyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    copyBtn.Text = "📋"
    copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextSize = 14
    copyBtn.Parent = card
    Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 6)
    
    copyBtn.MouseButton1Click:Connect(function()
        setclipboard(path)
        copyBtn.Text = "✓"
        copyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        task.delay(1, function()
            if copyBtn and copyBtn.Parent then
                copyBtn.Text = "📋"
                copyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            end
        end)
    end)
    
    -- تحديث ارتفاع السكرول
    task.defer(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)
end

-- =====================================================
-- مراقبة الـ Remotes
-- =====================================================
local function hookRemote(remote)
    if remote:IsA("RemoteEvent") then
        local oldFire = remote.FireServer
        remote.FireServer = function(self, ...)
            local path = self:GetFullName()
            addItem(self.Name, path, "RemoteEvent", "fired")
            return oldFire(self, ...)
        end
    elseif remote:IsA("RemoteFunction") then
        local oldInvoke = remote.InvokeServer
        remote.InvokeServer = function(self, ...)
            local path = self:GetFullName()
            addItem(self.Name, path, "RemoteFunction", "invoked")
            return oldInvoke(self, ...)
        end
    end
end

-- مسح جميع الـ Remotes الموجودة
local function scanAndHook()
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            hookRemote(obj)
        end
    end
end

-- مراقبة الإضافات الجديدة (لمسح الـ Remotes التي تظهر لاحقاً)
local function watchNewRemotes()
    local conn = ReplicatedStorage.DescendantAdded:Connect(function(child)
        if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
            hookRemote(child)
            local path = child:GetFullName()
            addItem(child.Name, path, child.ClassName, "detected")
        end
    end)
    table.insert(connections, conn)
end

-- =====================================================
-- مراقبة الأحداث العامة (Workspace, Players, إلخ)
-- =====================================================
local function watchGlobalEvents()
    -- مراقبة إضافة أي كائن في Workspace
    local conn1 = workspace.DescendantAdded:Connect(function(child)
        if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
            hookRemote(child)
            local path = child:GetFullName()
            addItem(child.Name, path, child.ClassName, "detected")
        end
    end)
    table.insert(connections, conn1)
    
    -- مراقبة إضافة أي كائن في Players
    local conn2 = game.Players.DescendantAdded:Connect(function(child)
        if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
            hookRemote(child)
            local path = child:GetFullName()
            addItem(child.Name, path, child.ClassName, "detected")
        end
    end)
    table.insert(connections, conn2)
end

-- =====================================================
-- بدء المراقبة
-- =====================================================
scanAndHook()
watchNewRemotes()
watchGlobalEvents()

print("🕵️ Silent Observer is watching...")
print("📡 Any RemoteEvent/RemoteFunction will appear here.")

-- =====================================================
-- وظائف الأزرار
-- =====================================================
clearBtn.MouseButton1Click:Connect(function()
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    itemCount = 0
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 10)
end)

minimizeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- =====================================================
-- نظام السحب (للجوال والكمبيوتر)
-- =====================================================
local function makeDraggable(frame)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

makeDraggable(mainFrame)
