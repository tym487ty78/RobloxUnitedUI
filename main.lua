--[[
    UILibrary.lua
    Unity/BepInEx-style transparent grey UI for Roblox
    
    Użycie:
        local UI = loadstring(game:HttpGet("..."))()
        local win = UI.Window("Title")
        win:Label("Hello!")
        win:Button("Click me", function() print("clicked") end)
        win:Toggle("Enable", false, function(v) print(v) end)
        win:Slider("Speed", 0, 100, 16, function(v) print(v) end)
        local toolbar = win:Toolbar({"Tab1","Tab2","Tab3"}, function(i) print(i) end)
        local grid = win:Grid(2, {
            {"Btn1", function() end},
            {"Btn2", function() end},
        })
]]

local UI = {}
UI.__index = UI

-- Kolory (Unity transparent dark grey style)
local C = {
    WinBG        = Color3.fromRGB(40, 40, 40),
    WinBGAlpha   = 0.72,
    TitleBG      = Color3.fromRGB(28, 28, 28),
    TitleAlpha   = 0.80,
    BtnBG        = Color3.fromRGB(75, 75, 75),
    BtnBGAlpha   = 0.75,
    BtnHover     = Color3.fromRGB(95, 95, 95),
    BtnActive    = Color3.fromRGB(50, 50, 50),
    BtnBorder    = Color3.fromRGB(15, 15, 15),
    SliderBG     = Color3.fromRGB(20, 20, 20),
    SliderFill   = Color3.fromRGB(90, 90, 90),
    SliderThumb  = Color3.fromRGB(90, 90, 90),
    CheckBG      = Color3.fromRGB(25, 25, 25),
    CheckOn      = Color3.fromRGB(200, 210, 225),
    TextMain     = Color3.fromRGB(210, 220, 230),
    TextMuted    = Color3.fromRGB(155, 170, 185),
    Separator    = Color3.fromRGB(10, 10, 10),
    SepAlpha     = 0.45,
}

local FONT      = Enum.Font.Arial
local FONT_SIZE = Enum.FontSize.Size12
local TXT_SIZE  = 12

-- Usługi
local Players        = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService   = game:GetService("TweenService")
local RunService     = game:GetService("RunService")

local LocalPlayer  = Players.LocalPlayer
local PlayerGui    = LocalPlayer:WaitForChild("PlayerGui")

------------------------------------------------------------------------
-- Helpers
------------------------------------------------------------------------

local function makeInst(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do
        inst[k] = v
    end
    return inst
end

local function makeFrame(props)
    return makeInst("Frame", props)
end

local function makeLabel(props)
    return makeInst("TextLabel", props)
end

local function makeButton(props)
    return makeInst("TextButton", props)
end

local function makeUICorner(radius, parent)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
end

local function makeUIPadding(t, b, l, r, parent)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, t)
    p.PaddingBottom = UDim.new(0, b)
    p.PaddingLeft   = UDim.new(0, l)
    p.PaddingRight  = UDim.new(0, r)
    p.Parent = parent
end

local function makeUIListLayout(parent, spacing, padding)
    local l = Instance.new("UIListLayout")
    l.SortOrder     = Enum.SortOrder.LayoutOrder
    l.Padding       = UDim.new(0, spacing or 4)
    l.Parent        = parent
    return l
end

local function makeUIGridLayout(parent, cellSize, cellPadding, cols)
    local g = Instance.new("UIGridLayout")
    g.SortOrder       = Enum.SortOrder.LayoutOrder
    g.CellSize        = cellSize or UDim2.new(0.5, -3, 0, 22)
    g.CellPadding     = cellPadding or UDim2.new(0, 4, 0, 4)
    g.FillDirection   = Enum.FillDirection.Horizontal
    g.HorizontalAlignment = Enum.HorizontalAlignment.Left
    g.Parent = parent
    return g
end

-- Automatyczne dopasowanie rozmiaru Frame do zawartości (UIListLayout)
local function autoSize(frame, layout, extraPadding)
    local function update()
        frame.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y + (extraPadding or 0))
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
    update()
end

------------------------------------------------------------------------
-- Dragging
------------------------------------------------------------------------

local function makeDraggable(handle, target)
    local dragging = false
    local dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = target.Position
        end
    end)

    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
                         input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

------------------------------------------------------------------------
-- Window
------------------------------------------------------------------------

