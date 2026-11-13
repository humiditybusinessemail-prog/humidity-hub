-- Humidity Hub UI Library
-- loadstring this first, then call it from the main script
-- Usage: local VLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/humiditybusinessemail-prog/humidity-hub/refs/heads/main/src.lua"))()

local VLibrary = {}
VLibrary.__index = VLibrary

-- ─── Services ────────────────────────────────────────────────────────────────
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local HttpService      = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- ─── Default Theme ───────────────────────────────────────────────────────────
local DEFAULT_THEME = {
    Background   = Color3.fromRGB(15,  15,  18),
    Surface      = Color3.fromRGB(22,  22,  26),
    Raised       = Color3.fromRGB(30,  30,  36),
    Border       = Color3.fromRGB(50,  50,  60),
    Accent       = Color3.fromRGB(66,  135, 245),  -- default blue, changeable
    AccentDim    = Color3.fromRGB(25,  55,  110),
    TextPrimary  = Color3.fromRGB(230, 230, 235),
    TextSecondary= Color3.fromRGB(120, 120, 135),
    TextDisabled = Color3.fromRGB(70,  70,  80),
    Success      = Color3.fromRGB(80,  210, 120),
    Warning      = Color3.fromRGB(240, 165, 0),
    Error        = Color3.fromRGB(220, 70,  70),
    TabBar       = Color3.fromRGB(18,  18,  22),
    Sidebar      = Color3.fromRGB(18,  18,  22),
}

-- Accent presets user can pick in settings
VLibrary.AccentPresets = {
    {name = "Blue",   color = Color3.fromRGB(66,  135, 245)},
    {name = "Amber",  color = Color3.fromRGB(240, 165, 0)},
    {name = "Green",  color = Color3.fromRGB(80,  210, 120)},
    {name = "Red",    color = Color3.fromRGB(220, 70,  70)},
    {name = "Teal",   color = Color3.fromRGB(0,   195, 180)},
    {name = "White",  color = Color3.fromRGB(220, 220, 225)},
}

-- ─── Internal helpers ─────────────────────────────────────────────────────────
local function tween(inst, props, t, style, dir)
    local info = TweenInfo.new(
        t or 0.18,
        style or Enum.EasingStyle.Quad,
        dir or Enum.EasingDirection.Out
    )
    TweenService:Create(inst, info, props):Play()
end

local function corner(inst, r)
    local c = Instance.new("UICorner", inst)
    c.CornerRadius = UDim.new(0, r or 6)
    return c
end

local function stroke(inst, color, thickness)
    local s = Instance.new("UIStroke", inst)
    s.Color = color
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

