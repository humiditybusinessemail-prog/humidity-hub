--[[
    Humidity Hub UI Library
    Roblox Luau | Client-side ModuleScript / loadstring-compatible source

    Quick start:
        local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/humiditybusinessemail-prog/humidity-hub/refs/heads/main/HumidityHub.lua"))()
        local Hub = Library.new({
            HubName = "Humidity Hub",
            GameName = "Universal",
            ToggleKey = Enum.KeyCode.RightShift,
        })

        Hub:Init()
        local Main = Hub:AddTab("Main")
        local Section = Hub:AddSection(Main, "General")
        Hub:AddToggle(Section, "Enabled", false, function(value)
            print("Enabled:", value)
        end)

    Existing API retained:
        Library.new(config)
        Hub:SetKey(validKey, onUnlock)
        Hub:AddTab(name, icon)
        Hub:AddSection(tab, name)
        Hub:AddLabel(section, text)
        Hub:AddParagraph(section, title, content)
        Hub:AddButton(section, text, callback)
        Hub:AddToggle(section, text, default, callback)
        Hub:AddSlider(section, text, min, max, default, isFloat, callback)
        Hub:AddTextbox(section, text, placeholder, default, callback)
        Hub:AddDropdown(section, text, options, default, callback)
        Hub:AddKeybind(section, text, default, callback)
        Hub:AddColorPicker(section, text, callback)
        Hub:SetAccent(color)
        Hub:SetToggleKey(keyCode)
        Hub:Notify(text, color, duration)
        Hub:Destroy()

    Notes:
        - The default logo uses the supplied Roblox decal ID.
        - The dim overlay fades in with the window and fades out when hidden.
        - Dropdowns render above the page content and do not clip at the row.
        - UI input listeners are owned by the library and disconnected on Destroy().
]]

local Library = {}
Library.__index = Library

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local LOGO_ID = "rbxassetid://127590426518205"

local DEFAULT_THEME = {
    Background = Color3.fromRGB(13, 15, 19),
    Sidebar = Color3.fromRGB(16, 18, 23),
    Surface = Color3.fromRGB(20, 23, 29),
    Surface2 = Color3.fromRGB(25, 29, 36),
    Raised = Color3.fromRGB(31, 36, 44),
    Hover = Color3.fromRGB(39, 45, 55),
    Border = Color3.fromRGB(48, 55, 67),
    Accent = Color3.fromRGB(116, 151, 255),
    AccentDim = Color3.fromRGB(38, 51, 88),
    TextPrimary = Color3.fromRGB(239, 242, 248),
    TextSecondary = Color3.fromRGB(153, 162, 177),
    TextMuted = Color3.fromRGB(105, 115, 132),
    Success = Color3.fromRGB(91, 204, 143),
    Warning = Color3.fromRGB(244, 184, 91),
    Error = Color3.fromRGB(235, 100, 108),
}

Library.AccentPresets = {
    {name = "Blue", color = Color3.fromRGB(116, 151, 255)},
    {name = "Purple", color = Color3.fromRGB(168, 130, 255)},
    {name = "Cyan", color = Color3.fromRGB(83, 202, 218)},
    {name = "Green", color = Color3.fromRGB(91, 204, 143)},
    {name = "Orange", color = Color3.fromRGB(244, 166, 91)},
    {name = "Red", color = Color3.fromRGB(235, 100, 108)},
    {name = "White", color = Color3.fromRGB(225, 231, 241)},
}

local function copyTable(source)
    local result = {}
    for key, value in pairs(source) do
        result[key] = value
    end
    return result
end

local function tween(instance, properties, duration, style, direction)
    if not instance or not instance.Parent then return nil end
    local info = TweenInfo.new(
        duration or 0.2,
        style or Enum.EasingStyle.Quart,
        direction or Enum.EasingDirection.Out
    )
    local animation = TweenService:Create(instance, info, properties)
    animation:Play()
    return animation
end

local function corner(instance, radius)
    local item = Instance.new("UICorner")
    item.CornerRadius = UDim.new(0, radius or 10)
    item.Parent = instance
    return item
end

local function outline(instance, color, transparency, thickness)
    local item = Instance.new("UIStroke")
    item.Color = color or DEFAULT_THEME.Border
    item.Transparency = transparency or 0
    item.Thickness = thickness or 1
    item.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    item.Parent = instance
    return item
end

local function padding(instance, left, right, top, bottom)
    local item = Instance.new("UIPadding")
    item.PaddingLeft = UDim.new(0, left or 0)
    item.PaddingRight = UDim.new(0, right or 0)
    item.PaddingTop = UDim.new(0, top or 0)
    item.PaddingBottom = UDim.new(0, bottom or 0)
    item.Parent = instance
    return item
end

local function make(className, parent, properties)
    local object = Instance.new(className)
    for key, value in pairs(properties or {}) do
        object[key] = value
    end
    object.Parent = parent
    return object
end

