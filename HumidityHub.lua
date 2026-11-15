local Library = {}
Library.__index = Library
Library.Version = "2.2.0"

local Tab = {}
Tab.__index = Tab

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local DEFAULT_LOGO = 127590426518205
local FOLDER = "HumidityHub"
local KEY_FILE = FOLDER .. "/key.txt"
local CONFIG_DIR = FOLDER .. "/configs"

local GOOD = Color3.fromRGB(78, 200, 120)
local WARN = Color3.fromRGB(255, 184, 76)
local BAD = Color3.fromRGB(240, 88, 96)
local WHITE = Color3.new(1, 1, 1)
local GOTHAM = Enum.Font.GothamMedium
local BOLD = Enum.Font.GothamBold
local LEFT = Enum.TextXAlignment.Left

Library.Themes = {
    Dark = {
        Background = Color3.fromRGB(13, 13, 17),
        Panel = Color3.fromRGB(18, 18, 24),
        Element = Color3.fromRGB(25, 25, 33),
        ElementHover = Color3.fromRGB(33, 33, 43),
        Stroke = Color3.fromRGB(44, 44, 58),
        Text = Color3.fromRGB(236, 236, 244),
        SubText = Color3.fromRGB(150, 150, 170),
        Accent = Color3.fromRGB(104, 138, 255),
    },
    Midnight = {
        Background = Color3.fromRGB(8, 11, 20),
        Panel = Color3.fromRGB(12, 16, 28),
        Element = Color3.fromRGB(18, 24, 40),
        ElementHover = Color3.fromRGB(25, 33, 54),
        Stroke = Color3.fromRGB(36, 48, 78),
        Text = Color3.fromRGB(230, 238, 252),
        SubText = Color3.fromRGB(135, 152, 186),
        Accent = Color3.fromRGB(64, 196, 255),
    },
    Crimson = {
        Background = Color3.fromRGB(15, 11, 13),
        Panel = Color3.fromRGB(21, 15, 18),
        Element = Color3.fromRGB(30, 21, 25),
        ElementHover = Color3.fromRGB(40, 28, 33),
        Stroke = Color3.fromRGB(62, 42, 50),
        Text = Color3.fromRGB(244, 234, 237),
        SubText = Color3.fromRGB(176, 150, 158),
        Accent = Color3.fromRGB(236, 80, 102),
    },
    Light = {
        Background = Color3.fromRGB(240, 241, 246),
        Panel = Color3.fromRGB(230, 232, 240),
        Element = Color3.fromRGB(250, 250, 253),
        ElementHover = Color3.fromRGB(238, 240, 248),
        Stroke = Color3.fromRGB(205, 208, 222),
        Text = Color3.fromRGB(28, 30, 40),
        SubText = Color3.fromRGB(110, 114, 134),
        Accent = Color3.fromRGB(80, 110, 240),
    },
}

local REASONS = {
    invalid_key = "that key doesn't exist",
    revoked = "this key was revoked",
    hwid_mismatch = "this key belongs to another device",
    expired = "this key has expired",
    rate_limited = "too many tries, wait a few minutes",
    missing_input = "enter your key first",
    error = "something went wrong, try again",
}

local NOTIFY_TYPES = {
    info = {glyph = "i"},
    success = {glyph = "✓", color = GOOD},
    warning = {glyph = "!", color = WARN},
    error = {glyph = "×", color = BAD},
}

local DEFAULTS = {
    Frame = {BorderSizePixel = 0},
    CanvasGroup = {BorderSizePixel = 0},
    TextLabel = {BackgroundTransparency = 1, BorderSizePixel = 0, Font = GOTHAM, TextSize = 13, Text = ""},
    TextButton = {BorderSizePixel = 0, AutoButtonColor = false, Font = GOTHAM, TextSize = 13, Text = ""},
    TextBox = {BorderSizePixel = 0, Font = GOTHAM, TextSize = 13, Text = ""},
    ImageLabel = {BackgroundTransparency = 1, BorderSizePixel = 0},
    ImageButton = {BorderSizePixel = 0, AutoButtonColor = false},
    ScrollingFrame = {BorderSizePixel = 0, BackgroundTransparency = 1},
}

local function new(class, props)
    local inst = Instance.new(class)
    local base = DEFAULTS[class]
    if base then
        for k, v in pairs(base) do
            inst[k] = v
        end
    end
    local parent
    for k, v in pairs(props or {}) do
        if k == "Parent" then
            parent = v
        else
            inst[k] = v
        end
    end
    if parent then
        inst.Parent = parent
    end
    return inst
end

local function tween(inst, props, time, style, dir)
    local t = TweenService:Create(inst, TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function round(parent, radius)
    return new("UICorner", {CornerRadius = UDim.new(0, radius), Parent = parent})
end

local function stroke(parent, color, thickness, transparency)
    return new("UIStroke", {
        Color = color,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function pad(parent, top, right, bottom, left)
    return new("UIPadding", {
        PaddingTop = UDim.new(0, top),
        PaddingRight = UDim.new(0, right),
        PaddingBottom = UDim.new(0, bottom),
        PaddingLeft = UDim.new(0, left),
        Parent = parent,
    })
end

local function list(parent, padding, order)
    return new("UIListLayout", {
        Padding = UDim.new(0, padding or 0),
        SortOrder = order or Enum.SortOrder.LayoutOrder,
        Parent = parent,
    })
end

local function safe(fn, ...)
    if type(fn) == "function" then
        local ok, err = pcall(fn, ...)
        if not ok then
            warn("[HumidityHub] " .. tostring(err))
        end
    end
end

local function trim(s)
    return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function copy(t)
    local out = {}
    for k, v in pairs(t) do
        out[k] = v
    end
    return out
end

local function normalize(res)
    if type(res) == "table" then
        return res.valid == true, res
    end
    return res == true, {}
end

local function fmt(seconds)
    seconds = math.max(0, math.floor(seconds))
    return string.format("%02d:%02d:%02d", math.floor(seconds / 3600), math.floor(seconds % 3600 / 60), seconds % 60)
end

local function toKey(v)
    if typeof(v) == "EnumItem" then
        return v
    end
    if type(v) == "string" then
        local ok, r = pcall(function()
            return Enum.KeyCode[v]
        end)
        if ok then
            return r
        end
    end
    return nil
end

local function fsReady()
    return type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
end

local function ensureFolders()
    if type(isfolder) == "function" and type(makefolder) == "function" then
        for _, path in ipairs({FOLDER, CONFIG_DIR}) do
            pcall(function()
                if not isfolder(path) then
                    makefolder(path)
                end
            end)
        end
    end
end

local function safeWrite(path, data)
    if not fsReady() then
        return false
    end
    ensureFolders()
    return (pcall(writefile, path, data))
end

local function safeRead(path)
    if not fsReady() then
        return nil
    end
    local ok, res = pcall(function()
        if isfile(path) then
            return readfile(path)
        end
        return nil
    end)
    if ok then
        return res
    end
    return nil
end

local function safeDelete(path)
    if type(delfile) == "function" and type(isfile) == "function" then
        pcall(function()
            if isfile(path) then
                delfile(path)
            end
        end)
    end
end

local function encodeValue(v)
    local kind = typeof(v)
    if kind == "Color3" then
        return {__c = {math.floor(v.R * 255 + 0.5), math.floor(v.G * 255 + 0.5), math.floor(v.B * 255 + 0.5)}}
    elseif kind == "EnumItem" then
        return {__k = v.Name}
    end
    return v
end

local function decodeValue(v)
    if type(v) == "table" then
        if v.__c then
            return Color3.fromRGB(v.__c[1], v.__c[2], v.__c[3])
        elseif v.__k then
            return v.__k
        end
    end
    return v
end

function Library.new(o)
    o = o or {}
    local self = setmetatable({}, Library)
    self.Alive = true
    self.Flags = {}
    self.Setters = {}
    self.Tabs = {}
    self._conns = {}
    self._bound = {}
    self._refresh = {}
    self._logos = {}
    self._notifs = {}
    self._notifN = 0
    self._open = false
    self._keyOpen = false
    self._loading = false
    self._remember = false
    self._keyInfo = {Valid = false}
    self.HubName = o.HubName or "Humidity Hub"
    self.GameName = o.GameName or ""
    self.Size = o.Size or UDim2.fromOffset(640, 430)
    self._scale = o.Scale or 1
    self._backdrop = true
    self._backdropTrans = 0.5
    self._blur = false
    self._blurSize = 16
    self._withSettings = o.Settings ~= false
    self._mobileButton = o.MobileButton
    if self._mobileButton == nil then
        self._mobileButton = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    end
    self.ToggleKey = toKey(o.ToggleKey) or Enum.KeyCode.RightShift
    self._accent = o.Accent
    self.ThemeName = "Dark"
    local base = Library.Themes.Dark
    if type(o.Theme) == "string" and Library.Themes[o.Theme] then
        self.ThemeName = o.Theme
        base = Library.Themes[o.Theme]
    elseif type(o.Theme) == "table" then
        base = copy(Library.Themes.Dark)
        for k, v in pairs(o.Theme) do
            base[k] = v
        end
        self.ThemeName = "Custom"
    end
    self.Theme = copy(base)
    if self._accent then
        self.Theme.Accent = self._accent
    end
    local logoNum = tostring(o.LogoId or DEFAULT_LOGO):match("%d+") or tostring(DEFAULT_LOGO)
    self._logoImage = "rbxassetid://" .. logoNum
    self:_build()
    self:SetLogo(o.LogoId or DEFAULT_LOGO)
    return self
end

function Library:_conn(c)
    table.insert(self._conns, c)
    return c
end

function Library:_bind(inst, prop, key)
    table.insert(self._bound, {inst, prop, key})
    inst[prop] = self.Theme[key]
    return inst
end

function Library:_applyTheme()
    for i = #self._bound, 1, -1 do
        local b = self._bound[i]
        if b[1].Parent then
            tween(b[1], {[b[2]] = self.Theme[b[3]]}, 0.25)
        else
            table.remove(self._bound, i)
        end
    end
    for _, fn in ipairs(self._refresh) do
        pcall(fn)
    end
end

function Library:_logo(img)
    table.insert(self._logos, img)
    img.Image = self._logoImage
    return img
end

function Library:_hover(row, target)
    target = target or row
    target.MouseEnter:Connect(function()
        tween(row, {BackgroundColor3 = self.Theme.ElementHover}, 0.15)
    end)
    target.MouseLeave:Connect(function()
        tween(row, {BackgroundColor3 = self.Theme.Element}, 0.15)
    end)
end

function Library:_drag(region, fn)
    local active = false
    region.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            active = true
            fn(input.Position)
            local c
            c = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    active = false
                    c:Disconnect()
                end
            end)
        end
    end)
    self:_conn(UserInputService.InputChanged:Connect(function(input)
        if active and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            fn(input.Position)
        end
    end))
end

function Library:_dragWindow(handle, target, onClick)
    local dragging, moved = false, false
    local startPos, startInput
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            startInput = input.Position
            startPos = target.Position
            local c
            c = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    c:Disconnect()
                    if not moved and onClick then
                        onClick()
                    end
                end
            end)
        end
    end)
    self:_conn(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - startInput
            if d.Magnitude > 5 then
                moved = true
            end
            if moved then
                target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end
    end))
