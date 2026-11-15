local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer

local DEFAULT_LOGO = "rbxassetid://127590426518205"
local SHADOW_IMAGE = "rbxassetid://6014261993"
local ARROW_IMAGE = "rbxassetid://6031091004"
local ROOT_FOLDER = "HumidityHub"
local CONFIG_FOLDER = "HumidityHub/configs"
local KEY_FILE = "HumidityHub/key.txt"

local AutoY = Enum.AutomaticSize.Y
local AutoXY = Enum.AutomaticSize.XY
local ByOrder = Enum.SortOrder.LayoutOrder
local Left = Enum.TextXAlignment.Left
local Right = Enum.TextXAlignment.Right
local Center = Enum.TextXAlignment.Center

local Library = {}
Library.__index = Library
Library.Version = "2.1.0"

local Tab = {}
Tab.__index = Tab

local Section = {}
Section.__index = Section

Library.Presets = {
    Blue = Color3.fromRGB(64, 140, 255),
    Violet = Color3.fromRGB(139, 92, 246),
    Pink = Color3.fromRGB(236, 72, 153),
    Red = Color3.fromRGB(239, 68, 68),
    Amber = Color3.fromRGB(245, 158, 11),
    Green = Color3.fromRGB(34, 197, 94),
    Teal = Color3.fromRGB(20, 184, 166),
    White = Color3.fromRGB(235, 235, 235),
}
Library.PresetOrder = { "Blue", "Violet", "Pink", "Red", "Amber", "Green", "Teal", "White" }

local DefaultTheme = {
    Background = Color3.fromRGB(15, 15, 19),
    Sidebar = Color3.fromRGB(19, 19, 24),
    Topbar = Color3.fromRGB(17, 17, 22),
    Element = Color3.fromRGB(26, 26, 33),
    ElementHover = Color3.fromRGB(34, 34, 43),
    Stroke = Color3.fromRGB(42, 42, 52),
    ToggleOff = Color3.fromRGB(55, 55, 68),
    Text = Color3.fromRGB(235, 235, 240),
    SubText = Color3.fromRGB(140, 140, 155),
    Success = Color3.fromRGB(34, 197, 94),
    Warning = Color3.fromRGB(245, 158, 11),
    Error = Color3.fromRGB(239, 68, 68),
    Accent = Library.Presets.Blue,
}

local hasFS = type(writefile) == "function"
    and type(readfile) == "function"
    and type(isfolder) == "function"
    and type(makefolder) == "function"
    and type(isfile) == "function"
    and type(listfiles) == "function"

local function create(class, props, children)
    local inst = Instance.new(class)
    local parent
    for key, value in pairs(props or {}) do
        if key == "Parent" then
            parent = value
        else
            inst[key] = value
        end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    if parent then
        inst.Parent = parent
    end
    return inst
end

local function corner(parent, radius)
    return create("UICorner", { CornerRadius = UDim.new(0, radius), Parent = parent })
end

