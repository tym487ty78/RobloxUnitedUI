local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/tym487ty78/RobloxUnitedUI/refs/heads/main/main.lua"))()
local win = UI.Window("United UI", 760, 120, 80, 500, {
    SaveConfigs = true, -- save/load size, position and toggle key
    Background = "transparent", -- transparent | blurr | normal
    Theme = "blue", -- blue/red/green/yellow/purple/black/white/custom
    -- CustomTheme = {Accent = Color3.fromRGB(255, 170, 80), AccentDark = Color3.fromRGB(204, 120, 52)},
})
win:SetToggleKeybind(Enum.KeyCode.RightShift) -- hide/show whole UI with this key

local mainTab = win:CreateTab("Main", 2, {"Aim", "Visuals"})
local miscTab = win:CreateTab("Misc", 1, {"General"})
local left = mainTab:GetContainer(1)
local right = mainTab:GetContainer(2)
local misc = miscTab:GetContainer(1)

-- Label with rich text colors + style options + double click callback
left:Label(
    "<font color=\"#f2f2f2\">Combat</font> <font color=\"#68d477\">ready</font> <font color=\"#7ab3ff\">v2</font>",
    function(text)
        print("Double clicked label:", text)
    end,
    {
        TextSize = 13,
        StrokeColor = Color3.fromRGB(22, 22, 22),
        StrokeThickness = 1,
    }
)

local tg = left:Toggle("Enabled", false, function(v) print("Enabled:", v) end)
left:Slider("Range", 0, 300, 120, function(v) print("Range:", v) end)
local dd = left:Dropdown("Mode", {"Legit", "Rage", "Silent"}, "Legit", function(v) print("Mode:", v) end)
local mdd = left:MultiDropdown("Targets", {"Head", "Torso", "Arms", "Legs"}, {"Head", "Torso"}, function(values)
    print("MultiDropdown:", table.concat(values, ", "))
end)
local cp = left:ColorPicker("ESP Color", Color3.fromRGB(255, 120, 120), function(c) print("Color:", c) end)
local menuKey = left:Keybind("Menu Key", Enum.KeyCode.RightShift, function(state, key)
end, function(oldKey, newKey)
    win:SetToggleKeybind(newKey)
end, "toggle")


win:SetToggleKeybind(menuKey)

local notes = left:MultiLabel({
    "This is MultiLabel",
    "It supports multiple lines.",
    "<font color=\"#ffd56c\">RichText works here too.</font>",
})

local notifTab = win:CreateNotificationsTab("Notifications")
notifTab:SetSettings({
    Delay = 3,
    Location = "bb",
    Mode = "Success",
    Title = "UnitedUI",
    Text = "This notification came from notifications tab!",
})
notifTab:Send()

local btn = right:Button("Execute", function() print("Clicked!") end)
right:Button("Minimize UI", function() win:Minimize() end)
local nameInput = right:Input("Name...", "", function(text) print("Input:", text) end, {
    ClearOnFocus = true,
})
local scriptInput = right:Input("Paste script here...", "", function(text)
    print("Multiline text:", text)
end, {
    Multiline = true,
    ClearOnFocus = false,
})
right:Separator()
right:Label("Helpers demo")
local removable = right:Label("I can be hidden / shown / deleted")

-- Helper API:
btn:PressButton()
tg:ToggleToggle()
print("toggle state:", tg:GetToggle())
dd:ChangeDropdown("Silent")
mdd:ToggleOption("Arms", true)
cp:ChangeColor(Color3.fromRGB(120, 220, 255))
win:ChangeColor(cp, Color3.fromRGB(200, 200, 200))
print("Menu key mode:", menuKey:GetMode())
menuKey:SetMode("press")
menuKey:SetMode("toggle")

misc:Label("Window controls")
misc:Button("Restore UI", function() win:Restore() end)
misc:Button("Send custom notification", function()
    UI.Notification({
        Delay = 4,
        Location = "ab",
        Mode = "Warning",
        Title = "Warning",
        Text = "Enemy nearby!",
    })
end)
misc:Button("Toggle removable label visibility", function()
    if removable:GetVisible() then
        removable:Hide()
    else
        removable:Show()
    end
end)
misc:Button("Delete removable label", function()
    removable:Delete()
end)
misc:Button("Manual save config", function()
    print("Saved:", win:SaveConfig())
end)
misc:Button("Manual load config", function()
    print("Loaded:", win:LoadConfig())
end)
misc:Button("Animated destroy", function() win:Destroy() end)