end

function Library:_viewport()
    local cam = workspace.CurrentCamera
    return cam and cam.ViewportSize or Vector2.new(1280, 720)
end

function Library:_applyScale()
    local vp = self:_viewport()
    local w, h = self.Size.X.Offset, self.Size.Y.Offset
    local fit = math.min(1, (vp.X - 20) / w, (vp.Y - 20) / h)
    self._holderScale.Scale = self._scale * fit
end

function Library:_keyFit()
    local vp = self:_viewport()
    return math.min(1, (vp.X - 24) / 400)
end

function Library:_build()
    local T = self.Theme

    local gui = new("ScreenGui", {
        Name = "HumidityHub",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        DisplayOrder = 999,
    })
    if type(syn) == "table" and type(syn.protect_gui) == "function" then
        pcall(syn.protect_gui, gui)
    end
    local parent
    if type(gethui) == "function" then
        local ok, h = pcall(gethui)
        if ok and h then
            parent = h
        end
    end
    parent = parent or CoreGui
    pcall(function()
        for _, c in ipairs(parent:GetChildren()) do
            if c.Name == "HumidityHub" and c:IsA("ScreenGui") then
                c:Destroy()
            end
        end
    end)
    local okParent = pcall(function()
        gui.Parent = parent
    end)
    if not okParent then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    self.Gui = gui

    self._backdropFrame = new("Frame", {
        Name = "Backdrop",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 1,
        Parent = gui,
    })

    self._blurObj = Instance.new("BlurEffect")
    self._blurObj.Name = "HumidityHubBlur"
    self._blurObj.Size = 0
    self._blurObj.Enabled = false
    self._blurObj.Parent = Lighting

    local holder = new("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = self.Size,
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 2,
        Parent = gui,
    })
    self._holder = holder
    self._holderScale = new("UIScale", {Scale = 1, Parent = holder})
    self:_applyScale()

    local main = new("CanvasGroup", {
        Name = "Main",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        GroupTransparency = 1,
        Parent = holder,
    })
    self:_bind(main, "BackgroundColor3", "Background")
    round(main, 14)
    self._main = main
    self._pop = new("UIScale", {Scale = 0.94, Parent = main})
    self:_bind(stroke(main, T.Stroke, 1, 0.35), "Color", "Stroke")

    local topbar = new("Frame", {Name = "Topbar", Size = UDim2.new(1, 0, 0, 50), Parent = main})
    self:_bind(topbar, "BackgroundColor3", "Panel")
    local topLine = new("Frame", {AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 1), BackgroundTransparency = 0.4, Parent = topbar})
    self:_bind(topLine, "BackgroundColor3", "Stroke")

    local logo = new("ImageLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 14, 0.5, 0),
        Size = UDim2.fromOffset(30, 30),
        ScaleType = Enum.ScaleType.Fit,
        Parent = topbar,
    })
    round(logo, 8)
    self:_logo(logo)

    local hasGame = self.GameName ~= ""
    local title = new("TextLabel", {
        Text = self.HubName,
        Font = BOLD,
        TextSize = 15,
        TextXAlignment = LEFT,
        Position = UDim2.fromOffset(054, hasGame and 8 or 0),
        Size = UDim2.new(1, -110, 0, hasGame and 18 or 50),
        Parent = topbar,
    })
    self:_bind(title, "TextColor3", "Text")
    if hasGame then
        local sub = new("TextLabel", {
            Text = self.GameName,
            Font = GOTHAM,
            TextSize = 11,
            TextXAlignment = LEFT,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Position = UDim2.fromOffset(54, 26),
            Size = UDim2.new(1, -110, 0, 14),
            Parent = topbar,
        })
        self:_bind(sub, "TextColor3", "SubText")
    end

    local close = new("TextButton", {
        Text = "×",
        Font = GOTHAM,
        TextSize = 22,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(28, 28),
        BackgroundColor3 = BAD,
        BackgroundTransparency = 1,
        Parent = topbar,
    })
    round(close, 8)
    self:_bind(close, "TextColor3", "SubText")
    close.MouseEnter:Connect(function()
        tween(close, {BackgroundTransparency = 0.8, TextColor3 = BAD}, 0.15)
    end)
    close.MouseLeave:Connect(function()
        tween(close, {BackgroundTransparency = 1, TextColor3 = self.Theme.SubText}, 0.15)
    end)
    close.MouseButton1Click:Connect(function()
        self:Hide()
    end)

    self:_dragWindow(topbar, holder)

    local sidebar = new("Frame", {Name = "Sidebar", Position = UDim2.fromOffset(0, 50), Size = UDim2.new(0, 168, 1, -50), Parent = main})
    self:_bind(sidebar, "BackgroundColor3", "Panel")
    local sideLine = new("Frame", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.new(0, 1, 1, 0), BackgroundTransparency = 0.4, Parent = sidebar})
    self:_bind(sideLine, "BackgroundColor3", "Stroke")

    local tabList = new("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -60),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0,
        Parent = sidebar,
    })
    pad(tabList, 10, 10, 6, 10)
    list(tabList, 4)
    self._tabList = tabList

    local pill = new("Frame", {
        Name = "KeyPill",
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, -0.5, 1, -10),
        Size = UDim2.new(1, -20, 0, 42),
        Visible = false,
        Parent = sidebar,
    })
    self:_bind(pill, "BackgroundColor3", "Element")
    round(pill, 10)
    self:_bind(stroke(pill, T.Stroke, 1, 0.4), "Color", "Stroke")
    local dot = new("Frame", {Position = UDim2.fromOffset(12, 17), Size = UDim2.fromOffset(8, 8), BackgroundColor3 = GOOD, Parent = pill})
    round(dot, 4)
    local tierLabel = new("TextLabel", {
        Text = "key",
        Font = GOTHAM,
        TextSize = 10,
        TextXAlignment = LEFT,
        Position = UDim2.fromOffset(30, 6),
        Size = UDim2.new(1, -36, 0, 12),
        Parent = pill,
    })
    self:_bind(tierLabel, "TextColor3", "SubText")
    local timeLabel = new("TextLabel", {
        Text = "00:00:00",
        Font = BOLD,
        TextSize = 14,
        TextXAlignment = LEFT,
        Position = UDim2.fromOffset(30, 19),
        Size = UDim2.new(1, -36, 0, 18),
        TextColor3 = GOOD,
        Parent = pill,
    })
    self._pill = {frame = pill, dot = dot, tier = tierLabel, time = timeLabel}

    self._pages = new("Frame", {
        Name = "Pages",
        Position = UDim2.fromOffset(168, 50),
        Size = UDim2.new(1, -168, 1, -50),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = main,
    })

    self._notifHolder = new("Frame", {
        Name = "Notifications",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -18, 1, -18),
        Size = UDim2.new(0, 330, 1, -36),
        BackgroundTransparency = 1,
        ZIndex = 100,
        Parent = gui,
    })
    new("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Parent = self._notifHolder,
    })

    self:_buildKey()
    self:_buildWatermark()

    if self._mobileButton then
        local mb = new("ImageButton", {
            Name = "MobileToggle",
            Position = UDim2.new(0, 14, 0.35, 0),
            Size = UDim2.fromOffset(46, 46),
            ZIndex = 5,
            Parent = gui,
        })
        self:_bind(mb, "BackgroundColor3", "Panel")
        round(mb, 23)
        self:_bind(stroke(mb, T.Accent, 1.5, 0.2), "Color", "Accent")
        local mlogo = new("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(28, 28),
            ZIndex = 6,
            Parent = mb,
        })
        round(mlogo, 14)
        self:_logo(mlogo)
        self:_dragWindow(mb, mb, function()
            self:Toggle()
        end)
    end

    self:_conn(UserInputService.InputBegan:Connect(function(input, gp)
        if gp or self._listening then
            return
        end
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == self.ToggleKey then
            self:Toggle()
        end
    end))

    local cam = workspace.CurrentCamera
    if cam then
        self:_conn(cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            self:_applyScale()
        end))
    end
end

function Library:_buildWatermark()
    local frame = new("Frame", {
        Name = "Watermark",
        Position = UDim2.fromOffset(14, 14),
        Size = UDim2.fromOffset(0, 28),
        AutomaticSize = Enum.AutomaticSize.X,
        Visible = false,
        ZIndex = 5,
        Parent = self.Gui,
    })
    self:_bind(frame, "BackgroundColor3", "Panel")
    round(frame, 8)
    self:_bind(stroke(frame, self.Theme.Stroke, 1, 0.3), "Color", "Stroke")
    pad(frame, 0, 12, 0, 8)
    list(frame, 8).FillDirection = Enum.FillDirection.Horizontal
    local img = new("ImageLabel", {Size = UDim2.fromOffset(16, 16), LayoutOrder = 1, Parent = frame})
    round(img, 4)
    self:_logo(img)
    local label = new("TextLabel", {
        Font = GOTHAM,
        TextSize = 12,
        Size = UDim2.fromOffset(0, 28),
        AutomaticSize = Enum.AutomaticSize.X,
        LayoutOrder = 2,
        Parent = frame,
    })
    self:_bind(label, "TextColor3", "Text")
    self._wmFrame = frame
    self._wmLabel = label

    local acc, frames = 0, 0
    self:_conn(RunService.Heartbeat:Connect(function(dt)
        acc = acc + dt
        frames = frames + 1
        if acc >= 0.5 then
            if self._wmText then
                label.Text = self._wmText .. "  |  " .. math.floor(frames / acc + 0.5) .. " fps"
            end
            acc = 0
            frames = 0
        end
    end))