local function stroke(parent, color, thickness, transparency)
    return create("UIStroke", {
        Color = color,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function pad(parent, left, top, right, bottom)
    return create("UIPadding", {
        PaddingLeft = UDim.new(0, left or 0),
        PaddingTop = UDim.new(0, top or 0),
        PaddingRight = UDim.new(0, right or 0),
        PaddingBottom = UDim.new(0, bottom or 0),
        Parent = parent,
    })
end

local function listLayout(parent, padding)
    return create("UIListLayout", {
        Padding = UDim.new(0, padding or 0),
        SortOrder = ByOrder,
        Parent = parent,
    })
end

local function tween(inst, time, props, style, direction)
    local info = TweenInfo.new(time, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out)
    local playing = TweenService:Create(inst, info, props)
    playing:Play()
    return playing
end

local function apply(inst, animate, time, props)
    if animate then
        tween(inst, time or 0.18, props)
    else
        for key, value in pairs(props) do
            inst[key] = value
        end
    end
end

local function norm(o, key)
    if type(o) == "table" then
        return o
    end
    return { [key or "Name"] = o }
end

local function imageId(value)
    if value == nil then
        return DEFAULT_LOGO
    end
    if type(value) == "number" then
        return "rbxassetid://" .. tostring(value)
    end
    value = tostring(value)
    if value:match("^%d+$") then
        return "rbxassetid://" .. value
    end
    return value
end

local function resolveDecal(source)
    if type(source) ~= "string" or not source:find("^rbxassetid://") then
        return nil
    end
    local id = source:match("%d+")
    if not id then
        return nil
    end
    local ok, result = pcall(function()
        local objects = game:GetObjects("rbxassetid://" .. id)
        local item = objects and objects[1]
        if item and (item:IsA("Decal") or item:IsA("Texture")) then
            return item.Texture
        end
        return nil
    end)
    if ok and type(result) == "string" and result ~= "" then
        return result
    end
    return nil
end

local function mount(gui)
    if syn and syn.protect_gui then
        pcall(syn.protect_gui, gui)
    end
    local targets = {}
    if gethui then
        table.insert(targets, function()
            return gethui()
        end)
    end
    table.insert(targets, function()
        return CoreGui
    end)
    table.insert(targets, function()
        return LocalPlayer:WaitForChild("PlayerGui")
    end)
    for _, getTarget in ipairs(targets) do
        local ok = pcall(function()
            gui.Parent = getTarget()
        end)
        if ok and gui.Parent then
            return
        end
    end
end

local function toScreen(input)
    local inset = GuiService:GetGuiInset()
    return Vector2.new(input.Position.X + inset.X, input.Position.Y + inset.Y)
end

local function isPress(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch
end

local function isMove(input)
    return input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
end

local function makeDrag(hub, area, callback)
    local dragging = false
    area.InputBegan:Connect(function(input)
        if isPress(input) then
            dragging = true
            callback(toScreen(input), true)
        end
    end)
    hub:_track(UserInputService.InputChanged:Connect(function(input)
        if dragging and isMove(input) then
            callback(toScreen(input), false)
        end
    end))
    hub:_track(UserInputService.InputEnded:Connect(function(input)
        if dragging and isPress(input) then
            dragging = false
        end
    end))
end

local function encodeValue(value)
    local kind = typeof(value)
    if kind == "Color3" then
        return { __t = "Color3", v = value:ToHex() }
    elseif kind == "EnumItem" then
        return { __t = "KeyCode", v = value.Name }
    elseif kind == "boolean" or kind == "number" or kind == "string" or kind == "table" then
        return value
    end
    return nil
end

local function decodeValue(raw)
    if type(raw) == "table" and raw.__t == "Color3" then
        return Color3.fromHex(raw.v)
    elseif type(raw) == "table" and raw.__t == "KeyCode" then
        return Enum.KeyCode[raw.v]
    end
    return raw
end

local function resolveKey(value)
    if typeof(value) == "EnumItem" then
        return value
    end
    if type(value) == "string" then
        local ok, key = pcall(function()
            return Enum.KeyCode[value]
        end)
        if ok and key then
            return key
        end
    end
    return Enum.KeyCode.Unknown
end

local function ensureFolders()
    if not hasFS then
        return false
    end
    pcall(function()
        if not isfolder(ROOT_FOLDER) then
            makefolder(ROOT_FOLDER)
        end
        if not isfolder(CONFIG_FOLDER) then
            makefolder(CONFIG_FOLDER)
        end
    end)
    return true
end

local function sanitize(name)
    local cleaned = tostring(name or ""):gsub("[^%w_ %-]", "")
    cleaned = cleaned:gsub("^%s+", ""):gsub("%s+$", "")
    return cleaned
end

function Library.new(config)
    config = config or {}
    local genv = getgenv and getgenv() or _G
    local previous = genv.__HumidityHub
    if previous and type(previous.Destroy) == "function" then
        pcall(function()
            previous:Destroy()
        end)
    end

    local theme = {}
    for key, value in pairs(DefaultTheme) do
        theme[key] = value
    end
    if type(config.Theme) == "table" then
        for key, value in pairs(config.Theme) do
            theme[key] = value
        end
    end
    local accent = config.Accent
    if type(accent) == "string" then
        accent = Library.Presets[accent]
    end
    if typeof(accent) == "Color3" then
        theme.Accent = accent
    end

    local mobile = config.MobileButton
    if mobile == nil then
        mobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    end

    local self = setmetatable({
        HubName = config.HubName or "Humidity Hub",
        GameName = config.GameName or "Universal",
        Size = typeof(config.Size) == "Vector2" and config.Size or Vector2.new(640, 420),
        Theme = theme,
        Flags = {},
        ToggleKey = config.ToggleKey or Enum.KeyCode.RightShift,
        Visible = false,
        LogoSource = imageId(config.LogoId),
        MobileButton = mobile and true or false,
        Settings = {
            Backdrop = true,
            DimAmount = 0.45,
            Blur = false,
            Watermark = false,
            Notifications = true,
            Scale = config.Scale or 1,
        },
        _setters = {},
        _conns = {},
        _binds = {},
        _tabs = {},
        _keybinds = {},
        _logos = {},
        _token = 0,
        _notifyOrder = 0,
        _remember = false,
    }, Library)

    self:_build()
    self:_bindInput()
    if config.Settings ~= false then
        self:_buildSettings()
    end
    genv.__HumidityHub = self
    return self
end

function Library:_track(connection)
    table.insert(self._conns, connection)
    return connection
end

function Library:_bindAccent(callback)
    table.insert(self._binds, callback)
    callback(self.Theme.Accent)
end

function Library:_fire(callback, ...)
    if type(callback) ~= "function" then
        return
    end
    task.spawn(function(...)
        local ok, err = pcall(callback, ...)
        if not ok then
            warn("[Humidity Hub] " .. tostring(err))
        end
    end, ...)
end

function Library:_register(flag, value, setter)
    if not flag then
        return
    end
    self.Flags[flag] = value
    self._setters[flag] = setter
end

function Library:_regLogo(image)
    table.insert(self._logos, image)
    image.Image = self._resolvedLogo or self.LogoSource
end

function Library:SetLogo(source)
    self.LogoSource = imageId(source)
    self._resolvedLogo = nil
    for _, image in ipairs(self._logos) do
        image.Image = self.LogoSource
    end
    local current = self.LogoSource
    task.spawn(function()
        local resolved = resolveDecal(current)
        if resolved and not self._destroyed and self.LogoSource == current then
            self._resolvedLogo = resolved
            for _, image in ipairs(self._logos) do
                image.Image = resolved
            end
        end
    end)
end

function Library:_build()
    local theme = self.Theme

    local gui = create("ScreenGui", {
        Name = "HumidityHub",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999,
    })
    mount(gui)
    self.Gui = gui

    self.Blur = create("BlurEffect", { Name = "HumidityBlur", Size = 0, Parent = Lighting })

    self.Backdrop = create("Frame", {
        Name = "Backdrop",
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Visible = false,
        ZIndex = 0,
        Parent = gui,
    })

    self.Holder = create("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(self.Size.X, self.Size.Y),
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 2,
        Parent = gui,
    })
    self.UserScale = create("UIScale", { Scale = 1, Parent = self.Holder })

    self.Shadow = create("ImageLabel", {
        Name = "Shadow",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 70, 1, 70),
        Image = SHADOW_IMAGE,
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 1,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = 0,
        Parent = self.Holder,
    })

    self.Main = create("CanvasGroup", {
        Name = "Main",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        GroupTransparency = 1,
        ZIndex = 1,
        Parent = self.Holder,
    })
    corner(self.Main, 14)
    stroke(self.Main, theme.Stroke, 1, 0.3)
    self.AnimScale = create("UIScale", { Scale = 0.92, Parent = self.Main })

    local sidebar = create("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = theme.Sidebar,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 172, 1, 0),
        Parent = self.Main,
    })
    create("Frame", {
        Name = "Divider",
        BackgroundColor3 = theme.Stroke,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.fromScale(1, 0),
        Size = UDim2.new(0, 1, 1, 0),
        Parent = sidebar,
    })

    local brand = create("Frame", {
        Name = "Brand",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 66),
        Parent = sidebar,
    })
    local logo = create("ImageLabel", {
        Name = "Logo",
        BackgroundColor3 = theme.Element,
        Position = UDim2.fromOffset(14, 16),
        Size = UDim2.fromOffset(36, 36),
        ScaleType = Enum.ScaleType.Crop,
        Parent = brand,
    })
    corner(logo, 10)
    self:_regLogo(logo)
    create("TextLabel", {
        Name = "HubName",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(58, 17),
        Size = UDim2.new(1, -66, 0, 18),
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = theme.Text,
        TextXAlignment = Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = self.HubName,
        Parent = brand,
    })
    create("TextLabel", {
        Name = "GameName",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(58, 36),
        Size = UDim2.new(1, -66, 0, 14),
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = theme.SubText,
        TextXAlignment = Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = self.GameName,
        Parent = brand,
    })

    self.TabList = create("ScrollingFrame", {
        Name = "Tabs",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 66),
        Size = UDim2.new(1, 0, 1, -128),
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = sidebar,
    })
    pad(self.TabList, 8, 4, 8, 4)
    listLayout(self.TabList, 4)

    local profile = create("Frame", {
        Name = "Profile",
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, -8),
        Size = UDim2.new(1, -16, 0, 46),
        BackgroundColor3 = theme.Element,
        BorderSizePixel = 0,
        Parent = sidebar,
    })
    corner(profile, 10)
    stroke(profile, theme.Stroke, 1, 0.5)
    local avatar = create("ImageLabel", {
        Name = "Avatar",
        BackgroundColor3 = theme.ElementHover,
        Position = UDim2.fromOffset(8, 8),
        Size = UDim2.fromOffset(30, 30),
        Parent = profile,
    })
    corner(avatar, 15)
    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(46, 7),
        Size = UDim2.new(1, -54, 0, 16),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = theme.Text,
        TextXAlignment = Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = LocalPlayer.DisplayName,
        Parent = profile,
    })
    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(46, 24),
        Size = UDim2.new(1, -54, 0, 14),
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = theme.SubText,
        TextXAlignment = Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = "@" .. LocalPlayer.Name,
        Parent = profile,
    })
    task.spawn(function()
        local ok, image = pcall(function()
            return Players:GetUserThumbnailAsync(
                LocalPlayer.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size100x100
            )
        end)
        if ok and avatar.Parent then
            avatar.Image = image
        end
    end)

    local content = create("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(172, 0),
        Size = UDim2.new(1, -172, 1, 0),
        Parent = self.Main,
    })

    local topbar = create("Frame", {
        Name = "Topbar",
        BackgroundColor3 = theme.Topbar,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 46),
        Parent = content,
    })
    create("Frame", {
        BackgroundColor3 = theme.Stroke,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.new(1, 0, 0, 1),
        Parent = topbar,
    })
    self.TitleLabel = create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(18, 0),
        Size = UDim2.new(0, 190, 1, 0),
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = theme.Text,
        TextXAlignment = Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = "",
        Parent = topbar,
    })

    self.Search = create("TextBox", {
        Name = "Search",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -80, 0.5, 0),
        Size = UDim2.fromOffset(150, 28),
        BackgroundColor3 = theme.Element,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = theme.Text,
        PlaceholderText = "Search...",
        PlaceholderColor3 = theme.SubText,
        TextXAlignment = Left,
        Text = "",
        Parent = topbar,
    })
    corner(self.Search, 8)
    pad(self.Search, 10, 0, 10, 0)
    local searchStroke = stroke(self.Search, theme.Stroke, 1, 0.4)
    self.Search.Focused:Connect(function()
        tween(searchStroke, 0.2, { Color = self.Theme.Accent, Transparency = 0 })
    end)
    self.Search.FocusLost:Connect(function()
        tween(searchStroke, 0.2, { Color = theme.Stroke, Transparency = 0.4 })
    end)
    self.Search:GetPropertyChangedSignal("Text"):Connect(function()
        if self.CurrentTab then
            self.CurrentTab:_filter(self.Search.Text)
        end
    end)

    local function topButton(name, text, size, position, hoverColor)
        local button = create("TextButton", {
            Name = name,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = position,
            Size = UDim2.fromOffset(28, 28),
            BackgroundColor3 = hoverColor,
            BackgroundTransparency = 1,
            AutoButtonColor = false,
            Font = Enum.Font.GothamBold,
            TextSize = size,
            TextColor3 = theme.SubText,
            Text = text,
            Parent = topbar,
        })
        corner(button, 8)
        button.MouseEnter:Connect(function()
            tween(button, 0.15, { BackgroundTransparency = 0.15, TextColor3 = theme.Text })
        end)
        button.MouseLeave:Connect(function()
            tween(button, 0.15, { BackgroundTransparency = 1, TextColor3 = theme.SubText })
        end)
        return button
    end

    local closeButton = topButton("Close", "×", 20, UDim2.new(1, -12, 0.5, 0), theme.Error)
    local minimizeButton = topButton("Minimize", "–", 18, UDim2.new(1, -46, 0.5, 0), theme.ElementHover)

    minimizeButton.MouseButton1Click:Connect(function()
        self:SetVisible(false)
        self:Notify({
            Title = self.HubName,
            Content = "Hidden. Press " .. self.ToggleKey.Name .. " to open it again.",
            Duration = 3,
        })
    end)
    closeButton.MouseButton1Click:Connect(function()
        self:Dialog({
            Title = "Unload " .. self.HubName .. "?",
            Content = "This removes the interface until you execute the script again.",
            Buttons = {
                { Text = "Cancel" },
                {
                    Text = "Unload",
                    Primary = true,
                    Callback = function()
                        self:SetVisible(false)
                        task.delay(0.4, function()
                            self:Destroy()
                        end)
                    end,
                },
            },
        })
    end)

    self.Pages = create("Frame", {
        Name = "Pages",
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Position = UDim2.fromOffset(0, 46),
        Size = UDim2.new(1, 0, 1, -46),
        Parent = content,
    })

    local dragging = false
    local dragStart, startPosition
    local function beginDrag(input)
        if isPress(input) then
            dragging = true
            dragStart = input.Position
            startPosition = self.Holder.Position
        end
    end
    topbar.InputBegan:Connect(beginDrag)
    brand.InputBegan:Connect(beginDrag)
    self:_track(UserInputService.InputChanged:Connect(function(input)
        if dragging and isMove(input) then
            local delta = input.Position - dragStart
            self.Holder.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end))
    self:_track(UserInputService.InputEnded:Connect(function(input)
        if dragging and isPress(input) then
            dragging = false
        end
    end))

    self.NotifyHolder = create("Frame", {
        Name = "Notifications",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -14, 1, -14),
        Size = UDim2.new(0, 300, 1, -28),
        BackgroundTransparency = 1,
        ZIndex = 40,
        Parent = gui,
    })
    create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = ByOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Parent = self.NotifyHolder,
    })

    self.WatermarkFrame = create("Frame", {
        Name = "Watermark",
        Position = UDim2.fromOffset(12, 12),
        Size = UDim2.fromOffset(0, 0),
        AutomaticSize = AutoXY,
        BackgroundColor3 = theme.Background,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 30,
        Parent = gui,
    })
    corner(self.WatermarkFrame, 8)
    stroke(self.WatermarkFrame, theme.Stroke, 1, 0.3)
    pad(self.WatermarkFrame, 12, 7, 12, 7)
    self.WatermarkLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(0, 16),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = theme.Text,
        Text = self.HubName,
        Parent = self.WatermarkFrame,
    })
    local frames, elapsed = 0, 0
    self:_track(RunService.Heartbeat:Connect(function(dt)
        if not self.Settings.Watermark then
            return
        end
        frames += 1
        elapsed += dt
        if elapsed >= 0.5 then
            local fps = math.floor(frames / elapsed + 0.5)
            local ping = 0
            pcall(function()
                ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5)
            end)
            self.WatermarkLabel.Text = string.format("%s  |  %d FPS  |  %d ms", self.HubName, fps, ping)
            frames, elapsed = 0, 0
        end
    end))

    if self.MobileButton then
        self.ToggleButton = create("TextButton", {
            Name = "MobileToggle",
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -14, 0.5, 0),
            Size = UDim2.fromOffset(46, 46),
            BackgroundColor3 = theme.Background,
            AutoButtonColor = false,
            Text = "",
            ZIndex = 35,
            Parent = gui,
        })
        corner(self.ToggleButton, 23)
        stroke(self.ToggleButton, theme.Stroke, 1, 0.2)
        local icon = create("ImageLabel", {
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(30, 30),
            ScaleType = Enum.ScaleType.Crop,
            Parent = self.ToggleButton,
        })
        corner(icon, 15)
        self:_regLogo(icon)
        self.ToggleButton.MouseButton1Click:Connect(function()
            self:Toggle()
        end)
    end

    local camera = workspace.CurrentCamera
    if camera then
        self:_track(camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            self:_updateScale()
        end))
    end
    self:_updateScale()
    self:SetLogo(self.LogoSource)
