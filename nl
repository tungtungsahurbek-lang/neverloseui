-- Neverlose UI - Blue/Cyan Edition (Self-contained)
-- Paste directly into executor

--// Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

--// Theme (Blue/Cyan)
local Theme = {
    Background    = Color3.fromRGB(13, 15, 18),
    Visible       = Color3.fromRGB(18, 21, 25),
    Inline        = Color3.fromRGB(24, 28, 33),
    InlineHover   = Color3.fromRGB(30, 35, 42),
    Accent        = Color3.fromRGB(0, 170, 255),
    AccentSoft    = Color3.fromRGB(80, 195, 255),
    AccentDim     = Color3.fromRGB(0, 120, 190),
    Text          = Color3.fromRGB(225, 230, 235),
    TextBright    = Color3.fromRGB(255, 255, 255),
    TextDim       = Color3.fromRGB(135, 145, 155),
    TextMuted     = Color3.fromRGB(95, 102, 110),
    Outline       = Color3.fromRGB(0, 0, 0),
    BorderSoft    = Color3.fromRGB(35, 40, 46),
    SectionLabel  = Color3.fromRGB(110, 120, 130),
    TrackBg       = Color3.fromRGB(24, 28, 33),
    Knob          = Color3.fromRGB(235, 240, 245),
}

--// Utility
local function Create(className, props, children)
    local inst = Instance.new(className)
    for k, v in pairs(props) do
        if k ~= "Parent" then inst[k] = v end
    end
    if children then
        for _, child in ipairs(children) do child.Parent = inst end
    end
    if props.Parent then inst.Parent = props.Parent end
    return inst
end

local function Corner(radius, parent)
    return Create("UICorner", { CornerRadius = UDim.new(0, radius), Parent = parent })
end

local function Stroke(color, thickness, parent, transparency)
    return Create("UIStroke", {
        Color = color,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        Parent = parent
    })
end

local function Padding(px, parent)
    return Create("UIPadding", {
        PaddingTop = UDim.new(0, px),
        PaddingBottom = UDim.new(0, px),
        PaddingLeft = UDim.new(0, px),
        PaddingRight = UDim.new(0, px),
        Parent = parent
    })
end

local function ListLayout(px, parent)
    return Create("UIListLayout", {
        Padding = UDim.new(0, px),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = parent
    })
end

-- Gear icon (drawn, no emoji dependency)
local function GearIcon(parent, size)
    local Frame = Create("Frame", {
        Size = UDim2.fromOffset(size, size),
        BackgroundTransparency = 1,
        Parent = parent
    })
    -- Outer ring
    local Outer = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.TextDim,
        Parent = Frame
    })
    Corner(size, Outer)
    -- Inner cutout
    local Inner = Create("Frame", {
        Size = UDim2.new(0, size - 6, 0, size - 6),
        Position = UDim2.new(0, 3, 0, 3),
        BackgroundColor3 = Theme.Inline,
        Parent = Frame
    })
    Corner(size - 6, Inner)
    return Frame
end

--// Library
local NeverloseUI = {}
NeverloseUI.__index = NeverloseUI

