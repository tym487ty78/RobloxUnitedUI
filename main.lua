--[[
    UnitedUI (imgui / unity inspired)
    Transparent dark grey style + tabs + containers (1/2/4)
]]

local UI = {}
UI.__index = UI

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local GuiService = game:GetService("GuiService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local C = {
    Window = Color3.fromRGB(34, 34, 34),
    WindowAlpha = 0.34,
    Header = Color3.fromRGB(18, 18, 18),
    HeaderAlpha = 0.34,
    Panel = Color3.fromRGB(43, 43, 43),
    PanelAlpha = 0.10,
    Border = Color3.fromRGB(112, 112, 112),
    BorderAlpha = 0.62,
    Separator = Color3.fromRGB(102, 102, 102),
    SeparatorAlpha = 0.72,
    Accent = Color3.fromRGB(154, 154, 154),
    AccentDark = Color3.fromRGB(124, 124, 124),
    Button = Color3.fromRGB(44, 44, 44),
    ButtonHover = Color3.fromRGB(54, 54, 54),
    ButtonDown = Color3.fromRGB(38, 38, 38),
    Input = Color3.fromRGB(29, 29, 29),
    Track = Color3.fromRGB(22, 22, 22),
    Thumb = Color3.fromRGB(184, 184, 184),
    Text = Color3.fromRGB(228, 228, 228),
    TextMuted = Color3.fromRGB(166, 166, 166),
}

local FONT = Enum.Font.Gotham
local TXT = 12
local DOUBLE_CLICK_TIME = 0.30
local activeKeybindCapture = nil

local function cloneTable(src)
    local out = {}
    for k, v in pairs(src or {}) do
        out[k] = v
    end
    return out
end

local function shiftColor(color, delta)
    return Color3.new(
        math.clamp(color.R + delta, 0, 1),
        math.clamp(color.G + delta, 0, 1),
        math.clamp(color.B + delta, 0, 1)
    )
end

local BASE_THEME = cloneTable(C)
local THEME_NAMES = {"default", "blue", "red", "green", "yellow", "purple", "black", "white", "custom"}
local THEME_ALIASES = {
    domyslny = "default",
    niebieski = "blue",
    czerwony = "red",
    zielony = "green",
    zolty = "yellow",
    fioletowy = "purple",
    czarny = "black",
    bialy = "white",
    wlasny = "custom",
}
local THEME_PRESETS = {
    default = {},
    blue = {
        Accent = Color3.fromRGB(89, 150, 255),
        AccentDark = Color3.fromRGB(66, 116, 208),
        Border = Color3.fromRGB(100, 122, 158),
        ButtonHover = Color3.fromRGB(55, 64, 78),
        Thumb = Color3.fromRGB(156, 195, 255),
    },
    red = {
        Accent = Color3.fromRGB(213, 92, 92),
        AccentDark = Color3.fromRGB(165, 68, 68),
        Border = Color3.fromRGB(146, 102, 102),
        ButtonHover = Color3.fromRGB(66, 48, 48),
        Thumb = Color3.fromRGB(230, 160, 160),
    },
    green = {
        Accent = Color3.fromRGB(91, 188, 125),
        AccentDark = Color3.fromRGB(68, 147, 98),
        Border = Color3.fromRGB(98, 132, 109),
        ButtonHover = Color3.fromRGB(49, 64, 53),
        Thumb = Color3.fromRGB(163, 222, 182),
    },
    yellow = {
        Accent = Color3.fromRGB(208, 176, 79),
        AccentDark = Color3.fromRGB(163, 137, 60),
        Border = Color3.fromRGB(147, 130, 85),
        ButtonHover = Color3.fromRGB(65, 60, 48),
        Thumb = Color3.fromRGB(232, 208, 129),
    },
    purple = {
        Accent = Color3.fromRGB(164, 118, 224),
        AccentDark = Color3.fromRGB(123, 88, 176),
        Border = Color3.fromRGB(124, 108, 149),
        ButtonHover = Color3.fromRGB(58, 52, 70),
        Thumb = Color3.fromRGB(200, 173, 237),
    },
    black = {
        Window = Color3.fromRGB(14, 14, 14),
        WindowAlpha = 0.18,
        Header = Color3.fromRGB(8, 8, 8),
        HeaderAlpha = 0.16,
        Panel = Color3.fromRGB(20, 20, 20),
        Border = Color3.fromRGB(66, 66, 66),
        BorderAlpha = 0.48,
        Separator = Color3.fromRGB(58, 58, 58),
        Accent = Color3.fromRGB(122, 122, 122),
        AccentDark = Color3.fromRGB(96, 96, 96),
        Button = Color3.fromRGB(28, 28, 28),
        ButtonHover = Color3.fromRGB(38, 38, 38),
        ButtonDown = Color3.fromRGB(22, 22, 22),
        Input = Color3.fromRGB(19, 19, 19),
        Track = Color3.fromRGB(14, 14, 14),
        Thumb = Color3.fromRGB(153, 153, 153),
        Text = Color3.fromRGB(225, 225, 225),
        TextMuted = Color3.fromRGB(152, 152, 152),
    },
    white = {
        Window = Color3.fromRGB(234, 234, 234),
        WindowAlpha = 0.08,
        Header = Color3.fromRGB(246, 246, 246),
        HeaderAlpha = 0.05,
        Panel = Color3.fromRGB(252, 252, 252),
        PanelAlpha = 0,
        Border = Color3.fromRGB(154, 154, 154),
        BorderAlpha = 0.34,
        Separator = Color3.fromRGB(186, 186, 186),
        Accent = Color3.fromRGB(96, 96, 96),
        AccentDark = Color3.fromRGB(74, 74, 74),
        Button = Color3.fromRGB(238, 238, 238),
        ButtonHover = Color3.fromRGB(224, 224, 224),
        ButtonDown = Color3.fromRGB(214, 214, 214),
        Input = Color3.fromRGB(245, 245, 245),
        Track = Color3.fromRGB(220, 220, 220),
        Thumb = Color3.fromRGB(120, 120, 120),
        Text = Color3.fromRGB(30, 30, 30),
        TextMuted = Color3.fromRGB(84, 84, 84),
    },
    custom = {},
}

local function resolveThemeName(themeName)
    local key = string.lower(tostring(themeName or "default"))
    return THEME_ALIASES[key] or key
end

local function applyTheme(themeName, customTheme)
    local selected = resolveThemeName(themeName)
    local preset = THEME_PRESETS[selected]
    if not preset then
        selected = "default"
        preset = THEME_PRESETS.default
    end

    local merged = cloneTable(BASE_THEME)
    for k, v in pairs(preset) do
        merged[k] = v
    end

    if selected == "custom" and type(customTheme) == "table" then
        for k, v in pairs(customTheme) do
            if merged[k] ~= nil then
                local t = typeof(v)
                if t == "Color3" or t == "number" then
                    merged[k] = v
                end
            end
        end
    end

    for k, v in pairs(merged) do
        C[k] = v
    end
    return selected
end

function UI.SetTheme(themeName, customTheme)
    return applyTheme(themeName, customTheme)
end

function UI.GetThemes()
    local out = {}
    for i, name in ipairs(THEME_NAMES) do
        out[i] = name
    end
    return out
end

local function isTypingInTextBox()
    return UserInputService:GetFocusedTextBox() ~= nil
end