end

function Library:_bindInput()
    self:_track(UserInputService.InputBegan:Connect(function(input, processed)
        if self._listening or processed then
            return
        end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then
            return
        end
        if self._ready and input.KeyCode == self.ToggleKey then
            self:Toggle()
            return
        end
        for _, keybind in ipairs(self._keybinds) do
            if keybind.Value ~= Enum.KeyCode.Unknown and keybind.Value == input.KeyCode then
                self:_fire(keybind.OnPress)
            end
        end
    end))
end

function Library:_updateScale()
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
    local fit = math.min((viewport.X - 20) / self.Size.X, (viewport.Y - 20) / self.Size.Y)
    self.UserScale.Scale = math.min(self.Settings.Scale, fit)
end

function Library:_applyBackdrop()
    local active = self.Visible or self._keyActive
    local target = 1
    if active and self.Settings.Backdrop then
        target = 1 - self.Settings.DimAmount
    end
    if active then
        self.Backdrop.Visible = true
    end
    tween(self.Backdrop, 0.35, { BackgroundTransparency = target }, Enum.EasingStyle.Quad)
end

function Library:_applyBlur()
    local active = self.Visible or self._keyActive
    local target = (active and self.Settings.Blur) and 18 or 0
    tween(self.Blur, 0.35, { Size = target }, Enum.EasingStyle.Quad)
end

function Library:SetVisible(state)
    state = state and true or false
    self.Visible = state
    self._token += 1
    local token = self._token
    if state then
        self.Holder.Visible = true
        self.AnimScale.Scale = 0.92
        tween(self.Main, 0.35, { GroupTransparency = 0 })
        tween(self.AnimScale, 0.45, { Scale = 1 }, Enum.EasingStyle.Back)
        tween(self.Shadow, 0.35, { ImageTransparency = 0.55 })
    else
        tween(self.Main, 0.25, { GroupTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tween(self.AnimScale, 0.25, { Scale = 0.94 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tween(self.Shadow, 0.25, { ImageTransparency = 1 })
        task.delay(0.3, function()
            if self._token == token and not self.Visible and not self._destroyed then
                self.Holder.Visible = false
                if not self._keyActive then
                    self.Backdrop.Visible = false
                end
            end
        end)
    end
    self:_applyBackdrop()
    self:_applyBlur()
end

function Library:Toggle()
    if not self._ready then
        return
    end
    self:SetVisible(not self.Visible)
end

function Library:SetBackdrop(enabled, amount)
    if enabled ~= nil then
        self.Settings.Backdrop = enabled and true or false
    end
    if amount ~= nil then
        self.Settings.DimAmount = math.clamp(amount, 0, 1)
    end
    self:_applyBackdrop()
end

function Library:SetBlur(state)
    self.Settings.Blur = state and true or false
    self:_applyBlur()
end

function Library:SetScale(scale)
    self.Settings.Scale = math.clamp(scale, 0.5, 1.5)
    self:_updateScale()
end

function Library:SetWatermark(state)
    self.Settings.Watermark = state and true or false
    self.WatermarkFrame.Visible = self.Settings.Watermark
end

function Library:SetNotifications(state)
    self.Settings.Notifications = state and true or false
end

function Library:SetToggleKey(key)
    key = resolveKey(key)
    if key == Enum.KeyCode.Unknown then
        return
    end
    self.ToggleKey = key
    if self._toggleKeybind then
        self._toggleKeybind:Set(key, true)
    end
end

function Library:SetAccent(color, fromPicker)
    if type(color) == "string" then
        color = Library.Presets[color]
    end
    if typeof(color) ~= "Color3" then
        return
    end
    self.Theme.Accent = color
    self.Flags.HH_Accent = color
    for _, callback in ipairs(self._binds) do
        callback(color)
    end
    if self._accentPicker and not fromPicker then
        self._accentPicker:Set(color, true)
    end
end

function Library:GetFlag(flag)
    return self.Flags[flag]
end

function Library:AddTab(a, b)
    local opts = type(a) == "table" and a or { Name = a, Icon = b }
    local theme = self.Theme
    local id = #self._tabs + 1
    local tab = setmetatable({
        Hub = self,
        Name = tostring(opts.Name or "Tab"),
        Sections = {},
        Order = opts.Order or id,
        _id = id,
        _n = 0,
    }, Tab)

    tab.Button = create("TextButton", {
        Name = tab.Name,
        AutoButtonColor = false,
        Text = "",
        BackgroundColor3 = theme.ElementHover,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 34),
        LayoutOrder = tab.Order,
        Parent = self.TabList,
    })
    corner(tab.Button, 8)

    local textX = 14
    if opts.Icon then
        tab.IconLabel = create("ImageLabel", {
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 12, 0.5, 0),
            Size = UDim2.fromOffset(18, 18),
            Image = imageId(opts.Icon),
            ImageColor3 = theme.SubText,
            Parent = tab.Button,
        })
        textX = 38
    end
    tab.Label = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(textX, 0),
        Size = UDim2.new(1, -textX - 6, 1, 0),
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = theme.SubText,
        TextXAlignment = Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = tab.Name,
        Parent = tab.Button,
    })
    tab.Indicator = create("Frame", {
        Name = "Indicator",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(3, 0),
        BorderSizePixel = 0,
        Parent = tab.Button,
    })
    corner(tab.Indicator, 2)
    self:_bindAccent(function(color)
        tab.Indicator.BackgroundColor3 = color
    end)

    tab.Page = create("CanvasGroup", {
        Name = tab.Name .. "Page",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Visible = false,
        Parent = self.Pages,
    })
    tab.Scroll = create("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.fromRGB(70, 70, 85),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = AutoY,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Parent = tab.Page,
    })
    pad(tab.Scroll, 12, 12, 12, 12)
    listLayout(tab.Scroll, 12)

    tab.Button.MouseEnter:Connect(function()
        if self.CurrentTab ~= tab then
            tween(tab.Button, 0.15, { BackgroundTransparency = 0.6 })
        end
    end)
    tab.Button.MouseLeave:Connect(function()
        if self.CurrentTab ~= tab then
            tween(tab.Button, 0.15, { BackgroundTransparency = 1 })
        end
    end)
    tab.Button.MouseButton1Click:Connect(function()
        self:_selectTab(tab)
    end)

    table.insert(self._tabs, tab)
    return tab
end