function NeverloseUI.new(title)
    local self = setmetatable({}, NeverloseUI)
    self.Tabs = {}
    self.Flags = {}
    self.ConfigFolder = "NeverloseUI"

    -- ScreenGui
    self.ScreenGui = Create("ScreenGui", {
        Name = "NeverloseUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        Parent = game.CoreGui
    })

    -- Shadow (small)
    local Shadow = Create("ImageLabel", {
        Size = UDim2.new(1, 24, 1, 24),
        Position = UDim2.new(0, -12, 0, -12),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Parent = self.ScreenGui
    })
    self.Shadow = Shadow

    -- Main
    self.Main = Create("Frame", {
        Size = UDim2.new(0, 840, 0, 540),
        Position = UDim2.new(0.5, -420, 0.5, -270),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Parent = self.ScreenGui
    })
    Corner(10, self.Main)
    Stroke(Theme.Outline, 1.5, self.Main)

    -- Sidebar (semi-transparent)
    self.Sidebar = Create("Frame", {
        Size = UDim2.new(0, 210, 1, 0),
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        Parent = self.Main
    })
    Corner(10, self.Sidebar)

    -- Logo
    local Logo = Create("TextLabel", {
        Size = UDim2.new(1, -30, 0, 28),
        Position = UDim2.new(0, 18, 0, 20),
        BackgroundTransparency = 1,
        Text = "NEVERLOSE",
        TextColor3 = Theme.Accent,
        TextSize = 19,
        Font = Enum.Font.GothamBlack,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.Sidebar
    })

    -- Accent underline
    Create("Frame", {
        Size = UDim2.new(0, 58, 0, 2),
        Position = UDim2.new(0, 18, 0, 50),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = self.Sidebar
    })

    -- Tab container
    self.TabContainer = Create("Frame", {
        Size = UDim2.new(1, -20, 1, -160),
        Position = UDim2.new(0, 12, 0, 70),
        BackgroundTransparency = 1,
        Parent = self.Sidebar
    })
    ListLayout(3, self.TabContainer)

    -- Content area
    self.ContentArea = Create("Frame", {
        Size = UDim2.new(1, -240, 1, -70),
        Position = UDim2.new(0, 228, 0, 60),
        BackgroundTransparency = 1,
        Parent = self.Main
    })

    -- Topbar
    self.Topbar = Create("Frame", {
        Size = UDim2.new(1, -240, 0, 42),
        Position = UDim2.new(0, 228, 0, 8),
        BackgroundTransparency = 1,
        Parent = self.Main
    })

    -- Save button
    local SaveBtn = Create("TextButton", {
        Size = UDim2.new(0, 78, 0, 28),
        Position = UDim2.new(0, 4, 0, 5),
        BackgroundColor3 = Theme.Inline,
        Text = "Save",
        TextColor3 = Theme.Text,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        Parent = self.Topbar
    })
    Corner(7, SaveBtn)
    Stroke(Theme.Outline, 1, SaveBtn, 0.4)
    SaveBtn.MouseEnter:Connect(function() SaveBtn.BackgroundColor3 = Theme.InlineHover end)
    SaveBtn.MouseLeave:Connect(function() SaveBtn.BackgroundColor3 = Theme.Inline end)

    -- Right icons
    local MenuBtn = Create("TextButton", {
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -66, 0, 7),
        BackgroundTransparency = 1,
        Text = "≡",
        TextColor3 = Theme.TextDim,
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        Parent = self.Topbar
    })
    MenuBtn.MouseEnter:Connect(function() MenuBtn.TextColor3 = Theme.Text end)
    MenuBtn.MouseLeave:Connect(function() MenuBtn.TextColor3 = Theme.TextDim end)

    local SearchBtn = Create("TextButton", {
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -34, 0, 7),
        BackgroundTransparency = 1,
        Text = "⌕",
        TextColor3 = Theme.TextDim,
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        Parent = self.Topbar
    })
    SearchBtn.MouseEnter:Connect(function() SearchBtn.TextColor3 = Theme.Text end)
    SearchBtn.MouseLeave:Connect(function() SearchBtn.TextColor3 = Theme.TextDim end)

    -- User card
    local UserCard = Create("Frame", {
        Size = UDim2.new(1, -20, 0, 52),
        Position = UDim2.new(0, 10, 1, -62),
        BackgroundColor3 = Theme.Inline,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
        Parent = self.Sidebar
    })
    Corner(9, UserCard)
    Stroke(Theme.BorderSoft, 1, UserCard)

    -- Avatar (gradient circle with initial)
    local Avatar = Create("Frame", {
        Size = UDim2.new(0, 38, 0, 38),
        Position = UDim2.new(0, 7, 0, 7),
        BackgroundColor3 = Theme.Accent,
        Parent = UserCard
    })
    Corner(19, Avatar)
    Create("UIGradient", {
        Rotation = 135,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Accent),
            ColorSequenceKeypoint.new(1, Theme.AccentDim)
        }),
        Parent = Avatar
    })
    Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = string.sub(LocalPlayer.Name, 1, 1):upper(),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = Avatar
    })

    Create("TextLabel", {
        Size = UDim2.new(1, -55, 0, 16),
        Position = UDim2.new(0, 54, 0, 8),
        BackgroundTransparency = 1,
        Text = LocalPlayer.DisplayName,
        TextColor3 = Theme.Text,
        TextSize = 12,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = UserCard
    })

    Create("TextLabel", {
        Size = UDim2.new(1, -55, 0, 14),
        Position = UDim2.new(0, 54, 0, 26),
        BackgroundTransparency = 1,
        Text = "Till: 01.01.2026",
        TextColor3 = Theme.AccentSoft,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = UserCard
    })

    -- Drag
    self.IsDrag = false
    local dragStart, startPos
    self.Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.IsDrag = true
            dragStart = input.Position
            startPos = self.Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    self.IsDrag = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if self.IsDrag and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            self.Shadow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X - 12, startPos.Y.Scale, startPos.Y.Offset + delta.Y - 12)
        end
    end)

    return self