local function label(parent, text, properties)
    properties = properties or {}
    properties.BackgroundTransparency = properties.BackgroundTransparency or 1
    properties.BorderSizePixel = 0
    properties.Text = text or ""
    properties.Font = properties.Font or Enum.Font.Gotham
    properties.TextSize = properties.TextSize or 13
    properties.TextColor3 = properties.TextColor3 or DEFAULT_THEME.TextPrimary
    properties.TextXAlignment = properties.TextXAlignment or Enum.TextXAlignment.Left
    properties.TextYAlignment = properties.TextYAlignment or Enum.TextYAlignment.Center
    properties.RichText = false
    return make("TextLabel", parent, properties)
end

local function button(parent, text, properties)
    properties = properties or {}
    properties.AutoButtonColor = false
    properties.BorderSizePixel = 0
    properties.Text = text or ""
    properties.Font = properties.Font or Enum.Font.GothamSemibold
    properties.TextSize = properties.TextSize or 12
    properties.TextColor3 = properties.TextColor3 or DEFAULT_THEME.TextPrimary
    return make("TextButton", parent, properties)
end

local function addConnection(self, connection)
    table.insert(self._connections, connection)
    return connection
end

local function addCorner(parent, radius)
    return corner(parent, radius)
end

function Library.new(config)
    local self = setmetatable({}, Library)
    config = config or {}

    self._theme = copyTable(DEFAULT_THEME)
    if type(config.Theme) == "table" then
        for key, value in pairs(config.Theme) do
            if self._theme[key] ~= nil then self._theme[key] = value end
        end
    end
    if typeof(config.Accent) == "Color3" then
        self._theme.Accent = config.Accent
    end
    self._theme.AccentDim = Color3.new(
        self._theme.Accent.R * 0.28,
        self._theme.Accent.G * 0.28,
        self._theme.Accent.B * 0.28
    )

    self._hubName = config.HubName or "Humidity Hub"
    self._gameName = config.GameName or "Universal"
    self._logoId = config.LogoId or LOGO_ID
    self._toggleKey = config.ToggleKey or Enum.KeyCode.RightShift
    self._windowSize = config.WindowSize or Vector2.new(720, 490)
    self._keyRequired = false
    self._tabs = {}
    self._connections = {}
    self._objects = {}
    self._open = false
    self._destroyed = false
    self._activeTab = nil
    self._notificationToken = 0

    local old = PlayerGui:FindFirstChild("HumidityHubUI")
    if old then old:Destroy() end

    self._gui = make("ScreenGui", PlayerGui, {
        Name = "HumidityHubUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 50,
    })

    return self
end

function Library:SetKey(validKey, onUnlock)
    self._keyRequired = true
    self._validKey = validKey
    self._onUnlock = onUnlock
    return self
end

function Library:SetToggleKey(keyCode)
    if typeof(keyCode) == "EnumItem" and keyCode.EnumType == Enum.KeyCode then
        self._toggleKey = keyCode
    end
    return self
end

function Library:_buildOverlay()
    self._overlay = make("Frame", self._gui, {
        Name = "DimOverlay",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 1,
    })
end