function Library:_selectTab(tab)
    if self.CurrentTab == tab then
        return
    end
    local old = self.CurrentTab
    if old then
        old:_filter("")
        old:_setActive(false)
    end
    self.CurrentTab = tab
    tab:_setActive(true)
    self.TitleLabel.Text = tab.Name
    self.Search.Text = ""
end

function Tab:_setActive(active)
    local theme = self.Hub.Theme
    tween(self.Button, 0.2, { BackgroundTransparency = active and 0.2 or 1 })
    tween(self.Label, 0.2, { TextColor3 = active and theme.Text or theme.SubText })
    if self.IconLabel then
        tween(self.IconLabel, 0.2, { ImageColor3 = active and theme.Accent or theme.SubText })
    end
    tween(self.Indicator, 0.3, { Size = UDim2.fromOffset(3, active and 16 or 0) }, Enum.EasingStyle.Back)
    if active then
        self.Page.Position = UDim2.fromOffset(0, 14)
        self.Page.GroupTransparency = 1
        self.Page.Visible = true
        tween(self.Page, 0.3, { Position = UDim2.fromOffset(0, 0), GroupTransparency = 0 })
    else
        self.Page.Visible = false
    end
end

function Tab:_filter(query)
    query = string.lower(query or "")
    for _, section in ipairs(self.Sections) do
        local any = query == ""
        local sectionMatch = section.Name ~= nil and section.Name:lower():find(query, 1, true) ~= nil
        for _, element in ipairs(section.Elements) do
            local match = query == "" or sectionMatch or element.Name:lower():find(query, 1, true) ~= nil
            element.Frame.Visible = match
            if match then
                any = true
            end
        end
        section.Frame.Visible = any
    end
end

function Tab:AddSection(name)
    local hub = self.Hub
    self._n += 1
    local section = setmetatable({
        Hub = hub,
        Tab = self,
        Name = name,
        Elements = {},
        _n = 0,
    }, Section)
    section.Frame = create("Frame", {
        Name = "Section",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = AutoY,
        LayoutOrder = self._n,
        Parent = self.Scroll,
    })
    listLayout(section.Frame, 6)
    if name then
        local header = create("TextLabel", {
            Name = "Header",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextColor3 = hub.Theme.SubText,
            TextXAlignment = Left,
            Text = string.upper(name),
            LayoutOrder = 0,
            Parent = section.Frame,
        })
        pad(header, 4, 0, 0, 0)
    end
    table.insert(self.Sections, section)
    return section
end

function Section:_next()
    self._n += 1
    return self._n
end

function Section:_base(name, desc, height, reserve)
    local hub = self.Hub
    local theme = hub.Theme
    height = height or 38

    local element = create("Frame", {
        Name = "Element",
        BackgroundColor3 = theme.Element,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = AutoY,
        ClipsDescendants = true,
        LayoutOrder = self:_next(),
        Parent = self.Frame,
    })
    corner(element, 8)
    stroke(element, theme.Stroke, 1, 0.5)
    listLayout(element, 0)

    local header = create("Frame", {
        Name = "Header",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, height),
        AutomaticSize = AutoY,
        LayoutOrder = 1,
        Parent = element,
    })
    local hit = create("TextButton", {
        Name = "Hit",
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Size = UDim2.fromScale(1, 1),
        Parent = header,
    })
    local info = create("Frame", {
        Name = "Info",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -(reserve or 0), 0, 0),
        AutomaticSize = AutoY,
        Parent = header,
    })
    pad(info, 12, 10, 0, 10)
    listLayout(info, 2)
    local title = create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = AutoY,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = theme.Text,
        TextXAlignment = Left,
        TextWrapped = true,
        Text = tostring(name or ""),
        LayoutOrder = 1,
        Parent = info,
    })
    local description
    if desc and desc ~= "" then
        description = create("TextLabel", {
            Name = "Description",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = AutoY,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextColor3 = theme.SubText,
            TextXAlignment = Left,
            TextWrapped = true,
            Text = tostring(desc),
            LayoutOrder = 2,
            Parent = info,
        })
    end

    hit.MouseEnter:Connect(function()
        tween(element, 0.15, { BackgroundColor3 = theme.ElementHover })
    end)
    hit.MouseLeave:Connect(function()
        tween(element, 0.15, { BackgroundColor3 = theme.Element })
    end)

    if name then
        table.insert(self.Elements, { Frame = element, Name = tostring(name) })
    end

    return {
        Frame = element,
        Header = header,
        Info = info,
        Title = title,
        Description = description,
        Hit = hit,
    }
end

local function attach(obj, base)
    obj.Frame = base.Frame
    function obj:SetName(text)
        base.Title.Text = tostring(text)
    end
    function obj:SetVisible(state)
        base.Frame.Visible = state and true or false
    end
    function obj:Destroy()
        base.Frame:Destroy()
    end
    return obj
end

function Section:AddLabel(o)
    o = norm(o, "Name")
    local base = self:_base(o.Name or o.Text, o.Description, 30)
    return attach({ Type = "Label" }, base)
end

function Section:AddParagraph(o)
    o = norm(o, "Content")
    local base = self:_base(o.Title or o.Name, o.Content or o.Description, 38)
    local obj = attach({ Type = "Paragraph" }, base)
    function obj:SetContent(text)
        if base.Description then
            base.Description.Text = tostring(text)
        end
    end
    if base.Description then
        base.Description.TextSize = 12
    end
    return obj
end

function Section:AddDivider()
    local frame = create("Frame", {
        Name = "Divider",
        BackgroundColor3 = self.Hub.Theme.Stroke,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 1),
        LayoutOrder = self:_next(),
        Parent = self.Frame,
    })
    return { Frame = frame, Type = "Divider" }
end

function Section:AddButton(o)
    o = norm(o, "Name")
    local hub = self.Hub
    local theme = hub.Theme
    local base = self:_base(o.Name or o.Text, o.Description, 38, 112)
    local chip = create("TextButton", {
        Name = "Chip",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(90, 24),
        AutoButtonColor = false,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Color3.new(1, 1, 1),
        Text = o.ButtonText or "Run",
        Parent = base.Header,
    })
    corner(chip, 6)
    hub:_bindAccent(function(color)
        chip.BackgroundColor3 = color
    end)

    local function click()
        tween(chip, 0.07, { Size = UDim2.fromOffset(84, 22) })
        task.delay(0.07, function()
            tween(chip, 0.25, { Size = UDim2.fromOffset(90, 24) }, Enum.EasingStyle.Back)
        end)
        hub:_fire(o.Callback)
    end
    base.Hit.MouseButton1Click:Connect(click)
    chip.MouseButton1Click:Connect(click)

    local obj = attach({ Type = "Button" }, base)
    function obj:Fire()
        click()
    end
    function obj:SetButtonText(text)
        chip.Text = tostring(text)
    end
    return obj
end

