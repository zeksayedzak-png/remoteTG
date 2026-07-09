-- [[ Remote Spy الاحترافي للهواتف ]] --

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdvancedRemoteSpy"
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 250)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Active = true
MainFrame.Draggable = true -- مهم للهواتف
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "📡 REMOTE DETECTOR (V2)"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Parent = MainFrame

local LogContainer = Instance.new("ScrollingFrame")
LogContainer.Size = UDim2.new(1, -10, 1, -40)
LogContainer.Position = UDim2.new(0, 5, 0, 35)
LogContainer.BackgroundTransparency = 1
LogContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
LogContainer.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Parent = LogContainer
UIList.Padding = UDim.new(0, 5)

-- دالة لجلب المسار الكامل للريموت
local function getFullPath(obj)
    local path = obj.Name
    local parent = obj.Parent
    while parent and parent ~= game do
        path = parent.Name .. "." .. path
        parent = parent.Parent
    end
    return "game." .. path
end

-- دالة تحويل الجدول لنص (Arguments)
local function serializeTable(t)
    local s = ""
    for i, v in pairs(t) do
        s = s .. tostring(v) .. (i == #t and "" or ", ")
    end
    return s
end

-- دالة إضافة السجل
local function AddLog(remote, method, args)
    local fullPath = getFullPath(remote)
    local argStr = serializeTable(args)
    
    local Entry = Instance.new("Frame")
    Entry.Size = UDim2.new(1, -10, 0, 50)
    Entry.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Entry.Parent = LogContainer
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Text = "Remote: " .. remote.Name .. "\nMethod: " .. method
    Label.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    Label.TextSize = 10
    Label.Parent = Entry
    
    local CopyBtn = Instance.new("TextButton")
    CopyBtn.Size = UDim2.new(0, 60, 0, 30)
    CopyBtn.Position = UDim2.new(0.75, 0, 0.2, 0)
    CopyBtn.Text = "Copy"
    CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    CopyBtn.Parent = Entry
    
    CopyBtn.MouseButton1Click:Connect(function()
        local scriptToCopy = fullPath .. ":" .. method .. "(" .. argStr .. ")"
        if setclipboard then
            setclipboard(scriptToCopy)
            CopyBtn.Text = "Copied!"
            wait(1)
            CopyBtn.Text = "Copy"
        end
    end)
    
    LogContainer.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y)
end

-- الـ Hook (جوهر السكريبت)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if method == "FireServer" or method == "InvokeServer" then
        -- نقوم بإضافة السجل فوراً عند حدوث الحدث
        task.spawn(function()
            AddLog(self, method, args)
        end)
    end
    
    return oldNamecall(self, ...)
end)

print("✅ Remote Spy V2 is Running!")