function Library:_buildWindow()
    local T = self._theme
    local width = math.clamp(self._windowSize.X, 560, 900)
    local height = math.clamp(self._windowSize.Y, 390, 680)
    local sidebarWidth = 184

    local root = make("Frame", self._gui, {
        Name = "MainWindow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(width, height),
        BackgroundColor3 = T.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 2,
    })
    corner(root, 15)
    self._windowStroke = outline(root, T.Border, 0.15, 1)
    self._window = root

    local sidebar = make("Frame", root, {
        Name = "Sidebar",
        Size = UDim2.new(0, sidebarWidth, 1, 0),
        BackgroundColor3 = T.Sidebar,
        BorderSizePixel = 0,
        ZIndex = 3,
    })
    self._sidebar = sidebar

    local logo = make("ImageLabel", sidebar, {
        Name = "HubLogo",
        Position = UDim2.fromOffset(18, 19),
        Size = UDim2.fromOffset(43, 43),
        BackgroundColor3 = T.Surface2,
        BorderSizePixel = 0,
        Image = self._logoId,
        ScaleType = Enum.ScaleType.Crop,
        ZIndex = 4,
    })
    corner(logo, 12)
    outline(logo, T.Border, 0.2, 1)

    label(sidebar, self._hubName, {
        Position = UDim2.fromOffset(72, 20),
        Size = UDim2.new(1, -82, 0, 22),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = T.TextPrimary,
        ZIndex = 4,
    })
    label(sidebar, self._gameName, {
        Position = UDim2.fromOffset(72, 42),
        Size = UDim2.new(1, -82, 0, 17),
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = T.TextMuted,
        ZIndex = 4,
    })

    make("Frame", sidebar, {
        Position = UDim2.fromOffset(16, 78),
        Size = UDim2.new(1, -32, 0, 1),
        BackgroundColor3 = T.Border,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        ZIndex = 4,
    })

    label(sidebar, "WORKSPACE", {
        Position = UDim2.fromOffset(20, 92),
        Size = UDim2.new(1, -40, 0, 18),
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        TextColor3 = T.TextMuted,
        ZIndex = 4,
    })

    local tabList = make("ScrollingFrame", sidebar, {
        Name = "TabList",
        Position = UDim2.fromOffset(12, 116),
        Size = UDim2.new(1, -24, 1, -178),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = T.Accent,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 4,
    })
    local tabLayout = make("UIListLayout", tabList, {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    self._tabList = tabList

    local footer = make("Frame", sidebar, {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 12, 1, -13),
        Size = UDim2.new(1, -24, 0, 42),
        BackgroundColor3 = T.Surface,
        BorderSizePixel = 0,
        ZIndex = 4,
    })
    corner(footer, 10)
    label(footer, "HUMIDITY HUB", {
        Position = UDim2.fromOffset(11, 5),
        Size = UDim2.new(1, -22, 0, 14),
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        TextColor3 = T.TextMuted,
        ZIndex = 5,
    })
    label(footer, "UI Library  •  Ready", {
        Position = UDim2.fromOffset(11, 19),
        Size = UDim2.new(1, -22, 0, 15),
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = T.TextSecondary,
        ZIndex = 5,
    })

    local main = make("Frame", root, {
        Name = "Main",
        Position = UDim2.fromOffset(sidebarWidth, 0),
        Size = UDim2.new(1, -sidebarWidth, 1, 0),
        BackgroundColor3 = T.Background,
        BorderSizePixel = 0,
        ZIndex = 3,
    })
    self._main = main

    local titleBar = make("Frame", main, {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 64),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 4,
    })
    self._title = label(titleBar, "Home", {
        Position = UDim2.fromOffset(23, 13),
        Size = UDim2.new(1, -120, 0, 25),
        Font = Enum.Font.GothamBold,
        TextSize = 19,
        TextColor3 = T.TextPrimary,
        ZIndex = 5,
    })
    label(titleBar, "Configure your experience", {
        Position = UDim2.fromOffset(24, 38),
        Size = UDim2.new(1, -120, 0, 16),
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = T.TextMuted,
        ZIndex = 5,
    })

    local function windowButton(text, x, color)
        local b = button(titleBar, text, {
            Position = UDim2.new(1, x, 0, 20),
            Size = UDim2.fromOffset(27, 27),
            BackgroundColor3 = T.Surface2,
            TextColor3 = color or T.TextSecondary,
            TextSize = 13,
            ZIndex = 6,
        })
        corner(b, 8)
        outline(b, T.Border, 0.45, 1)
        b.MouseEnter:Connect(function()
            tween(b, {BackgroundColor3 = T.Hover}, 0.12)
        end)
        b.MouseLeave:Connect(function()
            tween(b, {BackgroundColor3 = T.Surface2}, 0.12)
        end)
        return b
    end

    local minimize = windowButton("–", -66)
    local close = windowButton("×", -31, T.Error)
    addConnection(self, minimize.MouseButton1Click:Connect(function()
        self:SetVisible(false)
    end))
    addConnection(self, close.MouseButton1Click:Connect(function()
        self:SetVisible(false)
    end))

    local pageHost = make("Frame", main, {
        Name = "PageHost",
        Position = UDim2.fromOffset(15, 66),
        Size = UDim2.new(1, -30, 1, -82),
        BackgroundColor3 = T.Surface,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 4,
    })
    corner(pageHost, 12)
    outline(pageHost, T.Border, 0.45, 1)
    self._pageHost = pageHost

    -- Manual dragging keeps slider and textbox interactions independent.
    local dragging, dragStart, startPosition = false, nil, nil
    addConnection(self._window.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local localPos = input.Position - self._window.AbsolutePosition
            if localPos.Y <= 62 and localPos.X > sidebarWidth then
                dragging = true
                dragStart = input.Position
                startPosition = self._window.Position
            end
        end
    end))
    addConnection(UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self._window.Position = UDim2.new(
                startPosition.X.Scale, startPosition.X.Offset + delta.X,
                startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
            )
        end
    end))
    addConnection(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end))

    self._windowSizePixels = Vector2.new(width, height)
end