local function tween(inst, t, props, style, direction)
    local info = TweenInfo.new(t or 0.12, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
    local tw = TweenService:Create(inst, info, props)
    tw:Play()
    return tw
end

local function make(className, props)
    local inst = Instance.new(className)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    return inst
end

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
end

local function stroke(parent, color, alpha, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Transparency = alpha
    s.Thickness = thickness or 1
    s.Parent = parent
    return s
end

local function listLayout(parent, spacing)
    local l = Instance.new("UIListLayout")
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding = UDim.new(0, spacing or 6)
    l.Parent = parent
    return l
end

local function makeDraggable(handle, target, onMove, connectFn)
    local connect = connectFn or function(signal, callback)
        return signal:Connect(callback)
    end
    local dragging = false
    local dragStart, startPos

    connect(handle.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
        end
    end)

    connect(handle.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    connect(UserInputService.InputChanged, function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            if onMove then
                onMove()
            end
        end
    end)
end

local function attachAutoCanvas(scroll, layout, bottomPadding, connectFn)
    local connect = connectFn or function(signal, callback)
        return signal:Connect(callback)
    end
    local function refresh()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + (bottomPadding or 0))
    end
    connect(layout:GetPropertyChangedSignal("AbsoluteContentSize"), refresh)
    refresh()
end

local function createElementAPI(targetScroll, connectFn)
    local connect = connectFn or function(signal, callback)
        return signal:Connect(callback)
    end
    local api = {}
    api._parent = targetScroll
    local order = 0
    local function nextOrder()
        order += 1
        return order
    end

    local function withVisibilityAPI(inst, methods)
        local control = methods or {}
        control._instance = inst
        control.Show = function()
            if inst and inst.Parent then
                inst.Visible = true
            end
        end
        control.Hide = function()
            if inst and inst.Parent then
                inst.Visible = false
            end
        end
        control.GetVisible = function()
            return inst and inst.Parent and inst.Visible or false
        end
        control.Delete = function()
            if inst and inst.Parent then
                inst:Destroy()
            end
        end
        return control
    end

    function api:Label(text, onDoubleClick, options)
        options = options or {}
        local lbl = make("TextLabel", {
            Size = UDim2.new(1, -14, 0, options.Height or 18),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = tostring(text or ""),
            RichText = true,
            Font = options.Font or FONT,
            TextSize = tonumber(options.TextSize) or TXT,
            TextColor3 = options.TextColor or C.Text,
            TextXAlignment = options.TextXAlignment or Enum.TextXAlignment.Left,
            TextWrapped = options.Wrapped ~= false,
            LayoutOrder = nextOrder(),
            ClipsDescendants = false,
            Parent = targetScroll,
        })
        local lblStroke = nil
        if options.StrokeColor then
            lblStroke = make("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                Color = options.StrokeColor,
                Thickness = tonumber(options.StrokeThickness) or 1,
                Transparency = options.StrokeTransparency or 0,
                Parent = lbl,
            })
        end

        local clickSign = make("TextLabel", {
            Size = UDim2.new(0, 14, 0, 14),
            Position = UDim2.new(1, -10, 0.5, -7),
            BackgroundTransparency = 1,
            Text = "V",
            Font = FONT,
            TextSize = 12,
            TextColor3 = Color3.fromRGB(80, 210, 100),
            TextXAlignment = Enum.TextXAlignment.Right,
            Visible = false,
            ZIndex = (lbl.ZIndex or 1) + 1,
            Parent = lbl,
        })

        local lastClickAt = 0
        lbl.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
                return
            end
            local now = tick()
            if now - lastClickAt <= DOUBLE_CLICK_TIME then
                clickSign.Visible = true
                task.delay(3, function()
                    if clickSign.Parent then
                        clickSign.Visible = false
                    end
                end)
                if onDoubleClick then
                    onDoubleClick(lbl.Text)
                end
            end
            lastClickAt = now
        end)

        return withVisibilityAPI(lbl, {
            SetText = function(newText)
                lbl.Text = tostring(newText or "")
            end,
            GetText = function()
                return lbl.Text
            end,
            SetTextColor = function(color)
                if typeof(color) == "Color3" then
                    lbl.TextColor3 = color
                end
            end,
            SetTextSize = function(size)
                lbl.TextSize = tonumber(size) or lbl.TextSize
            end,
            SetStroke = function(color, thickness, transparency)
                if not lblStroke then
                    lblStroke = make("UIStroke", {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                        Parent = lbl,
                    })
                end
                if typeof(color) == "Color3" then
                    lblStroke.Color = color
                end
                if thickness ~= nil then
                    lblStroke.Thickness = tonumber(thickness) or lblStroke.Thickness
                end
                if transparency ~= nil then
                    lblStroke.Transparency = transparency
                end
            end,
        })
    end

    function api:MultiLabel(lines, options)
        options = options or {}
        local text = type(lines) == "table" and table.concat(lines, "\n") or tostring(lines or "")
        local holder = make("Frame", {
            Size = UDim2.new(1, 0, 0, options.Height or 52),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            LayoutOrder = nextOrder(),
            Parent = targetScroll,
        })
        local wrap = make("Frame", {
            Size = UDim2.new(1, -8, 1, 0),
            Position = UDim2.new(0, 4, 0, 0),
            BackgroundColor3 = options.BackgroundColor or Color3.fromRGB(52, 52, 52),
            BackgroundTransparency = options.BackgroundTransparency or 0.18,
            BorderSizePixel = 0,
            Parent = holder,
        })
        corner(wrap, 4)
        make("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = C.Border,
            Transparency = C.BorderAlpha,
            Thickness = 1,
            Parent = wrap,
        })
        local lbl = make("TextLabel", {
            Size = UDim2.new(1, -10, 1, -8),
            Position = UDim2.new(0, 5, 0, 6),
            BackgroundTransparency = 1,
            Text = text,
            RichText = true,
            Font = options.Font or FONT,
            TextSize = tonumber(options.TextSize) or (TXT - 1),
            TextColor3 = options.TextColor or C.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            Parent = wrap,
        })

        return withVisibilityAPI(holder, {
            SetText = function(newText)
                lbl.Text = tostring(newText or "")
            end,
            GetText = function()
                return lbl.Text
            end,
        })
    end

    function api:Separator()
        local sep = make("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = C.Separator,
            BackgroundTransparency = C.SeparatorAlpha,
            BorderSizePixel = 0,
            LayoutOrder = nextOrder(),
            Parent = targetScroll,
        })
        return withVisibilityAPI(sep, {})
    end

    function api:Button(text, callback)
        local btn = make("TextButton", {
            Size = UDim2.new(1, 0, 0, 24),
            AutoButtonColor = false,
            BackgroundColor3 = C.Button,
            BackgroundTransparency = 0.2,
            BorderSizePixel = 0,
            Text = tostring(text or "Button"),
            Font = FONT,
            TextSize = TXT - 1,
            TextColor3 = C.Text,
            LayoutOrder = nextOrder(),
            Parent = targetScroll,
        })
        corner(btn, 4)
        stroke(btn, C.Border, C.BorderAlpha, 1)
        local baseSize = btn.Size

        btn.MouseEnter:Connect(function()
            tween(btn, 0.10, {BackgroundColor3 = C.ButtonHover})
        end)
        btn.MouseLeave:Connect(function()
            tween(btn, 0.10, {BackgroundColor3 = C.Button, Size = baseSize})
        end)
        btn.MouseButton1Down:Connect(function()
            tween(btn, 0.05, {
                BackgroundColor3 = C.ButtonDown,
                Size = UDim2.new(baseSize.X.Scale, baseSize.X.Offset, baseSize.Y.Scale, baseSize.Y.Offset - 1),
            }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        end)
        btn.MouseButton1Up:Connect(function()
            tween(btn, 0.08, {BackgroundColor3 = C.ButtonHover, Size = baseSize})
        end)
        btn.MouseButton1Click:Connect(function()
            tween(btn, 0.06, {BackgroundColor3 = C.AccentDark}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            task.delay(0.07, function()
                if btn.Parent then
                    tween(btn, 0.10, {BackgroundColor3 = C.ButtonHover})
                end
            end)
            if callback then callback() end
        end)
        return withVisibilityAPI(btn, {
            PressButton = function()
                if btn.Parent then
                    tween(btn, 0.05, {BackgroundColor3 = C.ButtonDown})
                    task.delay(0.05, function()
                        if btn.Parent then
                            tween(btn, 0.10, {BackgroundColor3 = C.ButtonHover})
                        end
                    end)
                    if callback then callback() end
                end
            end,
            GetButton = function()
                return btn
            end,
        })
    end

    function api:Toggle(text, default, callback)
        local state = default == true

        local row = make("Frame", {
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            LayoutOrder = nextOrder(),
            Parent = targetScroll,
        })

        local box = make("TextButton", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 0, 0.5, -8),
            AutoButtonColor = false,
            BackgroundColor3 = C.Track,
            BorderSizePixel = 0,
            Text = "",
            Parent = row,
        })
        corner(box, 4)
        stroke(box, C.Border, C.BorderAlpha, 1)

        local mark = make("Frame", {
            Size = UDim2.new(1, -6, 1, -6),
            Position = UDim2.new(0, 3, 0, 3),
            BackgroundColor3 = C.Accent,
            Visible = state,
            BorderSizePixel = 0,
            Parent = box,
        })
        corner(mark, 3)

        local lbl = make("TextLabel", {
            Size = UDim2.new(1, -24, 1, 0),
            Position = UDim2.new(0, 24, 0, 0),
            BackgroundTransparency = 1,
            Text = tostring(text or "Toggle"),
            Font = FONT,
            TextSize = TXT - 1,
            TextColor3 = C.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = row,
        })

        local function setValue(newState, doCallback)
            state = newState == true
            mark.Visible = true
            if state then
                mark.Size = UDim2.new(1, -10, 1, -10)
                mark.Position = UDim2.new(0, 5, 0, 5)
                mark.BackgroundTransparency = 0.35
                tween(mark, 0.10, {
                    Size = UDim2.new(1, -6, 1, -6),
                    Position = UDim2.new(0, 3, 0, 3),
                    BackgroundTransparency = 0,
                })
                tween(box, 0.10, {BackgroundColor3 = C.ButtonHover})
            else
                tween(mark, 0.08, {
                    Size = UDim2.new(1, -10, 1, -10),
                    Position = UDim2.new(0, 5, 0, 5),
                    BackgroundTransparency = 1,
                })
                tween(box, 0.10, {BackgroundColor3 = C.Track})
                task.delay(0.09, function()
                    if mark.Parent and not state then
                        mark.Visible = false
                    end
                end)
            end
            if doCallback and callback then
                callback(state)
            end
        end

        box.MouseButton1Click:Connect(function()
            setValue(not state, true)
        end)
        lbl.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                setValue(not state, true)
            end
        end)

        return withVisibilityAPI(row, {
            SetValue = function(v) setValue(v, false) end,
            GetValue = function() return state end,
            ToggleToggle = function()
                setValue(not state, true)
            end,
            GetToggle = function()
                return state
            end,
        })
    end

    function api:Dropdown(text, options, default, callback)
        options = options or {}
        local selected = default
        local open = false

        local wrap = make("Frame", {
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            LayoutOrder = nextOrder(),
            Parent = targetScroll,
            ClipsDescendants = true,
        })

        local btn = make("TextButton", {
            Size = UDim2.new(1, -2, 0, 24),
            Position = UDim2.new(0, 1, 0, 0),
            BackgroundColor3 = C.Button,
            BackgroundTransparency = 0.14,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = "",
            Font = FONT,
            TextSize = TXT - 1,
            TextColor3 = C.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = wrap,
        })
        corner(btn, 4)
        stroke(btn, C.Border, C.BorderAlpha, 1)
        local p = Instance.new("UIPadding")
        p.PaddingLeft = UDim.new(0, 8)
        p.PaddingRight = UDim.new(0, 24)
        p.Parent = btn
        local icon = make("TextLabel", {
            Size = UDim2.new(0, 16, 1, 0),
            Position = UDim2.new(1, -18, 0, 0),
            BackgroundTransparency = 1,
            Text = "v",
            Font = FONT,
            TextSize = TXT - 1,
            TextColor3 = C.TextMuted,
            Parent = btn,
        })

        local list = make("Frame", {
            Size = UDim2.new(1, -2, 0, 0),
            Position = UDim2.new(0, 1, 0, 24),
            BackgroundColor3 = C.Input,
            BackgroundTransparency = 0.05,
            BorderSizePixel = 0,
            Visible = false,
            Parent = wrap,
            ClipsDescendants = true,
        })
        corner(list, 4)
        stroke(list, C.Border, C.BorderAlpha, 1)

        local listPad = Instance.new("UIPadding")
        listPad.PaddingTop = UDim.new(0, 4)
        listPad.PaddingBottom = UDim.new(0, 4)
        listPad.PaddingLeft = UDim.new(0, 4)
        listPad.PaddingRight = UDim.new(0, 4)
        listPad.Parent = list

        local lay = listLayout(list, 3)
        local optionButtons = {}
        local function updateBtnText()
            local valueText = ""
            if selected ~= nil and selected ~= "" and selected ~= "-" and type(selected) ~= "table" then
                valueText = tostring(selected)
            end
            btn.Text = valueText ~= ""
                and string.format("%s: %s", tostring(text or "Dropdown"), valueText)
                or tostring(text or "Dropdown")
        end

        local function setSelected(opt, doCallback)
            selected = opt
            updateBtnText()
            if doCallback and callback then
                callback(selected)
            end
        end

        local function rebuildOptions()
            for _, b in ipairs(optionButtons) do
                if b.Parent then
                    b:Destroy()
                end
            end
            optionButtons = {}

            for _, opt in ipairs(options) do
                local ob = make("TextButton", {
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundColor3 = C.Button,
                    BackgroundTransparency = 0.14,
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    Text = tostring(opt),
                    Font = FONT,
                    TextSize = TXT - 1,
                    TextColor3 = C.Text,
                    Parent = list,
                })
                corner(ob, 3)
                stroke(ob, C.Border, 0.72, 1)
                ob.MouseEnter:Connect(function() tween(ob, 0.08, {BackgroundColor3 = C.ButtonHover}) end)
                ob.MouseLeave:Connect(function() tween(ob, 0.08, {BackgroundColor3 = C.Button}) end)
                ob.MouseButton1Click:Connect(function()
                    setSelected(opt, true)
                    -- setOpen(false); -- disabled due to obfuscation errors
                end)
                table.insert(optionButtons, ob)
            end
        end

        local function setOpen(value)
            open = value == true
            if open then
                local targetH = math.max(0, lay.AbsoluteContentSize.Y + 8)
                list.Visible = true
                tween(list, 0.12, {Size = UDim2.new(1, -2, 0, targetH)})
                tween(wrap, 0.12, {Size = UDim2.new(1, 0, 0, 24 + targetH)})
                icon.Text = "^"
            else
                tween(list, 0.10, {Size = UDim2.new(1, -2, 0, 0)})
                tween(wrap, 0.10, {Size = UDim2.new(1, 0, 0, 24)})
                icon.Text = "v"
                task.delay(0.11, function()
                    if list.Parent and not open then
                        list.Visible = false
                    end
                end)
            end
        end

        btn.MouseEnter:Connect(function() tween(btn, 0.08, {BackgroundColor3 = C.ButtonHover}) end)
        btn.MouseLeave:Connect(function() tween(btn, 0.08, {BackgroundColor3 = C.Button}) end)
        btn.MouseButton1Click:Connect(function()
            setOpen(not open)
        end)

        rebuildOptions()
        setSelected(selected, false)

        return withVisibilityAPI(wrap, {
            GetValue = function() return selected end,
            SetValue = function(v, fireCallback) setSelected(v, fireCallback == true) end,
            ChangeDropdown = function(v)
                setSelected(v, true)
            end,
            GetDropdown = function()
                return selected
            end,
            SetOptions = function(newOptions)
                options = newOptions or {}
                rebuildOptions()
                if #options > 0 and table.find(options, selected) == nil then
                    setSelected(nil, false)
                elseif #options == 0 then
                    setSelected(nil, false)
                end
            end,
        })
    end

    function api:MultiDropdown(text, options, defaults, callback)
        options = options or {}
        defaults = defaults or {}
        local open = false
        local selectedMap = {}
        local selectedList = {}
        local optionRows = {}

        for _, v in ipairs(defaults) do
            selectedMap[v] = true
            table.insert(selectedList, v)
        end

        local wrap = make("Frame", {
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            LayoutOrder = nextOrder(),
            Parent = targetScroll,
            ClipsDescendants = true,
        })
        local btn = make("TextButton", {
            Size = UDim2.new(1, -2, 0, 24),
            Position = UDim2.new(0, 1, 0, 0),
            BackgroundColor3 = C.Button,
            BackgroundTransparency = 0.14,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = "",
            Font = FONT,
            TextSize = TXT - 1,
            TextColor3 = C.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = wrap,
        })
        corner(btn, 4)
        stroke(btn, C.Border, C.BorderAlpha, 1)
        local p = Instance.new("UIPadding")
        p.PaddingLeft = UDim.new(0, 8)
        p.PaddingRight = UDim.new(0, 24)
        p.Parent = btn
        local icon = make("TextLabel", {
            Size = UDim2.new(0, 16, 1, 0),
            Position = UDim2.new(1, -18, 0, 0),
            BackgroundTransparency = 1,
            Text = "v",
            Font = FONT,
            TextSize = TXT - 1,
            TextColor3 = C.TextMuted,
            Parent = btn,
        })

        local list = make("Frame", {
            Size = UDim2.new(1, -2, 0, 0),
            Position = UDim2.new(0, 1, 0, 24),
            BackgroundColor3 = C.Input,
            BackgroundTransparency = 0.05,
            BorderSizePixel = 0,
            Visible = false,
            Parent = wrap,
            ClipsDescendants = true,
        })
        corner(list, 4)
        stroke(list, C.Border, C.BorderAlpha, 1)
        local listPad = Instance.new("UIPadding")
        listPad.PaddingTop = UDim.new(0, 4)
        listPad.PaddingBottom = UDim.new(0, 4)
        listPad.PaddingLeft = UDim.new(0, 4)
        listPad.PaddingRight = UDim.new(0, 4)
        listPad.Parent = list
        local lay = listLayout(list, 3)

        local function syncSelectedList()
            selectedList = {}
            for _, opt in ipairs(options) do
                if selectedMap[opt] then
                    table.insert(selectedList, opt)
                end
            end
        end

        local function updateHeaderText()
            if #selectedList == 0 then
                btn.Text = string.format("%s: -", tostring(text or "MultiDropdown"))
            else
                btn.Text = string.format("%s: %s", tostring(text or "MultiDropdown"), table.concat(selectedList, ", "))
            end
        end

        local function updateRowVisual(opt)
            local rowData = optionRows[opt]
            if not rowData then
                return
            end
            local isSelected = selectedMap[opt] == true
            rowData.tick.Text = isSelected and "X" or ""
            rowData.row.BackgroundColor3 = isSelected and C.ButtonHover or C.Button
        end

        local function fireChanged()
            if callback then
                callback(table.clone(selectedList))
            end
        end

        local function setOpen(v)
            open = v == true
            if open then
                local targetH = math.max(0, lay.AbsoluteContentSize.Y + 8)
                list.Visible = true
                tween(list, 0.12, {Size = UDim2.new(1, -2, 0, targetH)})
                tween(wrap, 0.12, {Size = UDim2.new(1, 0, 0, 24 + targetH)})
                icon.Text = "^"
            else
                tween(list, 0.10, {Size = UDim2.new(1, -2, 0, 0)})
                tween(wrap, 0.10, {Size = UDim2.new(1, 0, 0, 24)})
                icon.Text = "v"
                task.delay(0.11, function()
                    if list.Parent and not open then
                        list.Visible = false
                    end
                end)
            end
        end

        local function rebuildOptions()
            for _, child in ipairs(list:GetChildren()) do
                if child:IsA("GuiObject") then
                    child:Destroy()
                end
            end
            optionRows = {}
            for _, opt in ipairs(options) do
                local row = make("TextButton", {
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundColor3 = C.Button,
                    BackgroundTransparency = 0.14,
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    Text = tostring(opt),
                    Font = FONT,
                    TextSize = TXT - 1,
                    TextColor3 = C.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = list,
                })
                corner(row, 3)
                stroke(row, C.Border, 0.72, 1)
                local rp = Instance.new("UIPadding")
                rp.PaddingLeft = UDim.new(0, 6)
                rp.PaddingRight = UDim.new(0, 16)
                rp.Parent = row
                local tick = make("TextLabel", {
                    Size = UDim2.new(0, 12, 1, 0),
                    Position = UDim2.new(1, -12, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Font = FONT,
                    TextSize = TXT - 1,
                    TextColor3 = Color3.fromRGB(80, 210, 100),
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = row,
                })
                optionRows[opt] = {row = row, tick = tick}
                updateRowVisual(opt)
                row.MouseEnter:Connect(function()
                    tween(row, 0.08, {BackgroundColor3 = C.ButtonHover})
                end)
                row.MouseLeave:Connect(function()
                    updateRowVisual(opt)
                end)
                row.MouseButton1Click:Connect(function()
                    selectedMap[opt] = not selectedMap[opt]
                    syncSelectedList()
                    updateRowVisual(opt)
                    updateHeaderText()
                    fireChanged()
                end)
            end
        end

        btn.MouseEnter:Connect(function() tween(btn, 0.08, {BackgroundColor3 = C.ButtonHover}) end)
        btn.MouseLeave:Connect(function() tween(btn, 0.08, {BackgroundColor3 = C.Button}) end)
        btn.MouseButton1Click:Connect(function()
            setOpen(not open)
        end)

        syncSelectedList()
        rebuildOptions()
        updateHeaderText()

        return withVisibilityAPI(wrap, {
            GetValue = function()
                return table.clone(selectedList)
            end,
            GetValues = function()
                return table.clone(selectedList)
            end,
            SetValues = function(values, fireCallback)
                selectedMap = {}
                for _, v in ipairs(values or {}) do
                    selectedMap[v] = true
                end
                syncSelectedList()
                for _, opt in ipairs(options) do
                    updateRowVisual(opt)
                end
                updateHeaderText()
                if fireCallback == true then
                    fireChanged()
                end
            end,
            SetOptions = function(newOptions)
                options = newOptions or {}
                local oldMap = selectedMap
                selectedMap = {}
                for _, opt in ipairs(options) do
                    if oldMap[opt] then
                        selectedMap[opt] = true
                    end
                end
                syncSelectedList()
                rebuildOptions()
                updateHeaderText()
            end,
            ToggleOption = function(option, fireCallback)
                selectedMap[option] = not selectedMap[option]
                syncSelectedList()
                updateRowVisual(option)
                updateHeaderText()
                if fireCallback == true then
                    fireChanged()
                end
            end,
        })
    end

    function api:Keybind(text, defaultKeyCode, onActivate, onChanged, mode)
        local current = defaultKeyCode or Enum.KeyCode.RightShift
        local listening = false
        local onChangedCb = type(onChanged) == "function" and onChanged or nil
        local modeValue = mode
        if modeValue == nil and onChanged ~= nil and type(onChanged) ~= "function" then
            modeValue = onChanged
        end
        local bindMode = string.lower(tostring(modeValue or "press"))
        if bindMode ~= "press" and bindMode ~= "toggle" and bindMode ~= "hold" then
            bindMode = "press"
        end
        local holdActive = false
        local toggleState = false

        local row = make("Frame", {
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            LayoutOrder = nextOrder(),
            Parent = targetScroll,
        })

        local lbl = make("TextLabel", {
            Size = UDim2.new(0.58, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = tostring(text or "Keybind"),
            Font = FONT,
            TextSize = TXT - 1,
            TextColor3 = C.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = row,
        })

        local bindBtn = make("TextButton", {
            Size = UDim2.new(0.42, 0, 1, 0),
            Position = UDim2.new(0.58, 0, 0, 0),
            BackgroundColor3 = C.Button,
            BackgroundTransparency = 0.2,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = current.Name,
            Font = FONT,
            TextSize = TXT - 1,
            TextColor3 = C.TextMuted,
            Parent = row,
        })
        corner(bindBtn, 4)
        stroke(bindBtn, C.Border, C.BorderAlpha, 1)

        bindBtn.MouseButton1Click:Connect(function()
            listening = true
            activeKeybindCapture = bindBtn
            bindBtn.Text = "Press key..."
            tween(bindBtn, 0.08, {BackgroundColor3 = C.ButtonHover})
        end)

        local function setKey(newKeyCode, fireChangedCallback)
            if not newKeyCode or newKeyCode == Enum.KeyCode.Unknown then
                return
            end
            local oldKeyCode = current
            current = newKeyCode
            bindBtn.Text = current.Name
            if fireChangedCallback and type(onChangedCb) == "function" and oldKeyCode ~= current then
                onChangedCb(oldKeyCode, current)
            end
        end

        local function setMode(newMode)
            local normalized = string.lower(tostring(newMode or "press"))
            if normalized ~= "press" and normalized ~= "toggle" and normalized ~= "hold" then
                return
            end
            bindMode = normalized
            holdActive = false
            toggleState = false
        end

        connect(UserInputService.InputBegan, function(input, gameProcessed)
            if gameProcessed then
                return
            end
            if isTypingInTextBox() then
                return
            end
            if listening and activeKeybindCapture ~= bindBtn then
                listening = false
                bindBtn.Text = current.Name
                tween(bindBtn, 0.08, {BackgroundColor3 = C.Button})
            end
            if activeKeybindCapture and activeKeybindCapture ~= bindBtn then
                return
            end
            if listening then
                if input.KeyCode ~= Enum.KeyCode.Unknown then
                    setKey(input.KeyCode, true)
                    listening = false
                    task.defer(function()
                        if activeKeybindCapture == bindBtn then
                            activeKeybindCapture = nil
                        end
                    end)
                    tween(bindBtn, 0.08, {BackgroundColor3 = C.Button})
                end
                return
            end

            if input.KeyCode == current then
                tween(bindBtn, 0.06, {BackgroundColor3 = C.AccentDark})
                task.delay(0.07, function()
                    if bindBtn.Parent then
                        tween(bindBtn, 0.08, {BackgroundColor3 = C.Button})
                    end
                end)
                if bindMode == "press" then
                    if onActivate then
                        onActivate(current)
                    end
                elseif bindMode == "toggle" then
                    toggleState = not toggleState
                    if onActivate then
                        onActivate(toggleState, current)
                    end
                elseif bindMode == "hold" then
                    if not holdActive then
                        holdActive = true
                        if onActivate then
                            onActivate(true, current)
                        end
                    end
                end
            end
        end)

        connect(UserInputService.InputEnded, function(input, gameProcessed)
            if gameProcessed then
                return
            end
            if bindMode == "hold" and input.KeyCode == current and holdActive then
                holdActive = false
                if onActivate then
                    onActivate(false, current)
                end
            end
        end)

        return withVisibilityAPI(row, {
            GetKey = function() return current end,
            SetKey = function(selfOrKeyCode, maybeKeyCode)
                local keyCode = maybeKeyCode or selfOrKeyCode
                setKey(keyCode, false)
            end,
            ChangeKeybind = function(selfOrKeyCode, maybeKeyCode)
                local keyCode = maybeKeyCode or selfOrKeyCode
                setKey(keyCode, true)
            end,
            GetKeybind = function()
                return current
            end,
            SetMode = function(selfOrMode, maybeMode)
                local newMode = maybeMode or selfOrMode
                setMode(newMode)
            end,
            GetMode = function()
                return bindMode
            end,
            SetOnChanged = function(selfOrCallback, maybeCallback)
                local callback = maybeCallback or selfOrCallback
                onChangedCb = type(callback) == "function" and callback or nil
            end,
        })
    end

    function api:ColorPicker(text, defaultColor, callback)
        local current = typeof(defaultColor) == "Color3" and defaultColor or Color3.fromRGB(255, 255, 255)
        local open = false

        local wrap = make("Frame", {
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            LayoutOrder = nextOrder(),
            Parent = targetScroll,
            ClipsDescendants = true,
        })

        local header = make("TextButton", {
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundColor3 = C.Button,
            BackgroundTransparency = 0.2,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = tostring(text or "Color") .. "  v",
            Font = FONT,
            TextSize = TXT - 1,
            TextColor3 = C.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = wrap,
        })
        corner(header, 4)
        stroke(header, C.Border, C.BorderAlpha, 1)

        local hp = Instance.new("UIPadding")
        hp.PaddingLeft = UDim.new(0, 8)
        hp.Parent = header

        local preview = make("Frame", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(1, -20, 0.5, -8),
            BorderSizePixel = 0,
            BackgroundColor3 = current,
            Parent = header,
        })
        corner(preview, 3)
        stroke(preview, C.Border, 0.35, 1)

        local panel = make("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 0, 24),
            BackgroundColor3 = C.Input,
            BackgroundTransparency = 0.05,
            BorderSizePixel = 0,
            Visible = false,
            ClipsDescendants = true,
            Parent = wrap,
        })
        corner(panel, 4)
        stroke(panel, C.Border, C.BorderAlpha, 1)

        local pp = Instance.new("UIPadding")
        pp.PaddingTop = UDim.new(0, 6)
        pp.PaddingBottom = UDim.new(0, 6)
        pp.PaddingLeft = UDim.new(0, 6)
        pp.PaddingRight = UDim.new(0, 6)
        pp.Parent = panel

        local pLayout = listLayout(panel, 6)
        local hue, sat, val = Color3.toHSV(current)
        local draggingSV = false
        local draggingHue = false

        local svArea = make("ImageButton", {
            Size = UDim2.new(1, 0, 0, 110),
            BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Image = "rbxassetid://4155801252",
            ScaleType = Enum.ScaleType.Stretch,
            Parent = panel,
        })
        corner(svArea, 4)
        stroke(svArea, C.Border, C.BorderAlpha, 1)
        local svCursor = make("Frame", {
            Size = UDim2.new(0, 8, 0, 8),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(245, 245, 245),
            BorderSizePixel = 0,
            Parent = svArea,
        })
        corner(svCursor, 999)

        local hueTrack = make("Frame", {
            Size = UDim2.new(1, 0, 0, 12),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            Parent = panel,
        })
        corner(hueTrack, 999)
        stroke(hueTrack, C.Border, C.BorderAlpha, 1)
        local hueGradient = make("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
            }),
            Parent = hueTrack,
        })
        local hueCursor = make("Frame", {
            Size = UDim2.new(0, 8, 0, 14),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0, 0, 0.5, 0),
            BackgroundColor3 = Color3.fromRGB(245, 245, 245),
            BorderSizePixel = 0,
            Parent = hueTrack,
        })
        corner(hueCursor, 999)

        local function apply(doCallback)
            current = Color3.fromHSV(hue, sat, val)
            preview.BackgroundColor3 = current
            svArea.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
            svCursor.Position = UDim2.new(sat, 0, 1 - val, 0)
            hueCursor.Position = UDim2.new(hue, 0, 0.5, 0)
            if doCallback and callback then
                callback(current)
            end
        end

        local function setFromSV(x, y, doCallback)
            local left = svArea.AbsolutePosition.X
            local topY = svArea.AbsolutePosition.Y
            local w = math.max(1, svArea.AbsoluteSize.X)
            local h = math.max(1, svArea.AbsoluteSize.Y)
            sat = math.clamp((x - left) / w, 0, 1)
            val = 1 - math.clamp((y - topY) / h, 0, 1)
            apply(doCallback)
        end

        local function setFromHueX(x, doCallback)
            local left = hueTrack.AbsolutePosition.X
            local w = math.max(1, hueTrack.AbsoluteSize.X)
            hue = math.clamp((x - left) / w, 0, 1)
            apply(doCallback)
        end

        svArea.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSV = true
                setFromSV(input.Position.X, input.Position.Y, true)
            end
        end)
        hueTrack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingHue = true
                setFromHueX(input.Position.X, true)
            end
        end)
        connect(UserInputService.InputChanged, function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseMovement then
                return
            end
            if draggingSV then
                setFromSV(input.Position.X, input.Position.Y, true)
            elseif draggingHue then
                setFromHueX(input.Position.X, true)
            end
        end)
        connect(UserInputService.InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSV = false
                draggingHue = false
            end
        end)

        local function setOpen(v)
            open = v == true
            if open then
                local h = pLayout.AbsoluteContentSize.Y + 12
                panel.Visible = true
                header.Text = tostring(text or "Color") .. "  ^"
                tween(panel, 0.12, {Size = UDim2.new(1, 0, 0, h)})
                tween(wrap, 0.12, {Size = UDim2.new(1, 0, 0, 24 + h)})
            else
                header.Text = tostring(text or "Color") .. "  v"
                tween(panel, 0.10, {Size = UDim2.new(1, 0, 0, 0)})
                tween(wrap, 0.10, {Size = UDim2.new(1, 0, 0, 24)})
                task.delay(0.11, function()
                    if panel.Parent and not open then
                        panel.Visible = false
                    end
                end)
            end
        end

        header.MouseButton1Click:Connect(function()
            setOpen(not open)
        end)

        apply(false)

        return withVisibilityAPI(wrap, {
            GetValue = function() return current end,
            SetValue = function(color, fireCallback)
                if typeof(color) == "Color3" then
                    hue, sat, val = Color3.toHSV(color)
                    apply(fireCallback == true)
                end
            end,
            ChangeColor = function(color)
                if typeof(color) == "Color3" then
                    hue, sat, val = Color3.toHSV(color)
                    apply(true)
                end
            end,
        })
    end

    function api:Input(placeholder, default, callback, options)
        options = options or {}
        local multiline = options.Multiline == true
        local box = make("TextBox", {
            Size = UDim2.new(1, 0, 0, multiline and 52 or 22),
            BackgroundColor3 = C.Input,
            BackgroundTransparency = 0.15,
            BorderSizePixel = 0,
            Text = default or "",
            PlaceholderText = placeholder or "",
            PlaceholderColor3 = C.TextMuted,
            TextColor3 = C.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = multiline and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
            TextWrapped = multiline,
            MultiLine = multiline,
            ClearTextOnFocus = options.ClearOnFocus == true,
            Font = FONT,
            TextSize = TXT - 1,
            LayoutOrder = nextOrder(),
            Parent = targetScroll,
        })
        corner(box, 4)
        stroke(box, C.Border, C.BorderAlpha, 1)

        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 8)
        pad.PaddingRight = UDim.new(0, 8)
        if multiline then
            pad.PaddingTop = UDim.new(0, 5)
            pad.PaddingBottom = UDim.new(0, 5)
        end
        pad.Parent = box

        box:GetPropertyChangedSignal("Text"):Connect(function()
            if multiline then
                local targetHeight = math.max(52, box.TextBounds.Y + 14)
                box.Size = UDim2.new(1, 0, 0, targetHeight)
            end
        end)

        box.FocusLost:Connect(function(enterPressed)
            if callback then callback(box.Text, enterPressed) end
        end)
        return withVisibilityAPI(box, {
            GetText = function()
                return box.Text
            end,
            SetText = function(value)
                box.Text = tostring(value or "")
            end,
        })
    end

    function api:Slider(text, min, max, default, callback)
        min = min or 0
        max = max or 100
        if max <= min then
            max = min + 1
        end

        local value = math.clamp(default or min, min, max)
        local dragging = false

        local wrap = make("Frame", {
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            LayoutOrder = nextOrder(),
            Parent = targetScroll,
        })

        local title = make("TextLabel", {
            Size = UDim2.new(0.72, 0, 0, 14),
            BackgroundTransparency = 1,
            Text = tostring(text or "Slider"),
            Font = FONT,
            TextSize = TXT - 1,
            TextColor3 = C.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = wrap,
        })

        local valueLabel = make("TextLabel", {
            Size = UDim2.new(0.28, 0, 0, 14),
            Position = UDim2.new(0.72, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = tostring(value),
            Font = FONT,
            TextSize = TXT - 1,
            TextColor3 = C.TextMuted,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = wrap,
        })

        local track = make("Frame", {
            Size = UDim2.new(1, -12, 0, 8),
            Position = UDim2.new(0, 6, 0, 21),
            BackgroundColor3 = C.Track,
            BorderSizePixel = 0,
            Parent = wrap,
        })
        corner(track, 999)
        stroke(track, C.Border, C.BorderAlpha, 1)

        local fill = make("Frame", {
            Size = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = C.Accent,
            BorderSizePixel = 0,
            Parent = track,
        })
        corner(fill, 999)

        local thumb = make("Frame", {
            Size = UDim2.new(0, 12, 0, 12),
            Position = UDim2.new(0, -6, 0.5, -6),
            BackgroundColor3 = C.Thumb,
            BorderSizePixel = 0,
            Parent = track,
        })
        corner(thumb, 999)
        stroke(thumb, C.AccentDark, 0.25, 1)

        local function percentFromValue(v)
            return (v - min) / (max - min)
        end

        local function redraw(doCallback)
            local pct = percentFromValue(value)
            fill.Size = UDim2.new(pct, 0, 1, 0)
            thumb.Position = UDim2.new(pct, -6, 0.5, -6)
            valueLabel.Text = tostring(value)
            if doCallback and callback then
                callback(value)
            end
        end

        local function setFromInputPosition(x, doCallback)
            local left = track.AbsolutePosition.X
            local width = math.max(track.AbsoluteSize.X, 1)
            local pct = math.clamp((x - left) / width, 0, 1)
            local raw = min + pct * (max - min)
            value = math.floor(raw + 0.5)
            redraw(doCallback)
        end

        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                setFromInputPosition(input.Position.X, true)
            end
        end)

        connect(UserInputService.InputChanged, function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                setFromInputPosition(input.Position.X, true)
            end
        end)

        connect(UserInputService.InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        redraw(false)

        return withVisibilityAPI(wrap, {
            GetValue = function()
                return value
            end,
            SetValue = function(v, fireCallback)
                value = math.clamp(v, min, max)
                redraw(fireCallback == true)
            end,
        })
    end

    return api
end

local function containerLayoutInfo(count, index)
    if count == 1 then
        return UDim2.new(1, -4, 1, -4), UDim2.new(0, 2, 0, 2)
    end
    if count == 2 then
        local width = UDim2.new(0.5, -6, 1, -4)
        local x = index == 1 and 0 or 0.5
        local offset = index == 1 and 2 or 4
        return width, UDim2.new(x, offset, 0, 2)
    end
    if index == 1 then
        return UDim2.new(0.5, -6, 0.5, -6), UDim2.new(0, 2, 0, 2)
    end
    if index == 2 then
        return UDim2.new(0.5, -6, 0.5, -6), UDim2.new(0.5, 4, 0, 2)
    end
    if index == 3 then
        return UDim2.new(0.5, -6, 0.5, -6), UDim2.new(0, 2, 0.5, 4)
    end
    return UDim2.new(0.5, -6, 0.5, -6), UDim2.new(0.5, 4, 0.5, 4)
end

local FRAME_BLUR_STEP_NAME = "UnitedUI_FrameBlurStep"
local FRAME_BLUR_PART_SIZE = 0.01
local FRAME_BLUR_PART_TRANSPARENCY = 1 - 1e-7
local frameBlurManager = {
    entries = {},
    effect = nil,
    bound = false,
}

local function frameBlurRayPlaneIntersect(planePos, planeNormal, rayOrigin, rayDirection)
    local n = planeNormal
    local d = rayDirection
    local v = rayOrigin - planePos

    local num = (n.X * v.X) + (n.Y * v.Y) + (n.Z * v.Z)
    local den = (n.X * d.X) + (n.Y * d.Y) + (n.Z * d.Z)
    if math.abs(den) <= 1e-6 then
        return rayOrigin
    end

    local a = -num / den
    return rayOrigin + (a * rayDirection)
end

local function frameBlurReadIgnoreGuiInset(frame)
    local current = frame
    while current do
        current = current.Parent
        if current and current:IsA("ScreenGui") then
            return current.IgnoreGuiInset == true
        end
    end
    return false
end

local function frameBlurNormalizeStrength(blurSize)
    local normalized = math.clamp((tonumber(blurSize) or 16) / 56, 0, 1)
    local intensity = 0.16 + (normalized * 0.64)
    local padding = math.clamp(math.floor(6 + (normalized * 14)), 6, 20)
    return intensity, Vector2.new(padding, padding)
end

local function frameBlurIsDescendantOf(instance, ancestor)
    local current = instance
    while current do
        if current == ancestor then
            return true
        end
        current = current.Parent
    end
    return false
end

function frameBlurManager:_ensureEffect()
    if self.effect and self.effect.Parent then
        return self.effect
    end

    self.effect = Instance.new("DepthOfFieldEffect")
    self.effect.Name = "UnitedUI_FrameDoFBlur"
    self.effect.FarIntensity = 0
    self.effect.NearIntensity = 0
    self.effect.FocusDistance = 0.25
    self.effect.InFocusRadius = 0
    self.effect.Enabled = true
    self.effect.Parent = Lighting
    return self.effect
end

function frameBlurManager:_unbindIfEmpty()
    if next(self.entries) ~= nil then
        return
    end
    if self.bound then
        pcall(function()
            RunService:UnbindFromRenderStep(FRAME_BLUR_STEP_NAME)
        end)
        self.bound = false
    end
    if self.effect and self.effect.Parent then
        self.effect:Destroy()
    end
    self.effect = nil
end

function frameBlurManager:_removeEntry(entry)
    if not entry or not self.entries[entry] then
        return
    end

    self.entries[entry] = nil
    if entry.part and entry.part.Parent then
        entry.part:Destroy()
    end
    entry.part = nil
    entry.mesh = nil
    self:_unbindIfEmpty()
end

function frameBlurManager:_step()
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end

    local hasVisible = false
    local maxIntensity = 0
    local staleEntries = {}

    for entry in pairs(self.entries) do
        local frame = entry.frame
        local part = entry.part
        local mesh = entry.mesh

        if not frame or not frame.Parent or not part or not mesh then
            table.insert(staleEntries, entry)
        elseif not entry.enabled or not frame.Visible then
            part.Transparency = 1
        else
            if part.Parent ~= camera then
                part.Parent = camera
            end
            part.CFrame = camera.CFrame
            part.Transparency = FRAME_BLUR_PART_TRANSPARENCY

            local corner0 = frame.AbsolutePosition + entry.padding + entry.manualOffset
            local corner1 = corner0 + frame.AbsoluteSize - (entry.padding * 2)
            if entry.coreGuiInsetCompensation then
                local insetTopLeft = select(1, GuiService:GetGuiInset())
                corner0 += insetTopLeft
                corner1 += insetTopLeft
            end

            if corner1.X <= corner0.X or corner1.Y <= corner0.Y then
                part.Transparency = 1
            else
                local ray0, ray1
                if entry.ignoreGuiInset then
                    ray0 = camera:ViewportPointToRay(corner0.X, corner0.Y, 1)
                    ray1 = camera:ViewportPointToRay(corner1.X, corner1.Y, 1)
                else
                    ray0 = camera:ScreenPointToRay(corner0.X, corner0.Y, 1)
                    ray1 = camera:ScreenPointToRay(corner1.X, corner1.Y, 1)
                end

                local planeOrigin = camera.CFrame.Position + (camera.CFrame.LookVector * (0.05 - camera.NearPlaneZ))
                local planeNormal = camera.CFrame.LookVector
                local pos0 = frameBlurRayPlaneIntersect(planeOrigin, planeNormal, ray0.Origin, ray0.Direction)
                local pos1 = frameBlurRayPlaneIntersect(planeOrigin, planeNormal, ray1.Origin, ray1.Direction)

                pos0 = camera.CFrame:PointToObjectSpace(pos0)
                pos1 = camera.CFrame:PointToObjectSpace(pos1)

                local size = pos1 - pos0
                local center = (pos0 + pos1) / 2

                mesh.Offset = center
                mesh.Scale = size / FRAME_BLUR_PART_SIZE

                hasVisible = true
                if entry.intensity > maxIntensity then
                    maxIntensity = entry.intensity
                end
            end
        end
    end

    for i = 1, #staleEntries do
        self:_removeEntry(staleEntries[i])
    end

    if next(self.entries) == nil then
        return
    end

    local effect = self:_ensureEffect()
    effect.Enabled = hasVisible
    effect.NearIntensity = hasVisible and maxIntensity or 0
    effect.FarIntensity = 0
    effect.InFocusRadius = 0
    effect.FocusDistance = 0.25 - camera.NearPlaneZ
end

function frameBlurManager:_ensureBound()
    if self.bound then
        return
    end
    self.bound = true
    self:_ensureEffect()
    RunService:BindToRenderStep(FRAME_BLUR_STEP_NAME, Enum.RenderPriority.Camera.Value + 1, function()
        frameBlurManager:_step()
    end)
end

function frameBlurManager:Create(frame, blurSize, manualOffset)
    local intensity, padding = frameBlurNormalizeStrength(blurSize)
    local offset = (typeof(manualOffset) == "Vector2") and manualOffset or Vector2.new(0, 0)
    local ignoreGuiInset = frameBlurReadIgnoreGuiInset(frame)

    local blurPart = Instance.new("Part")
    blurPart.Name = "UnitedUI_BlurPart"
    blurPart.Size = Vector3.new(1, 1, 1) * FRAME_BLUR_PART_SIZE
    blurPart.Anchored = true
    blurPart.CanCollide = false
    blurPart.CanTouch = false
    pcall(function()
        blurPart.CanQuery = false
    end)
    blurPart.Material = Enum.Material.Glass
    blurPart.Transparency = FRAME_BLUR_PART_TRANSPARENCY
    blurPart.Parent = workspace.CurrentCamera

    local mesh = Instance.new("BlockMesh")
    mesh.Parent = blurPart

    local entry = {
        frame = frame,
        part = blurPart,
        mesh = mesh,
        enabled = true,
        ignoreGuiInset = ignoreGuiInset,
        coreGuiInsetCompensation = ignoreGuiInset and frameBlurIsDescendantOf(frame, CoreGui),
        manualOffset = offset,
        intensity = intensity,
        padding = padding,
    }
    self.entries[entry] = true
    self:_ensureBound()

    local handle = {}

    function handle:SetEnabled(enabled)
        entry.enabled = enabled == true
        if not entry.enabled and entry.part then
            entry.part.Transparency = 1
        end
    end

    function handle:SetStrength(newBlurSize)
        local newIntensity, newPadding = frameBlurNormalizeStrength(newBlurSize)
        entry.intensity = newIntensity
        entry.padding = newPadding
    end

    function handle:SetOffset(newOffset)
        if typeof(newOffset) == "Vector2" then
            entry.manualOffset = newOffset
        end
    end

    function handle:Destroy()
        frameBlurManager:_removeEntry(entry)
    end

    return handle
end

local NOTIF_MODE_COLORS = {
    Info = Color3.fromRGB(60, 60, 60),
    Information = Color3.fromRGB(60, 60, 60),
    Success = Color3.fromRGB(61, 140, 84),
    Error = Color3.fromRGB(165, 68, 68),
    Fail = Color3.fromRGB(165, 68, 68),
    Warning = Color3.fromRGB(176, 146, 62),
    Debug = Color3.fromRGB(73, 119, 181),
}

local notifGui = nil
local notifByLocation = {aa = {}, ab = {}, ba = {}, bb = {}}
local notifQueue = {}
local notifQueueRunning = false
local notifQueueGap = 0.25
local notifViewportConn = nil
local layoutNotifications

local function ensureNotifGui()
    if notifGui and notifGui.Parent then
        return notifGui
    end
    notifGui = make("ScreenGui", {
        Name = "UnitedUI_Notifications",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui,
    })
    if notifViewportConn then
        notifViewportConn:Disconnect()
        notifViewportConn = nil
    end
    local cam = workspace.CurrentCamera
    if cam then
        notifViewportConn = cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            layoutNotifications("aa", true)
            layoutNotifications("ab", true)
            layoutNotifications("ba", true)
            layoutNotifications("bb", true)
        end)
    end
    return notifGui
