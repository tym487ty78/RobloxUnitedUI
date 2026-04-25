# UnitedUI

UnitedUI is a Roblox Lua UI library inspired by ImGui/Unity style.
It supports tabs, containers, modern controls, themes, notifications, and animated open/close behavior.

## Features

- Animated window open/minimize/destroy
- Improved header with custom `X` and `-` buttons
- Theme system (`blue`, `red`, `green`, `yellow`, `purple`, `black`, `white`, `custom`)
- Background modes: `transparent`, `blurr`, `normal`
- Tabs with 1/2/4 containers per tab
- Single-container mode (no tabs) for simple layouts
- Built-in controls: label, button, toggle, slider, input, dropdowns, keybind, color picker
- Notification system with queue and corner positions
- Optional config save/load (size, position, toggle key)
- Connection cleanup on window destroy

## Installation

Place `main.lua` in your project and load it:

```lua
local UI = loadstring(game:HttpGet("YOUR_RAW_MAIN_LUA_URL"))()
```

## Quick Start

```lua
local UI = loadstring(game:HttpGet("YOUR_RAW_MAIN_LUA_URL"))()

local win = UI.Window("UnitedUI", 760, 120, 80, 500, {
    SaveConfigs = true,
    Theme = "blue",
    Background = "transparent", -- transparent | blurr | normal
})

win:SetToggleKeybind(Enum.KeyCode.RightShift)

local tab = win:CreateTab("Main", 2, {"Left", "Right"})
local left = tab:GetContainer(1)
local right = tab:GetContainer(2)

left:Label("Hello from UnitedUI")
left:Toggle("Enabled", false, function(v) end)
right:Button("Run", function() end)
```

## Themes

### Window Option

Set theme while creating a window:

```lua
local win = UI.Window("My UI", 760, 120, 80, 500, {
    Theme = "purple",
})
```

### Global Theme API

```lua
UI.SetTheme("green")
local themes = UI.GetThemes() -- {"default","blue","red","green","yellow","purple","black","white","custom"}
```

### Custom Theme

```lua
local win = UI.Window("Custom", 760, 120, 80, 500, {
    Theme = "custom",
    CustomTheme = {
        Accent = Color3.fromRGB(255, 170, 80),
        AccentDark = Color3.fromRGB(204, 120, 52),
        Border = Color3.fromRGB(130, 110, 90),
    },
})
```

`CustomTheme` can override keys from the internal theme table (`Window`, `WindowAlpha`, `Header`, `HeaderAlpha`, `Panel`, `PanelAlpha`, `Border`, `BorderAlpha`, `Separator`, `SeparatorAlpha`, `Accent`, `AccentDark`, `Button`, `ButtonHover`, `ButtonDown`, `Input`, `Track`, `Thumb`, `Text`, `TextMuted`).

## Background Modes

Set in `UI.Window(..., options)`:

- `transparent` - default transparent style
- `blurr` - transparent style with blur effect
- `normal` - dark opaque-ish style

Extra option:

- `BlurSize` - blur intensity for `blurr` mode (default `16`)

Notes:

- `blurr` now uses a `DepthOfField + blur-plane` technique (based on `blur.lua`) to keep blur tied to the window area.
- If that technique fails in your executor/client, it tries local `UIBlur`.
- If `UIBlur` is also unavailable, it falls back to a local pseudo-blur overlay inside the window (still no global/world blur).

## Window API

Constructor:

```lua
local win = UI.Window(title, width, posX, posY, height, options)
```

### Options

- `SaveConfigs` (`boolean`) - saves size/position/toggle key to `UnitedUI_Configs`
- `Theme` (`string`) - theme name
- `CustomTheme` (`table`) - used when `Theme = "custom"`
- `Background` (`string`) - `transparent`, `blurr`, `normal`
- `BlurSize` (`number`) - blur size for `blurr`
- `BlurOffsetX` (`number`) - fine horizontal alignment offset for `blurr` (default `0`)
- `BlurOffsetY` (`number`) - fine vertical alignment offset for `blurr` (default `2`)

### Methods

- `win:Minimize()`
- `win:Restore()`
- `win:Open()`
- `win:Close()`
- `win:SetSize(width, height)`
- `win:SetPosition(x, y)`
- `win:SetToggleKeybind(keyCodeOrControl)`
- `win:GetToggleKeybind()`
- `win:SaveConfig()`
- `win:LoadConfig()`
- `win:Destroy()` (cleans tracked connections/binds and removes GUI)

## Layout Modes

### 1) Tabs Mode

```lua
local tab = win:CreateTab("Main", 2, {"Left", "Right"})
local left = tab:GetContainer(1)
local right = tab:GetContainer(2)
```

`containersCount` supports `1`, `2`, or `4`.

### 2) Single-Container Mode (No Tabs)