function Library:_animateVisibility(visible)
    if self._destroyed or not self._window then return end
    self._open = visible

    if visible then
        self._overlay.Visible = true
        self._window.Visible = true
        self._window.Size = UDim2.fromOffset(
            self._windowSizePixels.X * 0.965,
            self._windowSizePixels.Y * 0.965
        )
        self._window.BackgroundTransparency = 0.12
        tween(self._overlay, {BackgroundTransparency = 0.48}, 0.24)
        tween(self._window, {
            Size = UDim2.fromOffset(self._windowSizePixels.X, self._windowSizePixels.Y),
            BackgroundTransparency = 0,
        }, 0.28, Enum.EasingStyle.Quart)
    else
        tween(self._overlay, {BackgroundTransparency = 1}, 0.2)
        tween(self._window, {
            Size = UDim2.fromOffset(self._windowSizePixels.X * 0.97, self._windowSizePixels.Y * 0.97),
            BackgroundTransparency = 0.12,
        }, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.delay(0.21, function()
            if self._destroyed or self._open then return end
            self._window.Visible = false
            self._overlay.Visible = false
        end)
    end
end

function Library:SetVisible(visible)
    self:_animateVisibility(visible == true)
    return self
end

function Library:Toggle()
    self:SetVisible(not self._open)
    return self
end

function Library:_initKeybind()
    addConnection(self, UserInputService.InputBegan:Connect(function(input, processed)
        if processed or self._destroyed then return end
        if input.KeyCode == self._toggleKey then
            self:Toggle()
        end
    end))
end

function Library:_showKeyGate(onSuccess)
    local T = self._theme
    local overlay = make("Frame", self._gui, {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.35,
        ZIndex = 30,
    })
    local card = make("Frame", overlay, {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.53),
        Size = UDim2.fromOffset(360, 218),
        BackgroundColor3 = T.Surface,
        BorderSizePixel = 0,
        ZIndex = 31,
    })
    corner(card, 15)
    outline(card, T.Border, 0.1, 1)
    make("Frame", card, {
        Size = UDim2.new(1, 0, 0, 3),
        BackgroundColor3 = T.Accent,
        BorderSizePixel = 0,
        ZIndex = 32,
    })
    label(card, "Access required", {
        Position = UDim2.fromOffset(22, 22),
        Size = UDim2.new(1, -44, 0, 26),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        ZIndex = 32,
    })
    label(card, "Enter your key to continue to " .. self._hubName .. ".", {
        Position = UDim2.fromOffset(22, 52),
        Size = UDim2.new(1, -44, 0, 20),
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = T.TextSecondary,
        ZIndex = 32,
    })
    local input = make("TextBox", card, {
        Position = UDim2.fromOffset(22, 88),
        Size = UDim2.new(1, -44, 0, 39),
        BackgroundColor3 = T.Raised,
        TextColor3 = T.TextPrimary,
        PlaceholderText = "Enter access key",
        PlaceholderColor3 = T.TextMuted,
        Text = "",
        Font = Enum.Font.Gotham,
        TextSize = 13,
        ClearTextOnFocus = false,
        BorderSizePixel = 0,
        ZIndex = 32,
    })
    corner(input, 9)
    outline(input, T.Border, 0.2, 1)
    local errorLabel = label(card, "", {
        Position = UDim2.fromOffset(22, 131),
        Size = UDim2.new(1, -44, 0, 17),
        TextColor3 = T.Error,
        TextSize = 10,
        ZIndex = 32,
    })
    local unlock = button(card, "Unlock", {
        Position = UDim2.fromOffset(22, 158),
        Size = UDim2.new(1, -44, 0, 38),
        BackgroundColor3 = T.Accent,
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 12,
        ZIndex = 32,
    })
    corner(unlock, 9)

    local busy = false
    local function attempt()
        if busy then return end
        busy = true
        local valid = false
        local ok, result = pcall(function()
            if type(self._validKey) == "string" then
                return input.Text == self._validKey
            elseif type(self._validKey) == "function" then
                return self._validKey(input.Text) == true
            end
            return false
        end)
        valid = ok and result == true
        if valid then
            if self._onUnlock then pcall(self._onUnlock, input.Text) end
            tween(card, {Position = UDim2.fromScale(0.5, 0.48)}, 0.16)
            tween(overlay, {BackgroundTransparency = 1}, 0.2)
            task.delay(0.21, function()
                if overlay then overlay:Destroy() end
                onSuccess()
            end)
        else
            errorLabel.Text = "That key did not match. Try again."
            tween(input, {BackgroundColor3 = Color3.fromRGB(65, 35, 42)}, 0.1)
            task.delay(0.35, function()
                if input.Parent then tween(input, {BackgroundColor3 = T.Raised}, 0.16) end
                busy = false
            end)
        end
    end
    addConnection(self, unlock.MouseButton1Click:Connect(attempt))
    addConnection(self, input.FocusLost:Connect(function(enterPressed)
        if enterPressed then attempt() end
    end))
    tween(card, {Position = UDim2.fromScale(0.5, 0.5)}, 0.28, Enum.EasingStyle.Back)
end

function Library:Init()
    if self._initialized then return self end
    self._initialized = true

    local function build()
        if self._destroyed then return end
        self:_buildOverlay()
        self:_buildWindow()
        self:_initKeybind()
        self:_initToast()
        self:SetVisible(true)
        if #self._tabs > 0 then self:_switchTab(1) end
    end

    if self._keyRequired then
        self:_showKeyGate(build)
    else
        build()
    end
    return self
end

function Library:_initToast()
    local T = self._theme
    local toast = make("Frame", self._gui, {
        Name = "Toast",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 24),
        Size = UDim2.fromOffset(310, 48),
        BackgroundColor3 = T.Surface2,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 60,
    })
    corner(toast, 12)
    outline(toast, T.Border, 0.15, 1)
    local accent = make("Frame", toast, {
        Position = UDim2.fromOffset(0, 9),
        Size = UDim2.new(0, 3, 1, -18),
        BackgroundColor3 = T.Accent,
        BorderSizePixel = 0,
        ZIndex = 61,
    })
    corner(accent, 2)
    local textLabel = label(toast, "", {
        Position = UDim2.fromOffset(16, 0),
        Size = UDim2.new(1, -28, 1, 0),
        Font = Enum.Font.GothamSemibold,
        TextSize = 12,
        TextColor3 = T.TextPrimary,
        ZIndex = 61,
    })
    self._toast = toast
    self._toastText = textLabel
    self._toastAccent = accent