function Section:AddToggle(o)
    o = norm(o, "Name")
    local hub = self.Hub
    local theme = hub.Theme
    local state = o.Default and true or false
    local base = self:_base(o.Name or o.Text, o.Description, 38, 64)

    local track = create("Frame", {
        Name = "Track",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(38, 20),
        BackgroundColor3 = theme.ToggleOff,
        BorderSizePixel = 0,
        Parent = base.Header,
    })
    corner(track, 10)
    local knob = create("Frame", {
        Name = "Knob",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 3, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = track,
    })
    corner(knob, 7)

    local obj = attach({ Type = "Toggle" }, base)

    local function render(animate)
        apply(track, animate, 0.2, { BackgroundColor3 = state and hub.Theme.Accent or theme.ToggleOff })
        apply(knob, animate, 0.25, {
            Position = state and UDim2.new(0, 21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        })
    end

    function obj:Set(value, silent)
        state = value and true or false
        render(true)
        if o.Flag then
            hub.Flags[o.Flag] = state
        end
        if not silent then
            hub:_fire(o.Callback, state)
        end
    end
    function obj:Get()
        return state
    end

    hub:_bindAccent(function()
        render(false)
    end)
    hub:_register(o.Flag, state, function(value, silent)
        obj:Set(value, silent)
    end)
    base.Hit.MouseButton1Click:Connect(function()
        obj:Set(not state)
    end)
    return obj
end

function Section:AddSlider(o)
    o = norm(o, "Name")
    local hub = self.Hub
    local theme = hub.Theme
    local min = o.Min or 0
    local max = o.Max or 100
    local increment = o.Increment or o.Step or 1
    local suffix = o.Suffix or ""
    local decimals = 0
    local fraction = tostring(increment):match("%.(%d+)")
    if fraction then
        decimals = #fraction
    end

    local base = self:_base(o.Name or o.Text, o.Description, 54, 84)
    local box = create("TextBox", {
        Name = "Value",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -12, 0, 9),
        Size = UDim2.fromOffset(64, 22),
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = theme.Text,
        Text = "",
        Parent = base.Header,
    })
    corner(box, 6)
    stroke(box, theme.Stroke, 1, 0.4)

    local track = create("Frame", {
        Name = "Track",
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 12, 1, -13),
        Size = UDim2.new(1, -24, 0, 6),
        BackgroundColor3 = theme.Stroke,
        BorderSizePixel = 0,
        Parent = base.Header,
    })
    corner(track, 3)
    local fill = create("Frame", {
        Name = "Fill",
        Size = UDim2.fromScale(0, 1),
        BorderSizePixel = 0,
        Parent = track,
    })
    corner(fill, 3)
    local knob = create("Frame", {
        Name = "Knob",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(1, 0.5),
        Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = fill,
    })
    corner(knob, 7)
    local area = create("TextButton", {
        Name = "Area",
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.fromScale(0, 0.5),
        Size = UDim2.new(1, 0, 0, 26),
        Parent = track,
    })

    hub:_bindAccent(function(color)
        fill.BackgroundColor3 = color
    end)

    local function format(number)
        return string.format("%." .. decimals .. "f", number)
    end
    local function snap(number)
        number = math.clamp(number, min, max)
        number = min + math.floor((number - min) / increment + 0.5) * increment
        number = math.clamp(number, min, max)
        return tonumber(format(number))
    end

    local value = snap(o.Default or min)
    local obj = attach({ Type = "Slider" }, base)

    local function render(animate)
        local alpha = max == min and 0 or (value - min) / (max - min)
        apply(fill, animate, 0.12, { Size = UDim2.fromScale(alpha, 1) })
        box.Text = format(value) .. suffix
    end

    local function commit(newValue, silent, animate)
        local changed = newValue ~= value
        value = newValue
        render(animate)
        if o.Flag then
            hub.Flags[o.Flag] = value
        end
        if not silent and changed then
            hub:_fire(o.Callback, value)
        end
    end

    function obj:Set(newValue, silent)
        if type(newValue) ~= "number" then
            return
        end
        local snapped = snap(newValue)
        if silent then
            value = snapped
            render(true)
            if o.Flag then
                hub.Flags[o.Flag] = value
            end
        else
            local changed = snapped ~= value
            value = snapped
            render(true)
            if o.Flag then
                hub.Flags[o.Flag] = value
            end
            if changed then
                hub:_fire(o.Callback, value)
            end
        end
    end
    function obj:Get()
        return value
    end

    makeDrag(hub, area, function(position)
        local alpha = math.clamp((position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        commit(snap(min + alpha * (max - min)), false, false)
    end)
    box.FocusLost:Connect(function()
        local parsed = tonumber(box.Text:match("%-?%d+%.?%d*"))
        if parsed then
            obj:Set(parsed)
        else
            render(false)
        end
    end)

    render(false)
    hub:_register(o.Flag, value, function(newValue, silent)
        obj:Set(newValue, silent)
    end)
    return obj
end

function Section:AddTextbox(o)
    o = norm(o, "Name")
    local hub = self.Hub
    local theme = hub.Theme
    local base = self:_base(o.Name or o.Text, o.Description, 38, 170)
    local box = create("TextBox", {
        Name = "Input",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(150, 24),
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        ClearTextOnFocus = o.ClearOnFocus == true,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = theme.Text,
        PlaceholderText = o.Placeholder or "Type here...",
        PlaceholderColor3 = theme.SubText,
        Text = o.Default and tostring(o.Default) or "",
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = base.Header,
    })
    corner(box, 6)
    pad(box, 8, 0, 8, 0)
    local boxStroke = stroke(box, theme.Stroke, 1, 0.4)
    box.Focused:Connect(function()
        tween(boxStroke, 0.2, { Color = hub.Theme.Accent, Transparency = 0 })
    end)

    local obj = attach({ Type = "Textbox" }, base)
    function obj:Set(text, silent)
        box.Text = tostring(text)
        if o.Flag then
            hub.Flags[o.Flag] = box.Text
        end
        if not silent then
            hub:_fire(o.Callback, box.Text)
        end
    end
    function obj:Get()
        return box.Text
    end

    if o.Numeric then
        box:GetPropertyChangedSignal("Text"):Connect(function()
            local filtered = box.Text:gsub("[^%d%.%-]", "")
            if filtered ~= box.Text then
                box.Text = filtered
            end
        end)
    end
    box.FocusLost:Connect(function()
        tween(boxStroke, 0.2, { Color = theme.Stroke, Transparency = 0.4 })
        if o.Flag then
            hub.Flags[o.Flag] = box.Text
        end
        hub:_fire(o.Callback, box.Text)
    end)

    hub:_register(o.Flag, box.Text, function(text, silent)
        obj:Set(text, silent)
    end)
    return obj
end

function Section:AddDropdown(o)
    o = norm(o, "Name")
    local hub = self.Hub
    local theme = hub.Theme
    local options = {}
    for _, option in ipairs(o.Options or o.Values or {}) do
        table.insert(options, option)
    end
    local multi = o.Multi == true
    local selected = multi and {} or nil
    local open = false
    local buttons = {}

    local base = self:_base(o.Name or o.Text, o.Description, 38, 210)
    local valueLabel = create("TextLabel", {
        Name = "Value",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -34, 0.5, 0),
        Size = UDim2.fromOffset(150, 18),
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = theme.SubText,
        TextXAlignment = Right,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = "None",
        Parent = base.Header,
    })
    local arrow = create("ImageLabel", {
        Name = "Arrow",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(16, 16),
        Image = ARROW_IMAGE,
        ImageColor3 = theme.SubText,
        Parent = base.Header,
    })
    local body = create("Frame", {
        Name = "Body",
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Size = UDim2.new(1, 0, 0, 0),
        LayoutOrder = 2,
        Parent = base.Frame,
    })
    local list = create("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(8, 0),
        Size = UDim2.new(1, -16, 1, -8),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = theme.Stroke,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = AutoY,
        Parent = body,
    })
    listLayout(list, 2)

    local function currentValue()
        if multi then
            local out = {}
            for _, option in ipairs(options) do
                if selected[option] then
                    table.insert(out, option)
                end
            end
            return out
        end
        return selected
    end

    local function paint()
        local accent = hub.Theme.Accent
        for _, item in ipairs(buttons) do
            local isOn
            if multi then
                isOn = selected[item.option] == true
            else
                isOn = selected == item.option
            end
            tween(item.button, 0.15, {
                BackgroundColor3 = accent,
                BackgroundTransparency = isOn and 0.8 or 1,
                TextColor3 = isOn and accent or theme.Text,
            })
        end
        if multi then
            local chosen = currentValue()
            valueLabel.Text = #chosen > 0 and table.concat(chosen, ", ") or "None"
        else
            valueLabel.Text = selected ~= nil and tostring(selected) or "None"
        end
    end

    local function bodyHeight()
        return math.min(#options, 5) * 28 + 8
    end

    local function setOpen(state)
        open = state
        tween(body, 0.28, { Size = UDim2.new(1, 0, 0, state and bodyHeight() or 0) })
        tween(arrow, 0.28, { Rotation = state and 180 or 0 })
    end

    local function commit(silent)
        local value = currentValue()
        if o.Flag then
            hub.Flags[o.Flag] = value
        end
        if not silent then
            hub:_fire(o.Callback, value)
        end
    end

    local function build()
        for _, item in ipairs(buttons) do
            item.button:Destroy()
        end
        buttons = {}
        for index, option in ipairs(options) do
            local button = create("TextButton", {
                Name = "Option",
                AutoButtonColor = false,
                BackgroundColor3 = hub.Theme.Accent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -4, 0, 26),
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                TextColor3 = theme.Text,
                TextXAlignment = Left,
                Text = tostring(option),
                LayoutOrder = index,
                Parent = list,
            })
            corner(button, 6)
            pad(button, 10, 0, 10, 0)
            button.MouseButton1Click:Connect(function()
                if multi then
                    selected[option] = not selected[option] or nil
                    paint()
                    commit(false)
                else
                    selected = option
                    paint()
                    commit(false)
                    setOpen(false)
                end
            end)
            buttons[index] = { option = option, button = button }
        end
        paint()
    end

    local obj = attach({ Type = "Dropdown" }, base)

    function obj:Set(value, silent)
        if multi then
            selected = {}
            if type(value) == "table" then
                for _, option in ipairs(value) do
                    selected[option] = true
                end
            end
        else
            selected = value
        end
        paint()
        commit(silent)
    end
    function obj:Get()
        return currentValue()
    end
    function obj:Refresh(newOptions, keep)
        options = {}
        for _, option in ipairs(newOptions or {}) do
            table.insert(options, option)
        end
        if keep then
            if multi then
                local kept = {}
                for _, option in ipairs(options) do
                    if selected[option] then
                        kept[option] = true
                    end
                end
                selected = kept
            else
                local found = false
                for _, option in ipairs(options) do
                    if option == selected then
                        found = true
                    end
                end
                if not found then
                    selected = nil
                end
            end
        else
            selected = multi and {} or nil
        end
        build()
        commit(true)
        if open then
            tween(body, 0.2, { Size = UDim2.new(1, 0, 0, bodyHeight()) })
        end
    end
    function obj:SetOpen(state)
        setOpen(state and true or false)
    end

    hub:_bindAccent(function()
        paint()
    end)
    build()
    hub:_register(o.Flag, nil, function(value, silent)
        obj:Set(value, silent)
    end)
    obj:Set(o.Default, true)

    base.Hit.MouseButton1Click:Connect(function()
        setOpen(not open)
    end)
    return obj