end

function NeverloseUI:AddSectionLabel(text, order)
    local Label = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.SectionLabel,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = order or #self.TabContainer:GetChildren(),
        Parent = self.TabContainer
    })
    Create("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 6),
        Parent = Label
    })
    return Label
end

function NeverloseUI:AddTab(name, iconGlyph, order)
    local Tab = {
        Name = name,
        Button = nil,
        Content = nil,
        Library = self,
        Active = false
    }

    local Btn = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        BackgroundColor3 = Theme.Inline,
        Text = "",
        LayoutOrder = order or #self.TabContainer:GetChildren(),
        Parent = self.TabContainer
    })
    Corner(7, Btn)

    -- Icon
    Create("TextLabel", {
        Size = UDim2.new(0, 24, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = iconGlyph or "◆",
        TextColor3 = Theme.TextDim,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = Btn
    })

    -- Label
    Create("TextLabel", {
        Size = UDim2.new(1, -54, 1, 0),
        Position = UDim2.new(0, 42, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Theme.TextDim,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Btn
    })

    Tab.Button = Btn

    local Content = Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = self.ContentArea
    })
    Tab.Content = Content

    Tab.LeftColumn = Create("Frame", {
        Size = UDim2.new(0.5, -6, 1, 0),
        BackgroundTransparency = 1,
        Parent = Content
    })
    Tab.RightColumn = Create("Frame", {
        Size = UDim2.new(0.5, -6, 1, 0),
        Position = UDim2.new(0.5, 6, 0, 0),
        BackgroundTransparency = 1,
        Parent = Content
    })

    ListLayout(10, Tab.LeftColumn)
    ListLayout(10, Tab.RightColumn)

    Btn.MouseButton1Click:Connect(function()
        self:SelectTab(name)
    end)

    Btn.MouseEnter:Connect(function()
        if not Tab.Active then Btn.BackgroundTransparency = 0.65 end
    end)
    Btn.MouseLeave:Connect(function()
        if not Tab.Active then Btn.BackgroundTransparency = 1 end
    end)

    table.insert(self.Tabs, Tab)
    return Tab
end

function NeverloseUI:SelectTab(name)
    for _, tab in ipairs(self.Tabs) do
        local isActive = tab.Name == name
        tab.Active = isActive
        tab.Content.Visible = isActive

        local stroke = tab.Button:FindFirstChildOfClass("UIStroke")
        if isActive then
            tab.Button.BackgroundTransparency = 0
            tab.Button.BackgroundColor3 = Theme.Inline
            if not stroke then
                Stroke(Theme.Accent, 1, tab.Button, 0.35)
            else
                stroke.Color = Theme.Accent
                stroke.Transparency = 0.35
            end
            if not tab.Button:FindFirstChild("ActiveBar") then
                Create("Frame", {
                    Name = "ActiveBar",
                    Size = UDim2.new(0, 3, 1, -8),
                    Position = UDim2.new(0, 3, 0.5, -4),
                    BackgroundColor3 = Theme.Accent,
                    BorderSizePixel = 0,
                    Parent = tab.Button
                })
            end
        else
            tab.Button.BackgroundTransparency = 1
            if stroke then stroke.Transparency = 1 end
            local bar = tab.Button:FindFirstChild("ActiveBar")
            if bar then bar:Destroy() end
        end

        for _, child in ipairs(tab.Button:GetChildren()) do
            if child:IsA("TextLabel") then
                if child.Text == tab.Name then
                    child.TextColor3 = isActive and Theme.Text or Theme.TextDim
                elseif child.Text ~= "≡" and child.Text ~= "⌕" then
                    child.TextColor3 = isActive and Theme.Accent or Theme.TextDim
                end
            end
        end
    end
end