end

function Library:Notify(message, color, duration)
    if not self._toast then return end
    self._notificationToken += 1
    local token = self._notificationToken
    self._toastText.Text = tostring(message)
    self._toastAccent.BackgroundColor3 = color or self._theme.Accent
    self._toast.Visible = true
    self._toast.Position = UDim2.new(0.5, 0, 0, 12)
    tween(self._toast, {BackgroundTransparency = 0, Position = UDim2.new(0.5, 0, 0, 24)}, 0.2)
    task.delay(duration or 2.2, function()
        if self._destroyed or token ~= self._notificationToken then return end
        tween(self._toast, {
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0, 12),
        }, 0.18)
        task.delay(0.2, function()
            if token == self._notificationToken and self._toast then
                self._toast.Visible = false
            end
        end)
    end)
end

function Library:AddTab(name, icon)
    assert(self._tabList, "Call Hub:Init() before adding tabs")
    local T = self._theme
    local index = #self._tabs + 1

    local tabButton = button(self._tabList, "", {
        Size = UDim2.new(1, 0, 0, 39),
        BackgroundColor3 = T.Sidebar,
        Text = "",
        LayoutOrder = index,
        ZIndex = 5,
    })
    corner(tabButton, 9)

    local iconLabel
    if icon then
        iconLabel = make("ImageLabel", tabButton, {
            Position = UDim2.fromOffset(11, 11),
            Size = UDim2.fromOffset(17, 17),
            BackgroundTransparency = 1,
            Image = icon,
            ImageColor3 = T.TextMuted,
            ZIndex = 6,
        })
    end

    local title = label(tabButton, tostring(name), {
        Position = UDim2.fromOffset(icon and 39 or 13, 0),
        Size = UDim2.new(1, icon and -47 or -21, 1, 0),
        Font = Enum.Font.GothamSemibold,
        TextSize = 12,
        TextColor3 = T.TextSecondary,
        ZIndex = 6,
    })

    local activeMark = make("Frame", tabButton, {
        Position = UDim2.fromOffset(0, 9),
        Size = UDim2.fromOffset(3, 21),
        BackgroundColor3 = T.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 7,
    })
    corner(activeMark, 3)

    local page = make("ScrollingFrame", self._pageHost, {
        Name = tostring(name) .. "Page",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = T.Accent,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        ZIndex = 5,
    })
    padding(page, 15, 15, 14, 16)
    local layout = make("UIListLayout", page, {
        Padding = UDim.new(0, 9),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    local tab = {
        name = tostring(name),
        btn = tabButton,
        title = title,
        icon = iconLabel,
        activeMark = activeMark,
        page = page,
        sections = {},
        _rowOrder = 0,
    }
    self._tabs[index] = tab

    addConnection(self, tabButton.MouseButton1Click:Connect(function()
        self:_switchTab(index)
    end))
    tabButton.MouseEnter:Connect(function()
        if self._activeTab ~= index then tween(tabButton, {BackgroundColor3 = T.Surface}, 0.12) end
    end)
    tabButton.MouseLeave:Connect(function()
        if self._activeTab ~= index then tween(tabButton, {BackgroundColor3 = T.Sidebar}, 0.12) end
    end)

    if index == 1 then self:_switchTab(1) end
    return tab
end

function Library:_switchTab(index)
    local T = self._theme
    local selected = self._tabs[index]
    if not selected then return end

    for i, tab in ipairs(self._tabs) do
        local active = i == index
        tab.page.Visible = active
        tween(tab.btn, {BackgroundColor3 = active and T.Surface2 or T.Sidebar}, 0.16)
        tween(tab.title, {TextColor3 = active and T.TextPrimary or T.TextSecondary}, 0.16)
        tween(tab.activeMark, {BackgroundTransparency = active and 0 or 1}, 0.16)
        if tab.icon then
            tween(tab.icon, {ImageColor3 = active and T.Accent or T.TextMuted}, 0.16)
        end
    end
    self._activeTab = index
    if self._title then self._title.Text = selected.name end
end

function Library:AddSection(tab, name)
    assert(tab and tab.page, "AddSection expects a tab returned by AddTab")
    local section = {
        _tab = tab,
        _name = name or "",
        _rowOrder = 0,
    }
    table.insert(tab.sections, section)

    if name and name ~= "" then
        local heading = label(tab.page, string.upper(name), {
            Size = UDim2.new(1, 0, 0, 18),
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            TextColor3 = self._theme.TextMuted,
            LayoutOrder = #tab.sections * 1000,
            ZIndex = 6,
        })
        section._heading = heading
    end
    return section
end

function Library:_makeRow(section, height)
    assert(section and section._tab, "Element expects a section returned by AddSection")
    section._rowOrder += 1
    local row = make("Frame", section._tab.page, {
        Size = UDim2.new(1, 0, 0, height or 44),
        BackgroundColor3 = self._theme.Surface2,
        BorderSizePixel = 0,
        LayoutOrder = (#section._tab.sections - 1) * 1000 + section._rowOrder + 1,
        ZIndex = 6,
    })
    corner(row, 10)
    outline(row, self._theme.Border, 0.68, 1)
    return row
end

function Library:AddLabel(section, text)
    local T = self._theme
    local row = self:_makeRow(section, 36)
    label(row, tostring(text), {
        Position = UDim2.fromOffset(13, 0),
        Size = UDim2.new(1, -26, 1, 0),
        TextColor3 = T.TextSecondary,
        TextSize = 12,
        ZIndex = 7,
    })
    return row
end

function Library:AddParagraph(section, title, content)
    local T = self._theme
    local row = self:_makeRow(section, 72)
    local titleLabel = label(row, tostring(title), {
        Position = UDim2.fromOffset(13, 9),
        Size = UDim2.new(1, -26, 0, 19),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        ZIndex = 7,
    })
    local body = label(row, tostring(content), {
        Position = UDim2.fromOffset(13, 30),
        Size = UDim2.new(1, -26, 0, 34),
        TextColor3 = T.TextSecondary,
        TextSize = 11,
        TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 7,
    })
    return {Frame = row, Title = titleLabel, Content = body}
end

function Library:AddButton(section, text, callback)
    local T = self._theme
    local row = self:_makeRow(section, 46)
    label(row, tostring(text), {
        Position = UDim2.fromOffset(13, 0),
        Size = UDim2.new(1, -130, 1, 0),
        TextSize = 12,
        ZIndex = 7,
    })
    local action = button(row, "Run", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(92, 29),
        BackgroundColor3 = T.AccentDim,
        TextColor3 = T.Accent,
        TextSize = 11,
        ZIndex = 7,
    })
    corner(action, 8)
    action.MouseEnter:Connect(function()
        tween(action, {BackgroundColor3 = T.Accent, TextColor3 = Color3.new(1, 1, 1)}, 0.12)
    end)
    action.MouseLeave:Connect(function()
        tween(action, {BackgroundColor3 = T.AccentDim, TextColor3 = T.Accent}, 0.12)
    end)
    addConnection(self, action.MouseButton1Click:Connect(function()
        if callback then
            local ok, err = pcall(callback)
            if not ok then
                warn("[Humidity Hub] Button callback error:", err)
                self:Notify("Action failed. Check the developer console.", T.Error)
            end
        end
    end))
    return action
end

function Library:AddToggle(section, text, default, callback)
    local T = self._theme
    local row = self:_makeRow(section, 46)
    label(row, tostring(text), {
        Position = UDim2.fromOffset(13, 0),
        Size = UDim2.new(1, -82, 1, 0),
        TextSize = 12,
        ZIndex = 7,
    })
    local state = default == true
    local track = make("Frame", row, {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(43, 24),
        BackgroundColor3 = state and T.Accent or T.Raised,
        BorderSizePixel = 0,
        ZIndex = 7,
    })
    corner(track, 12)
    local knob = make("Frame", track, {
        Position = state and UDim2.fromOffset(22, 3) or UDim2.fromOffset(3, 3),
        Size = UDim2.fromOffset(18, 18),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 8,
    })
    corner(knob, 9)

    local hit = button(row, "", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ZIndex = 9,
    })
    local object = {value = state}
    local function set(value, fireCallback)
        state = value == true
        object.value = state
        tween(track, {BackgroundColor3 = state and T.Accent or T.Raised}, 0.18)
        tween(knob, {
            Position = state and UDim2.fromOffset(22, 3) or UDim2.fromOffset(3, 3),
        }, 0.18, Enum.EasingStyle.Back)
        if fireCallback ~= false and callback then callback(state) end
    end
    object.Set = function(value) set(value, true) end
    object.Get = function() return state end
    addConnection(self, hit.MouseButton1Click:Connect(function() set(not state, true) end))
    return object
end

function Library:AddSlider(section, text, minimum, maximum, default, isFloat, callback)
    assert(type(minimum) == "number" and type(maximum) == "number" and maximum > minimum,
        "Slider requires numeric min and max, with max > min")
    local T = self._theme
    local row = self:_makeRow(section, 66)
    local value = math.clamp(tonumber(default) or minimum, minimum, maximum)
    local valueLabel = label(row, tostring(value), {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -13, 0, 7),
        Size = UDim2.fromOffset(80, 18),
        TextColor3 = T.Accent,
        TextXAlignment = Enum.TextXAlignment.Right,
        Font = Enum.Font.GothamSemibold,
        TextSize = 11,
        ZIndex = 7,
    })
    label(row, tostring(text), {
        Position = UDim2.fromOffset(13, 7),
        Size = UDim2.new(1, -110, 0, 18),
        TextSize = 12,
        ZIndex = 7,
    })
    local track = make("Frame", row, {
        Position = UDim2.fromOffset(13, 39),
        Size = UDim2.new(1, -26, 0, 5),
        BackgroundColor3 = T.Raised,
        BorderSizePixel = 0,
        ZIndex = 7,
    })
    corner(track, 4)
    local fill = make("Frame", track, {
        Size = UDim2.new((value - minimum) / (maximum - minimum), 0, 1, 0),
        BackgroundColor3 = T.Accent,
        BorderSizePixel = 0,
        ZIndex = 8,
    })
    corner(fill, 4)
    local knob = make("Frame", track, {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new((value - minimum) / (maximum - minimum), 0, 0.5, 0),
        Size = UDim2.fromOffset(13, 13),
        BackgroundColor3 = T.TextPrimary,
        BorderSizePixel = 0,
        ZIndex = 9,
    })
    corner(knob, 7)

    local hit = button(row, "", {
        Position = UDim2.fromOffset(8, 27),
        Size = UDim2.new(1, -16, 0, 28),
        BackgroundTransparency = 1,
        ZIndex = 10,
    })
    local object = {value = value}
    local dragging = false
    local function set(newValue, fireCallback)
        newValue = math.clamp(tonumber(newValue) or minimum, minimum, maximum)
        if isFloat then
            newValue = math.floor(newValue * 100 + 0.5) / 100
        else
            newValue = math.floor(newValue + 0.5)
        end
        value = newValue
        object.value = value
        local ratio = (value - minimum) / (maximum - minimum)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        knob.Position = UDim2.new(ratio, 0, 0.5, 0)
        valueLabel.Text = tostring(value)
        if fireCallback ~= false and callback then callback(value) end
    end
    local function updateFromInput(input)
        local ratio = math.clamp(
            (input.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1),
            0, 1
        )
        set(minimum + ratio * (maximum - minimum), true)
    end
    addConnection(self, hit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
            input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromInput(input)
        end
    end))
    addConnection(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
            input.UserInputType == Enum.UserInputType.Touch) then
            updateFromInput(input)
        end
    end))
    addConnection(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
            input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))
    object.Set = function(newValue) set(newValue, true) end
    object.Get = function() return value end
    return object
