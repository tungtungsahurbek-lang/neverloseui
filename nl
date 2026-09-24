-- Neverlose UI Library for Roblox Executors (Custom Palette)
-- Accent: rgb(155, 92, 92) | Muted dark red/mauve
-- Luau | Synapse X, KRNL, Script-Ware, etc.

local NeverloseUI = {}
NeverloseUI.__index = NeverloseUI

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Theme (exact colors from Operator)
local Theme = {
    -- Core
    Background    = Color3.fromRGB(17, 19, 19),    -- main background
    Visible       = Color3.fromRGB(20, 23, 22),    -- visible backgrounds (sections, sidebar, topbar)
    Inline        = Color3.fromRGB(25, 27, 27),    -- inline elements (buttons, dropdowns, sliders track, toggles off)
    
    -- Accent
    Accent        = Color3.fromRGB(155, 92, 92),   -- main accent
    AccentSoft    = Color3.fromRGB(175, 115, 115), -- hover accent
    AccentDim     = Color3.fromRGB(120, 70, 70),   -- pressed/dim accent
    
    -- Text
    Text          = Color3.fromRGB(221, 223, 222), -- main text
    TextBright    = Color3.fromRGB(245, 247, 246), -- hover text
    TextDim       = Color3.fromRGB(140, 142, 141), -- secondary text
    TextMuted     = Color3.fromRGB(100, 102, 101), -- muted
    
    -- Outline / Glow
    Outline       = Color3.fromRGB(0, 0, 0),       -- window outline
    Glow          = Color3.fromRGB(0, 0, 0),       -- glow effect (shadow)
    
    -- Derived
    BorderSoft    = Color3.fromRGB(35, 38, 38),
    SectionLabel  = Color3.fromRGB(120, 124, 123),
    TrackBg       = Color3.fromRGB(25, 27, 27),    -- same as inline
    Knob          = Color3.fromRGB(221, 223, 222), -- white-ish knob
}

-- Utility
local function Create(className, props, children)
    local inst = Instance.new(className)
    for k, v in pairs(props) do
        if k ~= "Parent" then
            inst[k] = v
        end
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = inst
        end
    end
    if props.Parent then
        inst.Parent = props.Parent
    end
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

local function ListLayout(px, parent, direction)
    return Create("UIListLayout", {
        Padding = UDim.new(0, px),
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = direction or Enum.FillDirection.Vertical,
        Parent = parent
    })
end

local function Gradient(parent, rotation)
    return Create("UIGradient", {
        Rotation = rotation or 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(215, 218, 217))
        }),
        Parent = parent
    })
end

-- Dragging
local dragging, dragStart, startPos