function NeverloseUI:AddSection(tab, name, side)
    local parent = side == "right" and tab.RightColumn or tab.LeftColumn

    local Section = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Visible,
        BorderSizePixel = 0,
        Parent = parent
    })
    Corner(9, Section)
    Stroke(Theme.Outline, 1, Section, 0.4)
    Padding(14, Section)

    Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Section
    })

    local Container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(0, 0, 0, 26),
        BackgroundTransparency = 1,
        Parent = Section
    })
    ListLayout(8, Container)

    local section = { Frame = Section, Container = Container, Tab = tab }

    section.AddToggle        = function(_, ...) return self:AddToggle(section, ...) end
    section.AddSlider        = function(_, ...) return self:AddSlider(section, ...) end
    section.AddDropdown      = function(_, ...) return self:AddDropdown(section, ...) end
    section.AddMultiDropdown = function(_, ...) return self:AddMultiDropdown(section, ...) end
    section.AddKeybind       = function(_, ...) return self:AddKeybind(section, ...) end
    section.AddButton        = function(_, ...) return self:AddButton(section, ...) end
    section.AddColorPicker   = function(_, ...) return self:AddColorPicker(section, ...) end
    section.AddLabel         = function(_, ...) return self:AddLabel(section, ...) end
    section.AddDivider       = function(_) return self:AddDivider(section) end

    return section
end

function NeverloseUI:AddToggle(section, text, default, callback, flag, hasSettings)
    local toggled = default or false
    self.Flags[flag] = { Value = toggled, Type = "Toggle" }

    local Frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        Parent = section.Container
    })

    local Label = Create("TextLabel", {
        Size = UDim2.new(1, -90, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Frame
    })

    -- Gear icon (if hasSettings)
    if hasSettings then
        local gear = GearIcon(Frame, 14)
        gear.Position = UDim2.new(1, -52, 0.5, -7)
    end

    local ToggleBg = Create("Frame", {
        Size = UDim2.new(0, 32, 0, 16),
        Position = UDim2.new(1, -32, 0.5, -8),
        BackgroundColor3 = toggled and Theme.Accent or Theme.Inline,
        Parent = Frame
    })
    Corner(8, ToggleBg)
    Stroke(Theme.Outline, 1, ToggleBg, 0.3)

    local Knob = Create("Frame", {
        Size = UDim2.new(0, 12, 0, 12),
        Position = toggled and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
        BackgroundColor3 = toggled and Theme.Knob or Theme.TextDim,
        Parent = ToggleBg
    })
    Corner(6, Knob)

    local Button = Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = Frame
    })

    local function SetToggle(state)
        toggled = state
        if self.Flags[flag] then self.Flags[flag].Value = state end
        TweenService:Create(ToggleBg, TweenInfo.new(0.16, Enum.EasingStyle.Quart), {
            BackgroundColor3 = state and Theme.Accent or Theme.Inline
        }):Play()
        TweenService:Create(Knob, TweenInfo.new(0.16, Enum.EasingStyle.Quart), {
            Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
            BackgroundColor3 = state and Theme.Knob or Theme.TextDim
        }):Play()
        if callback then callback(state) end
    end

    Button.MouseButton1Click:Connect(function() SetToggle(not toggled) end)

    Frame.MouseEnter:Connect(function() Label.TextColor3 = Theme.TextBright end)
    Frame.MouseLeave:Connect(function() Label.TextColor3 = Theme.Text end)

    return { Set = SetToggle, Get = function() return toggled end, Frame = Frame }
end

