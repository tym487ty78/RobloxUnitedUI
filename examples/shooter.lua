-- UnitedUI shooter layout example (UI structure only, no shooter logic)

local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/tym487ty78/RobloxUnitedUI/refs/heads/main/main.lua"))()

local win = UI.Window("Shooter Panel", 860, 100, 70, 560, {
    SaveConfigs = true,
    Theme = "red",
    Background = "transparent",
})

win:SetToggleKeybind(Enum.KeyCode.Insert)

-- Aimbot
local aimbotTab = win:CreateTab("Aimbot", 2, {"Main", "Advanced"})
local aimMain = aimbotTab:GetContainer(1)
local aimAdv = aimbotTab:GetContainer(2)

aimMain:Label("Aimbot Core")
aimMain:Toggle("Enable Aimbot", false, function() end)
aimMain:Dropdown("Aim Part", {"Head", "Torso", "Closest"}, "Head", function() end)
aimMain:Slider("FOV", 1, 360, 90, function() end)
aimMain:Slider("Smoothness", 0, 100, 35, function() end)
aimMain:Toggle("Team Check", true, function() end)
aimMain:Toggle("Wall Check", false, function() end)
aimMain:Keybind("Aimbot Hold", Enum.KeyCode.Q, function(state, key)
    print("Aimbot hold:", state, key)
end, nil, "hold")

aimAdv:Label("Targeting Filters")
aimAdv:MultiDropdown("Hitboxes", {"Head", "Torso", "Arms", "Legs"}, {"Head", "Torso"}, function() end)
aimAdv:Slider("Prediction", 0, 100, 15, function() end)
aimAdv:Slider("Max Distance", 10, 2000, 600, function() end)
aimAdv:Dropdown("Priority", {"Distance", "Health", "Crosshair"}, "Distance", function() end)
aimAdv:Toggle("Auto Shoot", false, function() end)
aimAdv:Toggle("Silent Aim", false, function() end)

-- Visuals
local visualsTab = win:CreateTab("Visuals", 2, {"ESP", "World"})
local esp = visualsTab:GetContainer(1)
local world = visualsTab:GetContainer(2)

esp:Label("ESP")
esp:Toggle("Enable ESP", true, function() end)
esp:Toggle("Boxes", true, function() end)
esp:Toggle("Name", true, function() end)
esp:Toggle("Distance", true, function() end)
esp:Toggle("Health Bar", true, function() end)
esp:ColorPicker("Enemy Color", Color3.fromRGB(255, 85, 85), function() end)
esp:ColorPicker("Team Color", Color3.fromRGB(80, 170, 255), function() end)

world:Label("World / Camera")
world:Toggle("Crosshair", true, function() end)
world:Slider("Camera FOV", 60, 120, 90, function() end)
world:Toggle("Remove Fog", false, function() end)
world:Toggle("Night Mode", false, function() end)
world:Toggle("Bullet Tracers", false, function() end)
world:ColorPicker("Tracer Color", Color3.fromRGB(255, 210, 120), function() end)

-- Weapon tab
local weaponTab = win:CreateTab("Weapons", 2, {"Gun Mods", "Recoil"})
local gunMods = weaponTab:GetContainer(1)
local recoil = weaponTab:GetContainer(2)

gunMods:Label("Gun Mods")
gunMods:Toggle("No Spread", false, function() end)
gunMods:Toggle("Rapid Fire", false, function() end)
gunMods:Toggle("Infinite Ammo", false, function() end)
gunMods:Slider("Fire Rate", 1, 50, 8, function() end)
gunMods:Slider("Damage Multiplier", 1, 10, 2, function() end)

recoil:Label("Recoil")
recoil:Toggle("No Recoil", false, function() end)
recoil:Slider("Horizontal Recoil", 0, 100, 20, function() end)
recoil:Slider("Vertical Recoil", 0, 100, 25, function() end)
recoil:Toggle("No Camera Shake", false, function() end)

-- Player / movement
local playerTab = win:CreateTab("Player", 1, {"Movement"})
local move = playerTab:GetContainer(1)

move:Label("Movement")
move:Toggle("Bhop", false, function() end)
move:Toggle("Auto Strafe", false, function() end)
move:Slider("WalkSpeed", 16, 100, 16, function() end)
move:Slider("JumpPower", 50, 200, 50, function() end)
move:Toggle("Third Person", false, function() end)

-- Config / misc
local configTab = win:CreateTab("Config", 1, {"General"})
local cfg = configTab:GetContainer(1)

cfg:Label("Configs")
cfg:Input("Config name...", "default")
cfg:Button("Save Config", function()
    print("Saved:", win:SaveConfig())
end)
cfg:Button("Load Config", function()
    print("Loaded:", win:LoadConfig())
end)
cfg:Separator()
cfg:Dropdown("Theme", {"red", "blue", "green", "yellow", "purple", "black", "white"}, "red", function(name)
    UI.SetTheme(name)
end)
cfg:Dropdown("Background", {"transparent", "blurr", "normal"}, "transparent", function(mode)
    print("Background mode selected:", mode, "(recreate window to apply)")
end)
cfg:Button("Test Notification", function()
    UI.Notification({
        Delay = 3,
        Location = "bb",
        Mode = "Warning",
        Title = "Shooter UI",
        Text = "Structure-only example",
    })
end)
cfg:Button("Destroy", function()
    win:Destroy()
end)