end

function Library:_buildKey()
    local T = self.Theme
    local win = new("CanvasGroup", {
        Name = "KeyWindow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(400, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        GroupTransparency = 1,
        Visible = false,
        ZIndex = 3,
        Parent = self.Gui,
    })
    self:_bind(win, "BackgroundColor3", "Background")
    round(win, 16)
    self:_bind(stroke(win, T.Stroke, 1, 0.3), "Color", "Stroke")
    local pop = new("UIScale", {Scale = 0.94, Parent = win})
    pad(win, 22, 24, 24, 24)
    new("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Parent = win,
    })

    local top = new("Frame", {Size = UDim2.new(1, 0, 0, 60), BackgroundTransparency = 1, LayoutOrder = 1, Parent = win})
    local logo = new("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.fromScale(0.5, 0),
        Size = UDim2.fromOffset(58, 58),
        Parent = top,
    })
    round(logo, 14)
    self:_logo(logo)
    local x = new("TextButton", {
        Text = "×",
        TextSize = 22,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.fromScale(1, 0),
        Size = UDim2.fromOffset(26, 26),
        BackgroundTransparency = 1,
        Parent = top,
    })
    self:_bind(x, "TextColor3", "SubText")
    x.MouseButton1Click:Connect(function()
        self:_hideKey()
    end)

    local title = new("TextLabel", {
        Text = "Enter your key",
        Font = BOLD,
        TextSize = 20,
        Size = UDim2.new(1, 0, 0, 26),
        LayoutOrder = 2,
        Parent = win,
    })
    self:_bind(title, "TextColor3", "Text")
    local sub = new("TextLabel", {
        Text = "paste your key below to unlock the hub",
        TextSize = 12,
        TextWrapped = true,
        Size = UDim2.new(1, 0, 0, 16),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 3,
        Parent = win,
    })
    self:_bind(sub, "TextColor3", "SubText")

    local inputFrame = new("Frame", {Size = UDim2.new(1, 0, 0, 42), LayoutOrder = 4, Parent = win})
    self:_bind(inputFrame, "BackgroundColor3", "Element")
    round(inputFrame, 10)
    local inputStroke = stroke(inputFrame, T.Stroke, 1, 0.2)
    self:_bind(inputStroke, "Color", "Stroke")
    local box = new("TextBox", {
        PlaceholderText = "HUM-XXXX-XXXX-XXXX-XXXX",
        ClearTextOnFocus = false,
        BackgroundTransparency = 1,
        TextXAlignment = LEFT,
        Position = UDim2.fromOffset(14, 0),
        Size = UDim2.new(1, -28, 1, 0),
        Parent = inputFrame,
    })
    self:_bind(box, "TextColor3", "Text")
    self:_bind(box, "PlaceholderColor3", "SubText")
    box.Focused:Connect(function()
        tween(inputStroke, {Color = self.Theme.Accent}, 0.15)
    end)

    local track = new("Frame", {
        Size = UDim2.new(1, 0, 0, 3),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        LayoutOrder = 5,
        Parent = win,
    })
    self:_bind(track, "BackgroundColor3", "Stroke")
    round(track, 2)
    local seg = new("Frame", {
        Size = UDim2.fromScale(0.35, 1),
        Position = UDim2.fromScale(-0.35, 0),
        Visible = false,
        Parent = track,
    })
    self:_bind(seg, "BackgroundColor3", "Accent")
    round(seg, 2)

    local status = new("TextLabel", {
        Text = "",
        TextSize = 12,
        TextWrapped = true,
        Size = UDim2.new(1, 0, 0, 16),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 6,
        Parent = win,
    })
    status.TextColor3 = T.SubText

    local buttons = new("Frame", {Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, LayoutOrder = 7, Parent = win})
    local get = new("TextButton", {
        Text = "Get Key",
        Font = BOLD,
        Size = UDim2.new(0.5, -5, 1, 0),
        Parent = buttons,
    })
    self:_bind(get, "BackgroundColor3", "Element")
    self:_bind(get, "TextColor3", "Text")
    round(get, 10)
    local getStroke = stroke(get, T.Stroke, 1, 0.3)
    self:_bind(getStroke, "Color", "Stroke")
    local unlock = new("TextButton", {
        Text = "Unlock",
        Font = BOLD,
        TextColor3 = WHITE,
        Position = UDim2.new(0.5, 5, 0, 0),
        Size = UDim2.new(0.5, -5, 1, 0),
        Parent = buttons,
    })
    self:_bind(unlock, "BackgroundColor3", "Accent")
    round(unlock, 10)

    get.MouseEnter:Connect(function()
        tween(get, {BackgroundColor3 = self.Theme.ElementHover}, 0.15)
    end)
    get.MouseLeave:Connect(function()
        tween(get, {BackgroundColor3 = self.Theme.Element}, 0.15)
    end)
    unlock.MouseEnter:Connect(function()
        if not self._loading then
            tween(unlock, {BackgroundTransparency = 0.15}, 0.15)
        end
    end)
    unlock.MouseLeave:Connect(function()
        if not self._loading then
            tween(unlock, {BackgroundTransparency = 0}, 0.15)
        end
    end)

    unlock.MouseButton1Click:Connect(function()
        self:_submitKey(box.Text)
    end)
    box.FocusLost:Connect(function(enter)
        tween(inputStroke, {Color = self.Theme.Stroke}, 0.15)
        if enter then
            self:_submitKey(box.Text)
        end
    end)
    get.MouseButton1Click:Connect(function()
        self:_getKey()
    end)

    self._ui = {
        win = win,
        pop = pop,
        title = title,
        sub = sub,
        box = box,
        status = status,
        unlock = unlock,
        get = get,
        track = track,
        seg = seg,
    }
end

function Library:_keyStatus(text, kind)
    local ui = self._ui
    if not ui then
        return
    end
    local colors = {error = BAD, success = GOOD, warning = WARN}
    ui.status.Text = text or ""
    ui.status.TextColor3 = colors[kind] or self.Theme.SubText
end