```lua
local root = win:CreateContainer("Main Panel")
-- aliases:
-- win:AddContainer("Main Panel")
-- win:GetContainer()
```

Important:

- Single-container mode is only for windows without tabs.
- If a root container exists, `CreateTab` returns `nil`.

## Container/Control API

Each container supports:

- `Label(text, onDoubleClick?, options?)`
- `MultiLabel(lines, options?)`
- `Separator()`
- `Button(text, callback?)`
- `Toggle(text, default, callback?)`
- `Slider(text, min, max, default, callback?)`
- `Input(placeholder, default, callback?, options?)`
- `Dropdown(text, options, default, callback?)`
- `MultiDropdown(text, options, defaults, callback?)`
- `Keybind(text, defaultKeyCode, onActivate?, onChanged?, mode?)`
- `ColorPicker(text, defaultColor, callback?)`

### Detailed Control Docs + Examples

#### Label

Signature:

```lua
local label = container:Label(text, onDoubleClick, options)
```

Options:

- `Height` (`number`, default `18`)
- `Font` (`Enum.Font`, default `Enum.Font.Gotham`)
- `TextSize` (`number`, default `12`)
- `TextColor` (`Color3`)
- `TextXAlignment` (`Enum.TextXAlignment`, default `Left`)
- `Wrapped` (`boolean`, default `true`)
- `StrokeColor` (`Color3`)
- `StrokeThickness` (`number`, default `1`)
- `StrokeTransparency` (`number`, default `0`)

Example:

```lua
local title = left:Label(
    "<font color=\"#f2f2f2\">Combat</font> <font color=\"#68d477\">ready</font>",
    function(currentText)
        print("Double clicked:", currentText)
    end,
    {
        TextSize = 13,
        StrokeColor = Color3.fromRGB(20, 20, 20),
    }
)
title:SetText("Updated label text")
```

#### MultiLabel

Signature:

```lua
local block = container:MultiLabel(lines, options)
```

Options:

- `Height` (`number`, default `52`)
- `Font` (`Enum.Font`)
- `TextSize` (`number`, default `11`)
- `TextColor` (`Color3`)
- `BackgroundColor` (`Color3`, default dark gray)
- `BackgroundTransparency` (`number`, default `0.18`)

Example:

```lua
left:MultiLabel({
    "Line 1",
    "Line 2",
    "<font color=\"#ffd56c\">RichText works too.</font>",
}, {
    Height = 64,
})
```

#### Separator

Signature:

```lua
container:Separator()
```

Example:

```lua
left:Label("Aimbot")
left:Separator()
left:Label("Visuals")
```

#### Button

Signature:

```lua
local button = container:Button(text, callback)
```

Extra methods:

- `:PressButton()`
- `:GetButton()` (returns internal `TextButton`)

Example:

```lua
local execButton = right:Button("Execute", function()
    print("Executed")
end)

-- Simulate click in code:
execButton:PressButton()
```

#### Toggle

Signature:

```lua
local toggle = container:Toggle(text, default, callback)
```

Extra methods:

- `:SetValue(v)`
- `:GetValue()`
- `:ToggleToggle()`
- `:GetToggle()`

Example:

```lua
local enabled = left:Toggle("Enabled", false, function(v)
    print("Enabled:", v)
end)
enabled:SetValue(true)
```

#### Slider

Signature:

```lua
local slider = container:Slider(text, min, max, default, callback)
```

Notes:

- Slider value is integer-rounded while dragging.

Extra methods:

- `:GetValue()`
- `:SetValue(v, fireCallback?)`

Example:

```lua
local fov = left:Slider("FOV", 1, 360, 90, function(v)
    print("FOV:", v)
end)
fov:SetValue(120, true)
```

#### Input

Signature:

```lua
local input = container:Input(placeholder, default, callback, options)
```

Callback:

- `callback(text, enterPressed)` runs on focus lost.

Options:

- `Multiline` (`boolean`, default `false`)
- `ClearOnFocus` (`boolean`, default `false`)

Example:

```lua
local nameInput = right:Input("Name...", "", function(text, enterPressed)
    print("Name:", text, "enter:", enterPressed)
end, {
    ClearOnFocus = true,
})
```

#### Dropdown

Signature:

```lua
local dropdown = container:Dropdown(text, options, default, callback)
```

Extra methods:

- `:GetValue()`
- `:SetValue(v, fireCallback?)`
- `:ChangeDropdown(v)`
- `:GetDropdown()`
- `:SetOptions(newOptions)`

Example:

```lua
local mode = left:Dropdown("Mode", {"Legit", "Rage", "Silent"}, "Legit", function(v)
    print("Mode:", v)
end)
mode:SetValue("Silent", true)
```

#### MultiDropdown

Signature:

```lua
local multi = container:MultiDropdown(text, options, defaults, callback)
```

Extra methods:

