-- =====================================================
-- 🕵️ SILENT OBSERVER V2 - شغال على الهاتف
-- ⚡ يراقب كل الـ Remotes والمسارات
-- 📱 سحب باللمس + عرض فوري
-- =====================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- =====================================================
-- إنشاء الواجهة
-- =====================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ObserverV2"
screenGui.Parent = LocalPlayer.PlayerGui
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 380, 0, 450)
mainFrame.Position = UDim2.new(0.5, -190, 0.15, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)

-- شريط العنوان
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 38)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.7, 0, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🔍 Observer"
title.TextColor3 = Color3.fromRGB(0, 200, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -38, 0, 3)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.BackgroundTransparency = 1
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Parent = titleBar

local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(0, 35, 0, 28)
clearBtn.Position = UDim2.new(1, -80, 0, 5)
clearBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
clearBtn.Text = "🗑"
clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clearBtn.Font = Enum.Font.GothamBold
clearBtn.TextSize = 14
clearBtn.Parent = titleBar
Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 6)

-- منطقة التمرير
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -10, 1, -55)
scroll.Position = UDim2.new(0, 5, 0, 45)
scroll.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
scroll.ScrollBarThickness = 4
scroll.Parent = mainFrame
Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 10)

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 4)
layout.Parent = scroll

-- =====================================================
-- وظيفة إضافة حدث
-- =====================================================
local function addItem(name, path, typeName)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -10, 0, 65)
    card.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    card.Parent = scroll
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 25, 0, 25)
    icon.Position = UDim2.new(0, 6, 0, 6)
    icon.BackgroundTransparency = 1
    icon.Text = typeName == "RemoteEvent" and "📡" or "⚙️"
    icon.TextColor3 = Color3.fromRGB(255, 200, 100)
    icon.Font = Enum.Font.Gotham
    icon.TextSize = 14
    icon.Parent = card
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -90, 0, 20)
    nameLabel.Position = UDim2.new(0, 36, 0, 4)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 200)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 11
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = card
    
    local pathLabel = Instance.new("TextLabel")
    pathLabel.Size = UDim2.new(1, -90, 0, 26)
    pathLabel.Position = UDim2.new(0, 36, 0, 24)
    pathLabel.BackgroundTransparency = 1
    pathLabel.Text = path
    pathLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
    pathLabel.Font = Enum.Font.Gotham
    pathLabel.TextSize = 9
    pathLabel.TextWrapped = true
    pathLabel.TextXAlignment = Enum.TextXAlignment.Left
    pathLabel.Parent = card
    
    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0, 40, 0, 26)
    copyBtn.Position = UDim2.new(1, -48, 0, 20)
    copyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    copyBtn.Text = "📋"
    copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextSize = 14
    copyBtn.Parent = card
    Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 6)
    
    copyBtn.MouseButton1Click:Connect(function()
        setclipboard(path)
        copyBtn.Text = "✅"
        copyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        task.delay(1, function()
            if copyBtn and copyBtn.Parent then
                copyBtn.Text = "📋"
                copyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            end
        end)
    end)
    
    -- تحديث التمرير
    task.defer(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)
end

-- =====================================================
-- مراقبة الـ Remotes (الطريقة الصحيحة)
-- =====================================================
local function hookRemote(remote)
    if remote:IsA("RemoteEvent") then
        local old = remote.FireServer
        remote.FireServer = function(self, ...)
            local path = self:GetFullName()
            addItem(self.Name, path, "RemoteEvent")
            print("📡 RemoteEvent fired: " .. self.Name)
            return old(self, ...)
        end
    elseif remote:IsA("RemoteFunction") then
        local old = remote.InvokeServer
        remote.InvokeServer = function(self, ...)
            local path = self:GetFullName()
            addItem(self.Name, path, "RemoteFunction")
            print("⚙️ RemoteFunction invoked: " .. self.Name)
            return old(self, ...)
        end
    end
end

-- مسح جميع الـ Remotes الموجودة
local function scanAll()
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            hookRemote(obj)
        end
    end
end

-- مراقبة الإضافات الجديدة
ReplicatedStorage.DescendantAdded:Connect(function(child)
    if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
        hookRemote(child)
        addItem(child.Name, child:GetFullName(), child.ClassName)
    end
end)

-- مراقبة Workspace و Players
workspace.DescendantAdded:Connect(function(child)
    if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
        hookRemote(child)
        addItem(child.Name, child:GetFullName(), child.ClassName)
    end
end)

Players.DescendantAdded:Connect(function(child)
    if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
        hookRemote(child)
        addItem(child.Name, child:GetFullName(), child.ClassName)
    end
end)

scanAll()
print("✅ Observer is ready!")

-- =====================================================
-- مسح القائمة
-- =====================================================
clearBtn.MouseButton1Click:Connect(function()
    for _, child in pairs(scroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    scroll.CanvasSize = UDim2.new(0, 0, 0, 10)
end)

-- =====================================================
-- إظهار/إخفاء
-- =====================================================
closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- =====================================================
-- سحب بالإصبع (شغال 100%)
-- =====================================================
local dragData = {dragging = false, startPos = nil, startMouse = nil}

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragData.dragging = true
        dragData.startPos = mainFrame.Position
        dragData.startMouse = Vector2.new(input.Position.X, input.Position.Y)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragData.dragging then
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - dragData.startMouse
            local newX = dragData.startPos.X.Offset + delta.X
            local newY = dragData.startPos.Y.Offset + delta.Y
            mainFrame.Position = UDim2.new(0, newX, 0, newY)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragData.dragging = false
    end
end)

print("🕵️ Silent Observer V2 loaded successfully!")
print("📱 Drag the window by the title bar with your finger.")