function NeverloseUI:AddSlider(section, text, min, max, default, callback, flag, suffix)
    local value = default or min
    self.Flags[flag] = { Value = value, Type = "Slider" }

    local Frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundTransparency = 1,
        Parent = section.Container
    })

    local Label = Create("TextLabel", {
        Size = UDim2.new(0.6, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Frame
    })

    local ValueLabel = Create("TextLabel", {
        Size = UDim2.new(0.4, 0, 0, 16),
        Position = UDim2.new(0.6, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(value) .. (suffix or ""),
        TextColor3 = Theme.Accent,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = Frame
    })

    local Track = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 4),
        Position = UDim2.new(0, 0, 0, 25),
        BackgroundColor3 = Theme.TrackBg,
        Parent = Frame
    })
    Corner(2, Track)

    local percent = (value - min) / (max - min)
    local Fill = Create("Frame", {
        Size = UDim2.new(percent, 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        Parent = Track
    })
    Corner(2, Fill)

    local Knob = Create("Frame", {
        Size = UDim2.new(0, 11, 0, 11),
        Position = UDim2.new(percent, -5, 0.5, -5),
        BackgroundColor3 = Theme.Knob,
        Parent = Track
    })
    Corner(6, Knob)
    Stroke(Theme.Accent, 1, Knob, 0.4)

    local dragging = false

    local function UpdateSlider(inputPos)
        local relative = math.clamp((inputPos - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        local newValue = math.floor(min + (max - min) * relative + 0.5)
        value = newValue
        self.Flags[flag].Value = newValue
        ValueLabel.Text = tostring(newValue) .. (suffix or "")
        Fill.Size = UDim2.new(relative, 0, 1, 0)
        Knob.Position = UDim2.new(relative, -5, 0.5, -5)
        if callback then callback(newValue) end
    end

    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            UpdateSlider(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateSlider(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    return {
        Set = function(v)
            value = v
            local rel = (v - min) / (max - min)
            Fill.Size = UDim2.new(rel, 0, 1, 0)
            Knob.Position = UDim2.new(rel, -5, 0.5, -5)
            ValueLabel.Text = tostring(v) .. (suffix or "")
            self.Flags[flag].Value = v
        end,
        Get = function() return value end
    }
end

function NeverloseUI:AddDropdown(section, text, options, default, callback, flag)
    local selected = default
    local open = false
    self.Flags[flag] = { Value = selected, Type = "Dropdown" }

    local Frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        Parent = section.Container
    })

    local Label = Create("TextLabel", {
        Size = UDim2.new(0.45, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Frame
    })

    local DropdownBtn = Create("TextButton", {
        Size = UDim2.new(0.55, 0, 1, 0),
        Position = UDim2.new(0.45, 0, 0, 0),
        BackgroundColor3 = Theme.Inline,
        Text = (selected or "Select") .. "  ▾",
        TextColor3 = Theme.TextDim,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        Parent = Frame
    })
    Corner(6, DropdownBtn)
    Stroke(Theme.Outline, 1, DropdownBtn, 0.4)

    local DropList = Create("ScrollingFrame", {
        Size = UDim2.new(0.55, 0, 0, math.min(#options * 22, 110)),
        Position = UDim2.new(0.45, 0, 1, 4),
        BackgroundColor3 = Theme.Visible,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, #options * 22),
        Visible = false,
        ZIndex = 100,
        Parent = Frame
    })
    Corner(6, DropList)
    Stroke(Theme.Accent, 1, DropList, 0.5)
    ListLayout(2, DropList)

    for _, opt in ipairs(options) do
        local OptBtn = Create("TextButton", {
            Size = UDim2.new(1, -6, 0, 20),
            BackgroundTransparency = 1,
            Text = opt,
            TextColor3 = opt == selected and Theme.Accent or Theme.TextDim,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            ZIndex = 101,
            Parent = DropList
        })

        OptBtn.MouseButton1Click:Connect(function()
            selected = opt
            self.Flags[flag].Value = opt
            DropdownBtn.Text = opt .. "  ▾"
            DropdownBtn.TextColor3 = Theme.Text
            DropList.Visible = false
            open = false
            if callback then callback(opt) end
        end)

        OptBtn.MouseEnter:Connect(function()
            OptBtn.BackgroundColor3 = Theme.InlineHover
            OptBtn.BackgroundTransparency = 0
            OptBtn.TextColor3 = Theme.Text
        end)
        OptBtn.MouseLeave:Connect(function()
            OptBtn.BackgroundTransparency = 1
            OptBtn.TextColor3 = opt == selected and Theme.Accent or Theme.TextDim
        end)
    end

    DropdownBtn.MouseButton1Click:Connect(function()
        open = not open
        DropList.Visible = open
        DropdownBtn.TextColor3 = open and Theme.Accent or Theme.Text
    end)

    return {
        Set = function(v)
            selected = v
            DropdownBtn.Text = v .. "  ▾"
            self.Flags[flag].Value = v
        end,
        Get = function() return selected end
    }
end

function NeverloseUI:AddMultiDropdown(section, text, options, defaults, callback, flag)
    local selected = defaults or {}
    local open = false
    self.Flags[flag] = { Value = selected, Type = "MultiDropdown" }

    local Frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        Parent = section.Container
    })

    local Label = Create("TextLabel", {
        Size = UDim2.new(0.45, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Frame
    })

    local DropdownBtn = Create("TextButton", {
        Size = UDim2.new(0.55, 0, 1, 0),
        Position = UDim2.new(0.45, 0, 0, 0),
        BackgroundColor3 = Theme.Inline,
        Text = "Select  ▾",
        TextColor3 = Theme.TextDim,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        Parent = Frame
    })
    Corner(6, DropdownBtn)
    Stroke(Theme.Outline, 1, DropdownBtn, 0.4)

    local function UpdateText()
        if #selected == 0 then
            DropdownBtn.Text = "Select  ▾"
            DropdownBtn.TextColor3 = Theme.TextDim
        elseif #selected <= 2 then
            DropdownBtn.Text = table.concat(selected, ", ") .. "  ▾"
            DropdownBtn.TextColor3 = Theme.Text
        else
            DropdownBtn.Text = #selected .. " selected  ▾"
            DropdownBtn.TextColor3 = Theme.Text
        end
    end

    local DropList = Create("ScrollingFrame", {
        Size = UDim2.new(0.55, 0, 0, math.min(#options * 22, 110)),
        Position = UDim2.new(0.45, 0, 1, 4),
        BackgroundColor3 = Theme.Visible,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, #options * 22),
        Visible = false,
        ZIndex = 100,
        Parent = Frame
    })
    Corner(6, DropList)
    Stroke(Theme.Accent, 1, DropList, 0.5)
    ListLayout(2, DropList)

    for _, opt in ipairs(options) do
        local isSelected = table.find(selected, opt) ~= nil

        local OptBtn = Create("TextButton", {
            Size = UDim2.new(1, -6, 0, 20),
            BackgroundTransparency = 1,
            Text = (isSelected and "● " or "○ ") .. opt,
            TextColor3 = isSelected and Theme.Accent or Theme.TextDim,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 101,
            Parent = DropList
        })

        OptBtn.MouseButton1Click:Connect(function()
            local idx = table.find(selected, opt)
            if idx then
                table.remove(selected, idx)
                OptBtn.Text = "○ " .. opt
                OptBtn.TextColor3 = Theme.TextDim
            else
                table.insert(selected, opt)
                OptBtn.Text = "● " .. opt
                OptBtn.TextColor3 = Theme.Accent
            end
            UpdateText()
            self.Flags[flag].Value = selected
            if callback then callback(selected) end
        end)

        OptBtn.MouseEnter:Connect(function()
            OptBtn.BackgroundColor3 = Theme.InlineHover
            OptBtn.BackgroundTransparency = 0
        end)
        OptBtn.MouseLeave:Connect(function()
            OptBtn.BackgroundTransparency = 1
        end)
    end

    DropdownBtn.MouseButton1Click:Connect(function()
        open = not open
        DropList.Visible = open
        DropdownBtn.TextColor3 = open and Theme.Accent or Theme.Text
    end)

    UpdateText()

    return {
        Set = function(v)
            selected = v
            UpdateText()
            self.Flags[flag].Value = v
        end,
        Get = function() return selected end
    }
end

function NeverloseUI:AddKeybind(section, text, default, callback, flag)
    local binding = false
    local key = default or Enum.KeyCode.None
    self.Flags[flag] = { Value = key, Type = "Keybind" }

    local Frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        Parent = section.Container
    })

    local Label = Create("TextLabel", {
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Frame
    })

    local KeyBtn = Create("TextButton", {
        Size = UDim2.new(0.45, 0, 1, 0),
        Position = UDim2.new(0.55, 0, 0, 0),
        BackgroundColor3 = Theme.Inline,
        Text = key.Name,
        TextColor3 = Theme.TextDim,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        Parent = Frame
    })
    Corner(6, KeyBtn)
    Stroke(Theme.Outline, 1, KeyBtn, 0.4)

    KeyBtn.MouseButton1Click:Connect(function()
        binding = true
        KeyBtn.Text = "..."
        KeyBtn.TextColor3 = Theme.Accent
    end)

    UserInputService.InputBegan:Connect(function(input, processed)
        if binding and not processed then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                key = input.KeyCode
                KeyBtn.Text = key.Name
                KeyBtn.TextColor3 = Theme.Text
                binding = false
                self.Flags[flag].Value = key
                if callback then callback(key) end
            end
        elseif not processed and input.KeyCode == key and not binding then
            if callback then callback(key) end
        end
    end)

    return {
        Set = function(k)
            key = k
            KeyBtn.Text = k.Name
            self.Flags[flag].Value = k
        end,
        Get = function() return key end
    }
end

function NeverloseUI:AddColorPicker(section, text, default, callback, flag)
    local color = default or Theme.Accent
    self.Flags[flag] = { Value = color, Type = "ColorPicker" }

    local Frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        Parent = section.Container
    })

    local Label = Create("TextLabel", {
        Size = UDim2.new(1, -50, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Frame
    })

    local ColorBtn = Create("TextButton", {
        Size = UDim2.new(0, 32, 0, 16),
        Position = UDim2.new(1, -32, 0.5, -8),
        BackgroundColor3 = color,
        Text = "",
        Parent = Frame
    })
    Corner(5, ColorBtn)
    Stroke(Theme.Outline, 1, ColorBtn, 0.3)

    ColorBtn.MouseButton1Click:Connect(function()
        local colors = {
            Theme.Accent,
            Color3.fromRGB(0, 220, 180),
            Color3.fromRGB(130, 100, 255),
            Color3.fromRGB(255, 100, 150),
            Color3.fromRGB(255, 200, 80),
            Color3.fromRGB(221, 223, 222),
        }
        local idx = 1
        for i, c in ipairs(colors) do
            if c == color then idx = i break end
        end
        color = colors[(idx % #colors) + 1]
        ColorBtn.BackgroundColor3 = color
        self.Flags[flag].Value = color
        if callback then callback(color) end
    end)

    return {
        Set = function(c)
            color = c
            ColorBtn.BackgroundColor3 = c
            self.Flags[flag].Value = c
        end,
        Get = function() return color end
    }
end

function NeverloseUI:AddButton(section, text, callback)
    local Btn = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundColor3 = Theme.Inline,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        Parent = section.Container
    })
    Corner(6, Btn)
    Stroke(Theme.Outline, 1, Btn, 0.4)

    Btn.MouseEnter:Connect(function()
        Btn.BackgroundColor3 = Theme.AccentDim
        Btn.TextColor3 = Theme.TextBright
    end)
    Btn.MouseLeave:Connect(function()
        Btn.BackgroundColor3 = Theme.Inline
        Btn.TextColor3 = Theme.Text
    end)
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

function NeverloseUI:AddLabel(section, text)
    return Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.TextDim,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = section.Container
    })
end

function NeverloseUI:AddDivider(section)
    return Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Theme.BorderSoft,
        BorderSizePixel = 0,
        Parent = section.Container
    })