end

function Section:AddKeybind(o)
    o = norm(o, "Name")
    local hub = self.Hub
    local theme = hub.Theme
    local value = resolveKey(o.Default)
    local listening = false
    local base = self:_base(o.Name or o.Text, o.Description, 38, 110)

    local chip = create("TextButton", {
        Name = "Chip",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(90, 24),
        BackgroundColor3 = theme.Background,
        AutoButtonColor = false,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = theme.Text,
        Text = "",
        Parent = base.Header,
    })
    corner(chip, 6)
    local chipStroke = stroke(chip, theme.Stroke, 1, 0.4)

    local obj = attach({ Type = "Keybind", OnPress = o.OnPress }, base)

    local function render()
        chip.Text = value == Enum.KeyCode.Unknown and "None" or value.Name
    end

    function obj:Set(key, silent)
        value = resolveKey(key)
        obj.Value = value
        render()
        if o.Flag then
            hub.Flags[o.Flag] = value
        end
        if not silent then
            hub:_fire(o.Callback, value)
        end
    end
    function obj:Get()
        return value
    end
    obj.Value = value

    local function stopListening()
        listening = false
        tween(chipStroke, 0.2, { Color = theme.Stroke, Transparency = 0.4 })
        task.defer(function()
            hub._listening = false
        end)
        render()
    end

    local function startListening()
        listening = true
        hub._listening = true
        chip.Text = "..."
        tween(chipStroke, 0.2, { Color = hub.Theme.Accent, Transparency = 0 })
    end

    chip.MouseButton1Click:Connect(startListening)
    base.Hit.MouseButton1Click:Connect(startListening)

    hub:_track(UserInputService.InputBegan:Connect(function(input)
        if not listening or input.UserInputType ~= Enum.UserInputType.Keyboard then
            return
        end
        if input.KeyCode == Enum.KeyCode.Escape then
            stopListening()
        elseif input.KeyCode == Enum.KeyCode.Backspace then
            stopListening()
            obj:Set(Enum.KeyCode.Unknown)
        else
            stopListening()
            obj:Set(input.KeyCode)
        end
    end))

    render()
    table.insert(hub._keybinds, obj)
    hub:_register(o.Flag, value, function(key, silent)
        obj:Set(key, silent)
    end)
    return obj
end

function Section:AddColorPicker(o)
    o = norm(o, "Name")
    local hub = self.Hub
    local theme = hub.Theme
    local color = typeof(o.Default) == "Color3" and o.Default or Color3.fromRGB(255, 255, 255)
    local hue, sat, val = color:ToHSV()
    local open = false

    local base = self:_base(o.Name or o.Text, o.Description, 38, 70)
    local preview = create("Frame", {
        Name = "Preview",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(38, 20),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Parent = base.Header,
    })
    corner(preview, 6)
    stroke(preview, theme.Stroke, 1, 0.2)

    local body = create("Frame", {
        Name = "Body",
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Size = UDim2.new(1, 0, 0, 0),
        LayoutOrder = 2,
        Parent = base.Frame,
    })

    local svBox = create("Frame", {
        Name = "SV",
        Position = UDim2.fromOffset(10, 4),
        Size = UDim2.new(1, -20, 0, 96),
        BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
        BorderSizePixel = 0,
        Parent = body,
    })
    corner(svBox, 6)
    local white = create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = svBox,
    })
    corner(white, 6)
    create("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1),
        }),
        Parent = white,
    })
    local black = create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0,
        Parent = svBox,
    })
    corner(black, 6)
    create("UIGradient", {
        Rotation = 90,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0),
        }),
        Parent = black,
    })
    local svCursor = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(12, 12),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = svBox,
    })
    corner(svCursor, 6)
    stroke(svCursor, Color3.new(0, 0, 0), 1.5, 0.2)

    local hueBar = create("Frame", {
        Name = "Hue",
        Position = UDim2.fromOffset(10, 108),
        Size = UDim2.new(1, -20, 0, 12),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = body,
    })
    corner(hueBar, 6)
    local keypoints = {}
    for index = 0, 6 do
        table.insert(keypoints, ColorSequenceKeypoint.new(index / 6, Color3.fromHSV(index / 6, 1, 1)))
    end
    create("UIGradient", { Color = ColorSequence.new(keypoints), Parent = hueBar })
    local hueCursor = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(6, 18),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = hueBar,
    })
    corner(hueCursor, 3)
    stroke(hueCursor, Color3.new(0, 0, 0), 1.5, 0.2)

    local hexBox = create("TextBox", {
        Name = "Hex",
        Position = UDim2.fromOffset(10, 130),
        Size = UDim2.new(1, -20, 0, 24),
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = theme.Text,
        Text = "",
        Parent = body,
    })
    corner(hexBox, 6)
    stroke(hexBox, theme.Stroke, 1, 0.4)

    local obj = attach({ Type = "ColorPicker" }, base)

    local function refresh(silent)
        color = Color3.fromHSV(hue, sat, val)
        preview.BackgroundColor3 = color
        svBox.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
        svCursor.Position = UDim2.fromScale(sat, 1 - val)
        hueCursor.Position = UDim2.fromScale(hue, 0.5)
        hexBox.Text = "#" .. color:ToHex()
        if o.Flag then
            hub.Flags[o.Flag] = color
        end
        if not silent then
            hub:_fire(o.Callback, color)
        end
    end

    function obj:Set(newColor, silent)
        if typeof(newColor) ~= "Color3" then
            return
        end
        hue, sat, val = newColor:ToHSV()
        refresh(silent)
    end
    function obj:Get()
        return color
    end

    makeDrag(hub, svBox, function(position)
        sat = math.clamp((position.X - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
        val = 1 - math.clamp((position.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
        refresh(false)
    end)
    makeDrag(hub, hueBar, function(position)
        hue = math.clamp((position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
        refresh(false)
    end)
    hexBox.FocusLost:Connect(function()
        local ok, parsed = pcall(function()
            return Color3.fromHex(hexBox.Text)
        end)
        if ok and parsed then
            obj:Set(parsed)
        else
            hexBox.Text = "#" .. color:ToHex()
        end
    end)
    base.Hit.MouseButton1Click:Connect(function()
        open = not open
        tween(body, 0.3, { Size = UDim2.new(1, 0, 0, open and 164 or 0) })
    end)

    refresh(true)
    hub:_register(o.Flag, color, function(newColor, silent)
        obj:Set(newColor, silent)
    end)
    return obj
end

for _, method in ipairs({
    "AddLabel",
    "AddParagraph",
    "AddDivider",
    "AddButton",
    "AddToggle",
    "AddSlider",
    "AddTextbox",
    "AddDropdown",
    "AddKeybind",
    "AddColorPicker",
}) do
    Tab[method] = function(self, ...)
        if not self._default then
            self._default = self:AddSection(nil)
        end
        return self._default[method](self._default, ...)
    end
end

function Library:Notify(a, b, c)
    if not self.Settings.Notifications or self._destroyed then
        return
    end
    local theme = self.Theme
    local o
    if type(a) == "table" then
        o = a
    else
        o = { Content = tostring(a), Color = b, Duration = c }
    end
    local colors = {
        info = theme.Accent,
        success = theme.Success,
        warning = theme.Warning,
        error = theme.Error,
    }
    local color = o.Color or colors[o.Type or "info"] or theme.Accent
    local duration = o.Duration or 4

    self._notifyOrder += 1
    local wrapper = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = AutoY,
        LayoutOrder = self._notifyOrder,
        Parent = self.NotifyHolder,
    })
    local card = create("CanvasGroup", {
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 30, 0, 0),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = AutoY,
        GroupTransparency = 1,
        Parent = wrapper,
    })
    corner(card, 10)
    stroke(card, theme.Stroke, 1, 0.3)

    local inner = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = AutoY,
        Parent = card,
    })
    pad(inner, 16, 10, 12, 14)
    listLayout(inner, 2)
    create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 16),
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = theme.Text,
        TextXAlignment = Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = tostring(o.Title or self.HubName),
        LayoutOrder = 1,
        Parent = inner,
    })
    create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = AutoY,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = theme.SubText,
        TextXAlignment = Left,
        TextWrapped = true,
        Text = tostring(o.Content or o.Text or ""),
        LayoutOrder = 2,
        Parent = inner,
    })
    local bar = create("Frame", {
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 3, 1, 0),
        Parent = card,
    })
    local progress = create("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = color,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Parent = card,
    })
    bar.ZIndex = 2

    tween(card, 0.4, { Position = UDim2.new(0, 0, 0, 0), GroupTransparency = 0 })
    tween(progress, duration, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)

    local dismissed = false
    local function dismiss()
        if dismissed then
            return
        end
        dismissed = true
        tween(card, 0.3, { Position = UDim2.new(1, 30, 0, 0), GroupTransparency = 1 })
        task.delay(0.3, function()
            if not wrapper.Parent then
                return
            end
            wrapper.AutomaticSize = Enum.AutomaticSize.None
            wrapper.Size = UDim2.new(1, 0, 0, wrapper.AbsoluteSize.Y)
            tween(wrapper, 0.25, { Size = UDim2.new(1, 0, 0, 0) })
            task.delay(0.28, function()
                wrapper:Destroy()
            end)
        end)
    end
    local click = create("TextButton", {
        BackgroundTransparency = 1,
        Text = "",
        Size = UDim2.fromScale(1, 1),
        ZIndex = 5,
        Parent = card,
    })
    click.MouseButton1Click:Connect(dismiss)
    task.delay(duration, dismiss)