function Library:_keyLoading(on)
    local ui = self._ui
    self._loading = on
    self._loadTok = (self._loadTok or 0) + 1
    local tok = self._loadTok
    ui.seg.Visible = on
    ui.track.BackgroundTransparency = on and 0.4 or 1
    tween(ui.unlock, {BackgroundTransparency = on and 0.4 or 0}, 0.15)
    if not on then
        ui.unlock.Text = "Unlock"
        return
    end
    task.spawn(function()
        local n = 0
        while self.Alive and self._loading and self._loadTok == tok do
            n = n % 3 + 1
            ui.unlock.Text = "Checking" .. string.rep(".", n)
            ui.seg.Position = UDim2.fromScale(-0.35, 0)
            tween(ui.seg, {Position = UDim2.fromScale(1, 0)}, 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
            task.wait(0.6)
        end
    end)
end

function Library:_shake()
    local win = self._ui.win
    task.spawn(function()
        local base = UDim2.fromScale(0.5, 0.5)
        for i = 1, 4 do
            tween(win, {Position = base + UDim2.fromOffset(i % 2 == 0 and 8 or -8, 0)}, 0.05)
            task.wait(0.05)
        end
        tween(win, {Position = base}, 0.08)
    end)
end

function Library:_showKey(title, subtitle, status, kind)
    local ui = self._ui
    if title then
        ui.title.Text = title
    end
    if subtitle then
        ui.sub.Text = subtitle
    end
    if status then
        self:_keyStatus(status, kind)
    end
    local hasLink = self._keyLink ~= nil
    ui.get.Visible = hasLink
    ui.unlock.Position = hasLink and UDim2.new(0.5, 5, 0, 0) or UDim2.new(0, 0, 0, 0)
    ui.unlock.Size = hasLink and UDim2.new(0.5, -5, 1, 0) or UDim2.new(1, 0, 1, 0)
    self._keyTok = (self._keyTok or 0) + 1
    self._keyOpen = true
    ui.win.Visible = true
    ui.win.GroupTransparency = 1
    ui.pop.Scale = 0.94 * self:_keyFit()
    tween(ui.win, {GroupTransparency = 0}, 0.25)
    tween(ui.pop, {Scale = self:_keyFit()}, 0.3, Enum.EasingStyle.Back)
    self:_syncBackdrop()
end

function Library:_hideKey()
    if not self._keyOpen then
        return
    end
    local ui = self._ui
    self._keyOpen = false
    self._keyTok = (self._keyTok or 0) + 1
    local tok = self._keyTok
    tween(ui.win, {GroupTransparency = 1}, 0.2)
    tween(ui.pop, {Scale = 0.94 * self:_keyFit()}, 0.2)
    self:_syncBackdrop()
    task.delay(0.22, function()
        if self._keyTok == tok and not self._keyOpen then
            ui.win.Visible = false
        end
    end)
end

function Library:_getKey()
    local link = self._keyLink
    if type(link) == "string" then
        local ok = type(setclipboard) == "function" and pcall(setclipboard, link)
        if ok then
            self:_keyStatus("link copied to clipboard, open it in your browser", "success")
            self:Notify{Title = "Link copied", Content = "paste it into your browser to get a key", Type = "success", Duration = 4}
        else
            self:_keyStatus(link, "info")
        end
    elseif type(link) == "function" then
        task.spawn(function()
            local ok, res = pcall(link)
            if not ok then
                self:_keyStatus("could not start that, try again", "error")
            elseif type(res) == "string" then
                self:_keyStatus(res, "info")
            end
        end)
    end
end

function Library:_submitKey(key, auto)
    if self._loading or not self._validator then
        return
    end
    key = trim(key)
    if key == "" then
        self:_keyStatus("enter your key first", "warning")
        return
    end
    self:_keyLoading(true)
    self:_keyStatus(auto and "checking saved key..." or "checking key...", "info")
    task.spawn(function()
        local ok, res = pcall(self._validator, key)
        if not self.Alive then
            return
        end
        self:_keyLoading(false)
        if not ok then
            self:_keyStatus("could not reach the server, try again", "error")
            self:_shake()
            return
        end
        local valid, data = normalize(res)
        if valid then
            self:_unlock(key, data)
        else
            self:_reject(data, auto)
        end
    end)
end

function Library:_unlock(key, data)
    local left = tonumber(data.seconds_left)
    self._keyInfo = {Valid = true, Tier = data.tier, SecondsLeft = left}
    self._expiresAt = left and (os.time() + math.floor(left)) or nil
    if self._remember then
        safeWrite(KEY_FILE, key)
    end
    self:_keyStatus("key accepted", "success")
    self:_startCountdown()
    self:_syncKeyInfo()
    local tierText = data.tier and (" (" .. tostring(data.tier) .. ")") or ""
    self:Notify{Title = "Key accepted", Content = "welcome in" .. tierText, Type = "success", Duration = 4}
    task.delay(0.35, function()
        if self.Alive and self._keyInfo.Valid then
            self:_hideKey()
            self:Show()
            if self._onUnlock then
                task.spawn(safe, self._onUnlock, self:GetKeyInfo())
            end
        end
    end)
end

function Library:_reject(data, auto)
    local reason = data.reason or "invalid_key"
    local text = data.message or REASONS[reason] or "that key didn't work"
    self:_keyStatus(text, "error")
    self:_shake()
    if auto and (reason == "invalid_key" or reason == "revoked" or reason == "expired" or reason == "hwid_mismatch") then
        safeDelete(KEY_FILE)
    end
end

function Library:_startCountdown()
    self._cdTok = (self._cdTok or 0) + 1
    local tok = self._cdTok
    local pill = self._pill
    if not self._expiresAt then
        pill.frame.Visible = false
        return
    end
    pill.frame.Visible = true
    local tier = self._keyInfo.Tier
    pill.tier.Text = tier and (tostring(tier) .. " key") or "key"
    task.spawn(function()
        while self.Alive and self._cdTok == tok do
            local left = self._expiresAt - os.time()
            if left <= 0 then
                self:_expire()
                return
            end
            local color = left > 600 and GOOD or (left > 60 and WARN or BAD)
            pill.time.Text = fmt(left)
            pill.time.TextColor3 = color
            pill.dot.BackgroundColor3 = color
            self:_syncKeyInfo()
            task.wait(1)
        end
    end)
end

function Library:_expire()
    self._cdTok = (self._cdTok or 0) + 1
    self._keyInfo = {Valid = false}
    self._expiresAt = nil
    self._pill.frame.Visible = false
    safeDelete(KEY_FILE)
    self._ui.box.Text = ""
    self:_syncKeyInfo()
    self:Hide()
    self:_showKey("Key expired", "your key ran out, grab a new one to keep going", "key expired", "warning")
    self:Notify{Title = "Key expired", Content = "get a new key to continue", Type = "warning", Duration = 6}
    if self._onExpire then
        task.spawn(safe, self._onExpire)
    end
end

function Library:_syncKeyInfo()
    if not self._keyPara then
        return
    end
    local text
    if not self._validator then
        text = "no key needed for this hub"
    elseif self._keyInfo.Valid then
        local tier = self._keyInfo.Tier and (" (" .. tostring(self._keyInfo.Tier) .. ")") or ""
        if self._expiresAt then
            text = "active" .. tier .. ", " .. fmt(self._expiresAt - os.time()) .. " left"
        else
            text = "active" .. tier
        end
    else
        text = "locked"
    end
    self._keyPara:SetContent(text)
end

function Library:_syncBackdrop()
    local want = self._open or self._keyOpen
    local bd = self._backdropFrame
    self._bdTok = (self._bdTok or 0) + 1
    local tok = self._bdTok
    if want and self._backdrop then
        bd.Visible = true
        tween(bd, {BackgroundTransparency = self._backdropTrans}, 0.35)
    else
        tween(bd, {BackgroundTransparency = 1}, 0.25)
        task.delay(0.27, function()
            if self._bdTok == tok and bd.Parent then
                bd.Visible = false
            end
        end)
    end
    local blur = self._blurObj
    if blur then
        if want and self._blur then
            blur.Enabled = true
            tween(blur, {Size = self._blurSize}, 0.35)
        else
            tween(blur, {Size = 0}, 0.25)
            task.delay(0.27, function()
                if self._bdTok == tok and blur.Parent then
                    blur.Enabled = false
                end
            end)
        end
    end
end

function Library:_locked()
    return self._validator ~= nil and not self._keyInfo.Valid
end

function Library:Show()
    if self:_locked() then
        self:_showKey()
        return self
    end
    if self._open then
        return self
    end
    self._open = true
    self._visTok = (self._visTok or 0) + 1
    self._holder.Visible = true
    self._main.GroupTransparency = 1
    self._pop.Scale = 0.94
    tween(self._main, {GroupTransparency = 0}, 0.25)
    tween(self._pop, {Scale = 1}, 0.32, Enum.EasingStyle.Back)
    self:_syncBackdrop()
    return self
end

function Library:Hide()
    if not self._open then
        return self
    end
    self._open = false
    self._visTok = (self._visTok or 0) + 1
    local tok = self._visTok
    tween(self._main, {GroupTransparency = 1}, 0.2)
    tween(self._pop, {Scale = 0.94}, 0.2)
    self:_syncBackdrop()
    task.delay(0.22, function()
        if self._visTok == tok and not self._open and self._holder.Parent then
            self._holder.Visible = false
        end
    end)
    return self
end

function Library:Toggle()
    if self:_locked() then
        if self._keyOpen then
            self:_hideKey()
        else
            self:_showKey()
        end
        return self
    end
    if self._open then
        self:Hide()
    else
        self:Show()
    end
    return self
end

function Library:Init()
    if self._inited then
        return self
    end
    self._inited = true
    if self._withSettings then
        self:_buildSettings()
    end
    self:_syncKeyInfo()
    if self._validator then
        self:_showKey()
        if self._remember then
            local saved = trim(safeRead(KEY_FILE))
            if saved ~= "" then
                self._ui.box.Text = saved
                self:_submitKey(saved, true)
            end
        end
    else
        self:Show()
    end
    return self
end

function Library:SetKey(validator, onUnlock, onExpire)
    local fn
    if type(validator) == "function" then
        fn = validator
    elseif type(validator) == "string" then
        local want = validator
        fn = function(k)
            return k == want
        end
    elseif type(validator) == "table" then
        local keys = validator
        fn = function(k)
            for _, v in ipairs(keys) do
                if v == k then
                    return true
                end
            end
            return false
        end
    end
    self._validator = fn
    self._onUnlock = onUnlock
    self._onExpire = onExpire
    self._keyInfo = {Valid = false}
    self:_syncKeyInfo()
    return self
end

function Library:SetKeyLink(link)
    self._keyLink = link
    return self
end

function Library:SetKeyPrompt(title, subtitle)
    if title then
        self._ui.title.Text = title
    end
    if subtitle then
        self._ui.sub.Text = subtitle
    end
    return self
end

function Library:SetRememberKey(on)
    self._remember = on == true
    return self
end

function Library:SetKeyText(text)
    self._ui.box.Text = tostring(text or "")
    return self
end

function Library:SetKeyStatus(text, kind)
    self:_keyStatus(text, kind)
    return self
end

function Library:GetKeyInfo()
    local left
    if self._expiresAt then
        left = math.max(0, self._expiresAt - os.time())
    end
    return {Valid = self._keyInfo.Valid == true, Tier = self._keyInfo.Tier, SecondsLeft = left}
end

function Library:SetLogo(id)
    local n = tostring(id or ""):match("%d+")
    if not n then
        return self
    end
    self._logoImage = "rbxassetid://" .. n
    for _, img in ipairs(self._logos) do
        if img.Parent then
            img.Image = self._logoImage
        end
    end
    self._logoTok = (self._logoTok or 0) + 1
    local tok = self._logoTok
    task.spawn(function()
        local ok, objs = pcall(function()
            return game:GetObjects("rbxassetid://" .. n)
        end)
        if not ok or type(objs) ~= "table" or not objs[1] then
            return
        end
        local obj = objs[1]
        local tex
        if obj:IsA("Decal") or obj:IsA("Texture") then
            tex = obj.Texture
        elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
            tex = obj.Image
        end
        pcall(function()
            obj:Destroy()
        end)
        if tex and tex ~= "" and self.Alive and self._logoTok == tok then
            self._logoImage = tex
            for _, img in ipairs(self._logos) do
                if img.Parent then
                    img.Image = tex
                end
            end
        end
    end)
    return self
end

function Library:SetAccent(color)
    self._accent = color
    self.Theme.Accent = color
    self:_applyTheme()
    return self
end

function Library:SetTheme(name)
    local preset = Library.Themes[name]
    if not preset then
        return self
    end
    self.ThemeName = name
    self.Theme = copy(preset)
    if self._accent then
        self.Theme.Accent = self._accent
    end
    self:_applyTheme()
    return self
end

function Library:SetScale(n)
    self._scale = math.clamp(tonumber(n) or 1, 0.6, 1.6)
    self:_applyScale()
    return self
end

function Library:SetBackdrop(enabled, transparency)
    if enabled ~= nil then
        self._backdrop = enabled == true
    end
    if transparency then
        self._backdropTrans = math.clamp(transparency, 0, 1)
    end
    self:_syncBackdrop()
    return self
end

function Library:SetBlur(enabled, size)
    if enabled ~= nil then
        self._blur = enabled == true
    end
    if size then
        self._blurSize = math.clamp(size, 0, 56)
    end
    self:_syncBackdrop()
    return self
end

function Library:SetWatermark(text)
    if text == nil or text == false then
        self._wmText = nil
        self._wmFrame.Visible = false
        return self
    end
    if text == true then
        text = self.HubName
    end
    self._wmText = tostring(text)
    self._wmLabel.Text = self._wmText
    self._wmFrame.Visible = true
    return self
end

function Library:Notify(a, b, c)
    if not self.Alive then
        return {Dismiss = function() end}
    end
    local o
    if type(a) == "table" then
        o = a
    else
        o = {Title = a, Content = b}
        if type(c) == "number" then
            o.Duration = c
        elseif type(c) == "string" then
            o.Type = c
        end
    end
    local kind = NOTIFY_TYPES[o.Type or "info"] or NOTIFY_TYPES.info
    local color = o.Color or kind.color or self.Theme.Accent
    local duration = o.Duration
    if duration == nil then
        duration = 5
    end
    self._notifN = self._notifN + 1

    local holder = new("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        LayoutOrder = self._notifN,
        Parent = self._notifHolder,
    })
    local card = new("CanvasGroup", {
        Position = UDim2.new(1, 40, 0, 0),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        GroupTransparency = 1,
        Parent = holder,
    })
    self:_bind(card, "BackgroundColor3", "Panel")
    round(card, 12)
    self:_bind(stroke(card, self.Theme.Stroke, 1, 0.2), "Color", "Stroke")
    list(card, 0)

    local body = new("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = 1,
        Parent = card,
    })
    pad(body, 12, 12, 12, 12)

    local badge = new("Frame", {
        Size = UDim2.fromOffset(28, 28),
        BackgroundColor3 = color,
        BackgroundTransparency = 0.82,
        Parent = body,
    })
    round(badge, 14)
    new("TextLabel", {
        Text = kind.glyph,
        Font = BOLD,
        TextSize = 16,
        TextColor3 = color,
        Size = UDim2.fromScale(1, 1),
        Parent = badge,
    })

    local col = new("Frame", {
        Position = UDim2.fromOffset(40, 0),
        Size = UDim2.new(1, -66, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = body,
    })
    list(col, 3)
    local title = new("TextLabel", {
        Text = tostring(o.Title or self.HubName),
        Font = BOLD,
        TextSize = 14,
        TextXAlignment = LEFT,
        TextWrapped = true,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 1,
        Parent = col,
    })
    self:_bind(title, "TextColor3", "Text")
    if o.Content and tostring(o.Content) ~= "" then
        local content = new("TextLabel", {
            Text = tostring(o.Content),
            TextSize = 12,
            TextXAlignment = LEFT,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 2,
            Parent = col,
        })
        self:_bind(content, "TextColor3", "SubText")
    end

    local dead, hovered = false, false
    local handle = {}

    local function dismiss()
        if dead then
            return
        end
        dead = true
        local idx = table.find(self._notifs, handle)
        if idx then
            table.remove(self._notifs, idx)
        end
        tween(card, {Position = UDim2.new(1, 40, 0, 0), GroupTransparency = 1}, 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        task.delay(0.15, function()
            if holder.Parent then
                tween(holder, {Size = UDim2.new(1, 0, 0, 0)}, 0.25)
            end
        end)
        task.delay(0.45, function()
            if holder.Parent then
                holder:Destroy()
            end
        end)
    end
    handle.Dismiss = dismiss

    if type(o.Action) == "table" and o.Action.Text then
        local act = new("TextButton", {
            Text = tostring(o.Action.Text),
            Font = BOLD,
            TextSize = 12,
            TextColor3 = color,
            BackgroundColor3 = color,
            BackgroundTransparency = 0.85,
            Size = UDim2.fromOffset(0, 26),
            AutomaticSize = Enum.AutomaticSize.X,
            LayoutOrder = 3,
            Parent = col,
        })
        round(act, 7)
        pad(act, 0, 12, 0, 12)
        act.MouseEnter:Connect(function()
            tween(act, {BackgroundTransparency = 0.7}, 0.15)
        end)
        act.MouseLeave:Connect(function()
            tween(act, {BackgroundTransparency = 0.85}, 0.15)
        end)
        act.MouseButton1Click:Connect(function()
            safe(o.Action.Callback)
            dismiss()
        end)
    end

    local x = new("TextButton", {
        Text = "×",
        TextSize = 18,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.fromScale(1, 0),
        Size = UDim2.fromOffset(22, 22),
        BackgroundTransparency = 1,
        Parent = body,
    })
    self:_bind(x, "TextColor3", "SubText")
    x.MouseEnter:Connect(function()
        tween(x, {TextColor3 = self.Theme.Text}, 0.12)
    end)
    x.MouseLeave:Connect(function()
        tween(x, {TextColor3 = self.Theme.SubText}, 0.12)
    end)
    x.MouseButton1Click:Connect(dismiss)

    local bar
    if duration > 0 then
        local track = new("Frame", {
            Size = UDim2.new(1, 0, 0, 3),
            BackgroundTransparency = 0.6,
            LayoutOrder = 2,
            Parent = card,
        })
        self:_bind(track, "BackgroundColor3", "Stroke")
        bar = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = color, Parent = track})
    end

    card.MouseEnter:Connect(function()
        hovered = true
    end)
    card.MouseLeave:Connect(function()
        hovered = false
    end)

    table.insert(self._notifs, handle)
    while #self._notifs > 5 do
        local oldest = self._notifs[1]
        oldest.Dismiss()
        if self._notifs[1] == oldest then
            table.remove(self._notifs, 1)
        end
    end

    task.spawn(function()
        local waited = 0
        while card.AbsoluteSize.Y <= 1 and waited < 12 do
            RunService.Heartbeat:Wait()
            waited = waited + 1
        end
        RunService.Heartbeat:Wait()
        RunService.Heartbeat:Wait()
        if dead or not holder.Parent then
            return
        end
        local h = card.AbsoluteSize.Y
        tween(holder, {Size = UDim2.new(1, 0, 0, h)}, 0.28)
        tween(card, {Position = UDim2.new(0, 0, 0, 0), GroupTransparency = 0}, 0.35, Enum.EasingStyle.Back)
        if duration > 0 then
            local left = duration
            while not dead and left > 0 and self.Alive do
                local dt = RunService.Heartbeat:Wait()
                if not hovered then
                    left = left - dt
                    bar.Size = UDim2.new(math.max(left / duration, 0), 0, 1, 0)
                end
            end
            dismiss()
        end
    end)

    return handle