local function label(parent, props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.BorderSizePixel = 0
    l.RichText = true
    for k, v in pairs(props) do l[k] = v end
    l.Parent = parent
    return l
end

local function frame(parent, props)
    local f = Instance.new("Frame")
    f.BorderSizePixel = 0
    for k, v in pairs(props) do f[k] = v end
    f.Parent = parent
    return f
end

local function btn(parent, props)
    local b = Instance.new("TextButton")
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.RichText = true
    for k, v in pairs(props) do b[k] = v end
    b.Parent = parent
    return b
end

local function img(parent, props)
    local i = Instance.new("ImageLabel")
    i.BackgroundTransparency = 1
    i.BorderSizePixel = 0
    for k, v in pairs(props) do i[k] = v end
    i.Parent = parent
    return i
end

-- ─── Key System ───────────────────────────────────────────────────────────────
-- VLibrary:SetKey(key, callback)
-- Shows a key gate UI before the main hub appears
-- callback(enteredKey) → return true to unlock, false to deny

function VLibrary:SetKey(validKey, onUnlock)
    self._keyRequired = true
    self._validKey    = validKey
    self._onUnlock    = onUnlock or function() end
end

local function showKeyGate(lib, onSuccess)
    local T = lib._theme
    local SG = lib._sg

    local overlay = frame(SG, {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.3,
        ZIndex = 100,
    })

    local box = frame(overlay, {
        Size = UDim2.fromOffset(340, 180),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = T.Surface,
        ZIndex = 101,
    })
    corner(box, 10)
    stroke(box, T.Border, 1)

    -- accent top bar
    local topBar = frame(box, {
        Size = UDim2.new(1, 0, 0, 3),
        BackgroundColor3 = T.Accent,
        ZIndex = 102,
    })
    corner(topBar, 10)

    label(box, {
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.fromOffset(0, 12),
        Text = "Key Required",
        TextColor3 = T.TextPrimary,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 102,
    })

    label(box, {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.fromOffset(10, 44),
        Text = "Enter your key to access " .. lib._hubName,
        TextColor3 = T.TextSecondary,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 102,
    })

    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(1, -20, 0, 36)
    inputBox.Position = UDim2.fromOffset(10, 72)
    inputBox.BackgroundColor3 = T.Raised
    inputBox.TextColor3 = T.TextPrimary
    inputBox.PlaceholderText = "Enter key..."
    inputBox.PlaceholderColor3 = T.TextDisabled
    inputBox.Font = Enum.Font.GothamSemibold
    inputBox.TextSize = 13
    inputBox.BorderSizePixel = 0
    inputBox.ClearTextOnFocus = false
    inputBox.ZIndex = 102
    inputBox.Parent = box
    corner(inputBox, 6)
    stroke(inputBox, T.Border, 1)

    local errLbl = label(box, {
        Size = UDim2.new(1, -20, 0, 16),
        Position = UDim2.fromOffset(10, 112),
        Text = "",
        TextColor3 = T.Error,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 102,
    })

    local confirmBtn = btn(box, {
        Size = UDim2.new(1, -20, 0, 32),
        Position = UDim2.fromOffset(10, 136),
        BackgroundColor3 = T.Accent,
        Text = "Unlock",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        ZIndex = 102,
    })
    corner(confirmBtn, 6)

    local function tryUnlock()
        local entered = inputBox.Text
        local valid = false
        if type(lib._validKey) == "string" then
            valid = (entered == lib._validKey)
        elseif type(lib._validKey) == "function" then
            valid = lib._validKey(entered)
        end
        if valid then
            if lib._onUnlock then lib._onUnlock(entered) end
            tween(overlay, {BackgroundTransparency = 1}, 0.3)
            tween(box, {BackgroundTransparency = 1}, 0.3)
            task.delay(0.3, function()
                overlay:Destroy()
                onSuccess()
            end)
        else
            errLbl.Text = "Invalid key. Try again."
            tween(inputBox, {BackgroundColor3 = Color3.fromRGB(60, 20, 20)}, 0.1)
            task.delay(0.4, function()
                tween(inputBox, {BackgroundColor3 = T.Raised}, 0.2)
            end)
        end
    end

    confirmBtn.MouseButton1Click:Connect(tryUnlock)
    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then tryUnlock() end
    end)

    -- entry animation
    box.Position = UDim2.new(0.5, 0, 0.6, 0)
    box.BackgroundTransparency = 1
    tween(box, {
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 0,
    }, 0.3, Enum.EasingStyle.Back)
end

-- ─── Window ───────────────────────────────────────────────────────────────────
function VLibrary.new(config)
    local self = setmetatable({}, VLibrary)

    config = config or {}
    self._theme     = table.clone(DEFAULT_THEME)
    self._tabs      = {}
    self._activeTab = nil
    self._open      = true
    self._callbacks = {}

    -- merge config theme
    if config.Theme then
        for k, v in pairs(config.Theme) do
            self._theme[k] = v
        end
    end
    if config.Accent then
        self._theme.Accent    = config.Accent
        self._theme.AccentDim = Color3.new(
            config.Accent.R * 0.35,
            config.Accent.G * 0.35,
            config.Accent.B * 0.35
        )
    end

    self._hubName   = config.HubName   or "Humidity Hub"
    self._gameName  = config.GameName  or "Universal"
    self._logoId    = config.LogoId    or "rbxassetid://6031075938" -- fallback logo
    self._keyRequired = false

    -- ScreenGui
    local sg = Instance.new("ScreenGui")
    sg.Name = "VLibrary"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
    self._sg = sg

    if config.LogoId then
        -- try to load from imgur via proxy if starts with http
        if config.LogoId:sub(1,4) == "http" then
            -- use a decal upload or proxy; store raw URL for img src
            self._logoUrl = config.LogoId
        else
            self._logoUrl = config.LogoId
        end
    else
        self._logoUrl = "rbxassetid://6031075938"
    end

    return self
end