end

local function getNotificationTargetY(location, index, height, spacing)
    local topSide = location == "aa" or location == "ab"
    local camera = workspace.CurrentCamera
    local viewportY = (camera and camera.ViewportSize.Y) or 720
    if topSide then
        return 12 + ((index - 1) * (height + spacing))
    end
    return (viewportY - 12) - (index * height) - ((index - 1) * spacing)
end

layoutNotifications = function(location, instant)
    local list = notifByLocation[location]
    local spacing = 8

    for i, item in ipairs(list) do
        local targetY = getNotificationTargetY(location, i, item.height, spacing)
        local targetX = item._exiting and item.xHidden or item.xVisible
        local targetPos = UDim2.new(item.sideScale, targetX, 0, targetY)
        if instant then
            item.frame.Position = targetPos
        else
            tween(item.frame, 0.14, {Position = targetPos})
        end
    end
end

local function createNotificationNow(settings)
    settings = settings or {}
    local delaySec = tonumber(settings.Delay) or 3
    local location = tostring(settings.Location or "bb")
    if not notifByLocation[location] then
        location = "bb"
    end

    local mode = tostring(settings.Mode or "Info")
    local modeColor = NOTIF_MODE_COLORS[mode] or NOTIF_MODE_COLORS.Info
    local title = tostring(settings.Title or mode)
    local text = tostring(settings.Text or "Notification")

    ensureNotifGui()

    local isRight = location == "ab" or location == "bb"
    local sideScale = isRight and 1 or 0
    local width = 280
    local height = 62
    local xVisible = isRight and -12 or 12
    local xHidden = isRight and (width + 26) or (-width - 26)

    local frame = make("Frame", {
        Size = UDim2.new(0, width, 0, height),
        Position = UDim2.new(sideScale, xHidden, 0, 12),
        AnchorPoint = Vector2.new(isRight and 1 or 0, 0),
        BackgroundColor3 = Color3.fromRGB(28, 28, 28),
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Parent = notifGui,
    })
    corner(frame, 6)
    stroke(frame, modeColor, 0.15, 1)

    local modeBar = make("Frame", {
        Size = UDim2.new(0, 4, 1, 0),
        Position = UDim2.new(isRight and 1 or 0, isRight and -4 or 0, 0, 0),
        BackgroundColor3 = modeColor,
        BorderSizePixel = 0,
        Parent = frame,
    })

    if isRight then
        corner(modeBar, 6)
    else
        corner(modeBar, 6)
    end

    local titleLabel = make("TextLabel", {
        Size = UDim2.new(1, -18, 0, 18),
        Position = UDim2.new(0, 8, 0, 6),
        BackgroundTransparency = 1,
        Text = title,
        Font = FONT,
        TextSize = 12,
        TextColor3 = C.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })

    local textLabel = make("TextLabel", {
        Size = UDim2.new(1, -18, 0, 30),
        Position = UDim2.new(0, 8, 0, 24),
        BackgroundTransparency = 1,
        Text = text,
        Font = FONT,
        TextSize = 11,
        TextColor3 = C.TextMuted,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = frame,
    })

    local item = {
        frame = frame,
        height = height,
        sideScale = sideScale,
        xVisible = xVisible,
        xHidden = xHidden,
        location = location,
        _exiting = false,
    }

    -- New notifications should appear closest to selected corner.
    table.insert(notifByLocation[location], 1, item)
    layoutNotifications(location, true)
    tween(frame, 0.16, {Position = UDim2.new(sideScale, xVisible, 0, frame.Position.Y.Offset)})

    task.delay(delaySec, function()
        if frame.Parent then
            item._exiting = true
            layoutNotifications(location, false)
            task.delay(0.16, function()
                for i, n in ipairs(notifByLocation[location]) do
                    if n == item then
                        table.remove(notifByLocation[location], i)
                        break
                    end
                end
                if frame.Parent then
                    frame:Destroy()
                end
                layoutNotifications(location, false)
            end)
        end
    end)

    return {
        Destroy = function()
            if frame.Parent then
                frame:Destroy()
                for i, n in ipairs(notifByLocation[location]) do
                    if n == item then
                        table.remove(notifByLocation[location], i)
                        break
                    end
                end
                layoutNotifications(location, false)
            end
        end,
    }
