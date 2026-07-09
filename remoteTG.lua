-- [[ Remote Spy للهواتف - تصميم مخصص ]] --

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local TopBar = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ToggleBtn = Instance.new("TextButton")
local LogContainer = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

-- إعدادات الـ ScreenGui (لضمان ظهوره فوق كل شيء)
ScreenGui.Name = "DeltaRemoteSpy"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- إطار التصميم الأساسي (Main Frame)
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- أسود غامق
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 350, 0, 250)
MainFrame.Active = true
MainFrame.Draggable = true -- تفعيل السحب للهواتف

UICorner.CornerRadius = UDim.new(0, 15) -- حواف دائرية
UICorner.Parent = MainFrame

-- الشريط العلوي (Top Bar)
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TopBar.Size = UDim2.new(1, 0, 0, 40)

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 15)
TopCorner.Parent = TopBar

Title.Parent = TopBar
Title.Text = "  REMOTE MONITOR"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.TextXAlignment = Enum.TextXAlignment.Left

-- زر التشغيل والإيقاف (Square On/Off)
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Parent = TopBar
ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- أحمر (Off) بالبداية
ToggleBtn.Position = UDim2.new(0.75, 0, 0.15, 0)
ToggleBtn.Size = UDim2.new(0, 70, 0, 28)
ToggleBtn.Text = "OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 12

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 5)
BtnCorner.Parent = ToggleBtn

-- منطقة عرض الريموتات (Scrolling Frame)
LogContainer.Name = "LogContainer"
LogContainer.Parent = MainFrame
LogContainer.BackgroundColor3 = Color3.new(0,0,0)
LogContainer.BackgroundTransparency = 1
LogContainer.Position = UDim2.new(0, 5, 0, 50)
LogContainer.Size = UDim2.new(1, -10, 1, -60)
LogContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
LogContainer.ScrollBarThickness = 4

UIListLayout.Parent = LogContainer
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

-- متغيرات التحكم
local Monitoring = false

-- دالة نسخ الكود (لزر الـ Copy)
local function copyToClipboard(text)
    if setclipboard then
        setclipboard(text)
    else
        print("Setclipboard غير مدعوم في هذا المطور")
    end
end

-- دالة إضافة ريموت جديد للقائمة
local function AddLog(remoteName, method, args)
    local LogEntry = Instance.new("Frame")
    local LogText = Instance.new("TextLabel")
    local CopyBtn = Instance.new("TextButton")
    
    LogEntry.Size = UDim2.new(1, -10, 0, 40)
    LogEntry.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    LogEntry.Parent = LogContainer
    
    local LogCorner = Instance.new("UICorner")
    LogCorner.CornerRadius = UDim.new(0, 8)
    LogCorner.Parent = LogEntry

    LogText.Size = UDim2.new(0.7, 0, 1, 0)
    LogText.Position = UDim2.new(0.05, 0, 0, 0)
    LogText.BackgroundTransparency = 1
    LogText.TextColor3 = Color3.fromRGB(200, 200, 200)
    LogText.Text = remoteName .. " [" .. method .. "]"
    LogText.TextSize = 10
    LogText.TextXAlignment = Enum.TextXAlignment.Left
    LogText.Parent = LogEntry

    CopyBtn.Size = UDim2.new(0, 50, 0, 25)
    CopyBtn.Position = UDim2.new(0.75, 0, 0.2, 0)
    CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    CopyBtn.Text = "Copy"
    CopyBtn.TextColor3 = Color3.new(1,1,1)
    CopyBtn.Parent = LogEntry
    
    local CCorner = Instance.new("UICorner")
    CCorner.CornerRadius = UDim.new(0, 5)
    CCorner.Parent = CopyBtn

    -- كود النسخ الجاهز
    local argString = ""
    for i, v in pairs(args) do
        argString = argString .. tostring(v) .. (i == #args and "" or ", ")
    end
    local fullCode = "game:GetService(\"ReplicatedStorage\")." .. remoteName .. ":" .. method .. "(" .. argString .. ")"

    CopyBtn.MouseButton1Click:Connect(function()
        copyToClipboard(fullCode)
        CopyBtn.Text = "Done!"
        wait(1)
        CopyBtn.Text = "Copy"
    end)
    
    LogContainer.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end

-- زر التشغيل/الإيقاف
ToggleBtn.MouseButton1Click:Connect(function()
    Monitoring = not Monitoring
    if Monitoring then
        ToggleBtn.Text = "ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50) -- أخضر
    else
        ToggleBtn.Text = "OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- أحمر
    end
end)

-- السحب (Draggable) يدوي للهواتف لضمان السلاسة
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- [[ كود مراقبة الريموتات (The Hook) ]] --
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if Monitoring and (method == "FireServer" or method == "InvokeServer") then
        AddLog(self.Name, method, args)
    end

    return OldNamecall(self, ...)
end)

print("✅ Remote Spy Ready!")