end

function Library:ClearNotifications()
    local copyList = {}
    for _, n in ipairs(self._notifs) do
        table.insert(copyList, n)
    end
    for _, n in ipairs(copyList) do
        n.Dismiss()
    end
    return self
end

function Library:Dialog(o)
    o = o or {}
    local overlay = new("Frame", {
        Name = "Dialog",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        Active = true,
        ZIndex = 50,
        Parent = self.Gui,
    })
    local card = new("CanvasGroup", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(350, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        GroupTransparency = 1,
        Parent = overlay,
    })
    card.BackgroundColor3 = self.Theme.Panel
    round(card, 14)
    stroke(card, self.Theme.Stroke, 1, 0.2)
    local scale = new("UIScale", {Scale = 0.92, Parent = card})
    pad(card, 18, 18, 18, 18)
    list(card, 10)

    new("TextLabel", {
        Text = tostring(o.Title or self.HubName),
        Font = BOLD,
        TextSize = 16,
        TextXAlignment = LEFT,
        TextColor3 = self.Theme.Text,
        Size = UDim2.new(1, 0, 0, 20),
        LayoutOrder = 1,
        Parent = card,
    })
    local content = new("TextLabel", {
        Text = tostring(o.Content or ""),
        TextSize = 13,
        TextXAlignment = LEFT,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        TextColor3 = self.Theme.SubText,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 2,
        Parent = card,
    })

    local input
    if type(o.Input) == "table" then
        local frame = new("Frame", {
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = self.Theme.Element,
            LayoutOrder = 3,
            Parent = card,
        })
        round(frame, 9)
        stroke(frame, self.Theme.Stroke, 1, 0.2)
        input = new("TextBox", {
            Text = tostring(o.Input.Default or ""),
            PlaceholderText = tostring(o.Input.Placeholder or ""),
            PlaceholderColor3 = self.Theme.SubText,
            TextColor3 = self.Theme.Text,
            ClearTextOnFocus = false,
            BackgroundTransparency = 1,
            TextXAlignment = LEFT,
            Position = UDim2.fromOffset(12, 0),
            Size = UDim2.new(1, -24, 1, 0),
            Parent = frame,
        })
    end

    local closed = false
    local function close()
        if closed then
            return
        end
        closed = true
        tween(card, {GroupTransparency = 1}, 0.15)
        tween(scale, {Scale = 0.94}, 0.15)
        tween(overlay, {BackgroundTransparency = 1}, 0.15)
        task.delay(0.18, function()
            if overlay.Parent then
                overlay:Destroy()
            end
        end)
    end

    local defs = o.Buttons
    if type(defs) ~= "table" or #defs == 0 then
        defs = {{Text = "OK"}}
    end
    local n = #defs
    local row = new("Frame", {Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1, LayoutOrder = 4, Parent = card})
    new("UIListLayout", {
        Padding = UDim.new(0, 8),
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = row,
    })
    local busy = false
    for i, def in ipairs(defs) do
        local primary = def.Primary
        if primary == nil then
            primary = i == n
        end
        local b = new("TextButton", {
            Text = tostring(def.Text or "OK"),
            Font = BOLD,
            TextColor3 = primary and WHITE or self.Theme.Text,
            BackgroundColor3 = primary and self.Theme.Accent or self.Theme.Element,
            Size = UDim2.new(1 / n, -math.floor(8 * (n - 1) / n), 1, 0),
            LayoutOrder = i,
            Parent = row,
        })
        round(b, 9)
        b.MouseButton1Click:Connect(function()
            if busy then
                return
            end
            busy = true
            task.spawn(function()
                local ok, res = pcall(def.Callback or function() end, input and input.Text or nil)
                if not ok then
                    warn("[HumidityHub] " .. tostring(res))
                end
                busy = false
                if res ~= false then
                    close()
                end
            end)
        end)
    end

    tween(overlay, {BackgroundTransparency = 0.45}, 0.2)
    tween(card, {GroupTransparency = 0}, 0.2)
    tween(scale, {Scale = 1}, 0.28, Enum.EasingStyle.Back)

    local obj = {Close = close}
    function obj:SetContent(text)
        content.Text = tostring(text)
    end
    return obj
end

function Library:SaveConfig(name)
    name = trim(name)
    if name == "" then
        name = "default"
    end
    local data = {}
    for flag, v in pairs(self.Flags) do
        data[flag] = encodeValue(v)
    end
    local ok, json = pcall(function()
        return HttpService:JSONEncode(data)
    end)
    local saved = ok and safeWrite(CONFIG_DIR .. "/" .. name .. ".json", json)
    self:Notify{
        Title = saved and "Config saved" or "Could not save",
        Content = saved and name or "your executor has no file access",
        Type = saved and "success" or "error",
        Duration = 3,
    }
    return saved
end