function VLibrary:_buildWindow()
    local T   = self._theme
    local sg  = self._sg

    local WIN_W, WIN_H = 560, 380
    local SIDEBAR_W    = 160
    local TITLEBAR_H   = 46

    -- root window
    local win = frame(sg, {
        Size = UDim2.fromOffset(WIN_W, WIN_H),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = T.Background,
        Active = true,
        Draggable = true,
        ZIndex = 1,
    })
    corner(win, 10)
    stroke(win, T.Border, 1)
    self._win = win

    -- ── Opening animation ────────────────────────────────────────────────────
    win.Size = UDim2.fromOffset(WIN_W, 0)
    win.BackgroundTransparency = 1
    tween(win, {
        Size = UDim2.fromOffset(WIN_W, WIN_H),
        BackgroundTransparency = 0,
    }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    -- ── Accent top bar ───────────────────────────────────────────────────────
    local topAccent = frame(win, {
        Size = UDim2.new(1, 0, 0, 3),
        BackgroundColor3 = T.Accent,
        ZIndex = 2,
    })
    corner(topAccent, 10)
    self._topAccent = topAccent

    -- ── Sidebar ──────────────────────────────────────────────────────────────
    local sidebar = frame(win, {
        Size = UDim2.fromOffset(SIDEBAR_W, WIN_H),
        BackgroundColor3 = T.Sidebar,
        ZIndex = 2,
    })
    corner(sidebar, 10)
    self._sidebar = sidebar

    -- logo
    local logoFrame = frame(sidebar, {
        Size = UDim2.new(1, 0, 0, 80),
        BackgroundTransparency = 1,
        ZIndex = 3,
    })

    local logoImg = img(logoFrame, {
        Size = UDim2.fromOffset(40, 40),
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 10),
        Image = self._logoUrl,
        ZIndex = 4,
    })
    corner(logoImg, 6)

    label(logoFrame, {
        Size = UDim2.new(1, -10, 0, 18),
        Position = UDim2.new(0, 5, 0, 54),
        Text = self._hubName,
        TextColor3 = T.TextPrimary,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 4,
    })

    label(logoFrame, {
        Size = UDim2.new(1, -10, 0, 14),
        Position = UDim2.new(0, 5, 0, 68),
        Text = self._gameName,
        TextColor3 = T.TextSecondary,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 4,
    })

    -- divider under logo
    frame(sidebar, {
        Size = UDim2.new(1, -20, 0, 1),
        Position = UDim2.fromOffset(10, 82),
        BackgroundColor3 = T.Border,
        ZIndex = 3,
    })

    -- tab list container
    local tabList = frame(sidebar, {
        Size = UDim2.new(1, 0, 1, -90),
        Position = UDim2.fromOffset(0, 88),
        BackgroundTransparency = 1,
        ZIndex = 3,
    })
    local tabListLayout = Instance.new("UIListLayout", tabList)
    tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabListLayout.Padding = UDim.new(0, 2)
    self._tabList   = tabList
    self._tabBtns   = {}

    -- ── Main content area ────────────────────────────────────────────────────
    local content = frame(win, {
        Size = UDim2.new(1, -(SIDEBAR_W + 1), 1, -TITLEBAR_H),
        Position = UDim2.fromOffset(SIDEBAR_W + 1, TITLEBAR_H),
        BackgroundColor3 = T.Surface,
        ZIndex = 2,
    })
    corner(content, 10)
    self._content = content

    -- scrolling frame inside content
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = T.Accent
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.ZIndex = 3
    scroll.Parent = content
    self._scroll = scroll

    local scrollLayout = Instance.new("UIListLayout", scroll)
    scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
    scrollLayout.Padding = UDim.new(0, 6)
    local scrollPad = Instance.new("UIPadding", scroll)
    scrollPad.PaddingTop    = UDim.new(0, 10)
    scrollPad.PaddingBottom = UDim.new(0, 10)
    scrollPad.PaddingLeft   = UDim.new(0, 10)
    scrollPad.PaddingRight  = UDim.new(0, 14)
    self._scrollLayout = scrollLayout

    -- ── Title bar (top of main content) ─────────────────────────────────────
    local titleBar = frame(win, {
        Size = UDim2.new(1, -SIDEBAR_W, 0, TITLEBAR_H),
        Position = UDim2.fromOffset(SIDEBAR_W, 3),
        BackgroundTransparency = 1,
        ZIndex = 3,
    })

    self._titleLbl = label(titleBar, {
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.fromOffset(14, 0),
        Text = "",
        TextColor3 = T.TextPrimary,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
    })

    -- window controls
    local function makeWinBtn(xOff, bgColor, symbol)
        local b = btn(titleBar, {
            Size = UDim2.fromOffset(20, 20),
            Position = UDim2.new(1, xOff, 0.5, -10),
            BackgroundColor3 = bgColor,
            Text = symbol,
            TextColor3 = Color3.fromRGB(20, 20, 20),
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            ZIndex = 4,
        })
        corner(b, 10)
        return b
    end

    local closeWin    = makeWinBtn(-26, T.Error,   "x")
    local minimizeWin = makeWinBtn(-50, T.Warning, "-")

    local windowVisible = true
    closeWin.MouseButton1Click:Connect(function()
        windowVisible = false
        tween(win, {Size = UDim2.fromOffset(WIN_W, 0), BackgroundTransparency = 1}, 0.25,
            Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.delay(0.25, function() win.Visible = false end)
    end)
    minimizeWin.MouseButton1Click:Connect(function()
        windowVisible = not windowVisible
        if windowVisible then
            win.Visible = true
            tween(win, {Size = UDim2.fromOffset(WIN_W, WIN_H), BackgroundTransparency = 0},
                0.3, Enum.EasingStyle.Back)
        else
            tween(win, {Size = UDim2.fromOffset(WIN_W, 0), BackgroundTransparency = 1},
                0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            task.delay(0.25, function() win.Visible = false end)
        end
    end)

    self._closeBtn    = closeWin
    self._minimizeBtn = minimizeWin
    self._windowVisible = windowVisible
    self._WIN_W = WIN_W
    self._WIN_H = WIN_H

    -- toggle with RightShift by default, rebindable
    self._toggleKey = Enum.KeyCode.RightShift
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == self._toggleKey then
            windowVisible = not windowVisible
            if windowVisible then
                win.Visible = true
                tween(win, {Size = UDim2.fromOffset(WIN_W, WIN_H), BackgroundTransparency = 0},
                    0.3, Enum.EasingStyle.Back)
            else
                tween(win, {Size = UDim2.fromOffset(WIN_W, 0), BackgroundTransparency = 1},
                    0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                task.delay(0.25, function() win.Visible = false end)
            end
        end
    end)
end

-- ─── Toast ────────────────────────────────────────────────────────────────────
function VLibrary:_initToast()
    local T = self._theme
    local toast = label(self._sg, {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0.06, 0),
        Size = UDim2.fromOffset(260, 28),
        BackgroundColor3 = T.Raised,
        BackgroundTransparency = 0.1,
        TextColor3 = T.TextPrimary,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextTransparency = 1,
        Visible = false,
        ZIndex = 20,
        Text = "",
    })
    corner(toast, 6)
    stroke(toast, T.Border, 1)
    self._toast = toast
end

function VLibrary:Notify(text, color, duration)
    local T  = self._theme
    local t  = self._toast
    t.Text   = "  " .. text
    t.TextColor3 = color or T.TextPrimary
    t.Visible = true
    tween(t, {TextTransparency = 0}, 0.18)
    task.delay(duration or 1.8, function()
        tween(t, {TextTransparency = 1}, 0.35)
        task.delay(0.35, function() t.Visible = false end)
    end)
end

-- ─── Tab ──────────────────────────────────────────────────────────────────────
function VLibrary:AddTab(name, icon)
    local T  = self._theme
    local idx = #self._tabs + 1

    -- sidebar button
    local tabBtn = btn(self._tabList, {
        Size = UDim2.new(1, -8, 0, 34),
        BackgroundColor3 = T.Sidebar,
        Text = "",
        ZIndex = 4,
        LayoutOrder = idx,
    })
    corner(tabBtn, 6)

    -- icon (optional)
    if icon then
        img(tabBtn, {
            Size = UDim2.fromOffset(16, 16),
            Position = UDim2.fromOffset(10, 9),
            Image = icon,
            ImageColor3 = T.TextSecondary,
            ZIndex = 5,
        })
    end

    label(tabBtn, {
        Size = UDim2.new(1, icon and -34 or -14, 1, 0),
        Position = UDim2.fromOffset(icon and 32 or 12, 0),
        Text = name,
        TextColor3 = T.TextSecondary,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5,
    })

    -- active indicator bar
    local activeBar = frame(tabBtn, {
        Size = UDim2.fromOffset(3, 20),
        Position = UDim2.new(0, 0, 0.5, -10),
        BackgroundColor3 = T.Accent,
        BackgroundTransparency = 1,
        ZIndex = 5,
    })
    corner(activeBar, 2)

    -- content page (hidden scroll clone per tab)
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = T.Accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.ZIndex = 3
    page.Parent = self._content

    local layout = Instance.new("UIListLayout", page)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)
    local pad = Instance.new("UIPadding", page)
    pad.PaddingTop    = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.PaddingLeft   = UDim.new(0, 10)
    pad.PaddingRight  = UDim.new(0, 14)

    local tabObj = {
        name      = name,
        btn       = tabBtn,
        page      = page,
        activeBar = activeBar,
        layout    = layout,
        sections  = {},
        _rowCount = 0,
    }
    self._tabs[idx] = tabObj
    self._tabBtns[idx] = tabBtn

    tabBtn.MouseButton1Click:Connect(function()
        self:_switchTab(idx)
    end)

    -- select first tab automatically
    if idx == 1 then
        self:_switchTab(1)
    end

    return tabObj