end

function NeverloseUI:SaveConfig(name)
    if not isfolder or not writefile then return false end
    if not isfolder(self.ConfigFolder) then makefolder(self.ConfigFolder) end
    local data = {}
    for flag, item in pairs(self.Flags) do
        if item.Type == "ColorPicker" then
            data[flag] = { item.Value.R, item.Value.G, item.Value.B }
        elseif item.Type == "Keybind" then
            data[flag] = tostring(item.Value)
        else
            data[flag] = item.Value
        end
    end
    writefile(self.ConfigFolder .. "/" .. name .. ".json", HttpService:JSONEncode(data))
    return true
end

function NeverloseUI:LoadConfig(name)
    if not isfolder or not readfile then return false end
    local path = self.ConfigFolder .. "/" .. name .. ".json"
    if not isfile(path) then return false end
    local data = HttpService:JSONDecode(readfile(path))
    for flag, value in pairs(data) do
        if self.Flags[flag] then
            if self.Flags[flag].Type == "ColorPicker" then
                self.Flags[flag].Value = Color3.new(value[1], value[2], value[3])
            else
                self.Flags[flag].Value = value
            end
        end
    end
    return true
end

function NeverloseUI:GetConfigList()
    if not isfolder or not listfiles then return {} end
    if not isfolder(self.ConfigFolder) then return {} end
    local configs = {}
    for _, f in ipairs(listfiles(self.ConfigFolder)) do
        local name = f:match("[^/\\]+%.json$")
        if name then table.insert(configs, name:gsub("%.json$", "")) end
    end
    return configs
