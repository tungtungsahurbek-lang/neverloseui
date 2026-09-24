local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourpath/neverlose_blue_cyan.lua"))()

local Window = UI.new("NEVERLOSE")

UI:AddSectionLabel("Aimbot", 1)
Window:AddTab("Rage",         "◆", 2)
Window:AddTab("Legit",        "◈", 3)

UI:AddSectionLabel("Common", 4)
local VisualsTab = Window:AddTab("Visuals", "◉", 5)
Window:AddTab("Skinchanger",    "◇", 6)
Window:AddTab("Miscellaneous",  "◆", 7)

UI:AddSectionLabel("Presets", 8)
Window:AddTab("Configs", "○", 9)

-- Visuals tab
local PlayersSec = UI:AddSection(VisualsTab, "Players", "left")
local WorldSec   = UI:AddSection(VisualsTab, "World", "right")
local ModelsSec  = UI:AddSection(VisualsTab, "Models", "left")
local CommonSec  = UI:AddSection(VisualsTab, "Common", "right")

-- Players
PlayersSec:AddToggle("Enabled", true, nil, "vis_enabled")
PlayersSec:AddToggle("Teammates", false, nil, "vis_teammates", nil, true)  -- true = gear icon
PlayersSec:AddToggle("Behind Walls", true, nil, "vis_behind", nil, true)
PlayersSec:AddToggle("Bullet Tracers", true, nil, "vis_tracers", nil, true)
PlayersSec:AddToggle("Offscreen ESP", false, nil, "vis_offscreen", nil, true)
PlayersSec:AddToggle("Sounds", false, nil, "vis_sounds")
PlayersSec:AddToggle("Radar", false, nil, "vis_radar")

-- World
WorldSec:AddToggle("Bomb", false, nil, "world_bomb", nil, true)
WorldSec:AddToggle("Weapons", false, nil, "world_weapons", nil, true)
WorldSec:AddToggle("Grenades", false, nil, "world_grenades", nil, true)
WorldSec:AddToggle("Grenade Trajectory", false, nil, "world_traj", nil, true)
WorldSec:AddToggle("Grenade Proximity Warning", false, nil, "world_warn")
WorldSec:AddToggle("Night Mode", false, nil, "world_night", nil, true)
WorldSec:AddToggle("Force Thirdperson", false, nil, "world_thirdperson")
WorldSec:AddDropdown("Visual Recoil", {"Default", "Off", "Custom"}, "Default", nil, "world_recoil")
WorldSec:AddDropdown("Crosshair", {"Select", "Dot", "Cross"}, "Select", nil, "world_crosshair")
WorldSec:AddDropdown("Removals", {"Select", "Smoke", "Flash"}, "Select", nil, "world_removals")
WorldSec:AddToggle("Hit Marker", false, nil, "world_hitmarker", nil, true)

-- Models
ModelsSec:AddToggle("Enemies", false, nil, "models_enemies", nil, true)
ModelsSec:AddToggle("Teammates", false, nil, "models_teammates", nil, true)
ModelsSec:AddToggle("Local Player", false, nil, "models_local", nil, true)
ModelsSec:AddToggle("Ragdolls", false, nil, "models_ragdolls", nil, true)

Window:SelectTab("Visuals")

UserInputService.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.Insert then
        Window:Toggle()
    end
end)

Window:Notify("Neverlose", "Blue theme loaded. Insert to toggle.", 3)