end

function VLibrary:_switchTab(idx)
    local T = self._theme
    for i, t in ipairs(self._tabs) do
        local active = (i == idx)
        t.page.Visible = active
        tween(t.btn, {BackgroundColor3 = active and T.Raised or T.Sidebar}, 0.12)
        local txtLbl = t.btn:FindFirstChildWhichIsA("TextLabel")
        if txtLbl then
            tween(txtLbl, {TextColor3 = active and T.TextPrimary or T.TextSecondary}, 0.12)
        end
        tween(t.activeBar, {BackgroundTransparency = active and 0 or 1}, 0.12)
    end
    self._activeTab = idx
    if self._titleLbl then
        self._titleLbl.Text = self._tabs[idx].name
    end
end

-- ─── Section ──────────────────────────────────────────────────────────────────
function VLibrary:AddSection(tab, name)
    local T = self._theme
    local sectionCount = #tab.sections + 1

    -- section header label
    if name and name ~= "" then
        local hdr = label(tab.page, {
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = T.TextSecondary,
            Font = Enum.Font.GothamSemibold,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = sectionCount * 100,
            ZIndex = 4,
        })
        local hdrPad = Instance.new("UIPadding", hdr)
        hdrPad.PaddingLeft = UDim.new(0, 2)
    end

    local section = {
        _tab      = tab,
        _order    = sectionCount * 100 + 1,
        _rowIdx   = 0,
    }

    tab.sections[sectionCount] = section
    return section