function Library:LoadConfig(name)
    name = trim(name)
    if name == "" then
        name = "default"
    end
    local raw = safeRead(CONFIG_DIR .. "/" .. name .. ".json")
    local ok, data = pcall(function()
        return HttpService:JSONDecode(raw)
    end)
    if not raw or not ok or type(data) ~= "table" then
        self:Notify{Title = "Could not load", Content = "no config named " .. name, Type = "error", Duration = 3}
        return false
    end
    for flag, v in pairs(data) do
        local setter = self.Setters[flag]
        if setter then
            pcall(setter, decodeValue(v), false)
        end
    end
    self:Notify{Title = "Config loaded", Content = name, Type = "success", Duration = 3}
    return true
end

function Library:Destroy()
    if not self.Alive then
        return
    end
    self.Alive = false
    self._cdTok = (self._cdTok or 0) + 1
    for _, c in ipairs(self._conns) do
        pcall(function()
            c:Disconnect()
        end)
    end
    if self._blurObj then
        self._blurObj:Destroy()
    end
    if self.Gui then
        self.Gui:Destroy()
    end
end

function Library:_paintTabs()
    for _, t in ipairs(self.Tabs) do
        local on = t == self._current
        tween(t.Button, {BackgroundTransparency = on and 0.86 or 1}, 0.2)
        tween(t.Label, {TextColor3 = on and self.Theme.Text or self.Theme.SubText}, 0.2)
        tween(t.Icon, {[t.IconProp] = on and self.Theme.Accent or self.Theme.SubText}, 0.2)
        tween(t.Indicator, {
            BackgroundTransparency = on and 0 or 1,
            Size = on and UDim2.fromOffset(3, 16) or UDim2.fromOffset(3, 4),
        }, 0.2)
        t.Page.Visible = on
    end
end

function Library:_select(tab)
    if self._current == tab then
        return
    end
    self._current = tab
    self:_paintTabs()
    tab.Page.Position = UDim2.fromOffset(0, 10)
    tween(tab.Page, {Position = UDim2.fromOffset(0, 0)}, 0.28)
end

function Library:AddTab(o, icon)
    if type(o) ~= "table" then
        o = {Name = o, Icon = icon}
    end
    local name = tostring(o.Name or "Tab")
    local tab = setmetatable({Hub = self, Name = name, _n = 0, IsSettings = o.IsSettings == true}, Tab)
    local order = o.Order or (#self.Tabs + 1)

    local btn = new("TextButton", {
        Name = name,
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundTransparency = 1,
        LayoutOrder = order,
        Parent = self._tabList,
    })
    self:_bind(btn, "BackgroundColor3", "Accent")
    round(btn, 8)
    local ind = new("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(3, 4),
        BackgroundTransparency = 1,
        Parent = btn,
    })
    self:_bind(ind, "BackgroundColor3", "Accent")
    round(ind, 2)

    local isImage = type(o.Icon) == "number" or (type(o.Icon) == "string" and o.Icon:find("rbxassetid"))
    local ic, prop
    if isImage then
        prop = "ImageColor3"
        ic = new("ImageLabel", {
            Image = type(o.Icon) == "number" and ("rbxassetid://" .. o.Icon) or o.Icon,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 12, 0.5, 0),
            Size = UDim2.fromOffset(18, 18),
            Parent = btn,
        })
    else
        prop = "TextColor3"
        ic = new("TextLabel", {
            Text = type(o.Icon) == "string" and o.Icon or name:sub(1, 1):upper(),
            Font = BOLD,
            TextSize = 14,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 12, 0.5, 0),
            Size = UDim2.fromOffset(18, 18),
            Parent = btn,
        })
    end
    local label = new("TextLabel", {
        Text = name,
        TextXAlignment = LEFT,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Position = UDim2.fromOffset(38, 0),
        Size = UDim2.new(1, -44, 1, 0),
        Parent = btn,
    })

    local page = new("ScrollingFrame", {
        Name = name,
        Size = UDim2.fromScale(1, 1),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = self.Theme.Stroke,
        Visible = false,
        Parent = self._pages,
    })
    pad(page, 12, 14, 14, 12)
    list(page, 8)

    tab.Button, tab.Label, tab.Icon, tab.IconProp, tab.Indicator, tab.Page = btn, label, ic, prop, ind, page
    table.insert(self.Tabs, tab)

    btn.MouseButton1Click:Connect(function()
        self._userPicked = true
        self:_select(tab)
    end)
    btn.MouseEnter:Connect(function()
        if self._current ~= tab then
            tween(label, {TextColor3 = self.Theme.Text}, 0.12)
        end
    end)
    btn.MouseLeave:Connect(function()
        if self._current ~= tab then
            tween(label, {TextColor3 = self.Theme.SubText}, 0.12)
        end
    end)

    if not self._current or (self._current.IsSettings and not self._userPicked and not tab.IsSettings) then
        self._current = nil
        self:_select(tab)
    else
        self:_paintTabs()
    end
    return tab
end

function Library:_buildSettings()
    local t = self:AddTab{Name = "Settings", Order = 999, IsSettings = true}

    t:AddSection("Hub")
    self._keyPara = t:AddParagraph{Title = "Key", Content = "..."}
    t:AddKeybind{
        Name = "Toggle key",
        Description = "show or hide the hub",
        Default = self.ToggleKey,
        Changed = function(k)
            if k then
                self.ToggleKey = k
            end
        end,
    }
    t:AddButton{
        Name = "Unload hub",
        Callback = function()
            self:Destroy()
        end,
    }

    t:AddSection("Appearance")
    t:AddColorPicker{
        Name = "Accent",
        Default = self.Theme.Accent,
        Callback = function(c)
            self:SetAccent(c)
        end,
    }
    local names = {}
    for n in pairs(Library.Themes) do
        table.insert(names, n)
    end
    table.sort(names)
    t:AddDropdown{
        Name = "Theme",
        Options = names,
        Default = self.ThemeName,
        Callback = function(n)
            self:SetTheme(n)
        end,
    }
    t:AddSlider{
        Name = "UI scale",
        Min = 60,
        Max = 160,
        Increment = 5,
        Default = math.floor(self._scale * 100 + 0.5),
        Suffix = "%",
        Callback = function(v)
            self:SetScale(v / 100)
        end,
    }
    t:AddToggle{
        Name = "Dark backdrop",
        Description = "fades the screen behind the hub",
        Default = self._backdrop,
        Callback = function(v)
            self:SetBackdrop(v)
        end,
    }
    t:AddSlider{
        Name = "Backdrop strength",
        Min = 0,
        Max = 100,
        Increment = 5,
        Default = math.floor((1 - self._backdropTrans) * 100 + 0.5),
        Suffix = "%",
        Callback = function(v)
            self:SetBackdrop(nil, 1 - v / 100)
        end,
    }
    t:AddToggle{
        Name = "Background blur",
        Default = self._blur,
        Callback = function(v)
            self:SetBlur(v)
        end,
    }

    t:AddSection("Notifications")
    t:AddButton{
        Name = "Send test notification",
        Callback = function()
            self:Notify{
                Title = "Humidity Hub",
                Content = "this is what a notification looks like",
                Type = "info",
                Duration = 5,
                Action = {
                    Text = "Nice",
                    Callback = function() end,
                },
            }
        end,
    }
    t:AddButton{
        Name = "Clear notifications",
        Callback = function()
            self:ClearNotifications()
        end,
    }

    t:AddSection("Config")
    local cfgName = "default"
    t:AddTextbox{
        Name = "Config name",
        Default = cfgName,
        Callback = function(v)
            if trim(v) ~= "" then
                cfgName = trim(v)
            end
        end,
    }
    t:AddButton{
        Name = "Save config",
        Callback = function()
            self:SaveConfig(cfgName)
        end,
    }
    t:AddButton{
        Name = "Load config",
        Callback = function()
            self:LoadConfig(cfgName)
        end,
    }
end

function Tab:_row(o, cfg)
    cfg = cfg or {}
    local hub = self.Hub
    self._n = self._n + 1
    local desc = o.Description
    local hasDesc = type(desc) == "string" and desc ~= ""
    local h = cfg.height or (hasDesc and 50 or 38)
    if cfg.tall and hasDesc then
        h = h + 16
    end
    local row = new("Frame", {
        Name = tostring(o.Name or "Row"),
        Size = UDim2.new(1, 0, 0, h),
        LayoutOrder = self._n,
        Parent = self.Page,
    })
    hub:_bind(row, "BackgroundColor3", "Element")
    round(row, 9)
    hub:_bind(stroke(row, hub.Theme.Stroke, 1, 0.45), "Color", "Stroke")
    local ty, th
    if cfg.tall then
        ty, th = 9, 18
    elseif hasDesc then
        ty, th = 8, 16
    else
        ty, th = 0, h
    end
    local rw = cfg.rightW or 0
    local title = new("TextLabel", {
        Text = tostring(o.Name or ""),
        TextXAlignment = LEFT,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Position = UDim2.fromOffset(12, ty),
        Size = UDim2.new(1, -(24 + rw), 0, th),
        Parent = row,
    })
    hub:_bind(title, "TextColor3", "Text")
    local sub
    if hasDesc then
        sub = new("TextLabel", {
            Text = desc,
            TextSize = 11,
            TextXAlignment = LEFT,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Position = UDim2.fromOffset(12, ty + th + 1),
            Size = UDim2.new(1, -(24 + rw), 0, 14),
            Parent = row,
        })
        hub:_bind(sub, "TextColor3", "SubText")
    end
    return row, title, sub, h
end

function Tab:AddSection(name)
    if type(name) == "table" then
        name = name.Name
    end
    local hub = self.Hub
    self._n = self._n + 1
    local f = new("Frame", {Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, LayoutOrder = self._n, Parent = self.Page})
    local tick = new("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 2, 0.5, 2),
        Size = UDim2.fromOffset(3, 12),
        Parent = f,
    })
    round(tick, 2)
    hub:_bind(tick, "BackgroundColor3", "Accent")
    local l = new("TextLabel", {
        Text = string.upper(tostring(name or "")),
        Font = BOLD,
        TextSize = 11,
        TextXAlignment = LEFT,
        Position = UDim2.fromOffset(12, 2),
        Size = UDim2.new(1, -12, 1, 0),
        Parent = f,
    })
    hub:_bind(l, "TextColor3", "SubText")
    return self
end

function Tab:AddDivider()
    local hub = self.Hub
    self._n = self._n + 1
    local d = new("Frame", {Size = UDim2.new(1, 0, 0, 1), BackgroundTransparency = 0.5, LayoutOrder = self._n, Parent = self.Page})
    hub:_bind(d, "BackgroundColor3", "Stroke")
    return self