- `:GetValue()`
- `:GetValues()`
- `:SetValues(values, fireCallback?)`
- `:SetOptions(newOptions)`
- `:ToggleOption(option, fireCallback?)`

Example:

```lua
local targets = left:MultiDropdown(
    "Targets",
    {"Head", "Torso", "Arms", "Legs"},
    {"Head", "Torso"},
    function(values)
        print("Targets:", table.concat(values, ", "))
    end
)
targets:ToggleOption("Arms", true)
```

#### Keybind

Signature:

```lua
local bind = container:Keybind(text, defaultKeyCode, onActivate, onChanged, mode)
```

Modes:

- `press` (default): `onActivate(keyCode)` when key is pressed
- `toggle`: `onActivate(toggleState, keyCode)` each press toggles boolean state
- `hold`: `onActivate(true, keyCode)` on key down and `onActivate(false, keyCode)` on key up

`onChanged(oldKey, newKey)` runs when user assigns a new key.

Extra methods:

- `:GetKeybind()`, `:GetKey()`
- `:SetKey(key)`, `:ChangeKeybind(key)`
- `:SetMode(mode)`, `:GetMode()`
- `:SetOnChanged(fn)`

Example:

```lua
local menuKey = left:Keybind("Menu Key", Enum.KeyCode.RightShift, function(state, key)
    print("Mode callback:", state, key)
end, function(oldKey, newKey)
    print("Key changed:", oldKey, "->", newKey)
end, "toggle")

win:SetToggleKeybind(menuKey)
```

#### ColorPicker

Signature:

```lua
local picker = container:ColorPicker(text, defaultColor, callback)
```

Extra methods:

- `:GetValue()`
- `:SetValue(color, fireCallback?)`
- `:ChangeColor(color)`

Example:

```lua
local espColor = left:ColorPicker("ESP Color", Color3.fromRGB(255, 120, 120), function(c)
    print("Color:", c)
end)
espColor:ChangeColor(Color3.fromRGB(120, 220, 255))
```

### Common control visibility methods

Most controls include:

- `:Show()`
- `:Hide()`
- `:GetVisible()`
- `:Delete()`

### Extra control helpers

- Button: `:PressButton()`
- Toggle: `:SetValue(v)`, `:GetValue()`, `:ToggleToggle()`
- Slider: `:GetValue()`, `:SetValue(v, fireCallback?)`
- Input: `:GetText()`, `:SetText(v)`
- Dropdown: `:GetValue()`, `:SetValue(v, fireCallback?)`, `:SetOptions(newOptions)`
- MultiDropdown: `:GetValues()`, `:SetValues(values, fireCallback?)`, `:SetOptions(newOptions)`, `:ToggleOption(opt, fireCallback?)`
- Keybind: `:GetKeybind()`, `:SetKey(key)`, `:ChangeKeybind(key)`, `:SetMode(mode)`, `:GetMode()`, `:SetOnChanged(fn)`
- ColorPicker: `:GetValue()`, `:SetValue(color, fireCallback?)`, `:ChangeColor(color)`

## Window Shortcut Methods

The window forwards these to the current default container:

- `win:Label(...)`
- `win:Button(...)`
- `win:Toggle(...)`
- `win:Slider(...)`
- `win:Input(...)`
- `win:Dropdown(...)`
- `win:MultiDropdown(...)`
- `win:Keybind(...)`
- `win:ColorPicker(...)`
- `win:Separator()`

Legacy/utility helpers:

- `win:PressButton(control)`
- `win:ToggleToggle(control)`
- `win:ChangeDropdown(control, option)`
- `win:GetToggle(control)`
- `win:ChangeColor(control, color)`
- `win:Toolbar(tabNames, callback?)`
- `win:Grid(columns, items)`

## Notifications

Global API:

```lua
UI.Notification({
    Delay = 3,
    Location = "bb", -- aa | ab | ba | bb
    Mode = "Success", -- Info | Information | Success | Error | Fail | Warning | Debug
    Title = "UnitedUI",
    Text = "Saved successfully",
})
```

Alias:

```lua
UI.Notify({...})
```

Window helper:

```lua
win:Notification({...})
```

Optional tab generator:

```lua
local notifTab = win:CreateNotificationsTab("Notifications")
```

## Examples

Ready-to-edit UI structure examples are available in:

- `examples/basic.lua` (full feature showcase)
- `examples/shooter.lua` (shooter-style UI structure)
- `examples/authentication.lua` (authentication panel structure)

These examples intentionally contain UI structure only (no gameplay/backend logic).




*note*
*
this github post was made 90% in AI
AI's used to make this: Cursor AI (free) | Visual Studio X Codex(CHATGPT) 5.3 (free)
even though i put some time into it to even make it real and i am very happy of the outcome of the ui
*

forks & modifications
when forking or modifying, use the ui library name like that:
UnitedFork BlaBlaBla
eg. UnitedFork Medium