end

-- ─── Row builder (internal) ───────────────────────────────────────────────────
local ROW_H = 36

local function makeRow(section, zindex)
    local T   = section._tab._tab and section._tab._tab._theme
        or VLibrary  -- fallback, overridden in element methods
    section._rowIdx = section._rowIdx + 1
    local r = frame(section._tab.page, {
        Size = UDim2.new(1, 0, 0, ROW_H),
        BackgroundColor3 = Color3.fromRGB(28, 28, 34),
        ZIndex = zindex or 4,
        LayoutOrder = section._order + section._rowIdx,
    })
    corner(r, 6)
    return r
end

-- ─── Elements ─────────────────────────────────────────────────────────────────

-- Label
function VLibrary:AddLabel(section, text)
    local T   = self._theme
    local row = makeRow(section)
    row.Size = UDim2.new(1, 0, 0, 28)
    local lbl = label(row, {
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.fromOffset(10, 0),
        Text = text,
        TextColor3 = T.TextPrimary,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        ZIndex = 5,
    })
    return lbl
end

-- Paragraph
function VLibrary:AddParagraph(section, title, content)
    local T   = self._theme
    local row = frame(section._tab.page, {
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundColor3 = Color3.fromRGB(28, 28, 34),
        ZIndex = 4,
        LayoutOrder = section._order + section._rowIdx + 1,
        AutomaticSize = Enum.AutomaticSize.Y,
    })
    corner(row, 6)
    section._rowIdx = section._rowIdx + 1
    local pad = Instance.new("UIPadding", row)
    pad.PaddingLeft   = UDim.new(0, 10)
    pad.PaddingRight  = UDim.new(0, 10)
    pad.PaddingTop    = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)
    local rl = Instance.new("UIListLayout", row)
    rl.Padding = UDim.new(0, 2)
    label(row, {
        Size = UDim2.new(1, 0, 0, 18),
        Text = title,
        TextColor3 = T.TextPrimary,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        ZIndex = 5,
    })
    label(row, {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Text = content,
        TextColor3 = T.TextSecondary,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextWrapped = true,
        ZIndex = 5,
    })
end

-- Button
function VLibrary:AddButton(section, text, callback)
    local T   = self._theme
    local row = makeRow(section)
    local lbl = label(row, {
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.fromOffset(10, 0),
        Text = text,
        TextColor3 = T.TextPrimary,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        ZIndex = 5,
    })
    local b = btn(row, {
        Size = UDim2.fromOffset(80, 24),
        Position = UDim2.new(1, -88, 0.5, -12),
        BackgroundColor3 = T.Raised,
        Text = "Execute",
        TextColor3 = T.TextSecondary,
        Font = Enum.Font.GothamSemibold,
        TextSize = 11,
        ZIndex = 5,
    })
    corner(b, 5)
    stroke(b, T.Border, 1)

    b.MouseButton1Click:Connect(function()
        tween(b, {BackgroundColor3 = T.Accent}, 0.1)
        tween(b, {TextColor3 = Color3.fromRGB(255,255,255)}, 0.1)
        task.delay(0.18, function()
            tween(b, {BackgroundColor3 = T.Raised}, 0.2)
            tween(b, {TextColor3 = T.TextSecondary}, 0.2)
        end)
        if callback then callback() end
    end)

    b.MouseEnter:Connect(function()
        tween(b, {BackgroundColor3 = T.AccentDim}, 0.1)
    end)
    b.MouseLeave:Connect(function()
        tween(b, {BackgroundColor3 = T.Raised}, 0.1)
    end)

    return b
end