end

function Library:Dialog(o)
    o = o or {}
    local theme = self.Theme
    local overlay = create("TextButton", {
        Name = "DialogOverlay",
        AutoButtonColor = false,
        Text = "",
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 50,
        Parent = self.Gui,
    })
    local box = create("CanvasGroup", {
        Name = "Dialog",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0, 330, 0, 0),
        AutomaticSize = AutoY,
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        GroupTransparency = 1,
        ZIndex = 51,
        Parent = self.Gui,
    })
    corner(box, 12)
    stroke(box, theme.Stroke, 1, 0.3)
    local scale = create("UIScale", { Scale = 0.9, Parent = box })
    local inner = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = AutoY,
        Parent = box,
    })
    pad(inner, 18, 18, 18, 16)
    listLayout(inner, 10)
    create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = AutoY,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = theme.Text,
        TextXAlignment = Left,
        TextWrapped = true,
        Text = tostring(o.Title or self.HubName),
        LayoutOrder = 1,
        Parent = inner,
    })
    create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = AutoY,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = theme.SubText,
        TextXAlignment = Left,
        TextWrapped = true,
        Text = tostring(o.Content or ""),
        LayoutOrder = 2,
        Parent = inner,
    })
    local row = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 32),
        LayoutOrder = 3,
        Parent = inner,
    })
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 8),
        SortOrder = ByOrder,
        Parent = row,
    })

    local closed = false
    local function close(callback)
        if closed then
            return
        end
        closed = true
        tween(box, 0.2, { GroupTransparency = 1 })
        tween(scale, 0.2, { Scale = 0.94 })
        tween(overlay, 0.2, { BackgroundTransparency = 1 })
        task.delay(0.24, function()
            box:Destroy()
            overlay:Destroy()
        end)
        if callback then
            self:_fire(callback)
        end
    end

    local buttons = o.Buttons or { { Text = "OK", Primary = true } }
    for index, info in ipairs(buttons) do
        local primary = info.Primary == true
        local button = create("TextButton", {
            AutoButtonColor = false,
            Size = UDim2.fromOffset(88, 32),
            BackgroundColor3 = primary and theme.Accent or theme.Element,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextColor3 = primary and Color3.new(1, 1, 1) or theme.Text,
            Text = tostring(info.Text or "OK"),
            LayoutOrder = index,
            Parent = row,
        })
        corner(button, 8)
        if not primary then
            stroke(button, theme.Stroke, 1, 0.4)
        end
        button.MouseEnter:Connect(function()
            tween(button, 0.15, { BackgroundTransparency = 0.15 })
        end)
        button.MouseLeave:Connect(function()
            tween(button, 0.15, { BackgroundTransparency = 0 })
        end)
        button.MouseButton1Click:Connect(function()
            close(info.Callback)
        end)
    end

    tween(overlay, 0.25, { BackgroundTransparency = 0.5 })
    tween(box, 0.3, { GroupTransparency = 0 })
    tween(scale, 0.4, { Scale = 1 }, Enum.EasingStyle.Back)
    return { Close = close }
end

function Library:SetKey(key, onUnlock)
    self._key = key
    self._onUnlock = onUnlock
end

function Library:SetKeyLink(url)
    self._keyLink = url
end

function Library:SetRememberKey(state)
    self._remember = state and true or false
end

function Library:_checkKey(input)
    local entered = tostring(input or ""):gsub("^%s+", ""):gsub("%s+$", "")
    local key = self._key
    if type(key) == "function" then
        local ok, result = pcall(key, entered)
        return ok and result and true or false
    elseif type(key) == "table" then
        for _, valid in ipairs(key) do
            if tostring(valid) == entered then
                return true
            end
        end
        return false
    end
    return entered ~= "" and tostring(key) == entered
end

function Library:_readSavedKey()
    if not hasFS then
        return nil
    end
    local ok, data = pcall(function()
        if isfile(KEY_FILE) then
            return readfile(KEY_FILE)
        end
        return nil
    end)
    if ok then
        return data
    end
    return nil
end

function Library:_saveKey(text)
    if not hasFS then
        return
    end
    ensureFolders()
    pcall(writefile, KEY_FILE, tostring(text))
end

function Library:_unlock()
    if self._onUnlock then
        self:_fire(self._onUnlock)
    end
    self:_open()
end

function Library:_open()
    self._ready = true
    self._keyActive = false
    self:SetVisible(true)
    self:Notify({
        Title = self.HubName,
        Content = "Press " .. self.ToggleKey.Name .. " to show or hide the interface.",
        Type = "success",
    })
end

function Library:_showKey()
    local theme = self.Theme
    self._keyActive = true
    self:_applyBackdrop()
    self:_applyBlur()

    local window = create("CanvasGroup", {
        Name = "KeyWindow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0, 340, 0, 0),
        AutomaticSize = AutoY,
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        GroupTransparency = 1,
        ZIndex = 10,
        Parent = self.Gui,
    })
    corner(window, 14)
    stroke(window, theme.Stroke, 1, 0.3)
    local scale = create("UIScale", { Scale = 0.92, Parent = window })
    local body = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = AutoY,
        Parent = window,
    })
    pad(body, 22, 22, 22, 22)
    create("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = ByOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Parent = body,
    })

    local logo = create("ImageLabel", {
        BackgroundColor3 = theme.Element,
        Size = UDim2.fromOffset(54, 54),
        ScaleType = Enum.ScaleType.Crop,
        LayoutOrder = 1,
        Parent = body,
    })
    corner(logo, 14)
    self:_regLogo(logo)
    create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 22),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = theme.Text,
        Text = self.HubName,
        LayoutOrder = 2,
        Parent = body,
    })
    create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 16),
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = theme.SubText,
        Text = "Enter your key to continue",
        LayoutOrder = 3,
        Parent = body,
    })
    local input = create("TextBox", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = theme.Element,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = theme.Text,
        PlaceholderText = "Key",
        PlaceholderColor3 = theme.SubText,
        Text = "",
        LayoutOrder = 4,
        Parent = body,
    })
    corner(input, 8)
    local inputStroke = stroke(input, theme.Stroke, 1, 0.3)
    input.Focused:Connect(function()
        tween(inputStroke, 0.2, { Color = self.Theme.Accent, Transparency = 0 })
    end)
    input.FocusLost:Connect(function()
        tween(inputStroke, 0.2, { Color = theme.Stroke, Transparency = 0.3 })
    end)
    local status = create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 14),
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextColor3 = theme.SubText,
        Text = "",
        LayoutOrder = 5,
        Parent = body,
    })
    local submit = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = self.Theme.Accent,
        AutoButtonColor = false,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Color3.new(1, 1, 1),
        Text = "Unlock",
        LayoutOrder = 6,
        Parent = body,
    })
    corner(submit, 8)
    if self._keyLink then
        local getKey = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = theme.Element,
            AutoButtonColor = false,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextColor3 = theme.Text,
            Text = "Get Key",
            LayoutOrder = 7,
            Parent = body,
        })
        corner(getKey, 8)
        stroke(getKey, theme.Stroke, 1, 0.4)
        getKey.MouseButton1Click:Connect(function()
            if setclipboard then
                setclipboard(self._keyLink)
                status.TextColor3 = theme.Success
                status.Text = "Link copied to clipboard"
            else
                status.TextColor3 = theme.Warning
                status.Text = self._keyLink
            end
        end)
    end

    tween(window, 0.35, { GroupTransparency = 0 })
    tween(scale, 0.45, { Scale = 1 }, Enum.EasingStyle.Back)

    local busy = false
    local function attempt()
        if busy then
            return
        end
        local entered = input.Text
        if self:_checkKey(entered) then
            busy = true
            status.TextColor3 = theme.Success
            status.Text = "Key accepted"
            if self._remember then
                self:_saveKey(entered)
            end
            tween(window, 0.3, { GroupTransparency = 1 })
            tween(scale, 0.3, { Scale = 0.94 })
            task.delay(0.32, function()
                window:Destroy()
                self:_unlock()
            end)
        else
            status.TextColor3 = theme.Error
            status.Text = "Invalid key"
            task.spawn(function()
                for _, offset in ipairs({ -9, 9, -6, 6, 0 }) do
                    tween(window, 0.04, { Position = UDim2.new(0.5, offset, 0.5, 0) })
                    task.wait(0.045)
                end
            end)
        end
    end
    submit.MouseButton1Click:Connect(attempt)
    input.FocusLost:Connect(function(enter)
        if enter then
            attempt()
        end
    end)
end