end

function NeverloseUI:Toggle()
    self.Main.Visible = not self.Main.Visible
    self.Shadow.Visible = self.Main.Visible
end

function NeverloseUI:Notify(title, message, duration)
    duration = duration or 3

    local NotifFrame = Create("Frame", {
        Size = UDim2.new(0, 270, 0, 58),
        Position = UDim2.new(1, 280, 1, -68),
        BackgroundColor3 = Theme.Visible,
        Parent = self.ScreenGui
    })
    Corner(9, NotifFrame)
    Stroke(Theme.Accent, 1, NotifFrame, 0.3)

    Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 18),
        Position = UDim2.new(0, 10, 0, 6),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Accent,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = NotifFrame
    })

    Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 28),
        Position = UDim2.new(0, 10, 0, 26),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = Theme.TextDim,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = NotifFrame
    })

    TweenService:Create(NotifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
        Position = UDim2.new(1, -280, 1, -68)
    }):Play()

    task.delay(duration, function()
        TweenService:Create(NotifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            Position = UDim2.new(1, 280, 1, -68)
        }):Play()
        task.wait(0.35)
        NotifFrame:Destroy()
    end)
end

--========================================================
-- BUILD UI (inline, no external loading)
--========================================================

local Window = NeverloseUI.new("NEVERLOSE")