-- Main Window Constructor
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
        Parent = game.CoreGui
    })

    -- Drop shadow (glow effect using ImageLabel)
    local Shadow = Create("ImageLabel", {
        Size = UDim2.new(1, 60, 1, 60),
        Position = UDim2.new(0, -30, 0, -30),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Theme.Glow,
        ImageTransparency = 0.4,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Parent = self.ScreenGui
    })

    -- Main Frame
    self.Main = Create("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 840, 0, 560),
        Position = UDim2.new(0.5, -420, 0.5, -280),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Parent = self.ScreenGui
    })
    Corner(10, self.Main)
    Stroke(Theme.Outline, 1.5, self.Main)  -- window outline black

    -- Sidebar
    self.Sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 215, 1, 0),
        BackgroundColor3 = Theme.Visible,
        BorderSizePixel = 0,
        Parent = self.Main
    })
    Corner(10, self.Sidebar)

    -- Logo
    local Logo = Create("TextLabel", {
        Size = UDim2.new(1, -40, 0, 36),
        Position = UDim2.new(0, 20, 0, 18),
        BackgroundTransparency = 1,
        Text = "NEVERLOSE",
        TextColor3 = Theme.Text,
        TextSize = 20,
        Font = Enum.Font.GothamBlack,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.Sidebar
    })

    -- Tab Container
    self.TabContainer = Create("Frame", {
        Size = UDim2.new(1, -20, 1, -150),
        Position = UDim2.new(0, 10, 0, 70),
        BackgroundTransparency = 1,
        Parent = self.Sidebar
    })
    ListLayout(3, self.TabContainer)

    -- Content Area
    self.ContentArea = Create("Frame", {
        Size = UDim2.new(1, -240, 1, -75),
        Position = UDim2.new(0, 225, 0, 65),
        BackgroundTransparency = 1,
        Parent = self.Main
    })

    -- Topbar
    self.Topbar = Create("Frame", {
        Size = UDim2.new(1, -240, 0, 50),
        Position = UDim2.new(0, 225, 0, 8),
        BackgroundTransparency = 1,
        Parent = self.Main
    })

    -- Save button
    local SaveBtn = Create("TextButton", {
        Size = UDim2.new(0, 75, 0, 30),
        Position = UDim2.new(0, 4, 0, 8),
        BackgroundColor3 = Theme.Inline,
        Text = "Save",
        TextColor3 = Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        Parent = self.Topbar
    })
    Corner(7, SaveBtn)
    Stroke(Theme.Outline, 1, SaveBtn, 0.5)
    SaveBtn.MouseEnter:Connect(function() SaveBtn.BackgroundColor3 = Theme.AccentDim end)
    SaveBtn.MouseLeave:Connect(function() SaveBtn.BackgroundColor3 = Theme.Inline end)

    -- Config dropdown
    local ConfigDropdown = Create("TextButton", {
        Size = UDim2.new(0, 160, 0, 30),
        Position = UDim2.new(0, 88, 0, 8),
        BackgroundColor3 = Theme.Inline,
        Text = "Global ▼",
        TextColor3 = Theme.TextDim,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        Parent = self.Topbar
    })
    Corner(7, ConfigDropdown)
    Stroke(Theme.Outline, 1, ConfigDropdown, 0.5)

    -- User card
    local UserCard = Create("Frame", {
        Size = UDim2.new(1, -20, 0, 52),
        Position = UDim2.new(0, 10, 1, -64),
        BackgroundColor3 = Theme.Inline,
        BorderSizePixel = 0,
        Parent = self.Sidebar
    })
    Corner(9, UserCard)
    Stroke(Theme.Outline, 1, UserCard, 0.5)

    local Avatar = Create("Frame", {
        Size = UDim2.new(0, 38, 0, 38),
        Position = UDim2.new(0, 7, 0, 7),
        BackgroundColor3 = Theme.Accent,
        Parent = UserCard
    })
    Corner(8, Avatar)
    local avatarGrad = Create("UIGradient", {
        Rotation = 135,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Accent),
            ColorSequenceKeypoint.new(1, Theme.AccentDim)
        }),
        Parent = Avatar
    })

    Create("TextLabel", {
        Size = UDim2.new(1, -55, 0, 16),
        Position = UDim2.new(0, 54, 0, 8),
        BackgroundTransparency = 1,
        Text = LocalPlayer.Name,
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
        Text = "Till: 28.09 21:54",
        TextColor3 = Theme.AccentSoft,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = UserCard
    })

    -- Drag
    self.Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.Main.Position
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
            self.Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            Shadow.Position = self.Main.Position - UDim2.new(0, 30, 0, 30)
        end
    end)

    return self
end

-- Add Section Label to Sidebar
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
        PaddingLeft = UDim.new(0, 14),
        PaddingTop = UDim.new(0, 6),
        Parent = Label
    })
    return Label
end