end

function Library:AddTextbox(section, text, placeholder, default, callback)
    local T = self._theme
    local row = self:_makeRow(section, 46)
    label(row, tostring(text), {
        Position = UDim2.fromOffset(13, 0),
        Size = UDim2.new(0.43, -8, 1, 0),
        TextSize = 12,
        ZIndex = 7,
    })
    local input = make("TextBox", row, {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0.53, 0, 0, 29),
        BackgroundColor3 = T.Raised,
        TextColor3 = T.TextPrimary,
        PlaceholderColor3 = T.TextMuted,
        PlaceholderText = placeholder or "Type here...",
        Text = default or "",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        ClearTextOnFocus = false,
        BorderSizePixel = 0,
        ZIndex = 7,
    })
    corner(input, 8)
    outline(input, T.Border, 0.3, 1)
    padding(input, 9, 9, 0, 0)
    addConnection(self, input.FocusLost:Connect(function(enterPressed)
        if callback then callback(input.Text, enterPressed) end
    end))
    return input
end

function Library:AddDropdown(section, text, options, default, callback)
    local T = self._theme
    options = options or {}
    local row = self:_makeRow(section, 46)
    label(row, tostring(text), {
        Position = UDim2.fromOffset(13, 0),
        Size = UDim2.new(0.43, -8, 1, 0),
        TextSize = 12,
        ZIndex = 7,
    })
    local selected = default
    if selected == nil then selected = options[1] or "None" end

    local drop = button(row, tostring(selected) .. "   ▾", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0.53, 0, 0, 29),
        BackgroundColor3 = T.Raised,
        TextColor3 = T.TextPrimary,
        TextSize = 11,
        ZIndex = 8,
    })
    corner(drop, 8)
    outline(drop, T.Border, 0.3, 1)

    local object = {value = selected}
    local open = false
    local popup
    local function closePopup()
        open = false
        if popup then
            local old = popup
            popup = nil
            tween(old, {BackgroundTransparency = 1}, 0.12)
            task.delay(0.13, function()
                if old then old:Destroy() end
            end)
        end
    end
    local function set(value, fireCallback)
        selected = value
        object.value = value
        drop.Text = tostring(value) .. "   ▾"
        if fireCallback ~= false and callback then callback(value) end
        closePopup()
    end

    addConnection(self, drop.MouseButton1Click:Connect(function()
        if open then closePopup() return end
        open = true
        popup = make("Frame", self._gui, {
            Name = "DropdownPopup",
            Position = UDim2.fromOffset(drop.AbsolutePosition.X, drop.AbsolutePosition.Y + drop.AbsoluteSize.Y + 5),
            Size = UDim2.fromOffset(drop.AbsoluteSize.X, 0),
            BackgroundColor3 = T.Surface2,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            ZIndex = 80,
        })
        corner(popup, 9)
        outline(popup, T.Border, 0.1, 1)
        local list = make("ScrollingFrame", popup, {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = T.Accent,
            CanvasSize = UDim2.new(),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ZIndex = 81,
        })
        local layout = make("UIListLayout", list, {
            Padding = UDim.new(0, 2),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
        padding(list, 5, 5, 5, 5)
        for index, option in ipairs(options) do
            local choice = button(list, tostring(option), {
                Size = UDim2.new(1, 0, 0, 29),
                BackgroundColor3 = option == selected and T.AccentDim or T.Surface2,
                TextColor3 = option == selected and T.Accent or T.TextPrimary,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextSize = 11,
                LayoutOrder = index,
                ZIndex = 82,
            })
            corner(choice, 6)
            padding(choice, 9, 6, 0, 0)
            choice.MouseEnter:Connect(function()
                if option ~= selected then tween(choice, {BackgroundColor3 = T.Hover}, 0.1) end
            end)
            choice.MouseLeave:Connect(function()
                tween(choice, {BackgroundColor3 = option == selected and T.AccentDim or T.Surface2}, 0.1)
            end)
            addConnection(self, choice.MouseButton1Click:Connect(function()
                set(option, true)
            end))
        end
        local targetHeight = math.min(#options * 31 + 10, 180)
        tween(popup, {Size = UDim2.fromOffset(drop.AbsoluteSize.X, targetHeight)}, 0.16)
    end))

    object.Set = function(value) set(value, true) end
    object.Get = function() return selected end
    return object
end

function Library:AddKeybind(section, text, default, callback)
    local T = self._theme
    local row = self:_makeRow(section, 46)
    label(row, tostring(text), {
        Position = UDim2.fromOffset(13, 0),
        Size = UDim2.new(1, -125, 1, 0),
        TextSize = 12,
        ZIndex = 7,
    })
    local key = default or Enum.KeyCode.Unknown
    local listening = false
    local function keyName(value)
        if value == Enum.KeyCode.Unknown then return "None" end
        return value.Name
    end
    local bindButton = button(row, keyName(key), {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(91, 29),
        BackgroundColor3 = T.Raised,
        TextColor3 = T.TextPrimary,
        TextSize = 11,
        ZIndex = 7,
    })
    corner(bindButton, 8)
    outline(bindButton, T.Border, 0.3, 1)
    local object = {value = key}
    local function set(newKey, fireCallback)
        key = newKey
        object.value = key
        bindButton.Text = keyName(key)
        if fireCallback ~= false and callback then callback(key) end
    end
    addConnection(self, bindButton.MouseButton1Click:Connect(function()
        listening = true
        bindButton.Text = "Press a key..."
        tween(bindButton, {BackgroundColor3 = T.AccentDim}, 0.12)
    end))
    addConnection(self, UserInputService.InputBegan:Connect(function(input, processed)
        if not listening or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        listening = false
        tween(bindButton, {BackgroundColor3 = T.Raised}, 0.12)
        if input.KeyCode == Enum.KeyCode.Escape then
            bindButton.Text = keyName(key)
            return
        end
        set(input.KeyCode, true)
    end))
    object.Set = function(newKey) set(newKey, true) end
    object.Get = function() return key end
    return object
end

function Library:AddColorPicker(section, text, callback)
    local T = self._theme
    local row = self:_makeRow(section, 46)
    label(row, tostring(text), {
        Position = UDim2.fromOffset(13, 0),
        Size = UDim2.new(0.45, 0, 1, 0),
        TextSize = 12,
        ZIndex = 7,
    })
    local swatches = make("Frame", row, {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0.53, 0, 0, 28),
        BackgroundTransparency = 1,
        ZIndex = 7,
    })
    local layout = make("UIListLayout", swatches, {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
    })
    local buttons = {}
    for _, preset in ipairs(Library.AccentPresets) do
        local swatch = button(swatches, "", {
            Size = UDim2.fromOffset(20, 20),
            BackgroundColor3 = preset.color,
            ZIndex = 8,
        })
        corner(swatch, 10)
        outline(swatch, Color3.new(1, 1, 1), 0.7, 1)
        table.insert(buttons, swatch)
        addConnection(self, swatch.MouseButton1Click:Connect(function()
            self:SetAccent(preset.color)
            if callback then callback(preset.color, preset.name) end
            self:Notify("Accent set to " .. preset.name, preset.color)
        end))
        swatch.MouseEnter:Connect(function()
            tween(swatch, {Size = UDim2.fromOffset(23, 23)}, 0.1)
        end)
        swatch.MouseLeave:Connect(function()
            tween(swatch, {Size = UDim2.fromOffset(20, 20)}, 0.1)
        end)
    end
    return buttons
end

function Library:SetAccent(color)
    if typeof(color) ~= "Color3" then return self end
    local T = self._theme
    T.Accent = color
    T.AccentDim = Color3.new(color.R * 0.28, color.G * 0.28, color.B * 0.28)
    if self._windowStroke then self._windowStroke.Color = T.Border end
    if self._tabList then self._tabList.ScrollBarImageColor3 = color end
    for _, tab in ipairs(self._tabs) do
        tab.page.ScrollBarImageColor3 = color
        tab.activeMark.BackgroundColor3 = color
    end
    return self
end

function Library:Destroy()
    if self._destroyed then return end
    self._destroyed = true
    for _, connection in ipairs(self._connections) do
        pcall(function() connection:Disconnect() end)
    end
    table.clear(self._connections)
    if self._gui then self._gui:Destroy() end
end

return Library