-- Sidebar structure
Window:AddSectionLabel("Aimbot", 1)
local RageTab  = Window:AddTab("Rage",  "◆", 2)
local LegitTab = Window:AddTab("Legit", "◈", 3)

Window:AddSectionLabel("Common", 4)
local VisualsTab = Window:AddTab("Visuals", "◉", 5)
local SkinTab    = Window:AddTab("Skinchanger",   "◇", 6)
local MiscTab    = Window:AddTab("Miscellaneous", "▣", 7)

Window:AddSectionLabel("Presets", 8)
local ConfigsTab = Window:AddTab("Configs", "○", 9)

-- RAGE
local RageMain   = Window:AddSection(RageTab, "Main", "left")
local RageOther  = Window:AddSection(RageTab, "Other", "right")

RageMain:AddToggle("Enabled", true, function(v) print("Rage:", v) end, "rage_enabled")
RageMain:AddToggle("Silent Aim", true, nil, "rage_silent", nil, true)
RageMain:AddToggle("Automatic Fire", true, nil, "rage_autofire")
RageMain:AddToggle("Penetrate Walls", true, nil, "rage_penetrate")
RageMain:AddSlider("Field of View", 0, 360, 180, nil, "rage_fov", "°")

RageOther:AddDropdown("History", {"Maximum", "High", "Medium", "Low"}, "Maximum", nil, "rage_history")
RageOther:AddToggle("Delay Shot", false, nil, "rage_delay")
RageOther:AddToggle("Duck Peek Assist", false, nil, "rage_duck")
RageOther:AddToggle("Rapid Fire", true, nil, "rage_rapid")

-- LEGIT
local LegitMain = Window:AddSection(LegitTab, "Main", "left")
local LegitAcc  = Window:AddSection(LegitTab, "Accuracy", "left")

LegitMain:AddToggle("Enabled", false, nil, "legit_enabled")
LegitMain:AddDropdown("Activation", {"Hotkey", "Always", "Toggle"}, "Hotkey", nil, "legit_act")
LegitMain:AddKeybind("Hotkey", Enum.KeyCode.LeftAlt, nil, "legit_key")
LegitAcc:AddSlider("Field Of View", 0, 30, 10, nil, "legit_fov", "°")
LegitAcc:AddSlider("Smooth", 0, 100, 50, nil, "legit_smooth")

-- VISUALS
local VisPlayers = Window:AddSection(VisualsTab, "Players", "left")
local VisWorld   = Window:AddSection(VisualsTab, "World", "right")

VisPlayers:AddToggle("Enabled", true, nil, "vis_enabled")
VisPlayers:AddToggle("Teammates", false, nil, "vis_teammates", nil, true)
VisPlayers:AddToggle("Behind Walls", true, nil, "vis_behind", nil, true)
VisPlayers:AddToggle("Bullet Tracers", true, nil, "vis_tracers", nil, true)

VisWorld:AddToggle("Bomb", false, nil, "world_bomb", nil, true)
VisWorld:AddToggle("Weapons", false, nil, "world_weapons", nil, true)
VisWorld:AddToggle("Night Mode", false, nil, "world_night", nil, true)
VisWorld:AddDropdown("Crosshair", {"Select", "Dot", "Cross"}, "Select", nil, "world_crosshair")

-- MISC
local MiscUtil = Window:AddSection(MiscTab, "Utilities", "left")
MiscUtil:AddButton("Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)
MiscUtil:AddButton("Copy Job ID", function()
    if setclipboard then
        setclipboard(game.JobId)
        Window:Notify("Copied", "Job ID in clipboard", 2)
    end
end)

-- CONFIGS
local CfgMain = Window:AddSection(ConfigsTab, "Config", "left")
CfgMain:AddButton("Save Config", function()
    if Window:SaveConfig("mysave") then
        Window:Notify("Saved", "Config saved", 2)
    else
        Window:Notify("Error", "Filesystem not available", 2)
    end
end)
CfgMain:AddButton("Load Config", function()
    if Window:LoadConfig("mysave") then
        Window:Notify("Loaded", "Config loaded", 2)
    else
        Window:Notify("Error", "Not found", 2)
    end
end)

-- Init
Window:SelectTab("Rage")

UserInputService.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.Insert then
        Window:Toggle()
    end
end)

Window:Notify("Neverlose", "UI loaded. Insert to toggle.", 3)