end

function Tab:AddLabel(o)
    if type(o) ~= "table" then
        o = {Text = o}
    end
    local hub = self.Hub
    self._n = self._n + 1
    local l = new("TextLabel", {
        Text = tostring(o.Text or o.Name or ""),
        TextXAlignment = LEFT,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = self._n,
        Parent = self.Page,
    })
    pad(l, 2, 4, 2, 6)
    hub:_bind(l, "TextColor3", "SubText")
    local obj = {}
    function obj:Set(text)
        l.Text = tostring(text)
    end
    function obj:Destroy()
        l:Destroy()
    end
    return obj
end

function Tab:AddParagraph(o, content)
    if type(o) ~= "table" then
        o = {Title = o, Content = content}
    end
    local hub = self.Hub
    self._n = self._n + 1
    local card = new("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = self._n,
        Parent = self.Page,
    })
    hub:_bind(card, "BackgroundColor3", "Element")
    round(card, 9)
    hub:_bind(stroke(card, hub.Theme.Stroke, 1, 0.45), "Color", "Stroke")
    pad(card, 10, 12, 10, 12)
    list(card, 4)
    local t = new("TextLabel", {
        Text = tostring(o.Title or ""),
        Font = BOLD,
        TextXAlignment = LEFT,
        TextWrapped = true,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 1,
        Parent = card,
    })
    hub:_bind(t, "TextColor3", "Text")
    local c = new("TextLabel", {
        Text = tostring(o.Content or ""),
        TextSize = 12,
        TextXAlignment = LEFT,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 2,
        Parent = card,
    })
    hub:_bind(c, "TextColor3", "SubText")
    local obj = {}
    function obj:SetTitle(x)
        t.Text = tostring(x)
    end
    function obj:SetContent(x)
        c.Text = tostring(x)
    end
    function obj:Set(a, b)
        t.Text = tostring(a)
        c.Text = tostring(b or "")
    end
    function obj:Destroy()
        card:Destroy()
    end
    return obj
end

function Tab:AddButton(o, cb)
    if type(o) ~= "table" then
        o = {Name = o, Callback = cb}
    end
    local hub = self.Hub
    local row, title = self:_row(o, {rightW = 24})
    local arrow = new("TextLabel", {
        Text = ">",
        Font = BOLD,
        TextSize = 14,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        Parent = row,
    })
    hub:_bind(arrow, "TextColor3", "SubText")
    local click = new("TextButton", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = row})
    hub:_hover(row, click)
    click.MouseButton1Click:Connect(function()
        tween(arrow, {Position = UDim2.new(1, -6, 0.5, 0), TextColor3 = hub.Theme.Accent}, 0.1)
        task.delay(0.12, function()
            if arrow.Parent then
                tween(arrow, {Position = UDim2.new(1, -12, 0.5, 0), TextColor3 = hub.Theme.SubText}, 0.2)
            end
        end)
        safe(o.Callback)
    end)
    local obj = {}
    function obj:SetText(t)
        title.Text = tostring(t)
    end
    function obj:Destroy()
        row:Destroy()
    end
    return obj
end

function Tab:AddToggle(o, default, cb)
    if type(o) ~= "table" then
        o = {Name = o, Default = default, Callback = cb}
    end
    local hub = self.Hub
    local row = self:_row(o, {rightW = 54})
    local state = o.Default == true
    local track = new("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(38, 20),
        Parent = row,
    })
    round(track, 10)
    local knob = new("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = WHITE,
        Parent = track,
    })
    round(knob, 7)
    local function paint(animate)
        local t = animate and 0.18 or 0
        tween(track, {BackgroundColor3 = state and hub.Theme.Accent or hub.Theme.Stroke}, t)
        tween(knob, {Position = state and UDim2.new(0, 21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)}, t)
    end
    table.insert(hub._refresh, function()
        paint(true)
    end)
    local obj = {}
    function obj:Set(v, silent)
        state = v == true
        paint(true)
        if o.Flag then
            hub.Flags[o.Flag] = state
        end
        if not silent then
            safe(o.Callback, state)
        end
    end
    function obj:Get()
        return state
    end
    function obj:Destroy()
        row:Destroy()
    end
    local click = new("TextButton", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = row})
    hub:_hover(row, click)
    click.MouseButton1Click:Connect(function()
        obj:Set(not state)
    end)
    if o.Flag then
        hub.Flags[o.Flag] = state
        hub.Setters[o.Flag] = function(v, silent)
            obj:Set(v, silent)
        end
    end
    paint(false)
    return obj
end