-- Add Tab
function NeverloseUI:AddTab(name, icon, order)
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

    Create("TextLabel", {
        Size = UDim2.new(0, 24, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = icon or "●",
        TextColor3 = Theme.TextDim,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = Btn
    })

    Create("TextLabel", {
        Size = UDim2.new(1, -54, 1, 0),
        Position = UDim2.new(0, 44, 0, 0),
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
        if not Tab.Active then
            Btn.BackgroundTransparency = 0.6
        end
    end)
    Btn.MouseLeave:Connect(function()
        if not Tab.Active then
            Btn.BackgroundTransparency = 1
        end
    end)

    table.insert(self.Tabs, Tab)
    return Tab
end

-- Select Tab
function NeverloseUI:SelectTab(name)
    for _, tab in ipairs(self.Tabs) do
        local isActive = tab.Name == name
        tab.Active = isActive
        tab.Content.Visible = isActive

        if isActive then
            tab.Button.BackgroundTransparency = 0
            tab.Button.BackgroundColor3 = Theme.Inline
            local existingStroke = tab.Button:FindFirstChildOfClass("UIStroke")
            if not existingStroke then
                Stroke(Theme.Accent, 1, tab.Button, 0.3)
            else
                existingStroke.Color = Theme.Accent
                existingStroke.Transparency = 0.3
            end
        else
            tab.Button.BackgroundTransparency = 1
            local existingStroke = tab.Button:FindFirstChildOfClass("UIStroke")
            if existingStroke then
                existingStroke.Transparency = 1
            end
        end

        for _, child in ipairs(tab.Button:GetChildren()) do
            if child:IsA("TextLabel") then
                if child.Text == tab.Name then
                    child.TextColor3 = isActive and Theme.Text or Theme.TextDim
                else
                    child.TextColor3 = isActive and Theme.Accent or Theme.TextDim
                end
            end
        end
    end
end

-- Add Section (groupbox)
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

    local section = {
        Frame = Section,
        Container = Container,
        Tab = tab
    }

    section.AddToggle = function(_, text, default, callback, flag)
        return self:AddToggle(section, text, default, callback, flag)
    end
    section.AddSlider = function(_, text, min, max, default, callback, flag, suffix)
        return self:AddSlider(section, text, min, max, default, callback, flag, suffix)
    end
    section.AddDropdown = function(_, text, options, default, callback, flag)
        return self:AddDropdown(section, text, options, default, callback, flag)
    end
    section.AddMultiDropdown = function(_, text, options, defaults, callback, flag)
        return self:AddMultiDropdown(section, text, options, defaults, callback, flag)
    end
    section.AddKeybind = function(_, text, default, callback, flag)
        return self:AddKeybind(section, text, default, callback, flag)
    end
    section.AddButton = function(_, text, callback)
        return self:AddButton(section, text, callback)
    end
    section.AddColorPicker = function(_, text, default, callback, flag)
        return self:AddColorPicker(section, text, default, callback, flag)
    end
    section.AddLabel = function(_, text)
        return self:AddLabel(section, text)
    end
    section.AddDivider = function(_)
        return self:AddDivider(section)
    end

    return section
end

-- Toggle Element
function NeverloseUI:AddToggle(section, text, default, callback, flag)
    local toggled = default or false
    self.Flags[flag] = { Value = toggled, Type = "Toggle" }

    local Frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
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

    local ToggleBg = Create("Frame", {
        Size = UDim2.new(0, 34, 0, 18),
        Position = UDim2.new(1, -34, 0.5, -9),
        BackgroundColor3 = toggled and Theme.Accent or Theme.Inline,
        Parent = Frame
    })
    Corner(9, ToggleBg)
    Stroke(Theme.Outline, 1, ToggleBg, 0.4)

    local Knob = Create("Frame", {
        Size = UDim2.new(0, 12, 0, 12),
        Position = toggled and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6),
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
        self.Flags[flag].Value = state
        TweenService:Create(ToggleBg, TweenInfo.new(0.18, Enum.EasingStyle.Quart), {
            BackgroundColor3 = state and Theme.Accent or Theme.Inline
        }):Play()
        TweenService:Create(Knob, TweenInfo.new(0.18, Enum.EasingStyle.Quart), {
            Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6),
            BackgroundColor3 = state and Theme.Knob or Theme.TextDim
        }):Play()
        if callback then callback(state) end
    end

    Button.MouseButton1Click:Connect(function()
        SetToggle(not toggled)
    end)

    Frame.MouseEnter:Connect(function()
        Label.TextColor3 = Theme.TextBright
    end)
    Frame.MouseLeave:Connect(function()
        Label.TextColor3 = Theme.Text
    end)

    return {
        Set = SetToggle,
        Get = function() return toggled end,
        Frame = Frame
    }
end

-- Slider Element
function NeverloseUI:AddSlider(section, text, min, max, default, callback, flag, suffix)
    local value = default or min
    self.Flags[flag] = { Value = value, Type = "Slider" }

    local Frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
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
        TextColor3 = Theme.TextDim,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = Frame
    })

    local Track = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 4),
        Position = UDim2.new(0, 0, 0, 26),
        BackgroundColor3 = Theme.Inline,
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