function Library:Init()
    if self._initialized then
        return self
    end
    self._initialized = true
    table.sort(self._tabs, function(a, b)
        if a.Order == b.Order then
            return a._id < b._id
        end
        return a.Order < b.Order
    end)
    if not self.CurrentTab and self._tabs[1] then
        self:_selectTab(self._tabs[1])
    end
    if self._key ~= nil then
        local saved = self._remember and self:_readSavedKey() or nil
        if saved and self:_checkKey(saved) then
            self:_unlock()
        else
            self:_showKey()
        end
        return self
    end
    self:_open()
    return self
end

function Library:SaveConfig(name)
    if not hasFS then
        return false, "no file access"
    end
    name = sanitize(name)
    if name == "" then
        return false, "invalid name"
    end
    ensureFolders()
    local data = {}
    for flag, value in pairs(self.Flags) do
        local encoded = encodeValue(value)
        if encoded ~= nil then
            data[flag] = encoded
        end
    end
    local ok, err = pcall(function()
        writefile(CONFIG_FOLDER .. "/" .. name .. ".json", HttpService:JSONEncode(data))
    end)
    if not ok then
        return false, tostring(err)
    end
    return true
end

function Library:LoadConfig(name)
    if not hasFS then
        return false, "no file access"
    end
    name = sanitize(name)
    local path = CONFIG_FOLDER .. "/" .. name .. ".json"
    local ok, data = pcall(function()
        if not isfile(path) then
            return nil
        end
        return HttpService:JSONDecode(readfile(path))
    end)
    if not ok or type(data) ~= "table" then
        return false, "config not found"
    end
    for flag, raw in pairs(data) do
        local setter = self._setters[flag]
        if setter then
            local decoded
            local decodeOk = pcall(function()
                decoded = decodeValue(raw)
            end)
            if decodeOk and decoded ~= nil then
                pcall(setter, decoded, false)
            end
        end
    end
    return true
end

function Library:DeleteConfig(name)
    if not hasFS or type(delfile) ~= "function" then
        return false, "no file access"
    end
    name = sanitize(name)
    local path = CONFIG_FOLDER .. "/" .. name .. ".json"
    local ok = pcall(function()
        if isfile(path) then
            delfile(path)
        end
    end)
    return ok
end

function Library:ListConfigs()
    local names = {}
    if not hasFS then
        return names
    end
    ensureFolders()
    local ok, files = pcall(listfiles, CONFIG_FOLDER)
    if ok and type(files) == "table" then
        for _, path in ipairs(files) do
            local name = tostring(path):match("([^/\\]+)%.json$")
            if name then
                table.insert(names, name)
            end
        end
    end
    table.sort(names)
    return names
end

function Library:_buildSettings()
    local tab = self:AddTab({ Name = "Settings", Order = 1000 })

    local interface = tab:AddSection("Interface")
    self._toggleKeybind = interface:AddKeybind({
        Name = "Toggle Keybind",
        Description = "Key that shows or hides the hub",
        Default = self.ToggleKey,
        Flag = "HH_ToggleKey",
        Callback = function(key)
            if key ~= Enum.KeyCode.Unknown then
                self.ToggleKey = key
            end
        end,
    })
    interface:AddDropdown({
        Name = "Accent Preset",
        Options = Library.PresetOrder,
        Callback = function(name)
            self:SetAccent(name)
        end,
    })
    self._accentPicker = interface:AddColorPicker({
        Name = "Accent Color",
        Default = self.Theme.Accent,
        Flag = "HH_Accent",
        Callback = function(color)
            self:SetAccent(color, true)
        end,
    })
    interface:AddSlider({
        Name = "UI Scale",
        Min = 60,
        Max = 140,
        Default = math.floor(self.Settings.Scale * 100 + 0.5),
        Increment = 5,
        Suffix = "%",
        Flag = "HH_Scale",
        Callback = function(value)
            self:SetScale(value / 100)
        end,
    })
    interface:AddToggle({
        Name = "Background Dim",
        Description = "Black fade behind the window while it is open",
        Default = true,
        Flag = "HH_Dim",
        Callback = function(state)
            self:SetBackdrop(state)
        end,
    })
    interface:AddSlider({
        Name = "Dim Amount",
        Min = 0,
        Max = 90,
        Default = 45,
        Increment = 5,
        Suffix = "%",
        Flag = "HH_DimAmount",
        Callback = function(value)
            self:SetBackdrop(nil, value / 100)
        end,
    })
    interface:AddToggle({
        Name = "Background Blur",
        Default = false,
        Flag = "HH_Blur",
        Callback = function(state)
            self:SetBlur(state)
        end,
    })
    interface:AddToggle({
        Name = "Watermark",
        Description = "Name, FPS and ping in the corner",
        Default = false,
        Flag = "HH_Watermark",
        Callback = function(state)
            self:SetWatermark(state)
        end,
    })
    interface:AddToggle({
        Name = "Notifications",
        Default = true,
        Flag = "HH_Notifs",
        Callback = function(state)
            self:SetNotifications(state)
        end,
    })

    local configuration = tab:AddSection("Configuration")
    if hasFS then
        local current = ""
        local list
        configuration:AddTextbox({
            Name = "Config Name",
            Placeholder = "my config",
            Callback = function(text)
                current = text
            end,
        })
        list = configuration:AddDropdown({
            Name = "Saved Configs",
            Options = self:ListConfigs(),
            Callback = function(name)
                if type(name) == "string" then
                    current = name
                end
            end,
        })
        configuration:AddButton({
            Name = "Save Config",
            ButtonText = "Save",
            Callback = function()
                local ok, err = self:SaveConfig(current)
                if ok then
                    list:Refresh(self:ListConfigs(), true)
                    self:Notify({ Title = "Config", Content = "Saved " .. sanitize(current), Type = "success" })
                else
                    self:Notify({ Title = "Config", Content = tostring(err), Type = "error" })
                end
            end,
        })
        configuration:AddButton({
            Name = "Load Config",
            ButtonText = "Load",
            Callback = function()
                local ok, err = self:LoadConfig(current)
                if ok then
                    self:Notify({ Title = "Config", Content = "Loaded " .. sanitize(current), Type = "success" })
                else
                    self:Notify({ Title = "Config", Content = tostring(err), Type = "error" })
                end
            end,
        })
        configuration:AddButton({
            Name = "Delete Config",
            ButtonText = "Delete",
            Callback = function()
                if self:DeleteConfig(current) then
                    list:Refresh(self:ListConfigs(), false)
                    self:Notify({ Title = "Config", Content = "Deleted " .. sanitize(current), Type = "warning" })
                end
            end,
        })
        configuration:AddButton({
            Name = "Refresh List",
            ButtonText = "Refresh",
            Callback = function()
                list:Refresh(self:ListConfigs(), true)
            end,
        })
    else
        configuration:AddParagraph({
            Title = "No file access",
            Content = "This executor does not expose the file functions needed to save configs.",
        })
    end

    local hubSection = tab:AddSection("Hub")
    hubSection:AddParagraph({
        Title = self.HubName .. " v" .. Library.Version,
        Content = "Game: " .. self.GameName,
    })
    hubSection:AddButton({
        Name = "Rejoin Server",
        ButtonText = "Rejoin",
        Callback = function()
            pcall(function()
                if #Players:GetPlayers() <= 1 then
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                else
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                end
            end)
        end,
    })
    hubSection:AddButton({
        Name = "Unload UI",
        ButtonText = "Unload",
        Callback = function()
            self:SetVisible(false)
            task.delay(0.4, function()
                self:Destroy()
            end)
        end,
    })
end

function Library:AddSection(tab, name)
    return tab:AddSection(name)
end

function Library:AddLabel(section, text)
    return section:AddLabel({ Name = text })
end

function Library:AddParagraph(section, title, content)
    return section:AddParagraph({ Title = title, Content = content })
end

function Library:AddButton(section, text, callback)
    return section:AddButton({ Name = text, Callback = callback })
end

function Library:AddToggle(section, text, default, callback)
    return section:AddToggle({ Name = text, Default = default, Callback = callback })
end

function Library:AddSlider(section, text, min, max, default, isFloat, callback)
    return section:AddSlider({
        Name = text,
        Min = min,
        Max = max,
        Default = default,
        Increment = isFloat and 0.1 or 1,
        Callback = callback,
    })
end

function Library:AddTextbox(section, text, placeholder, callback)
    return section:AddTextbox({ Name = text, Placeholder = placeholder, Callback = callback })
end

function Library:AddDropdown(section, text, options, default, callback)
    return section:AddDropdown({ Name = text, Options = options, Default = default, Callback = callback })
end

function Library:AddKeybind(section, text, default, callback)
    return section:AddKeybind({ Name = text, Default = default, OnPress = callback })
end

function Library:AddColorPicker(section, text, callback)
    return section:AddColorPicker({
        Name = text,
        Default = self.Theme.Accent,
        Callback = function(color)
            self:SetAccent(color)
            if callback then
                callback(color)
            end
        end,
    })
end

function Library:Destroy()
    if self._destroyed then
        return
    end
    self._destroyed = true
    for _, connection in ipairs(self._conns) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    if self.Blur then
        self.Blur:Destroy()
    end
    if self.Gui then
        self.Gui:Destroy()
    end
    local genv = getgenv and getgenv() or _G
    if genv.__HumidityHub == self then
        genv.__HumidityHub = nil
    end
end

Library.Create = Library.new

return Library