-- Toggle
function VLibrary:AddToggle(section, text, default, callback)
    local T    = self._theme
    local row  = makeRow(section)
    local state = default or false

    label(row, {
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.fromOffset(10, 0),
        Text = text,
        TextColor3 = T.TextPrimary,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        ZIndex = 5,
    })

    local track = frame(row, {
        Size = UDim2.fromOffset(44, 24),
        Position = UDim2.new(1, -52, 0.5, -12),
        BackgroundColor3 = state and T.Accent or T.Raised,
        ZIndex = 5,
    })
    corner(track, 12)
    stroke(track, T.Border, 1)

    local knob = frame(track, {
        Size = UDim2.fromOffset(18, 18),
        Position = state and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3),
        BackgroundColor3 = state and Color3.fromRGB(255,255,255) or T.TextSecondary,
        ZIndex = 6,
    })
    corner(knob, 9)

    local obj = {value = state}

    local function set(v)
        obj.value = v
        tween(track, {BackgroundColor3 = v and T.Accent or T.Raised}, 0.15)
        tween(knob, {
            Position = v and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3),
            BackgroundColor3 = v and Color3.fromRGB(255,255,255) or T.TextSecondary,
        }, 0.15)
        if callback then callback(v) end
    end

    obj.Set = set

    track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            set(not obj.value)
        end
    end)

    return obj
end

-- Slider
function VLibrary:AddSlider(section, text, min, max, default, isFloat, callback)
    local T    = self._theme
    local row  = frame(section._tab.page, {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Color3.fromRGB(28, 28, 34),
        ZIndex = 4,
        LayoutOrder = section._order + section._rowIdx + 1,
    })
    corner(row, 6)
    section._rowIdx = section._rowIdx + 1

    local val = default or min

    local topLbl = label(row, {
        Size = UDim2.new(0.65, 0, 0, 20),
        Position = UDim2.fromOffset(10, 6),
        Text = text,
        TextColor3 = T.TextPrimary,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        ZIndex = 5,
    })

    local valLbl = label(row, {
        Size = UDim2.new(0.35, -10, 0, 20),
        Position = UDim2.new(0.65, 0, 0, 6),
        Text = tostring(val),
        TextColor3 = T.Accent,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 5,
    })

    local trackBg = frame(row, {
        Size = UDim2.new(1, -20, 0, 6),
        Position = UDim2.fromOffset(10, 34),
        BackgroundColor3 = T.Raised,
        ZIndex = 5,
    })
    corner(trackBg, 3)

    local fillF = frame(trackBg, {
        Size = UDim2.new((val - min)/(max - min), 0, 1, 0),
        BackgroundColor3 = T.Accent,
        ZIndex = 6,
    })
    corner(fillF, 3)

    local knob = frame(trackBg, {
        Size = UDim2.fromOffset(14, 14),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new((val - min)/(max - min), 0, 0.5, 0),
        BackgroundColor3 = T.TextPrimary,
        ZIndex = 7,
    })
    corner(knob, 7)

    local hitArea = btn(trackBg, {
        Size = UDim2.new(1, 0, 0, 24),
        Position = UDim2.fromOffset(0, -9),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 8,
    })

    local dragging = false
    local obj = {value = val}

    local function updateFromX(absX)
        local rel = math.clamp(
            (absX - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X, 0, 1)
        local raw = min + rel * (max - min)
        local v = isFloat
            and (math.floor(raw * 100 + 0.5) / 100)
            or  math.floor(raw + 0.5)
        obj.value = v
        fillF.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, 0, 0.5, 0)
        valLbl.Text = tostring(v)
        if callback then callback(v) end
    end

    hitArea.MouseButton1Down:Connect(function()
        dragging = true
        -- disable window drag while sliding
        if self._win then self._win.Draggable = false end
        updateFromX(UserInputService:GetMouseLocation().X)
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            updateFromX(inp.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            if self._win then self._win.Draggable = true end
        end
    end)

    obj.Set = function(v)
        local rel = math.clamp((v - min)/(max - min), 0, 1)
        obj.value = v
        fillF.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, 0, 0.5, 0)
        valLbl.Text = tostring(v)
    end

    return obj
end

-- Textbox
function VLibrary:AddTextbox(section, text, placeholder, default, callback)
    local T   = self._theme
    local row = makeRow(section)
    row.Size  = UDim2.new(1, 0, 0, 36)

    label(row, {
        Size = UDim2.new(0.45, 0, 1, 0),
        Position = UDim2.fromOffset(10, 0),
        Text = text,
        TextColor3 = T.TextPrimary,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        ZIndex = 5,
    })

    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(0.5, -10, 0, 24)
    inputBox.Position = UDim2.new(0.5, 0, 0.5, -12)
    inputBox.BackgroundColor3 = T.Raised
    inputBox.TextColor3 = T.TextPrimary
    inputBox.PlaceholderText = placeholder or ""
    inputBox.PlaceholderColor3 = T.TextDisabled
    inputBox.Text = default or ""
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextSize = 12
    inputBox.BorderSizePixel = 0
    inputBox.ClearTextOnFocus = false
    inputBox.ZIndex = 5
    inputBox.Parent = row
    corner(inputBox, 5)
    stroke(inputBox, T.Border, 1)

    local pad = Instance.new("UIPadding", inputBox)
    pad.PaddingLeft  = UDim.new(0, 6)
    pad.PaddingRight = UDim.new(0, 6)

    inputBox.FocusLost:Connect(function(enter)
        if callback then callback(inputBox.Text, enter) end
    end)

    return inputBox