-- Dropdown
function NeverloseUI:AddDropdown(section, text, options, default, callback, flag)
    local selected = default
    local open = false
    self.Flags[flag] = { Value = selected, Type = "Dropdown" }

    local Frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
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

    local DropdownBtn = Create("TextButton", {
        Size = UDim2.new(0.45, 0, 1, 0),
        Position = UDim2.new(0.55, 0, 0, 0),
        BackgroundColor3 = Theme.Inline,
        Text = (selected or "Select...") .. " ▼",
        TextColor3 = Theme.TextDim,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        Parent = Frame
    })
    Corner(6, DropdownBtn)
    Stroke(Theme.Outline, 1, DropdownBtn, 0.4)

    local DropList = Create("ScrollingFrame", {
        Size = UDim2.new(0.45, 0, 0, math.min(#options * 24, 120)),
        Position = UDim2.new(0.55, 0, 1, 4),
        BackgroundColor3 = Theme.Visible,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, #options * 24),
        Visible = false,
        ZIndex = 100,
        Parent = Frame
    })
    Corner(6, DropList)
    Stroke(Theme.Outline, 1, DropList, 0.2)
    ListLayout(2, DropList)

    for _, opt in ipairs(options) do
        local OptBtn = Create("TextButton", {
            Size = UDim2.new(1, -6, 0, 22),
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
            DropdownBtn.Text = opt .. " ▼"
            DropdownBtn.TextColor3 = Theme.Text
            DropList.Visible = false
            open = false
            if callback then callback(opt) end
        end)

        OptBtn.MouseEnter:Connect(function()
            OptBtn.BackgroundColor3 = Theme.Inline
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
            DropdownBtn.Text = v .. " ▼"
            self.Flags[flag].Value = v
        end,
        Get = function() return selected end
    }
end

-- Multi Dropdown
function NeverloseUI:AddMultiDropdown(section, text, options, defaults, callback, flag)
    local selected = defaults or {}
    local open = false
    self.Flags[flag] = { Value = selected, Type = "MultiDropdown" }

    local Frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
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

    local function UpdateText()
        if #selected == 0 then
            DropdownBtn.Text = "Select... ▼"
            DropdownBtn.TextColor3 = Theme.TextDim
        elseif #selected <= 2 then
            DropdownBtn.Text = table.concat(selected, ", ") .. " ▼"
            DropdownBtn.TextColor3 = Theme.Text
        else
            DropdownBtn.Text = #selected .. " selected ▼"
            DropdownBtn.TextColor3 = Theme.Text
        end
    end

    local DropdownBtn = Create("TextButton", {
        Size = UDim2.new(0.45, 0, 1, 0),
        Position = UDim2.new(0.55, 0, 0, 0),
        BackgroundColor3 = Theme.Inline,
        Text = "Select... ▼",
        TextColor3 = Theme.TextDim,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        Parent = Frame
    })
    Corner(6, DropdownBtn)
    Stroke(Theme.Outline, 1, DropdownBtn, 0.4)

    local DropList = Create("ScrollingFrame", {
        Size = UDim2.new(0.45, 0, 0, math.min(#options * 24, 120)),
        Position = UDim2.new(0.55, 0, 1, 4),
        BackgroundColor3 = Theme.Visible,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, #options * 24),
        Visible = false,
        ZIndex = 100,
        Parent = Frame
    })
    Corner(6, DropList)
    Stroke(Theme.Outline, 1, DropList, 0.2)
    ListLayout(2, DropList)

    for _, opt in ipairs(options) do
        local isSelected = table.find(selected, opt) ~= nil

        local OptBtn = Create("TextButton", {
            Size = UDim2.new(1, -6, 0, 22),
            BackgroundTransparency = 1,
            Text = (isSelected and "✓ " or "  ") .. opt,
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
                OptBtn.Text = "  " .. opt
                OptBtn.TextColor3 = Theme.TextDim
            else
                table.insert(selected, opt)
                OptBtn.Text = "✓ " .. opt
                OptBtn.TextColor3 = Theme.Accent
            end
            UpdateText()
            self.Flags[flag].Value = selected
            if callback then callback(selected) end
        end)

        OptBtn.MouseEnter:Connect(function()
            OptBtn.BackgroundColor3 = Theme.Inline
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

-- Keybind
function NeverloseUI:AddKeybind(section, text, default, callback, flag)
    local binding = false
    local key = default or Enum.KeyCode.None
    self.Flags[flag] = { Value = key, Type = "Keybind" }

    local Frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
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
        Size = UDim2.new(0.35, 0, 1, 0),
        Position = UDim2.new(0.65, 0, 0, 0),
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

-- Color Picker
function NeverloseUI:AddColorPicker(section, text, default, callback, flag)
    local color = default or Theme.Accent
    self.Flags[flag] = { Value = color, Type = "ColorPicker" }

    local Frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
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
        Size = UDim2.new(0, 34, 0, 18),
        Position = UDim2.new(1, -34, 0.5, -9),
        BackgroundColor3 = color,
        Text = "",
        Parent = Frame
    })
    Corner(5, ColorBtn)
    Stroke(Theme.Outline, 1, ColorBtn, 0.3)

    ColorBtn.MouseButton1Click:Connect(function()
        local colors = {
            Color3.fromRGB(155, 92, 92),
            Color3.fromRGB(92, 155, 120),
            Color3.fromRGB(92, 120, 155),
            Color3.fromRGB(155, 140, 92),
            Color3.fromRGB(130, 92, 155),
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

-- Button
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

-- Label
function NeverloseUI:AddLabel(section, text)
    local Label = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.TextDim,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = section.Container
    })
    return Label
end

-- Divider
function NeverloseUI:AddDivider(section)
    local Divider = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Theme.Outline,
        BorderSizePixel = 0,
        BackgroundTransparency = 0.5,
        Parent = section.Container
    })
    return Divider
end

-- Config System
function NeverloseUI:SaveConfig(name)
    if not isfolder(self.ConfigFolder) then
        makefolder(self.ConfigFolder)
    end
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
end

function NeverloseUI:LoadConfig(name)
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
    if not isfolder(self.ConfigFolder) then return {} end
    local files = listfiles(self.ConfigFolder)
    local configs = {}
    for _, f in ipairs(files) do
        local name = f:match("[^/\\]+%.json$")
        if name then
            table.insert(configs, name:gsub("%.json$", ""))
        end
    end
    return configs
end

-- Toggle visibility
function NeverloseUI:Toggle()
    self.Main.Visible = not self.Main.Visible
end

-- Notification (accent colored)
function NeverloseUI:Notify(title, message, duration)
    duration = duration or 3

    local NotifFrame = Create("Frame", {
        Size = UDim2.new(0, 280, 0, 60),
        Position = UDim2.new(1, 290, 1, -70),
        BackgroundColor3 = Theme.Visible,
        Parent = self.ScreenGui
    })
    Corner(9, NotifFrame)
    Stroke(Theme.Accent, 1, NotifFrame, 0.2)

    Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 6),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Accent,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = NotifFrame
    })

    Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 28),
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
        Position = UDim2.new(1, -290, 1, -70)
    }):Play()

    task.delay(duration, function()
        TweenService:Create(NotifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            Position = UDim2.new(1, 290, 1, -70)
        }):Play()
        task.wait(0.35)
        NotifFrame:Destroy()
    end)
end

return NeverloseUI