function Tab:AddSlider(o, min, max, default, cb)
    if type(o) ~= "table" then
        o = {Name = o, Min = min, Max = max, Default = default, Callback = cb}
    end
    local hub = self.Hub
    local mn, mx = o.Min or 0, o.Max or 100
    local inc = o.Increment or 1
    local dec = tostring(inc):match("%.(%d+)")
    dec = dec and #dec or 0
    local suffix = o.Suffix or ""
    local value = math.clamp(o.Default or mn, mn, mx)
    local row = self:_row(o, {tall = true, height = 54, rightW = 90})
    local valLabel = new("TextLabel", {
        Font = BOLD,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -12, 0, 9),
        Size = UDim2.fromOffset(80, 18),
        Parent = row,
    })
    hub:_bind(valLabel, "TextColor3", "SubText")
    local bar = new("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 12, 1, -13),
        Size = UDim2.new(1, -24, 0, 6),
        Parent = row,
    })
    hub:_bind(bar, "BackgroundColor3", "Stroke")
    round(bar, 3)
    local fill = new("Frame", {Size = UDim2.fromScale(0, 1), Parent = bar})
    hub:_bind(fill, "BackgroundColor3", "Accent")
    round(fill, 3)
    local knob = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0, 0.5),
        Size = UDim2.fromOffset(12, 12),
        BackgroundColor3 = WHITE,
        Parent = bar,
    })
    round(knob, 6)
    local hit = new("TextButton", {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 6, 1, -4),
        Size = UDim2.new(1, -12, 0, 26),
        BackgroundTransparency = 1,
        Parent = row,
    })
    local function render()
        local a = (value - mn) / math.max(mx - mn, 1e-9)
        fill.Size = UDim2.fromScale(a, 1)
        knob.Position = UDim2.fromScale(a, 0.5)
        valLabel.Text = string.format("%." .. dec .. "f", value) .. suffix
    end
    local function set(v, silent)
        v = math.clamp(math.floor((v - mn) / inc + 0.5) * inc + mn, mn, mx)
        v = tonumber(string.format("%." .. dec .. "f", v)) or v
        local changed = v ~= value
        value = v
        render()
        if o.Flag then
            hub.Flags[o.Flag] = value
        end
        if not silent and changed then
            safe(o.Callback, value)
        end
    end
    hub:_drag(hit, function(pos)
        local a = math.clamp((pos.X - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
        set(mn + (mx - mn) * a)
    end)
    local obj = {}
    function obj:Set(v, silent)
        set(v, silent)
    end
    function obj:Get()
        return value
    end
    function obj:Destroy()
        row:Destroy()
    end
    if o.Flag then
        hub.Setters[o.Flag] = set
    end
    set(value, true)
    return obj
end

function Tab:AddTextbox(o, default, cb)
    if type(o) ~= "table" then
        o = {Name = o, Default = default, Callback = cb}
    end
    local hub = self.Hub
    local row = self:_row(o, {rightW = 160})
    local frame = new("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(140, 26),
        Parent = row,
    })
    hub:_bind(frame, "BackgroundColor3", "Background")
    round(frame, 7)
    local st = stroke(frame, hub.Theme.Stroke, 1, 0.2)
    hub:_bind(st, "Color", "Stroke")
    local box = new("TextBox", {
        Text = tostring(o.Default or ""),
        PlaceholderText = o.Placeholder or "type here",
        ClearTextOnFocus = false,
        TextSize = 12,
        BackgroundTransparency = 1,
        TextXAlignment = LEFT,
        Position = UDim2.fromOffset(8, 0),
        Size = UDim2.new(1, -16, 1, 0),
        Parent = frame,
    })
    hub:_bind(box, "TextColor3", "Text")
    hub:_bind(box, "PlaceholderColor3", "SubText")
    box.Focused:Connect(function()
        tween(st, {Color = hub.Theme.Accent}, 0.15)
    end)
    local value = box.Text
    local obj = {}
    function obj:Set(v, silent)
        box.Text = tostring(v or "")
        value = box.Text
        if o.Flag then
            hub.Flags[o.Flag] = value
        end
        if not silent then
            safe(o.Callback, value)
        end
    end
    function obj:Get()
        return value
    end
    function obj:Destroy()
        row:Destroy()
    end
    box.FocusLost:Connect(function()
        tween(st, {Color = hub.Theme.Stroke}, 0.15)
        value = box.Text
        if o.Flag then
            hub.Flags[o.Flag] = value
        end
        safe(o.Callback, value)
    end)
    if o.Flag then
        hub.Flags[o.Flag] = value
        hub.Setters[o.Flag] = function(v, silent)
            obj:Set(v, silent)
        end
    end
    return obj
end

function Tab:AddDropdown(o, options, default, cb)
    if type(o) ~= "table" then
        o = {Name = o, Options = options, Default = default, Callback = cb}
    end
    local hub = self.Hub
    local multi = o.Multi == true
    local opts = o.Options or {}
    local selected, single = {}, nil
    if multi then
        for _, v in ipairs(type(o.Default) == "table" and o.Default or {}) do
            selected[v] = true
        end
    else
        single = o.Default
    end
    local row, _, _, h = self:_row(o, {rightW = 180})
    row.ClipsDescendants = true
    local current = new("TextLabel", {
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextTruncate = Enum.TextTruncate.AtEnd,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -34, 0, 0),
        Size = UDim2.fromOffset(150, h),
        Parent = row,
    })
    hub:_bind(current, "TextColor3", "SubText")
    local arrow = new("TextLabel", {
        Text = ">",
        Font = BOLD,
        TextSize = 14,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(1, -19, 0, h / 2),
        Size = UDim2.fromOffset(14, 14),
        Parent = row,
    })
    hub:_bind(arrow, "TextColor3", "SubText")
    local head = new("TextButton", {Size = UDim2.new(1, 0, 0, h), BackgroundTransparency = 1, Parent = row})
    hub:_hover(row, head)
    local holder = new("ScrollingFrame", {
        Position = UDim2.fromOffset(8, h + 2),
        Size = UDim2.new(1, -16, 0, 0),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 2,
        Parent = row,
    })
    list(holder, 2)
    local open = false
    local buttons = {}

    local function listHeight()
        return math.max(math.min(#opts, 6) * 30 - 2, 0)
    end
    local function summary()
        if multi then
            local out = {}
            for _, v in ipairs(opts) do
                if selected[v] then
                    table.insert(out, tostring(v))
                end
            end
            current.Text = #out > 0 and table.concat(out, ", ") or "None"
        else
            current.Text = single ~= nil and tostring(single) or "None"
        end
    end
    local function paintOptions()
        for v, b in pairs(buttons) do
            local on = multi and selected[v] or (not multi and single == v)
            tween(b, {BackgroundTransparency = on and 0.8 or 1, TextColor3 = on and hub.Theme.Accent or hub.Theme.Text}, 0.15)
        end
    end
    local function resize()
        local total = open and (h + 2 + listHeight() + 8) or h
        tween(row, {Size = UDim2.new(1, 0, 0, total)}, 0.22)
        tween(arrow, {Rotation = open and 90 or 0}, 0.22)
    end
    local function setOpen(v)
        open = v
        resize()
    end
    local function result()
        if multi then
            local out = {}
            for _, v in ipairs(opts) do
                if selected[v] then
                    table.insert(out, v)
                end
            end
            return out
        end
        return single
    end
    local function fire(silent)
        local r = result()
        if o.Flag then
            hub.Flags[o.Flag] = r
        end
        if not silent then
            safe(o.Callback, r)
        end
    end
    local function rebuild()
        for _, c in ipairs(holder:GetChildren()) do
            if c:IsA("TextButton") then
                c:Destroy()
            end
        end
        buttons = {}
        for i, v in ipairs(opts) do
            local b = new("TextButton", {
                Text = "   " .. tostring(v),
                TextSize = 12,
                TextXAlignment = LEFT,
                BackgroundColor3 = hub.Theme.Accent,
                BackgroundTransparency = 1,
                TextColor3 = hub.Theme.Text,
                Size = UDim2.new(1, -4, 0, 28),
                LayoutOrder = i,
                Parent = holder,
            })
            round(b, 7)
            b.MouseButton1Click:Connect(function()
                if multi then
                    selected[v] = not selected[v] or nil
                else
                    single = v
                end
                paintOptions()
                summary()
                fire()
                if not multi then
                    setOpen(false)
                end
            end)
            buttons[v] = b
        end
        holder.Size = UDim2.new(1, -16, 0, listHeight())
        paintOptions()
        summary()
        if open then
            resize()
        end
    end
    table.insert(hub._refresh, function()
        for _, b in pairs(buttons) do
            b.BackgroundColor3 = hub.Theme.Accent
        end
        paintOptions()
    end)
    head.MouseButton1Click:Connect(function()
        setOpen(not open)
    end)
    local obj = {}
    function obj:Set(v, silent)
        if multi then
            selected = {}
            for _, x in ipairs(type(v) == "table" and v or {}) do
                selected[x] = true
            end
        else
            single = v
        end
        paintOptions()
        summary()
        fire(silent)
    end
    function obj:Get()
        return result()
    end
    function obj:Refresh(newOptions)
        opts = newOptions or {}
        rebuild()
    end
    function obj:Destroy()
        row:Destroy()
    end
    if o.Flag then
        hub.Setters[o.Flag] = function(v, silent)
            obj:Set(v, silent)
        end
    end
    rebuild()
    fire(true)
    return obj
end

function Tab:AddKeybind(o, default, cb)
    if type(o) ~= "table" then
        o = {Name = o, Default = default, Callback = cb}
    end
    local hub = self.Hub
    local key = toKey(o.Default)
    local listening = false
    local row = self:_row(o, {rightW = 110})
    local btn = new("TextButton", {
        TextSize = 12,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(96, 26),
        Parent = row,
    })
    hub:_bind(btn, "BackgroundColor3", "Background")
    hub:_bind(btn, "TextColor3", "Text")
    round(btn, 7)
    hub:_bind(stroke(btn, hub.Theme.Stroke, 1, 0.2), "Color", "Stroke")
    local function label()
        btn.Text = listening and "..." or (key and key.Name or "None")
    end
    local function changed()
        if o.Flag then
            hub.Flags[o.Flag] = key
        end
        safe(o.Changed, key)
    end
    btn.MouseButton1Click:Connect(function()
        listening = true
        hub._listening = true
        label()
    end)
    hub:_conn(UserInputService.InputBegan:Connect(function(input, gp)
        if listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                listening = false
                task.defer(function()
                    hub._listening = false
                end)
                if input.KeyCode == Enum.KeyCode.Escape then
                    label()
                    return
                elseif input.KeyCode == Enum.KeyCode.Backspace then
                    key = nil
                else
                    key = input.KeyCode
                end
                label()
                changed()
            end
            return
        end
        if key and not gp and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == key then
            safe(o.Callback, key)
        end
    end))
    local obj = {}
    function obj:Set(v, silent)
        key = toKey(v)
        label()
        if o.Flag then
            hub.Flags[o.Flag] = key
        end
        if not silent then
            safe(o.Changed, key)
        end
    end
    function obj:Get()
        return key
    end
    function obj:Destroy()
        row:Destroy()
    end
    if o.Flag then
        hub.Flags[o.Flag] = key
        hub.Setters[o.Flag] = function(v, silent)
            obj:Set(v, silent)
        end
    end
    label()
    return obj
end

function Tab:AddColorPicker(o, default, cb)
    if type(o) ~= "table" then
        o = {Name = o, Default = default, Callback = cb}
    end
    local hub = self.Hub
    local color = o.Default or Color3.fromRGB(255, 255, 255)
    local hue, sat, val = color:ToHSV()
    local row, _, _, h = self:_row(o, {rightW = 60})
    row.ClipsDescendants = true
    local head = new("TextButton", {Size = UDim2.new(1, 0, 0, h), BackgroundTransparency = 1, Parent = row})
    hub:_hover(row, head)
    local swatch = new("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0, h / 2),
        Size = UDim2.fromOffset(34, 18),
        BackgroundColor3 = color,
        Parent = row,
    })
    round(swatch, 6)
    hub:_bind(stroke(swatch, hub.Theme.Stroke, 1, 0.2), "Color", "Stroke")

    local panel = new("Frame", {
        Position = UDim2.fromOffset(12, h + 4),
        Size = UDim2.new(1, -24, 0, 122),
        BackgroundTransparency = 1,
        Parent = row,
    })
    local sv = new("Frame", {Size = UDim2.new(1, 0, 0, 100), BackgroundColor3 = Color3.fromHSV(hue, 1, 1), Parent = panel})
    round(sv, 7)
    local white = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, Parent = sv})
    round(white, 7)
    new("UIGradient", {Transparency = NumberSequence.new(0, 1), Parent = white})
    local black = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), Parent = sv})
    round(black, 7)
    new("UIGradient", {Rotation = 90, Transparency = NumberSequence.new(1, 0), Parent = black})
    local cursor = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(12, 12),
        BackgroundColor3 = WHITE,
        ZIndex = 3,
        Parent = sv,
    })
    round(cursor, 6)
    stroke(cursor, Color3.new(0, 0, 0), 1.5, 0.2)

    local hueBar = new("Frame", {
        Position = UDim2.fromOffset(0, 108),
        Size = UDim2.new(1, 0, 0, 12),
        BackgroundColor3 = WHITE,
        Parent = panel,
    })
    round(hueBar, 6)
    new("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(1 / 6, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(2 / 6, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(3 / 6, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(4 / 6, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(5 / 6, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
        }),
        Parent = hueBar,
    })
    local hueCursor = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(6, 16),
        BackgroundColor3 = WHITE,
        ZIndex = 3,
        Parent = hueBar,
    })
    round(hueCursor, 3)
    stroke(hueCursor, Color3.new(0, 0, 0), 1.5, 0.2)

    local function apply(silent)
        color = Color3.fromHSV(hue, sat, val)
        swatch.BackgroundColor3 = color
        sv.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
        cursor.Position = UDim2.fromScale(sat, 1 - val)
        hueCursor.Position = UDim2.fromScale(hue, 0.5)
        if o.Flag then
            hub.Flags[o.Flag] = color
        end
        if not silent then
            safe(o.Callback, color)
        end
    end
    hub:_drag(sv, function(pos)
        sat = math.clamp((pos.X - sv.AbsolutePosition.X) / math.max(sv.AbsoluteSize.X, 1), 0, 1)
        val = 1 - math.clamp((pos.Y - sv.AbsolutePosition.Y) / math.max(sv.AbsoluteSize.Y, 1), 0, 1)
        apply()
    end)
    hub:_drag(hueBar, function(pos)
        hue = math.clamp((pos.X - hueBar.AbsolutePosition.X) / math.max(hueBar.AbsoluteSize.X, 1), 0, 0.999)
        apply()
    end)
    local open = false
    head.MouseButton1Click:Connect(function()
        open = not open
        tween(row, {Size = UDim2.new(1, 0, 0, open and (h + 4 + 122 + 10) or h)}, 0.22)
    end)
    local obj = {}
    function obj:Set(c, silent)
        if typeof(c) == "Color3" then
            hue, sat, val = c:ToHSV()
            apply(silent)
        end
    end
    function obj:Get()
        return color
    end
    function obj:Destroy()
        row:Destroy()
    end
    if o.Flag then
        hub.Setters[o.Flag] = function(c, silent)
            obj:Set(c, silent)
        end
    end
    apply(true)
    return obj
end

Library.Tab = Library.AddTab
Tab.Section = Tab.AddSection
Tab.Divider = Tab.AddDivider
Tab.Label = Tab.AddLabel
Tab.Paragraph = Tab.AddParagraph
Tab.Button = Tab.AddButton
Tab.Toggle = Tab.AddToggle
Tab.Slider = Tab.AddSlider
Tab.Textbox = Tab.AddTextbox
Tab.Dropdown = Tab.AddDropdown
Tab.Keybind = Tab.AddKeybind
Tab.ColorPicker = Tab.AddColorPicker

return Library