end

-- Dropdown
function VLibrary:AddDropdown(section, text, options, default, callback)
    local T    = self._theme
    local row  = frame(section._tab.page, {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Color3.fromRGB(28, 28, 34),
        ZIndex = 4,
        LayoutOrder = section._order + section._rowIdx + 1,
        ClipsDescendants = false,
    })
    corner(row, 6)
    section._rowIdx = section._rowIdx + 1

    local selected = default or (options[1] or "None")

    label(row, {
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.fromOffset(10, 0),
        Text = text,
        TextColor3 = T.TextPrimary,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        ZIndex = 5,
    })

    local dropBtn = btn(row, {
        Size = UDim2.new(0.46, 0, 0, 24),
        Position = UDim2.new(0.5, 2, 0.5, -12),
        BackgroundColor3 = T.Raised,
        Text = selected,
        TextColor3 = T.TextPrimary,
        Font = Enum.Font.GothamSemibold,
        TextSize = 11,
        ZIndex = 5,
    })
    corner(dropBtn, 5)
    stroke(dropBtn, T.Border, 1)

    local arrow = label(dropBtn, {
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.new(1, -18, 0.5, -8),
        Text = "v",
        TextColor3 = T.TextSecondary,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        ZIndex = 6,
    })

    local listOpen = false
    local listFrame

    local obj = {value = selected}

    local function closeList()
        if listFrame then
            tween(listFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.12)
            task.delay(0.12, function()
                if listFrame then listFrame:Destroy(); listFrame = nil end
            end)
            listOpen = false
            tween(arrow, {Rotation = 0}, 0.12)
        end
    end

    dropBtn.MouseButton1Click:Connect(function()
        if listOpen then closeList() return end
        listOpen = true
        tween(arrow, {Rotation = 180}, 0.12)

        listFrame = frame(row, {
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.fromOffset(0, 38),
            BackgroundColor3 = T.Raised,
            ZIndex = 20,
            ClipsDescendants = true,
        })
        corner(listFrame, 6)
        stroke(listFrame, T.Border, 1)

        local listLayout = Instance.new("UIListLayout", listFrame)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        local listPad = Instance.new("UIPadding", listFrame)
        listPad.PaddingTop    = UDim.new(0, 4)
        listPad.PaddingBottom = UDim.new(0, 4)

        for i, opt in ipairs(options) do
            local optBtn = btn(listFrame, {
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundColor3 = opt == selected and T.AccentDim or T.Raised,
                Text = opt,
                TextColor3 = opt == selected and T.Accent or T.TextPrimary,
                Font = Enum.Font.Gotham,
                TextSize = 12,
                ZIndex = 21,
                LayoutOrder = i,
            })
            local optPad = Instance.new("UIPadding", optBtn)
            optPad.PaddingLeft = UDim.new(0, 8)

            optBtn.MouseEnter:Connect(function()
                tween(optBtn, {BackgroundColor3 = T.AccentDim}, 0.08)
            end)
            optBtn.MouseLeave:Connect(function()
                tween(optBtn, {BackgroundColor3 = opt == obj.value and T.AccentDim or T.Raised}, 0.08)
            end)
            optBtn.MouseButton1Click:Connect(function()
                obj.value = opt
                selected = opt
                dropBtn.Text = opt
                if callback then callback(opt) end
                closeList()
            end)
        end

        local targetH = math.min(#options * 28 + 8, 160)
        tween(listFrame, {Size = UDim2.new(1, 0, 0, targetH)}, 0.15)
    end)

    obj.Set = function(v)
        obj.value = v
        dropBtn.Text = v
    end

    return obj
end

-- Keybind
function VLibrary:AddKeybind(section, text, default, callback)
    local T    = self._theme
    local row  = makeRow(section)
    local bind = default or Enum.KeyCode.Unknown
    local listening = false

    label(row, {
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.fromOffset(10, 0),
        Text = text,
        TextColor3 = T.TextPrimary,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        ZIndex = 5,
    })

    local function bindName(kc)
        if kc == Enum.KeyCode.Unknown then return "---" end
        return tostring(kc):match("KeyCode%.(.+)") or "?"
    end

    local kbBtn = btn(row, {
        Size = UDim2.fromOffset(72, 24),
        Position = UDim2.new(1, -88, 0.5, -12),
        BackgroundColor3 = T.Raised,
        Text = bindName(bind),
        TextColor3 = T.TextPrimary,
        Font = Enum.Font.GothamSemibold,
        TextSize = 11,
        ZIndex = 5,
    })
    corner(kbBtn, 5)
    stroke(kbBtn, T.Border, 1)

    local clrBtn = btn(row, {
        Size = UDim2.fromOffset(20, 24),
        Position = UDim2.new(1, -14, 0.5, -12),
        BackgroundColor3 = Color3.fromRGB(70, 20, 20),
        Text = "x",
        TextColor3 = T.Error,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        ZIndex = 5,
    })
    corner(clrBtn, 5)

    local obj = {value = bind}

    kbBtn.MouseButton1Click:Connect(function()
        if listening then
            listening = false
            kbBtn.Text = bindName(obj.value)
            tween(kbBtn, {BackgroundColor3 = T.Raised}, 0.1)
            return
        end
        listening = true
        kbBtn.Text = "..."
        tween(kbBtn, {BackgroundColor3 = T.AccentDim}, 0.1)
    end)

    clrBtn.MouseButton1Click:Connect(function()
        listening = false
        obj.value = Enum.KeyCode.Unknown
        kbBtn.Text = "---"
        tween(kbBtn, {BackgroundColor3 = T.Raised}, 0.1)
        if callback then callback(Enum.KeyCode.Unknown) end
    end)

    UserInputService.InputBegan:Connect(function(inp, gp)
        if not listening then return end
        if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if inp.KeyCode == Enum.KeyCode.Escape then
            listening = false
            kbBtn.Text = bindName(obj.value)
            tween(kbBtn, {BackgroundColor3 = T.Raised}, 0.1)
            return
        end
        obj.value = inp.KeyCode
        bind = inp.KeyCode
        kbBtn.Text = bindName(bind)
        tween(kbBtn, {BackgroundColor3 = T.Raised}, 0.1)
        listening = false
        if callback then callback(bind) end
    end)

    obj.Set = function(kc)
        obj.value = kc
        bind = kc
        kbBtn.Text = bindName(kc)
    end

    return obj
end

-- Color Picker (accent switcher)
function VLibrary:AddColorPicker(section, text, callback)
    local T   = self._theme
    local row = frame(section._tab.page, {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Color3.fromRGB(28, 28, 34),
        ZIndex = 4,
        LayoutOrder = section._order + section._rowIdx + 1,
    })
    corner(row, 6)
    section._rowIdx = section._rowIdx + 1

    label(row, {
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.fromOffset(10, 0),
        Text = text,
        TextColor3 = T.TextPrimary,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        ZIndex = 5,
    })

    local swatchRow = frame(row, {
        Size = UDim2.new(0.5, -10, 0, 24),
        Position = UDim2.new(0.5, 0, 0.5, -12),
        BackgroundTransparency = 1,
        ZIndex = 5,
    })
    local swatchLayout = Instance.new("UIListLayout", swatchRow)
    swatchLayout.FillDirection = Enum.FillDirection.Horizontal
    swatchLayout.Padding = UDim.new(0, 4)
    swatchLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    for _, preset in ipairs(VLibrary.AccentPresets) do
        local sw = btn(swatchRow, {
            Size = UDim2.fromOffset(20, 20),
            BackgroundColor3 = preset.color,
            Text = "",
            ZIndex = 6,
        })
        corner(sw, 10)

        sw.MouseButton1Click:Connect(function()
            self:SetAccent(preset.color)
            if callback then callback(preset.color, preset.name) end
            self:Notify("Accent: " .. preset.name, preset.color)
        end)
        sw.MouseEnter:Connect(function()
            tween(sw, {Size = UDim2.fromOffset(22, 22)}, 0.1)
        end)
        sw.MouseLeave:Connect(function()
            tween(sw, {Size = UDim2.fromOffset(20, 20)}, 0.1)
        end)
    end
end

-- ─── SetAccent: live recolor ──────────────────────────────────────────────────
function VLibrary:SetAccent(color)
    self._theme.Accent = color
    self._theme.AccentDim = Color3.new(
        color.R * 0.35,
        color.G * 0.35,
        color.B * 0.35
    )
    if self._topAccent then
        tween(self._topAccent, {BackgroundColor3 = color}, 0.2)
    end
    -- update tab underlines / active bars
    for i, t in ipairs(self._tabs) do
        if i == self._activeTab then
            tween(t.activeBar, {BackgroundColor3 = color}, 0.2)
        end
    end
    -- update scroll bar color
    for _, page in ipairs(self._tabs) do
        if page.page then
            page.page.ScrollBarImageColor3 = color
        end
    end
end

-- ─── SetToggleKey ────────────────────────────────────────────────────────────
function VLibrary:SetToggleKey(kc)
    self._toggleKey = kc
end

-- ─── Init ─────────────────────────────────────────────────────────────────────
function VLibrary:Init()
    if self._keyRequired then
        showKeyGate(self, function()
            self:_buildWindow()
            self:_initToast()
        end)
    else
        self:_buildWindow()
        self:_initToast()
    end
    return self
end
return VLibrary