function UI.Window(title, width, posX, posY)
    width  = width  or 280
    posX   = posX   or 100
    posY   = posY   or 100

    -- ScreenGui
    local screenGui = makeInst("ScreenGui", {
        Name           = "UILibrary_" .. title,
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent         = PlayerGui,
    })

    -- Główne okno
    local winFrame = makeFrame({
        Name            = "Window",
        Size            = UDim2.new(0, width, 0, 60),
        Position        = UDim2.new(0, posX, 0, posY),
        BackgroundColor3 = C.WinBG,
        BackgroundTransparency = 1 - C.WinBGAlpha,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent          = screenGui,
    })
    makeUICorner(7, winFrame)

    -- Cień (opcjonalny, symulowany przez UIStroke)
    local stroke = Instance.new("UIStroke")
    stroke.Color       = Color3.fromRGB(0, 0, 0)
    stroke.Transparency = 0.4
    stroke.Thickness   = 1
    stroke.Parent      = winFrame

    -- Titlebar
    local titleBar = makeFrame({
        Name            = "TitleBar",
        Size            = UDim2.new(1, 0, 0, 24),
        Position        = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = C.TitleBG,
        BackgroundTransparency = 1 - C.TitleAlpha,
        BorderSizePixel = 0,
        ZIndex          = 2,
        Parent          = winFrame,
    })

    local titleLabel = makeLabel({
        Size            = UDim2.new(1, -30, 1, 0),
        Position        = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text            = title,
        TextColor3      = C.TextMain,
        Font            = FONT,
        TextSize        = TXT_SIZE,
        TextXAlignment  = Enum.TextXAlignment.Center,
        Parent          = titleBar,
    })

    -- Przycisk zamknięcia
    local closeBtn = makeButton({
        Size            = UDim2.new(0, 18, 0, 18),
        Position        = UDim2.new(1, -22, 0.5, -9),
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Text            = "×",
        TextColor3      = C.TextMuted,
        Font            = FONT,
        TextSize        = 14,
        ZIndex          = 3,
        Parent          = titleBar,
    })
    makeUICorner(3, closeBtn)
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    closeBtn.MouseEnter:Connect(function()
        closeBtn.BackgroundColor3 = Color3.fromRGB(160, 50, 50)
    end)
    closeBtn.MouseLeave:Connect(function()
        closeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end)

    -- Separator pod titlebar
    local sep0 = makeFrame({
        Size            = UDim2.new(1, 0, 0, 1),
        Position        = UDim2.new(0, 0, 0, 24),
        BackgroundColor3 = C.Separator,
        BackgroundTransparency = 1 - C.SepAlpha,
        BorderSizePixel = 0,
        Parent          = winFrame,
    })

    -- Scroll / zawartość
    local contentFrame = makeFrame({
        Name            = "Content",
        Size            = UDim2.new(1, 0, 1, -25),
        Position        = UDim2.new(0, 0, 0, 25),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent          = winFrame,
    })
    makeUIPadding(5, 7, 8, 8, contentFrame)

    local listLayout = makeUIListLayout(contentFrame, 5)

    -- Auto-resize okna
    local function updateWinSize()
        local contentH = listLayout.AbsoluteContentSize.Y + 12
        winFrame.Size = UDim2.new(0, width, 0, 25 + contentH)
    end
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateWinSize)

    -- Drag
    makeDraggable(titleBar, winFrame)

    -- Minimalizacja
    local minimized = false
    local function toggleMinimize()
        minimized = not minimized
        contentFrame.Visible = not minimized
        sep0.Visible = not minimized
        if minimized then
            winFrame.Size = UDim2.new(0, width, 0, 24)
        else
            updateWinSize()
        end
    end
    titleLabel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            toggleMinimize()
        end
    end)

    -- Obiekt window zwracany użytkownikowi
    local win = {
        _frame    = winFrame,
        _content  = contentFrame,
        _layout   = listLayout,
        _order    = 0,
        _screenGui = screenGui,
    }

    local function nextOrder(self)
        self._order = self._order + 1
        return self._order
    end

    --------------------------------------------------------------------
    -- Label
    --------------------------------------------------------------------
    function win:Label(text)
        local lbl = makeLabel({
            Size            = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            Text            = text,
            TextColor3      = C.TextMain,
            Font            = FONT,
            TextSize        = TXT_SIZE,
            TextXAlignment  = Enum.TextXAlignment.Left,
            TextWrapped     = true,
            LayoutOrder     = nextOrder(self),
            Parent          = self._content,
        })
        return lbl
    end

    --------------------------------------------------------------------
    -- Button
    --------------------------------------------------------------------
    function win:Button(text, callback)
        local btn = makeButton({
            Size            = UDim2.new(1, 0, 0, 22),
            BackgroundColor3 = C.BtnBG,
            BackgroundTransparency = 1 - C.BtnBGAlpha,
            BorderSizePixel = 0,
            Text            = text,
            TextColor3      = C.TextMain,
            Font            = FONT,
            TextSize        = TXT_SIZE,
            LayoutOrder     = nextOrder(self),
            Parent          = self._content,
        })
        makeUICorner(4, btn)

        local stroke2 = Instance.new("UIStroke")
        stroke2.Color       = C.BtnBorder
        stroke2.Transparency = 0.4
        stroke2.Thickness   = 1
        stroke2.Parent      = btn

        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = C.BtnHover
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = C.BtnBG
        end)
        btn.MouseButton1Down:Connect(function()
            btn.BackgroundColor3 = C.BtnActive
        end)
        btn.MouseButton1Up:Connect(function()
            btn.BackgroundColor3 = C.BtnHover
        end)
        btn.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)

        return btn
    end

    --------------------------------------------------------------------
    -- Toggle
    --------------------------------------------------------------------
    function win:Toggle(text, default, callback)
        local state = default or false

        local row = makeFrame({
            Size            = UDim2.new(1, 0, 0, 22),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            LayoutOrder     = nextOrder(self),
            Parent          = self._content,
        })

        -- Checkbox
        local box = makeButton({
            Size            = UDim2.new(0, 14, 0, 14),
            Position        = UDim2.new(0, 0, 0.5, -7),
            BackgroundColor3 = C.CheckBG,
            BackgroundTransparency = 0.2,
            BorderSizePixel = 0,
            Text            = "",
            Parent          = row,
        })
        makeUICorner(2, box)
        local strokeChk = Instance.new("UIStroke")
        strokeChk.Color       = Color3.fromRGB(0,0,0)
        strokeChk.Transparency = 0.45
        strokeChk.Parent      = box

        -- Tick wewnątrz checkboxa
        local tick = makeLabel({
            Size            = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text            = "✓",
            TextColor3      = C.CheckOn,
            Font            = FONT,
            TextSize        = 11,
            Visible         = state,
            Parent          = box,
        })

        local lbl = makeLabel({
            Size            = UDim2.new(1, -22, 1, 0),
            Position        = UDim2.new(0, 20, 0, 0),
            BackgroundTransparency = 1,
            Text            = text,
            TextColor3      = C.TextMain,
            Font            = FONT,
            TextSize        = TXT_SIZE,
            TextXAlignment  = Enum.TextXAlignment.Left,
            Parent          = row,
        })

        local function toggle()
            state = not state
            tick.Visible = state
            if callback then callback(state) end
        end

        box.MouseButton1Click:Connect(toggle)
        lbl.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                toggle()
            end
        end)

        return {
            SetValue = function(v)
                state = v
                tick.Visible = state
            end,
            GetValue = function()
                return state
            end,
        }
    end

    --------------------------------------------------------------------
    -- Slider
    --------------------------------------------------------------------
    function win:Slider(text, min, max, default, callback)
        min     = min     or 0
        max     = max     or 100
        default = default or min

        local value = default
        local dragging = false

        local container = makeFrame({
            Size            = UDim2.new(1, 0, 0, 36),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            LayoutOrder     = nextOrder(self),
            Parent          = self._content,
        })

        -- Etykieta + wartość
        local headerFrame = makeFrame({
            Size            = UDim2.new(1, 0, 0, 14),
            BackgroundTransparency = 1,
            Parent          = container,
        })
        local sliderLabel = makeLabel({
            Size            = UDim2.new(0.75, 0, 1, 0),
            BackgroundTransparency = 1,
            Text            = text,
            TextColor3      = C.TextMain,
            Font            = FONT,
            TextSize        = TXT_SIZE,
            TextXAlignment  = Enum.TextXAlignment.Left,
            Parent          = headerFrame,
        })
        local valueLabel = makeLabel({
            Size            = UDim2.new(0.25, 0, 1, 0),
            Position        = UDim2.new(0.75, 0, 0, 0),
            BackgroundTransparency = 1,
            Text            = tostring(default),
            TextColor3      = C.TextMuted,
            Font            = FONT,
            TextSize        = TXT_SIZE,
            TextXAlignment  = Enum.TextXAlignment.Right,
            Parent          = headerFrame,
        })

        -- Track
        local track = makeFrame({
            Size            = UDim2.new(1, 0, 0, 8),
            Position        = UDim2.new(0, 0, 0, 22),
            BackgroundColor3 = C.SliderBG,
            BackgroundTransparency = 0.35,
            BorderSizePixel = 0,
            Parent          = container,
        })
        makeUICorner(4, track)
        local trackStroke = Instance.new("UIStroke")
        trackStroke.Color       = Color3.fromRGB(0,0,0)
        trackStroke.Transparency = 0.4
        trackStroke.Parent      = track

        -- Fill
        local fill = makeFrame({
            Size            = UDim2.new((default - min)/(max - min), 0, 1, 0),
            BackgroundColor3 = C.SliderFill,
            BackgroundTransparency = 0.4,
            BorderSizePixel = 0,
            Parent          = track,
        })
        makeUICorner(4, fill)

        -- Thumb
        local thumb = makeButton({
            Size            = UDim2.new(0, 16, 0, 16),
            Position        = UDim2.new((default - min)/(max - min), -8, 0.5, -8),
            BackgroundColor3 = C.SliderThumb,
            BackgroundTransparency = 0.25,
            BorderSizePixel = 0,
            Text            = "",
            ZIndex          = 2,
            Parent          = track,
        })
        makeUICorner(3, thumb)
        local thumbStroke = Instance.new("UIStroke")
        thumbStroke.Color       = Color3.fromRGB(0,0,0)
        thumbStroke.Transparency = 0.4
        thumbStroke.Parent      = thumb

        local function setSliderValue(absX)
            local trackPos   = track.AbsolutePosition.X
            local trackWidth = track.AbsoluteSize.X
            local rel = math.clamp((absX - trackPos) / trackWidth, 0, 1)
            value = math.floor(min + rel * (max - min) + 0.5)
            local pct = (value - min) / (max - min)
            fill.Size     = UDim2.new(pct, 0, 1, 0)
            thumb.Position = UDim2.new(pct, -8, 0.5, -8)
            valueLabel.Text = tostring(value)
            if callback then callback(value) end
        end

        thumb.MouseButton1Down:Connect(function()
            dragging = true
        end)
        track.MouseButton1Down:Connect(function(_, _, x)
            setSliderValue(x)
            dragging = true
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                setSliderValue(input.Position.X)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        return {
            GetValue = function() return value end,
            SetValue = function(v)
                value = math.clamp(v, min, max)
                local pct = (value - min) / (max - min)
                fill.Size      = UDim2.new(pct, 0, 1, 0)
                thumb.Position = UDim2.new(pct, -8, 0.5, -8)
                valueLabel.Text = tostring(value)
            end,
        }
    end

    --------------------------------------------------------------------
    -- Toolbar (zakładki)
    --------------------------------------------------------------------
    function win:Toolbar(tabs, callback)
        local selected = 1

        local toolbarFrame = makeFrame({
            Size            = UDim2.new(1, 0, 0, 22),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            LayoutOrder     = nextOrder(self),
            Parent          = self._content,
        })

        local grid = makeUIGridLayout(
            toolbarFrame,
            UDim2.new(1/#tabs, -3, 0, 22),
            UDim2.new(0, 3, 0, 0)
        )

        local btnRefs = {}

        local function updateSelected()
            for i, btn in ipairs(btnRefs) do
                if i == selected then
                    btn.BackgroundColor3         = C.BtnActive
                    btn.BackgroundTransparency   = 0.15
                    btn.TextColor3               = Color3.fromRGB(230,235,245)
                else
                    btn.BackgroundColor3         = C.BtnBG
                    btn.BackgroundTransparency   = 1 - C.BtnBGAlpha
                    btn.TextColor3               = C.TextMain
                end
            end
        end

        for i, tabName in ipairs(tabs) do
            local btn = makeButton({
                BackgroundColor3 = C.BtnBG,
                BackgroundTransparency = 1 - C.BtnBGAlpha,
                BorderSizePixel = 0,
                Text            = tabName,
                TextColor3      = C.TextMain,
                Font            = FONT,
                TextSize        = TXT_SIZE,
                LayoutOrder     = i,
                Parent          = toolbarFrame,
            })
            makeUICorner(4, btn)
            local st = Instance.new("UIStroke")
            st.Color       = C.BtnBorder
            st.Transparency = 0.4
            st.Parent      = btn

            btn.MouseButton1Click:Connect(function()
                selected = i
                updateSelected()
                if callback then callback(i) end
            end)
            table.insert(btnRefs, btn)
        end

        updateSelected()

        return {
            GetSelected = function() return selected end,
            SetSelected = function(i)
                selected = math.clamp(i, 1, #tabs)
                updateSelected()
            end,
        }
    end

    --------------------------------------------------------------------
    -- Grid (przyciski w siatce)
    --------------------------------------------------------------------
    function win:Grid(columns, items)
        local gridFrame = makeFrame({
            Size            = UDim2.new(1, 0, 0, math.ceil(#items / columns) * 26),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            LayoutOrder     = nextOrder(self),
            Parent          = self._content,
        })

        local cellW = 1 / columns
        local gl = makeUIGridLayout(
            gridFrame,
            UDim2.new(cellW, -3, 0, 22),
            UDim2.new(0, 3, 0, 4)
        )

        -- Aktualizuj wysokość Frame
        gl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            gridFrame.Size = UDim2.new(1, 0, 0, gl.AbsoluteContentSize.Y)
        end)

        for i, item in ipairs(items) do
            local label, cb = item[1], item[2]
            local btn = makeButton({
                BackgroundColor3 = C.BtnBG,
                BackgroundTransparency = 1 - C.BtnBGAlpha,
                BorderSizePixel = 0,
                Text            = label,
                TextColor3      = C.TextMain,
                Font            = FONT,
                TextSize        = TXT_SIZE,
                LayoutOrder     = i,
                Parent          = gridFrame,
            })
            makeUICorner(4, btn)
            local st = Instance.new("UIStroke")
            st.Color       = C.BtnBorder
            st.Transparency = 0.4
            st.Parent      = btn

            btn.MouseEnter:Connect(function() btn.BackgroundColor3 = C.BtnHover end)
            btn.MouseLeave:Connect(function() btn.BackgroundColor3 = C.BtnBG end)
            btn.MouseButton1Down:Connect(function() btn.BackgroundColor3 = C.BtnActive end)
            btn.MouseButton1Up:Connect(function() btn.BackgroundColor3 = C.BtnHover end)
            btn.MouseButton1Click:Connect(function()
                if cb then cb() end
            end)
        end

        return gridFrame
    end

    --------------------------------------------------------------------
    -- Separator
    --------------------------------------------------------------------
    function win:Separator()
        local sep = makeFrame({
            Size            = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = C.Separator,
            BackgroundTransparency = 1 - C.SepAlpha,
            BorderSizePixel = 0,
            LayoutOrder     = nextOrder(self),
            Parent          = self._content,
        })
        return sep
    end

    --------------------------------------------------------------------
    -- Input (TextBox)
    --------------------------------------------------------------------
    function win:Input(placeholder, default, callback)
        local box = makeInst("TextBox", {
            Size            = UDim2.new(1, 0, 0, 22),
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            BackgroundTransparency = 0.35,
            BorderSizePixel = 0,
            Text            = default or "",
            PlaceholderText = placeholder or "",
            TextColor3      = C.TextMain,
            PlaceholderColor3 = C.TextMuted,
            Font            = FONT,
            TextSize        = TXT_SIZE,
            TextXAlignment  = Enum.TextXAlignment.Left,
            ClearTextOnFocus = false,
            LayoutOrder     = nextOrder(self),
            Parent          = self._content,
        })
        makeUICorner(4, box)
        makeUIPadding(0, 0, 6, 6, box)
        local st = Instance.new("UIStroke")
        st.Color       = Color3.fromRGB(0,0,0)
        st.Transparency = 0.4
        st.Parent      = box

        box.FocusLost:Connect(function(enterPressed)
            if callback then callback(box.Text, enterPressed) end
        end)

        return box
    end

    --------------------------------------------------------------------
    -- Destroy
    --------------------------------------------------------------------
    function win:Destroy()
        self._screenGui:Destroy()
    end

    return win
end

------------------------------------------------------------------------
-- Przykład użycia (odkomentuj żeby przetestować)
------------------------------------------------------------------------

--[[
local win = UI.Window("This is the title of a box", 280, 120, 80)

win:Button("I am a button", function()
    print("Button clicked!")
end)

win:Label("I'm a Label!")

win:Toggle("I am a Toggle button", false, function(v)
    print("Toggle:", v)
end)

win:Toolbar({"Toolbar1", "Toolbar2", "Toolbar3"}, function(i)
    print("Tab selected:", i)
end)

win:Grid(2, {
    {"Grid 1", function() print("Grid 1") end},
    {"Grid 2", function() print("Grid 2") end},
    {"Grid 3", function() print("Grid 3") end},
    {"Grid 4", function() print("Grid 4") end},
})

win:Slider("Slider 1", 0, 100, 35, function(v)
    print("Slider 1:", v)
end)

win:Slider("Slider 2", 0, 100, 55, function(v)
    print("Slider 2:", v)
end)
]]

return UI
