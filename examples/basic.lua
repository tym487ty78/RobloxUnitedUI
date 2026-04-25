-- UnitedUI basic example (UI structure only, no game logic)

local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/tym487ty78/RobloxUnitedUI/refs/heads/main/main.lua"))()

-- Optional global theme set
UI.SetTheme("blue")

local win = UI.Window("UnitedUI Basic", 780, 120, 80, 520, {
    SaveConfigs = true,
    Background = "blurr", -- transparent | blurr | normal
    BlurSize = 18,
    Theme = "custom", -- blue/red/green/yellow/purple/black/white/custom
    CustomTheme = {
        Accent = Color3.fromRGB(123, 185, 255),
        AccentDark = Color3.fromRGB(84, 134, 205),
        Border = Color3.fromRGB(108, 124, 152),
    },
})

win:SetToggleKeybind(Enum.KeyCode.RightShift)

-- Tabs mode
local mainTab = win:CreateTab("Main", 2, {"Left", "Right"})
local miscTab = win:CreateTab("Misc", 1, {"General"})
local left = mainTab:GetContainer(1)
local right = mainTab:GetContainer(2)
local misc = miscTab:GetContainer(1)

-- Label + multiline label + separator
local titleLabel = left:Label(
    "<font color=\"#f2f2f2\">UnitedUI</font> <font color=\"#6ccafc\">basic</font> <font color=\"#9ff39f\">demo</font>",
    function(text)
        print("Double click:", text)
    end,
    {
        TextSize = 13,
        StrokeColor = Color3.fromRGB(18, 18, 18),
        StrokeThickness = 1,
    }
)
local notes = left:MultiLabel({
    "This script demonstrates UI structure only.",
    "No gameplay systems are connected.",
    "Use this as a layout template.",
})
left:Separator()

-- Core controls
local runBtn = left:Button("Action Button", function()
    print("Action button pressed")
end)
local enabledTg = left:Toggle("Enabled", false, function(v)
    print("Enabled:", v)
end)
local rangeSl = left:Slider("Range", 0, 300, 120, function(v)
    print("Range:", v)
end)
local modeDd = left:Dropdown("Mode", {"Legit", "Rage", "Silent"}, "Legit", function(v)
    print("Mode:", v)
end)
local targetMdd = left:MultiDropdown("Targets", {"Head", "Torso", "Arms", "Legs"}, {"Head", "Torso"}, function(values)
    print("Targets:", table.concat(values, ", "))
end)
local menuKey = left:Keybind("Menu Key", Enum.KeyCode.RightShift, function(state, key)
    print("Menu key:", state, key)
end, function(oldKey, newKey)
    print("Key changed:", oldKey, newKey)
end, "toggle")
local espColor = left:ColorPicker("ESP Color", Color3.fromRGB(255, 120, 120), function(c)
    print("Color:", c)
end)

left:Separator()

-- Input controls
local nameInput = right:Input("Name...", "", function(text)
    print("Name:", text)
end, {
    ClearOnFocus = true,
})
local scriptInput = right:Input("Paste text...", "", function(text)
    print("Script text:", text)
end, {
    Multiline = true,
    ClearOnFocus = false,
})

right:Separator()

-- Helpers + visibility API
right:Label("Helpers and visibility")
local removable = right:Label("I can be hidden, shown, or deleted")

right:Button("Hide label", function()
    removable:Hide()
end)
right:Button("Show label", function()
    removable:Show()
end)
right:Button("Delete label", function()
    removable:Delete()
end)

right:Button("Run helper methods", function()
    win:PressButton(runBtn)
    win:ToggleToggle(enabledTg)
    win:ChangeDropdown(modeDd, "Silent")
    win:ChangeColor(espColor, Color3.fromRGB(140, 210, 255))
    targetMdd:ToggleOption("Arms", true)
end)

-- Notification tab generator
local notifTab = win:CreateNotificationsTab("Notifications")
if notifTab then
    notifTab:SetSettings({
        Delay = 3,
        Location = "bb",
        Mode = "Info",
        Title = "UnitedUI",
        Text = "Notifications tab is ready",
    })
end

-- Misc window actions
misc:Label("Window actions")
misc:Button("Minimize", function()
    win:Minimize()
end)
misc:Button("Restore", function()
    win:Restore()
end)
misc:Button("Save Config", function()
    print("Saved:", win:SaveConfig())
end)
misc:Button("Load Config", function()
    print("Loaded:", win:LoadConfig())
end)
misc:Button("Send Notification", function()
    UI.Notification({
        Delay = 3,
        Location = "ab",
        Mode = "Success",
        Title = "Basic Demo",
        Text = "UI-only notification example",
    })
end)
misc:Button("Destroy Window", function()
    win:Destroy()
end)

-- Legacy helpers
local toolbar = win:Toolbar({"Legacy A", "Legacy B"}, function(index)
    print("Toolbar selected:", index)
end)
if toolbar then
    toolbar:SetSelected(1)
end
win:Grid(2, {
    {"Legacy Button 1", function() end},
    {"Legacy Button 2", function() end},
})

-- Single-container mode demo in a second window (cannot mix tabs + root container in one window)
local rootWin = UI.Window("Single Container Demo", 480, 940, 80, 340, {
    Background = "normal",
    Theme = "green",
})
local root = rootWin:CreateContainer("Root")
root:Label("This is single-container mode")
root:Input("Search...", "")
root:Toggle("Quick Toggle", true, function() end)
root:Button("Close", function()
    rootWin:Destroy()
end)