end

local function runNotificationQueue()
    if notifQueueRunning then
        return
    end
    notifQueueRunning = true
    task.spawn(function()
        while #notifQueue > 0 do
            local entry = table.remove(notifQueue, 1)
            if entry and not entry.cancelled then
                local created = createNotificationNow(entry.settings)
                entry.created = created
                if created and created.Destroy then
                    entry.proxy.Destroy = function()
                        if entry.cancelled then
                            return
                        end
                        entry.cancelled = true
                        created:Destroy()
                    end
                end
            end
            task.wait(notifQueueGap)
        end
        notifQueueRunning = false
    end)
end

function UI.Notification(settings)
    local queuedSettings = settings or {}
    local entry = {
        settings = queuedSettings,
        cancelled = false,
        created = nil,
        proxy = {},
    }

    entry.proxy.Destroy = function()
        if entry.cancelled then
            return
        end
        entry.cancelled = true
        if entry.created and entry.created.Destroy then
            entry.created:Destroy()
        end
    end

    table.insert(notifQueue, entry)
    runNotificationQueue()
    return entry.proxy
end

UI.Notify = UI.Notification

function UI.Window(title, width, posX, posY, height, options)
    options = options or {}
    width = width or 760
    posX = posX or 120
    posY = posY or 80
    height = height or 500

    local minWidth = 520
    local minHeight = 340
    local maxWidthPad = 8
    local maxHeightPad = 8
    local saveConfigs = options.SaveConfigs == true
    local configFolder = "UnitedUI_Configs"
    local configName = (tostring(title or "window"):gsub("[^%w_%-]", "_")) .. "_main.cfg"
    local configPath = configFolder .. "/" .. configName
    local selectedTheme = applyTheme(options.Theme or options.theme or "default", options.CustomTheme or options.customTheme)

    local rawBackgroundMode = string.lower(tostring(options.Background or options.background or "transparent"))
    local backgroundModeAliases = {
        transparent = "transparent",
        normal = "normal",
        opaque = "normal",
        blur = "blurr",
        blurr = "blurr",
        rozmycie = "blurr",
    }
    local backgroundMode = backgroundModeAliases[rawBackgroundMode] or "transparent"
    local blurSize = math.clamp(tonumber(options.BlurSize or options.blurSize) or 16, 0, 56)
    local blurOffsetX = tonumber(options.BlurOffsetX or options.blurOffsetX) or 0
    local blurOffsetYRaw = options.BlurOffsetY
    if blurOffsetYRaw == nil then
        blurOffsetYRaw = options.blurOffsetY
    end
    -- Default +2 Y aligns blur plane with UI in CoreGui across most executors.
    local blurOffsetY = tonumber(blurOffsetYRaw)
    if blurOffsetY == nil then
        blurOffsetY = 2
    end

    local windowBackgroundTransparency = C.WindowAlpha
    local headerBackgroundTransparency = math.min(0.95, C.HeaderAlpha + 0.14)
    if backgroundMode == "normal" then
        windowBackgroundTransparency = math.max(0, math.min(0.12, C.WindowAlpha * 0.12))
        headerBackgroundTransparency = math.max(0, math.min(0.10, C.HeaderAlpha * 0.10))
    elseif backgroundMode == "blurr" then
        headerBackgroundTransparency = math.min(0.95, C.HeaderAlpha + 0.18)
    end

    local gui = make("ScreenGui", {
        Name = "UnitedUI_" .. tostring(title or "Window"),
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui,
    })

    local frame = make("Frame", {
        Size = UDim2.new(0, width, 0, height),
        Position = UDim2.new(0, posX, 0, posY),
        BackgroundColor3 = C.Window,
        BackgroundTransparency = windowBackgroundTransparency,
        BorderSizePixel = 0,
        Parent = gui,
    })
    corner(frame, 7)
    stroke(frame, C.Border, C.BorderAlpha, 1)
    local blurOverlay = nil
    if backgroundMode == "blurr" then
        blurOverlay = make("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = shiftColor(C.Window, 0.05),
            BackgroundTransparency = 0.48,
            BorderSizePixel = 0,
            ZIndex = 1,
            Parent = frame,
        })
        corner(blurOverlay, 7)
        make("UIGradient", {
            Rotation = 90,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, shiftColor(C.Window, 0.10)),
                ColorSequenceKeypoint.new(1, shiftColor(C.Window, -0.08)),
            }),
            Parent = blurOverlay,
        })
    end
    local trackedConnections = {}
    local connectionsCleaned = false
    local function trackConnection(connection)
        if connection then
            table.insert(trackedConnections, connection)
        end
        return connection
    end
    local function connectTracked(signal, callback)
        return trackConnection(signal:Connect(callback))
    end
    local function disconnectTrackedConnections()
        if connectionsCleaned then
            return
        end
        connectionsCleaned = true
        for i = #trackedConnections, 1, -1 do
            local connection = trackedConnections[i]
            trackedConnections[i] = nil
            if connection and connection.Connected then
                pcall(function()
                    connection:Disconnect()
                end)
            end
        end
    end

    local function getViewportSize()
        local cam = workspace.CurrentCamera
        if cam then
            return cam.ViewportSize
        end
        return Vector2.new(1920, 1080)
    end

    local function clampWindowToViewport()
        local viewport = getViewportSize()
        local maxW = math.max(minWidth, viewport.X - maxWidthPad)
        local maxH = math.max(minHeight, viewport.Y - maxHeightPad)
        local curSize = frame.Size
        local clampedW = math.clamp(curSize.X.Offset, minWidth, maxW)
        local clampedH = math.clamp(curSize.Y.Offset, minHeight, maxH)
        frame.Size = UDim2.new(0, clampedW, 0, clampedH)

        local curPos = frame.Position
        local maxX = math.max(0, viewport.X - clampedW)
        local maxY = math.max(0, viewport.Y - clampedH)
        local clampedX = math.clamp(curPos.X.Offset, 0, maxX)
        local clampedY = math.clamp(curPos.Y.Offset, 0, maxY)
        frame.Position = UDim2.new(0, clampedX, 0, clampedY)
    end

    clampWindowToViewport()

    local top = make("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = C.Header,
        BackgroundTransparency = headerBackgroundTransparency,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = frame,
    })
    corner(top, 7)
    make("UIGradient", {
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, shiftColor(C.Header, 0.06)),
            ColorSequenceKeypoint.new(1.00, shiftColor(C.Header, -0.05)),
        }),
        Parent = top,
    })

    local topHighlight = make("Frame", {
        Size = UDim2.new(1, -14, 0, 1),
        Position = UDim2.new(0, 7, 0, 1),
        BackgroundColor3 = shiftColor(C.Border, 0.30),
        BackgroundTransparency = 0.88,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = top,
    })

    local topDivider = make("Frame", {
        Size = UDim2.new(1, -4, 0, 1),
        Position = UDim2.new(0, 2, 1, -1),
        BackgroundColor3 = C.Border,
        BackgroundTransparency = math.min(0.9, C.BorderAlpha * 0.75),
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = top,
    })

    local nameLabel = make("TextLabel", {
        Size = UDim2.new(1, -96, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(title or "Window"),
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = C.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
        Parent = top,
    })

    local nameShadow = make("TextLabel", {
        Size = nameLabel.Size,
        Position = UDim2.new(0, 1, 0, 1),
        BackgroundTransparency = 1,
        Text = nameLabel.Text,
        Font = nameLabel.Font,
        TextSize = nameLabel.TextSize,
        TextColor3 = shiftColor(C.Header, -0.20),
        TextTransparency = 0.55,
        TextXAlignment = nameLabel.TextXAlignment,
        ZIndex = 3,
        Parent = top,
    })

    local close = make("TextButton", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(1, -21, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        AutoButtonColor = false,
        BackgroundColor3 = Color3.fromRGB(56, 41, 41),
        BackgroundTransparency = 0.12,
        BorderSizePixel = 0,
        Text = "",
        ZIndex = 4,
        Parent = top,
    })
    corner(close, 5)
    local closeStroke = stroke(close, Color3.fromRGB(142, 95, 95), 0.52, 1)
    local closeIcon = make("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "X",
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = Color3.fromRGB(215, 185, 185),
        ZIndex = 5,
        Parent = close,
    })

    local minimize = make("TextButton", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(1, -45, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        AutoButtonColor = false,
        BackgroundColor3 = Color3.fromRGB(42, 44, 50),
        BackgroundTransparency = 0.12,
        BorderSizePixel = 0,
        Text = "",
        ZIndex = 4,
        Parent = top,
    })
    corner(minimize, 5)
    local minimizeStroke = stroke(minimize, Color3.fromRGB(121, 128, 145), 0.56, 1)
    local minimizeIcon = make("TextLabel", {
        Size = UDim2.new(1, 0, 1, -1),
        BackgroundTransparency = 1,
        Text = "-",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Color3.fromRGB(184, 192, 208),
        ZIndex = 5,
        Parent = minimize,
    })

    local function styleHeaderButton(btn, icon, outline, opts)
        local baseSize = btn.Size
        local pressSize = UDim2.new(baseSize.X.Scale, baseSize.X.Offset - 1, baseSize.Y.Scale, baseSize.Y.Offset - 1)
        btn.MouseEnter:Connect(function()
            tween(btn, 0.10, {
                BackgroundColor3 = opts.hoverBg,
                BackgroundTransparency = opts.hoverAlpha,
                Size = baseSize,
            })
            tween(icon, 0.10, {TextColor3 = opts.hoverText})
            tween(outline, 0.10, {
                Color = opts.hoverStrokeColor,
                Transparency = opts.hoverStrokeAlpha,
            })
        end)
        btn.MouseLeave:Connect(function()
            tween(btn, 0.10, {
                BackgroundColor3 = opts.baseBg,
                BackgroundTransparency = opts.baseAlpha,
                Size = baseSize,
            })
            tween(icon, 0.10, {TextColor3 = opts.baseText})
            tween(outline, 0.10, {
                Color = opts.baseStrokeColor,
                Transparency = opts.baseStrokeAlpha,
            })
        end)
        btn.MouseButton1Down:Connect(function()
            tween(btn, 0.05, {
                BackgroundColor3 = opts.pressBg,
                BackgroundTransparency = opts.pressAlpha,
                Size = pressSize,
            }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        end)
        btn.MouseButton1Up:Connect(function()
            tween(btn, 0.07, {
                BackgroundColor3 = opts.hoverBg,
                BackgroundTransparency = opts.hoverAlpha,
                Size = baseSize,
            }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        end)
    end

    styleHeaderButton(close, closeIcon, closeStroke, {
        baseBg = Color3.fromRGB(56, 41, 41),
        hoverBg = Color3.fromRGB(130, 70, 70),
        pressBg = Color3.fromRGB(104, 57, 57),
        baseAlpha = 0.12,
        hoverAlpha = 0.02,
        pressAlpha = 0.06,
        baseText = Color3.fromRGB(215, 185, 185),
        hoverText = Color3.fromRGB(252, 244, 244),
        baseStrokeColor = Color3.fromRGB(142, 95, 95),
        hoverStrokeColor = Color3.fromRGB(186, 130, 130),
        baseStrokeAlpha = 0.52,
        hoverStrokeAlpha = 0.30,
    })
    styleHeaderButton(minimize, minimizeIcon, minimizeStroke, {
        baseBg = Color3.fromRGB(42, 44, 50),
        hoverBg = Color3.fromRGB(64, 70, 85),
        pressBg = Color3.fromRGB(56, 60, 73),
        baseAlpha = 0.12,
        hoverAlpha = 0.04,
        pressAlpha = 0.08,
        baseText = Color3.fromRGB(184, 192, 208),
        hoverText = Color3.fromRGB(238, 242, 250),
        baseStrokeColor = Color3.fromRGB(121, 128, 145),
        hoverStrokeColor = Color3.fromRGB(152, 162, 182),
        baseStrokeAlpha = 0.56,
        hoverStrokeAlpha = 0.34,
    })

    local tabsBar = make("ScrollingFrame", {
        Size = UDim2.new(1, -20, 0, 22),
        Position = UDim2.new(0, 10, 0, 38),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = C.Border,
        ScrollBarImageTransparency = 0.35,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.None,
        ClipsDescendants = true,
        Parent = frame,
    })
    local tabsList = listLayout(tabsBar, 5)
    tabsList.FillDirection = Enum.FillDirection.Horizontal

    local pagesHost = make("Frame", {
        Size = UDim2.new(1, -20, 1, -70),
        Position = UDim2.new(0, 10, 0, 66),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = frame,
    })
    local pagesHostTabsSize = UDim2.new(1, -20, 1, -70)
    local pagesHostTabsPos = UDim2.new(0, 10, 0, 66)
    local pagesHostSingleSize = UDim2.new(1, -20, 1, -42)
    local pagesHostSinglePos = UDim2.new(0, 10, 0, 38)
    local function setTabsBarVisible(visible)
        tabsBar.Visible = visible == true
        if tabsBar.Visible then
            pagesHost.Size = pagesHostTabsSize
            pagesHost.Position = pagesHostTabsPos
        else
            pagesHost.Size = pagesHostSingleSize
            pagesHost.Position = pagesHostSinglePos
        end
    end
    setTabsBarVisible(false)

    local windowScale = make("UIScale", {
        Scale = 1,
        Parent = frame,
    })
    local dofWindowBlur = nil
    local localWindowBlur = nil
    local blurFallbackVisuals = nil
    local function buildPseudoBlurFallback(baseOverlay, strength)
        if not baseOverlay or not baseOverlay.Parent then
            return nil
        end

        local normalized = math.clamp((tonumber(strength) or 16) / 56, 0, 1)
        local visuals = {}

        local frostTop = make("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = shiftColor(C.Window, 0.14),
            BackgroundTransparency = math.clamp(0.90 - (normalized * 0.18), 0.62, 0.90),
            BorderSizePixel = 0,
            ZIndex = 1,
            Parent = baseOverlay,
        })
        corner(frostTop, 7)
        make("UIGradient", {
            Rotation = 28,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, shiftColor(C.Window, 0.20)),
                ColorSequenceKeypoint.new(1, shiftColor(C.Window, -0.03)),
            }),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0.00, 0.08),
                NumberSequenceKeypoint.new(0.45, 0.88),
                NumberSequenceKeypoint.new(1.00, 0.05),
            }),
            Parent = frostTop,
        })
        table.insert(visuals, {instance = frostTop, alpha = frostTop.BackgroundTransparency})

        local frostBottom = make("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = shiftColor(C.Window, -0.12),
            BackgroundTransparency = math.clamp(0.94 - (normalized * 0.16), 0.66, 0.94),
            BorderSizePixel = 0,
            ZIndex = 1,
            Parent = baseOverlay,
        })
        corner(frostBottom, 7)
        make("UIGradient", {
            Rotation = 202,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, shiftColor(C.Window, -0.20)),
                ColorSequenceKeypoint.new(1, shiftColor(C.Window, 0.07)),
            }),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0.00, 0.20),
                NumberSequenceKeypoint.new(0.50, 0.92),
                NumberSequenceKeypoint.new(1.00, 0.20),
            }),
            Parent = frostBottom,
        })
        table.insert(visuals, {instance = frostBottom, alpha = frostBottom.BackgroundTransparency})

        local scanlines = make("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            ZIndex = 1,
            Parent = baseOverlay,
        })
        corner(scanlines, 7)
        local lineCount = math.max(10, math.floor(10 + (normalized * 16)))
        local lineAlpha = math.clamp(0.95 - (normalized * 0.10), 0.80, 0.95)
        local lineAccentAlpha = math.clamp(lineAlpha - 0.05, 0.70, 0.92)
        for i = 1, lineCount do
            local y = (i - 1) / (lineCount - 1)
            local line = make("Frame", {
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.new(0, 0, y, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = (i % 2 == 0) and shiftColor(C.Window, 0.18) or shiftColor(C.Window, -0.14),
                BackgroundTransparency = (i % 3 == 0) and lineAccentAlpha or lineAlpha,
                BorderSizePixel = 0,
                ZIndex = 1,
                Parent = scanlines,
            })
            table.insert(visuals, {instance = line, alpha = line.BackgroundTransparency})
        end

        return visuals
    end
    if backgroundMode == "blurr" then
        local dofOk, dofHandle = pcall(function()
            return frameBlurManager:Create(frame, blurSize, Vector2.new(blurOffsetX, blurOffsetY))
        end)
        if dofOk and dofHandle then
            dofWindowBlur = dofHandle
        else
            local ok, blurObject = pcall(function()
                local blur = Instance.new("UIBlur")
                blur.Size = blurSize
                blur.Enabled = true
                blur.Parent = frame
                return blur
            end)
            if ok and blurObject then
                localWindowBlur = blurObject
            elseif blurOverlay then
                -- Fallback when UIBlur is unavailable: keep effect local to the window only.
                blurOverlay.BackgroundTransparency = math.clamp(0.58 - (blurSize / 160), 0.24, 0.58)
                blurFallbackVisuals = buildPseudoBlurFallback(blurOverlay, blurSize)
            end
        end
    end

    makeDraggable(top, frame, clampWindowToViewport, connectTracked)
    local function setWindowBlurEnabled(enabled)
        if backgroundMode ~= "blurr" then
            return
        end
        if dofWindowBlur and dofWindowBlur.SetEnabled then
            dofWindowBlur:SetEnabled(enabled == true)
        end
        if localWindowBlur then
            localWindowBlur.Enabled = enabled == true
        end
    end

    local win = {
        _gui = gui,
        _frame = frame,
        _tabs = {},
        _tabButtons = {},
        _activeTab = nil,
        _defaultContainerApi = nil,
        _rootContainerApi = nil,
        _rootContainerHolder = nil,
        _rootContainerTitle = nil,
        _tabsList = tabsList,
        _pagesHost = pagesHost,
        _toggleKey = Enum.KeyCode.RightShift,
        _hidden = false,
        _destroying = false,
        _saveConfigs = saveConfigs,
        _configPath = configPath,
        _theme = selectedTheme,
        _backgroundMode = backgroundMode,
    }
    local relayoutTabs
    local cleanedUpWindow = false
    local function cleanupDestroyedWindow()
        if cleanedUpWindow then
            return
        end
        cleanedUpWindow = true
        local captureBelongsToWindow = false
        if activeKeybindCapture and gui then
            local ok, result = pcall(function()
                return activeKeybindCapture:IsDescendantOf(gui)
            end)
            captureBelongsToWindow = ok and result == true
        end
        if captureBelongsToWindow then
            activeKeybindCapture = nil
        end
        win._toggleKey = Enum.KeyCode.Unknown
        if dofWindowBlur and dofWindowBlur.Destroy then
            dofWindowBlur:Destroy()
            dofWindowBlur = nil
        end
        setWindowBlurEnabled(false)
        disconnectTrackedConnections()
    end
    connectTracked(gui.Destroying, cleanupDestroyedWindow)

    setWindowBlurEnabled(true)

    local savedSize = frame.Size
    local savedPos = frame.Position
    local openDuration = 0.24
    local closeDuration = 0.20
    local collapsedScale = 0.90
    local animationId = 0

    local baseFrameBg = frame.BackgroundTransparency
    local baseBlurOverlay = blurOverlay and blurOverlay.BackgroundTransparency or nil
    local blurFallbackAlphaBoost = 0.42
    local baseTopBg = top.BackgroundTransparency
    local baseNameText = nameLabel.TextTransparency
    local baseNameShadowText = nameShadow.TextTransparency
    local baseTopHighlight = topHighlight.BackgroundTransparency
    local baseTopDivider = topDivider.BackgroundTransparency
    local baseTabsScroll = tabsBar.ScrollBarImageTransparency
    local baseCloseBg = close.BackgroundTransparency
    local baseCloseText = closeIcon.TextTransparency
    local baseCloseStroke = closeStroke.Transparency
    local baseMinimizeBg = minimize.BackgroundTransparency
    local baseMinimizeText = minimizeIcon.TextTransparency
    local baseMinimizeStroke = minimizeStroke.Transparency

    local animationFade = make("NumberValue", {
        Value = 0,
        Parent = frame,
    })

    local function applyAnimationFade(alpha)
        alpha = math.clamp(alpha or 0, 0, 1)
        frame.BackgroundTransparency = math.min(1, baseFrameBg + (0.55 * alpha))
        if blurOverlay then
            blurOverlay.BackgroundTransparency = math.min(1, baseBlurOverlay + (0.35 * alpha))
        end
        if blurFallbackVisuals then
            for i = 1, #blurFallbackVisuals do
                local visual = blurFallbackVisuals[i]
                if visual and visual.instance and visual.instance.Parent then
                    visual.instance.BackgroundTransparency = math.min(1, visual.alpha + (blurFallbackAlphaBoost * alpha))
                end
            end
        end
        top.BackgroundTransparency = math.min(1, baseTopBg + (0.45 * alpha))
        nameLabel.TextTransparency = math.min(1, baseNameText + (0.78 * alpha))
        nameShadow.TextTransparency = math.min(1, baseNameShadowText + (0.42 * alpha))
        topHighlight.BackgroundTransparency = math.min(1, baseTopHighlight + (0.55 * alpha))
        topDivider.BackgroundTransparency = math.min(1, baseTopDivider + (0.50 * alpha))
        tabsBar.ScrollBarImageTransparency = math.min(1, baseTabsScroll + (0.55 * alpha))
        close.BackgroundTransparency = math.min(1, baseCloseBg + (0.62 * alpha))
        closeIcon.TextTransparency = math.min(1, baseCloseText + (0.82 * alpha))
        closeStroke.Transparency = math.min(1, baseCloseStroke + (0.50 * alpha))
        minimize.BackgroundTransparency = math.min(1, baseMinimizeBg + (0.62 * alpha))
        minimizeIcon.TextTransparency = math.min(1, baseMinimizeText + (0.82 * alpha))
        minimizeStroke.Transparency = math.min(1, baseMinimizeStroke + (0.50 * alpha))
    end

    connectTracked(animationFade:GetPropertyChangedSignal("Value"), function()
        applyAnimationFade(animationFade.Value)
    end)
    applyAnimationFade(0)

    local function getCollapsedWindowState(size, pos)
        local targetW = math.max(220, math.floor(size.X.Offset * collapsedScale))
        local targetH = math.max(44, math.floor(size.Y.Offset * collapsedScale))
        local targetX = pos.X.Offset + math.floor((size.X.Offset - targetW) * 0.5)
        local targetY = pos.Y.Offset + math.floor((size.Y.Offset - targetH) * 0.5) + 14
        local targetSize = UDim2.new(0, targetW, 0, targetH)
        local targetPos = UDim2.new(0, targetX, 0, targetY)
        return targetSize, targetPos
    end

    local function animateOut(onDone, force)
        if win._destroying and not force then
            return
        end
        animationId += 1
        local currentId = animationId
        local startSize = frame.Size
        local startPos = frame.Position
        savedSize = startSize
        savedPos = startPos
        local targetSize, targetPos = getCollapsedWindowState(startSize, startPos)
        tween(frame, closeDuration, {Size = targetSize, Position = targetPos}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        tween(windowScale, closeDuration, {Scale = 0.94}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tween(animationFade, closeDuration * 0.9, {Value = 1}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        task.delay(closeDuration + 0.01, function()
            if currentId ~= animationId then
                return
            end
            if onDone then
                onDone()
            end
        end)
    end

    local function animateIn(onDone)
        animationId += 1
        local currentId = animationId
        local finalSize = savedSize
        local finalPos = savedPos
        local startSize, startPos = getCollapsedWindowState(finalSize, finalPos)
        frame.Size = startSize
        frame.Position = startPos
        windowScale.Scale = 0.94
        animationFade.Value = 1
        tween(frame, openDuration, {Size = finalSize, Position = finalPos}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        tween(windowScale, openDuration, {Scale = 1}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        tween(animationFade, openDuration * 0.9, {Value = 0}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        task.delay(openDuration + 0.01, function()
            if currentId ~= animationId then
                return
            end
            if onDone then
                onDone()
            end
        end)
    end

    function win:Minimize()
        if self._hidden or self._destroying then
            return
        end
        animateOut(function()
            if self._gui and self._gui.Parent then
                self._gui.Enabled = false
                self._hidden = true
                setWindowBlurEnabled(false)
            end
        end)
    end

    function win:Restore()
        if self._destroying then
            return
        end
        if self._gui and self._gui.Parent then
            self._gui.Enabled = true
            self._hidden = false
            setWindowBlurEnabled(true)
            animateIn(function()
                clampWindowToViewport()
                if relayoutTabs then
                    relayoutTabs()
                end
            end)
        end
    end

    function win:Open()
        self:Restore()
    end

    function win:Close()
        self:Minimize()
    end

    function win:SetSize(newWidth, newHeight)
        if self._destroying then
            return
        end
        local current = self._frame.Size
        local w = tonumber(newWidth) or current.X.Offset
        local h = tonumber(newHeight) or current.Y.Offset
        self._frame.Size = UDim2.new(0, w, 0, h)
        clampWindowToViewport()
        if relayoutTabs then
            relayoutTabs()
        end
        self:SaveConfig()
    end

    function win:SetPosition(newX, newY)
        if self._destroying then
            return
        end
        local current = self._frame.Position
        local x = tonumber(newX) or current.X.Offset
        local y = tonumber(newY) or current.Y.Offset
        self._frame.Position = UDim2.new(0, x, 0, y)
        clampWindowToViewport()
        self:SaveConfig()
    end

    function win:SetToggleKeybind(keyCodeOrControl)
        if typeof(keyCodeOrControl) == "EnumItem" then
            if keyCodeOrControl.EnumType == Enum.KeyCode and keyCodeOrControl ~= Enum.KeyCode.Unknown then
                self._toggleKey = keyCodeOrControl
                self:SaveConfig()
            end
            return
        end
        if type(keyCodeOrControl) == "table" and keyCodeOrControl.GetKeybind then
            self._toggleKey = keyCodeOrControl:GetKeybind()
            if keyCodeOrControl.SetMode then
                keyCodeOrControl:SetMode("toggle")
            end
            if keyCodeOrControl.SetOnChanged then
                keyCodeOrControl:SetOnChanged(function(_, newKey)
                    self._toggleKey = newKey
                    self:SaveConfig()
                end)
            end
            self:SaveConfig()
            return
        end
        if type(keyCodeOrControl) == "table" and keyCodeOrControl.GetKey then
            self._toggleKey = keyCodeOrControl:GetKey()
            self:SaveConfig()
            return
        end
        if keyCodeOrControl and keyCodeOrControl ~= Enum.KeyCode.Unknown then
            self._toggleKey = keyCodeOrControl
        end
        self:SaveConfig()
    end

    function win:SaveConfig()
        if not self._saveConfigs then
            return false
        end
        if type(writefile) ~= "function" or type(makefolder) ~= "function" then
            return false
        end
        if type(isfolder) == "function" and not isfolder(configFolder) then
            makefolder(configFolder)
        end
        local data = {
            sizeX = self._frame.Size.X.Offset,
            sizeY = self._frame.Size.Y.Offset,
            posX = self._frame.Position.X.Offset,
            posY = self._frame.Position.Y.Offset,
            toggleKey = self._toggleKey and self._toggleKey.Name or "RightShift",
        }
        writefile(self._configPath, game:GetService("HttpService"):JSONEncode(data))
        return true
    end

    function win:LoadConfig()
        if not self._saveConfigs then
            return false
        end
        if type(readfile) ~= "function" or type(isfile) ~= "function" or not isfile(self._configPath) then
            return false
        end
        local ok, decoded = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile(self._configPath))
        end)
        if not ok or type(decoded) ~= "table" then
            return false
        end
        self:SetSize(decoded.sizeX, decoded.sizeY)
        self:SetPosition(decoded.posX, decoded.posY)
        if decoded.toggleKey and Enum.KeyCode[decoded.toggleKey] then
            self:SetToggleKeybind(Enum.KeyCode[decoded.toggleKey])
        end
        return true
    end

    function win:GetToggleKeybind()
        return self._toggleKey
    end

    connectTracked(minimize.Activated, function()
        win:Minimize()
    end)

    connectTracked(close.Activated, function()
        if win._destroying then
            return
        end
        win._destroying = true
        animateOut(function()
            cleanupDestroyedWindow()
            if gui and gui.Parent then
                gui:Destroy()
            end
        end, true)
    end)

    connectTracked(UserInputService.InputBegan, function(input, gameProcessed)
        if isTypingInTextBox() then
            return
        end
        if activeKeybindCapture then
            return
        end
        if input.KeyCode == win._toggleKey then
            if win._hidden then
                win:Restore()
            else
                win:Minimize()
            end
            return
        end
        if gameProcessed then
            return
        end
    end)

    local function switchTab(tabObj)
        for _, t in ipairs(win._tabs) do
            local selected = t == tabObj
            t._page.Visible = selected
            local btn = t._button
            if selected then
                btn.BackgroundColor3 = C.Accent
                btn.TextColor3 = Color3.fromRGB(244, 244, 244)
                btn.BackgroundTransparency = 0.15
            else
                btn.BackgroundColor3 = C.Button
                btn.TextColor3 = C.Text
                btn.BackgroundTransparency = 0.2
            end
        end
        win._activeTab = tabObj
        win._defaultContainerApi = tabObj and tabObj._containersApi[1] or nil
    end

    relayoutTabs = function()
        local count = #win._tabs
        if count == 0 then
            return
        end
        local totalWidth = tabsBar.AbsoluteSize.X
        if totalWidth <= 0 then
            return
        end

        local spacing = tabsList.Padding.Offset
        local usable = totalWidth - ((count - 1) * spacing)
        local each = math.floor(usable / count)
        each = math.clamp(math.floor(each * 0.70), 24, 80)

        for _, t in ipairs(win._tabs) do
            t._button.Size = UDim2.new(0, each, 1, 0)
        end
        tabsBar.CanvasSize = UDim2.new(0, (each * count) + ((count - 1) * spacing), 0, 0)
    end

    connectTracked(tabsBar:GetPropertyChangedSignal("AbsoluteSize"), relayoutTabs)

    local function createContainer(parent, name, size, pos)
        local holder = make("Frame", {
            Size = size,
            Position = pos,
            BackgroundColor3 = C.Panel,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Parent = parent,
        })
        corner(holder, 6)
        stroke(holder, C.Border, C.BorderAlpha, 1)

        local title = make("TextLabel", {
            Size = UDim2.new(1, -12, 0, 18),
            Position = UDim2.new(0, 8, 0, 6),
            BackgroundTransparency = 1,
            Text = tostring(name or ""),
            Font = FONT,
            TextSize = 12,
            TextColor3 = C.TextMuted,
            TextXAlignment = Enum.TextXAlignment.Left,
            Visible = tostring(name or "") ~= "",
            Parent = holder,
        })

        local scroll = make("ScrollingFrame", {
            Size = UDim2.new(1, -12, 1, -28),
            Position = UDim2.new(0, 6, 0, 24),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = C.AccentDark,
            ScrollBarImageTransparency = 0.35,
            AutomaticCanvasSize = Enum.AutomaticSize.None,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            TopImage = "",
            MidImage = "",
            BottomImage = "",
            Parent = holder,
        })
        local scrollPad = Instance.new("UIPadding")
        scrollPad.PaddingRight = UDim.new(0, 6)
        scrollPad.Parent = scroll

        local layout = listLayout(scroll, 6)
        attachAutoCanvas(scroll, layout, 10, connectTracked)

        return holder, scroll, title
    end

    local function ensureRootContainer(containerName)
        if #win._tabs > 0 then
            return nil
        end
        setTabsBarVisible(false)
        if not win._rootContainerApi or not win._rootContainerHolder or not win._rootContainerHolder.Parent then
            local holder, scroll, titleLabel = createContainer(
                pagesHost,
                containerName or "",
                UDim2.new(1, -4, 1, -4),
                UDim2.new(0, 2, 0, 2)
            )
            win._rootContainerHolder = holder
            win._rootContainerTitle = titleLabel
            win._rootContainerApi = createElementAPI(scroll, connectTracked)
        end
        if win._rootContainerTitle and containerName ~= nil then
            local textName = tostring(containerName)
            win._rootContainerTitle.Text = textName
            win._rootContainerTitle.Visible = textName ~= ""
        end
        if win._rootContainerHolder and win._rootContainerHolder.Parent then
            win._rootContainerHolder.Visible = true
        end
        win._defaultContainerApi = win._rootContainerApi
        return win._rootContainerApi
    end

    function win:CreateContainer(name)
        return ensureRootContainer(name)
    end

    function win:AddContainer(name)
        return ensureRootContainer(name)
    end

    function win:GetContainer()
        if #self._tabs == 0 then
            return ensureRootContainer()
        end
        if self._activeTab and self._activeTab.GetContainer then
            return self._activeTab:GetContainer(1)
        end
        return nil
    end

    function win:CreateTab(tabName, containersCount, containerNames)
        if self._rootContainerApi then
            return nil
        end
        setTabsBarVisible(true)
        local names = containerNames
        if type(containersCount) == "table" then
            local cfg = containersCount
            containersCount = cfg.count or cfg.containers or cfg[1] or 1
            names = cfg.names or cfg.containerNames or cfg[2]
        end

        containersCount = containersCount or 1
        if containersCount ~= 1 and containersCount ~= 2 and containersCount ~= 4 then
            containersCount = 1
        end

        local page = make("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Visible = false,
            Parent = self._pagesHost,
        })

        local tabButton = make("TextButton", {
            Size = UDim2.new(0, 70, 1, 0),
            AutoButtonColor = false,
            BackgroundColor3 = C.Button,
            BackgroundTransparency = 0.2,
            BorderSizePixel = 0,
            Text = tostring(tabName),
            Font = FONT,
            TextSize = 11,
            TextColor3 = C.Text,
            Parent = tabsBar,
        })
        corner(tabButton, 4)
        stroke(tabButton, C.Border, C.BorderAlpha, 1)

        local tab = {
            Name = tabName,
            _button = tabButton,
            _page = page,
            _containers = {},
            _containersApi = {},
            _containersCount = containersCount,
        }

        for i = 1, containersCount do
            local size, pos = containerLayoutInfo(containersCount, i)
            local customName = (type(names) == "table" and names[i]) and tostring(names[i]) or ""
            local holder, scroll = createContainer(page, customName, size, pos)
            tab._containers[i] = holder
            tab._containersApi[i] = createElementAPI(scroll, connectTracked)
        end

        function tab:GetContainer(i)
            i = math.clamp(i or 1, 1, #self._containersApi)
            return self._containersApi[i]
        end

        function tab:GetContainersCount()
            return self._containersCount
        end

        connectTracked(tabButton.MouseButton1Click, function()
            switchTab(tab)
        end)

        table.insert(self._tabs, tab)
        relayoutTabs()
        if #self._tabs == 1 then
            switchTab(tab)
        end
        return tab
    end

    -- Backward compatibility: controls are added to first container of active tab.
    local function ensureDefaultContainer()
        if not win._defaultContainerApi then
            if #win._tabs == 0 then
                local defaultTab = win:CreateTab("Main", 1)
                if defaultTab then
                    switchTab(defaultTab)
                else
                    return ensureRootContainer()
                end
            else
                win._defaultContainerApi = win._activeTab and win._activeTab._containersApi[1] or nil
            end
        end
        return win._defaultContainerApi
    end

    function win:Label(text)
        return ensureDefaultContainer():Label(text)
    end

    function win:Button(text, callback)
        return ensureDefaultContainer():Button(text, callback)
    end

    function win:Toggle(text, default, callback)
        return ensureDefaultContainer():Toggle(text, default, callback)
    end

    function win:Slider(text, min, max, default, callback)
        return ensureDefaultContainer():Slider(text, min, max, default, callback)
    end

    function win:Input(placeholder, default, callback, options)
        return ensureDefaultContainer():Input(placeholder, default, callback, options)
    end

    function win:Dropdown(text, options, default, callback)
        return ensureDefaultContainer():Dropdown(text, options, default, callback)
    end

    function win:MultiDropdown(text, options, defaults, callback)
        return ensureDefaultContainer():MultiDropdown(text, options, defaults, callback)
    end

    function win:Keybind(text, defaultKeyCode, onActivate, onChanged, mode)
        return ensureDefaultContainer():Keybind(text, defaultKeyCode, onActivate, onChanged, mode)
    end

    function win:ColorPicker(text, defaultColor, callback)
        return ensureDefaultContainer():ColorPicker(text, defaultColor, callback)
    end

    function win:Notification(settings)
        return UI.Notification(settings)
    end

    function win:CreateNotificationsTab(tabName)
        local tab = self:CreateTab(tabName or "Notifications", 1, {"Notifications"})
        if not tab then
            return nil
        end
        local api = tab:GetContainer(1)

        api:Label("Notification settings")
        api:Label("Location: aa=left top, ab=right top, ba=left bottom, bb=right bottom")

        local delayInput = api:Input("Delay (seconds)", "3")
        local locationDrop = api:Dropdown("Location", {"aa", "ab", "ba", "bb"}, "bb")
        local modeDrop = api:Dropdown("Mode", {"Info", "Success", "Error", "Fail", "Warning", "Debug", "Information"}, "Info")
        local titleInput = api:Input("Title", "Info")
        local textInput = api:Input("Text", "Notification", nil, {Multiline = true})

        local function readSettings()
            local mode = modeDrop:GetValue()
            local titleText = titleInput:GetText()
            if titleText == nil or titleText == "" then
                titleText = mode
            end
            return {
                Delay = tonumber(delayInput:GetText()) or 3,
                Location = locationDrop:GetValue(),
                Mode = mode,
                Title = titleText,
                Text = (textInput:GetText() and textInput:GetText() ~= "") and textInput:GetText() or "Notification",
            }
        end

        api:Button("Send", function()
            UI.Notification(readSettings())
        end)

        return {
            Tab = tab,
            GetSettings = function()
                return readSettings()
            end,
            Send = function(customSettings)
                local cfg = customSettings or readSettings()
                return UI.Notification(cfg)
            end,
            SetSettings = function(newSettings)
                newSettings = newSettings or {}
                if newSettings.Delay ~= nil then
                    delayInput:SetText(tostring(newSettings.Delay))
                end
                if newSettings.Location ~= nil then
                    locationDrop:SetValue(tostring(newSettings.Location), false)
                end
                if newSettings.Mode ~= nil then
                    modeDrop:SetValue(tostring(newSettings.Mode), false)
                end
                if newSettings.Title ~= nil then
                    titleInput:SetText(tostring(newSettings.Title))
                end
                if newSettings.Text ~= nil then
                    textInput:SetText(tostring(newSettings.Text))
                end
            end,
        }
    end

    function win:Separator()
        return ensureDefaultContainer():Separator()
    end

    function win:PressButton(buttonControl)
        if buttonControl and buttonControl.PressButton then
            buttonControl:PressButton()
        end
    end

    function win:ToggleToggle(toggleControl)
        if toggleControl and toggleControl.ToggleToggle then
            toggleControl:ToggleToggle()
        end
    end

    function win:ChangeDropdown(dropdownControl, option)
        if dropdownControl and dropdownControl.ChangeDropdown then
            dropdownControl:ChangeDropdown(option)
        end
    end

    function win:GetToggle(toggleControl)
        if toggleControl and toggleControl.GetToggle then
            return toggleControl:GetToggle()
        end
        return nil
    end

    function win:ChangeColor(colorPickerControl, color)
        if colorPickerControl and colorPickerControl.ChangeColor then
            colorPickerControl:ChangeColor(color)
        end
    end

    -- Legacy Toolbar -> maps to tabs and returns old-like API.
    function win:Toolbar(tabNames, callback)
        local created = {}
        for _, n in ipairs(tabNames or {}) do
            local tab = self:CreateTab(n, 1)
            if tab then
                table.insert(created, tab)
            end
        end
        if #created == 0 then
            local fallback = self:CreateTab("Main", 1)
            if fallback then
                table.insert(created, fallback)
            else
                return nil
            end
        end

        local function getSelected()
            for i, t in ipairs(created) do
                if self._activeTab == t then
                    return i
                end
            end
            return 1
        end

        for i, tab in ipairs(created) do
            connectTracked(tab._button.MouseButton1Click, function()
                if callback then callback(i) end
            end)
        end

        return {
            GetSelected = function()
                return getSelected()
            end,
            SetSelected = function(i)
                local idx = math.clamp(i or 1, 1, #created)
                switchTab(created[idx])
                if callback then callback(idx) end
            end,
        }
    end

    -- Legacy Grid: rendered as rows of buttons in current container.
    function win:Grid(columns, items)
        columns = math.max(columns or 1, 1)
        local api = ensureDefaultContainer()
        for _, it in ipairs(items or {}) do
            api:Button(it[1], it[2])
        end
        return columns
    end

    function win:Destroy()
        if self._destroying then
            return
        end
        self:SaveConfig()
        self._destroying = true
        animateOut(function()
            cleanupDestroyedWindow()
            if self._gui and self._gui.Parent then
                self._gui:Destroy()
            end
        end, true)
    end

    local resizeGrip = make("TextButton", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -22, 1, -22),
        AnchorPoint = Vector2.new(0, 0),
        AutoButtonColor = false,
        BackgroundColor3 = C.Button,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        Parent = frame,
    })

    local resizing = false
    local resizeStartMouse = Vector2.new(0, 0)
    local resizeStartSize = Vector2.new(0, 0)

    connectTracked(resizeGrip.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeStartMouse = input.Position
            resizeStartSize = Vector2.new(frame.Size.X.Offset, frame.Size.Y.Offset)
        end
    end)

    connectTracked(UserInputService.InputChanged, function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - resizeStartMouse
            frame.Size = UDim2.new(0, resizeStartSize.X + delta.X, 0, resizeStartSize.Y + delta.Y)
            clampWindowToViewport()
            relayoutTabs()
        end
    end)

    connectTracked(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)

    connectTracked(RunService.RenderStepped, function()
        if frame.Parent ~= nil then
            clampWindowToViewport()
        end
    end)

    if win._saveConfigs then
        win:LoadConfig()
    end

    return win
end

return UI
