local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local TextService = game:GetService("TextService")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")

local Library = {}
Library.__index = Library
Library.Version = "2.4.1"
Library.DefaultLogo = 127590426518205
Library.DefaultScale = 1.25

local Tab = {}
Tab.__index = Tab

local Element = {}
Element.__index = Element

Library.Themes = {
    Dark = {
        Background = Color3.fromRGB(15, 15, 19),
        Surface = Color3.fromRGB(21, 21, 27),
        Element = Color3.fromRGB(28, 28, 36),
        ElementHover = Color3.fromRGB(36, 36, 47),
        Stroke = Color3.fromRGB(44, 44, 56),
        Text = Color3.fromRGB(235, 235, 242),
        SubText = Color3.fromRGB(142, 142, 160),
        Accent = Color3.fromRGB(74, 163, 255),
        Success = Color3.fromRGB(72, 199, 128),
        Warning = Color3.fromRGB(255, 184, 77),
        Error = Color3.fromRGB(240, 84, 84),
    },
    Midnight = {
        Background = Color3.fromRGB(8, 10, 22),
        Surface = Color3.fromRGB(13, 16, 33),
        Element = Color3.fromRGB(19, 23, 46),
        ElementHover = Color3.fromRGB(27, 32, 60),
        Stroke = Color3.fromRGB(38, 44, 80),
        Text = Color3.fromRGB(232, 234, 248),
        SubText = Color3.fromRGB(132, 138, 176),
        Accent = Color3.fromRGB(125, 112, 255),
        Success = Color3.fromRGB(72, 199, 128),
        Warning = Color3.fromRGB(255, 184, 77),
        Error = Color3.fromRGB(240, 84, 84),
    },
    Crimson = {
        Background = Color3.fromRGB(16, 10, 12),
        Surface = Color3.fromRGB(23, 14, 17),
        Element = Color3.fromRGB(31, 19, 23),
        ElementHover = Color3.fromRGB(41, 25, 30),
        Stroke = Color3.fromRGB(60, 34, 40),
        Text = Color3.fromRGB(242, 232, 234),
        SubText = Color3.fromRGB(160, 136, 142),
        Accent = Color3.fromRGB(236, 66, 84),
        Success = Color3.fromRGB(72, 199, 128),
        Warning = Color3.fromRGB(255, 184, 77),
        Error = Color3.fromRGB(255, 96, 96),
    },
    Light = {
        Background = Color3.fromRGB(243, 244, 248),
        Surface = Color3.fromRGB(231, 233, 240),
        Element = Color3.fromRGB(255, 255, 255),
        ElementHover = Color3.fromRGB(238, 241, 248),
        Stroke = Color3.fromRGB(210, 215, 226),
        Text = Color3.fromRGB(28, 30, 40),
        SubText = Color3.fromRGB(100, 106, 126),
        Accent = Color3.fromRGB(50, 115, 235),
        Success = Color3.fromRGB(34, 160, 94),
        Warning = Color3.fromRGB(222, 148, 30),
        Error = Color3.fromRGB(215, 62, 62),
    },
}

Library.Icons = {
    ["home"] = 7733960981, ["main"] = 7733970318, ["settings"] = 7734053495, ["combat"] = 7733765307, ["visuals"] = 7733774602, ["player"] = 7743875962,
    ["settings-2"] = 8997386997, ["user"] = 7743875962, ["users"] = 7743876054, ["user-check"] = 7743875503, ["user-plus"] = 7743875759, ["user-x"] = 7743875879, ["user-minus"] = 7743875629,
    ["eye"] = 7733774602, ["eye-off"] = 7733774495, ["crosshair"] = 7733765307, ["target"] = 7743872758, ["shield"] = 7734056608, ["shield-check"] = 7734056411, ["shield-alert"] = 7734056326, ["shield-off"] = 7734056540,
    ["key"] = 7733965118, ["lock"] = 7733992528, ["unlock"] = 7743875263, ["bell"] = 7733911828, ["bell-off"] = 7733675107, ["bell-ring"] = 7733675275, ["info"] = 7733964719,
    ["link"] = 7733978098, ["link-2"] = 7743869163, ["copy"] = 7733764083, ["clipboard"] = 7733734762, ["clipboard-list"] = 7733920117, ["check"] = 7733715400, ["check-circle"] = 7733919427, ["check-square"] = 7733919526,
    ["x"] = 7743878857, ["x-circle"] = 7743878496, ["plus"] = 7734042071, ["plus-circle"] = 7734040271, ["plus-square"] = 7734040369, ["minus"] = 7734000129, ["search"] = 7734052925, ["star"] = 7734068321,
    ["heart"] = 7733956134, ["flame"] = 7733798747, ["electricity"] = 7733771628, ["electricity-off"] = 7733771563, ["gamepad"] = 7733799901, ["gamepad-2"] = 7733799795, ["cpu"] = 7733765045, ["monitor"] = 7734002839,
    ["monitor-off"] = 7734000184, ["palette"] = 7734021595, ["brush"] = 7733701455, ["sliders"] = 7734058803, ["wrench"] = 7743878358, ["hammer"] = 7733955511, ["terminal"] = 7743872929, ["terminal-square"] = 7734079055,
    ["code"] = 7733749837, ["file-code"] = 7733779730, ["bug"] = 7733701545, ["globe"] = 7733954760, ["wifi"] = 7743878148, ["wifi-off"] = 7743878056, ["cloud"] = 7733746980, ["cloud-off"] = 7733745572,
    ["cloud-lightning"] = 7733741741, ["download"] = 7733770755, ["upload"] = 7743875428, ["download-cloud"] = 7733770689, ["upload-cloud"] = 7743875358, ["save"] = 7734052335, ["refresh-cw"] = 7734051052, ["refresh-ccw"] = 7734050715,
    ["play"] = 7743871480, ["play-circle"] = 7734037784, ["pause"] = 7734021897, ["pause-circle"] = 7734021767, ["stop-circle"] = 7734068379, ["power"] = 7734042493, ["power-off"] = 7734042423, ["clock"] = 7733734848,
    ["timer"] = 7743873443, ["alarm-clock"] = 7733656100, ["calendar"] = 7733919198, ["map"] = 7733992829, ["map-pin"] = 7733992789, ["compass"] = 7733924216, ["navigation"] = 7734020989, ["flag"] = 7733798691,
    ["bookmark"] = 7733692043, ["book"] = 7733914390, ["book-open"] = 7733687281, ["library"] = 7743869054, ["layers"] = 7743868936, ["layout-dashboard"] = 7733970318, ["layout-grid"] = 7733970390, ["layout-list"] = 7733970442,
    ["layout"] = 7733970543, ["layout-template"] = 7733970494, ["list"] = 7743869612, ["menu"] = 7733993211, ["grid"] = 7733955179, ["columns"] = 7733757178, ["table"] = 7734073253, ["sidebar"] = 7734058260,
    ["mouse-pointer"] = 7743870392, ["mouse-pointer-2"] = 7734010405, ["mouse-pointer-click"] = 7734010488, ["pointer"] = 7734042307, ["hand"] = 7733955740, ["grab"] = 7733954884, ["move"] = 7743870731, ["maximize"] = 7733992982,
    ["minimize"] = 7733997941, ["expand"] = 7733771982, ["music"] = 7734020554, ["camera"] = 7733708692, ["video"] = 7743876610, ["video-off"] = 7743876466, ["image"] = 7733964126, ["mic"] = 7743869805,
    ["mic-off"] = 7743869714, ["volume-2"] = 7743877250, ["volume-x"] = 7743877381, ["speaker"] = 7734063416, ["headphones"] = 7733956063, ["sun"] = 7734068495, ["moon"] = 7743870134, ["snowflake"] = 7734059180,
    ["droplet"] = 7733770982, ["droplets"] = 7733771078, ["wind"] = 7743878264, ["tornado"] = 7743873633, ["umbrella"] = 7743874820, ["ghost"] = 7743868000, ["skull"] = 7734058599, ["crown"] = 7733765398,
    ["gem"] = 7733942651, ["gift"] = 7733946818, ["award"] = 7733673987, ["bot"] = 7733916988, ["box"] = 7733917120, ["package"] = 7734021469, ["archive"] = 7733911621, ["database"] = 7743866778,
    ["server"] = 7734053426, ["hard-drive"] = 7733955793, ["activity"] = 7733655755, ["bar-chart"] = 7733674319, ["bar-chart-2"] = 7733674239, ["pie-chart"] = 7734034378, ["gauge"] = 7733799969, ["battery"] = 7733674820,
    ["battery-full"] = 7733674503, ["alert-triangle"] = 7733658504, ["alert-circle"] = 7733658271, ["alert-octagon"] = 7733658335, ["help-circle"] = 7733956210, ["trash"] = 7743873871, ["trash-2"] = 7743873772, ["edit"] = 7733771472,
    ["edit-2"] = 7733771217, ["pencil"] = 7734022107, ["scissors"] = 7734052570, ["filter"] = 7733798407, ["tag"] = 7734075797, ["ticket"] = 7734086558, ["wallet"] = 7743877573, ["coins"] = 7743866529,
    ["dollar-sign"] = 7733770599, ["banknote"] = 7733674153, ["shopping-cart"] = 7734056813, ["shopping-bag"] = 7734056747, ["truck"] = 7743874482, ["car"] = 7733708835, ["plane"] = 7734037723, ["bike"] = 7733678330,
    ["tent"] = 7734078943, ["mountain"] = 7734008868, ["mountain-snow"] = 7743870286, ["sprout"] = 7743872071, ["feather"] = 7733777166, ["anchor"] = 7733911490, ["axe"] = 7733674079, ["beaker"] = 7733674922,
    ["flask-conical"] = 7733798901, ["lightbulb"] = 7733975185, ["megaphone"] = 7733993049, ["quote"] = 7734045100, ["send"] = 7734053039, ["mail"] = 7733992732, ["message-circle"] = 7733993311, ["message-square"] = 7733993369,
    ["hash"] = 7733955906, ["at-sign"] = 7733673907, ["github"] = 7733954058, ["chrome"] = 7733919783, ["share"] = 7734053697, ["share-2"] = 7734053595, ["external-link"] = 7743866903, ["log-in"] = 7733992604,
    ["log-out"] = 7733992677, ["wand"] = 8997388430, ["aperture"] = 7733666258, ["scan"] = 8997386861, ["locate"] = 7733992469, ["locate-fixed"] = 7733992424, ["radio"] = 7743871662, ["rewind"] = 7734051670,
    ["fast-forward"] = 7743867090, ["forward"] = 7733799371, ["skip-back"] = 7734058404, ["skip-forward"] = 7734058495, ["repeat"] = 7734051454, ["shuffle"] = 7734057059, ["undo"] = 7743874974, ["redo"] = 7743871739,
    ["rotate-cw"] = 7734051957, ["rotate-ccw"] = 7734051861, ["history"] = 7733960880, ["glasses"] = 7733954403, ["shirt"] = 7734056672, ["person-standing"] = 7743871002, ["smile"] = 7734059095, ["frown"] = 7733799591,
    ["meh"] = 7733993147, ["thumbs-up"] = 7743873212, ["thumbs-down"] = 7734084236, ["toggle-left"] = 7734091286, ["toggle-right"] = 7743873539, ["sigma"] = 7734058345, ["percent"] = 7743870852, ["calculator"] = 7733919105,
    ["ruler"] = 7734052157, ["scale"] = 7734052454, ["gavel"] = 7733800044, ["landmark"] = 7733965184, ["building"] = 7733701625, ["briefcase"] = 7733919017, ["smartphone"] = 7734058979, ["laptop"] = 7733965386,
    ["tv"] = 7743874674, ["signal"] = 8997387546, ["signal-high"] = 8997387110, ["network"] = 7734021047, ["loader"] = 7733992358, ["loader-2"] = 7733989869, ["infinity"] = 7733964640, ["command"] = 7733924046,
    ["option"] = 7734021300, ["regex"] = 7734051188, ["binary"] = 7733678388, ["type"] = 7743874740, ["bold"] = 7733687211, ["italic"] = 7733964917, ["align-left"] = 7733911357, ["align-center"] = 7733909776,
    ["align-right"] = 7733663582, ["arrow-up"] = 7733673717, ["arrow-down"] = 7733672933, ["arrow-left"] = 7733673136, ["arrow-right"] = 7733673345, ["chevron-up"] = 7733919605, ["chevron-down"] = 7733717447, ["chevron-left"] = 7733717651,
    ["chevron-right"] = 7733717755, ["more-horizontal"] = 7734006080, ["more-vertical"] = 7734006187, ["circle"] = 7733919881, ["square"] = 7743872181, ["triangle"] = 7743874367, ["hexagon"] = 7743868527, ["pin"] = 8997386648,
    ["paperclip"] = 7734021680, ["file"] = 7733793319, ["file-text"] = 7733789088, ["file-check"] = 7733779668, ["files"] = 7743867811, ["folder"] = 7733799185, ["folder-open"] = 8997386062, ["verified"] = 7743876142,
    ["zoom-in"] = 7743878977, ["zoom-out"] = 7743879082, ["flashlight"] = 7733798851, ["inspect"] = 7733964808, ["qr-code"] = 7743871575, ["cookie"] = 8997385628, ["coffee"] = 7733752630, ["crop"] = 7733765140,
    ["cast"] = 7733919326, ["haze"] = 7733955969, ["life-buoy"] = 7733973479, ["lasso"] = 7733967892, ["bluetooth"] = 7733687147, ["unlink"] = 7743875149, ["git-branch"] = 7733949149, ["git-merge"] = 7733952195,
    ["git-commit"] = 7743868360, ["git-pull-request"] = 7733952287, ["thermometer"] = 7734084149, ["tv-2"] = 7743874599, ["pipette"] = 7743871384, ["piggy-bank"] = 7734034513, ["trending-up"] = 7743874262, ["trending-down"] = 7743874143,
    ["clover"] = 7733747233, ["contrast"] = 7733764005, ["sort-asc"] = 7734060715, ["sort-desc"] = 7743871973, ["slash"] = 8997387644, ["screen-share"] = 7734052814, ["rss"] = 7734052075, ["watch"] = 7743877668,
}

local function clamp(v, a, b)
    return math.max(a, math.min(b, v))
end

local function round(v, dec)
    local m = 10 ^ (dec or 0)
    return math.floor(v * m + 0.5) / m
end

local function randomName()
    return HttpService:GenerateGUID(false)
end

local function toAsset(v)
    if type(v) == "number" then
        return "rbxassetid://" .. tostring(math.floor(v))
    end
    if type(v) == "string" then
        if v:find("^rbxasset") or v:find("^http") then
            return v
        end
        if v:match("^%d+$") then
            return "rbxassetid://" .. v
        end
    end
    return nil
end

local function mergeIcons(into, pack)
    if type(pack) ~= "table" then
        return
    end
    for k, v in pairs(pack) do
        into[tostring(k):lower()] = v
    end
end

local function resolveIcon(icons, icon, name)
    local letter = tostring(name or "?"):sub(1, 1):upper()
    if icon == nil then
        return "text", letter
    end
    if type(icon) == "number" then
        return "image", toAsset(icon)
    end
    if type(icon) == "string" then
        if icon == "" then
            return "text", letter
        end
        local direct = toAsset(icon)
        if direct and (icon:find("^rbxasset") or icon:find("^http") or #icon >= 4) then
            return "image", direct
        end
        local entry = icons[icon:lower()]
        if entry ~= nil then
            local asset = toAsset(entry)
            if asset then
                return "image", asset
            end
            return "text", letter
        end
        return "text", icon:sub(1, 2)
    end
    return "text", letter
end

local function norm(o, cb)
    if type(o) == "string" then
        return { Name = o, Callback = cb }
    end
    return o or {}
end

local function fire(cb, ...)
    if type(cb) ~= "function" then
        return
    end
    local ok, err = pcall(cb, ...)
    if not ok then
        warn("[HumidityHub] " .. tostring(err))
    end
end

local function tw(obj, time, props, style, dir)
    local tween = TweenService:Create(obj, TweenInfo.new(time, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
    tween:Play()
    return tween
end

local TEXT_CLASSES = { TextLabel = true, TextButton = true, TextBox = true }

local function new(class, props, children)
    local obj = Instance.new(class)
    if class == "Frame" or class == "CanvasGroup" or class == "ScrollingFrame" or class == "ImageLabel" or class == "ImageButton" or TEXT_CLASSES[class] then
        obj.BorderSizePixel = 0
    end
    if TEXT_CLASSES[class] then
        obj.Font = Enum.Font.Gotham
        obj.TextSize = 14
        obj.TextColor3 = Color3.new(1, 1, 1)
    end
    if class == "TextLabel" then
        obj.BackgroundTransparency = 1
        obj.TextXAlignment = Enum.TextXAlignment.Left
    end
    if class == "ImageLabel" then
        obj.BackgroundTransparency = 1
    end
    if class == "TextButton" or class == "ImageButton" then
        obj.AutoButtonColor = false
    end
    local parent
    for k, v in pairs(props or {}) do
        if k == "Parent" then
            parent = v
        else
            obj[k] = v
        end
    end
    for _, c in ipairs(children or {}) do
        c.Parent = obj
    end
    if parent then
        obj.Parent = parent
    end
    return obj
end

local function corner(parent, radius)
    return new("UICorner", { CornerRadius = UDim.new(0, radius), Parent = parent })
end

local function stroke(parent, thickness, transparency)
    return new("UIStroke", {
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function padding(parent, l, t, r, b)
    return new("UIPadding", {
        PaddingLeft = UDim.new(0, l or 0),
        PaddingTop = UDim.new(0, t or 0),
        PaddingRight = UDim.new(0, r or 0),
        PaddingBottom = UDim.new(0, b or 0),
        Parent = parent,
    })
end

local function listLayout(parent, gap, horizontal)
    return new("UIListLayout", {
        Padding = UDim.new(0, gap or 0),
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = horizontal and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
        Parent = parent,
    })
end

local function safeParent()
    local ok, ui = pcall(function()
        return gethui and gethui()
    end)
    if ok and ui then
        return ui
    end
    local ok2 = pcall(function()
        return CoreGui.Name
    end)
    if ok2 then
        return CoreGui
    end
    return Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function canFile()
    return type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
end

local function ensureFolder(path)
    if type(makefolder) ~= "function" or type(isfolder) ~= "function" then
        return
    end
    local built = ""
    for part in path:gmatch("[^/\\]+") do
        built = built == "" and part or (built .. "/" .. part)
        pcall(function()
            if not isfolder(built) then
                makefolder(built)
            end
        end)
    end
end

local function writeFile(path, data)
    if not canFile() then
        return false
    end
    local dir = path:match("^(.*)[/\\][^/\\]+$")
    if dir then
        ensureFolder(dir)
    end
    local ok = pcall(writefile, path, data)
    return ok
end

local function readFile(path)
    if not canFile() then
        return nil
    end
    local ok, exists = pcall(isfile, path)
    if not ok or not exists then
        return nil
    end
    local ok2, data = pcall(readfile, path)
    if ok2 then
        return data
    end
    return nil
end

local function deleteFile(path)
    if type(delfile) == "function" then
        pcall(delfile, path)
    end
end

local function pointer(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        local inset = GuiService:GetGuiInset()
        return Vector2.new(input.Position.X, input.Position.Y + inset.Y)
    end
    return UserInputService:GetMouseLocation()
end

local function toKeyCode(v)
    if typeof(v) == "EnumItem" then
        return v
    end
    if type(v) == "string" then
        local ok, code = pcall(function()
            return Enum.KeyCode[v]
        end)
        if ok and code then
            return code
        end
    end
    return Enum.KeyCode.Unknown
end

local function daysFromCivil(y, m, d)
    if m <= 2 then
        y = y - 1
    end
    local era = math.floor(y / 400)
    local yoe = y - era * 400
    local mp = (m + 9) % 12
    local doy = math.floor((153 * mp + 2) / 5) + d - 1
    local doe = yoe * 365 + math.floor(yoe / 4) - math.floor(yoe / 100) + doy
    return era * 146097 + doe - 719468
end

local function parseISO(s)
    local y, mo, d, h, mi, sec = tostring(s):match("(%d+)-(%d+)-(%d+)[T ](%d+):(%d+):(%d+)")
    if not y then
        return nil
    end
    local t = daysFromCivil(tonumber(y), tonumber(mo), tonumber(d)) * 86400 + tonumber(h) * 3600 + tonumber(mi) * 60 + tonumber(sec)
    local sign, oh, om = tostring(s):match("([%+%-])(%d%d):?(%d%d)$")
    if sign then
        local off = tonumber(oh) * 3600 + tonumber(om) * 60
        if sign == "+" then
            t = t - off
        else
            t = t + off
        end
    end
    return t
end

local function extractExpiry(info)
    if type(info) == "number" then
        if info > 1e11 then
            info = info / 1000
        end
        if info > 1e9 then
            return info
        end
        return os.time() + info
    end
    if type(info) == "string" then
        return parseISO(info)
    end
    if type(info) == "table" then
        for _, k in ipairs({ "ExpiresAt", "expiresAt", "expires_at", "Expires", "expires", "Expiry", "expiry" }) do
            local v = info[k]
            if v ~= nil and type(v) ~= "table" then
                local r = extractExpiry(v)
                if r then
                    return r
                end
            end
        end
        for _, k in ipairs({ "SecondsLeft", "secondsLeft", "seconds_left", "Remaining", "remaining", "TimeLeft", "ttl" }) do
            local v = info[k]
            if type(v) == "number" then
                return os.time() + v
            end
        end
    end
    return nil
end

local function extractMessage(info, default)
    if type(info) == "string" and info ~= "" then
        return info
    end
    if type(info) == "table" then
        for _, k in ipairs({ "message", "Message", "reason", "error", "Error", "msg" }) do
            if type(info[k]) == "string" then
                return info[k]
            end
        end
    end
    return default
end

local function formatTime(seconds)
    seconds = math.max(0, math.floor(seconds))
    local d = math.floor(seconds / 86400)
    local h = math.floor((seconds % 86400) / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    if d > 0 then
        return string.format("%dd %dh", d, h)
    elseif h > 0 then
        return string.format("%dh %02dm", h, m)
    end
    return string.format("%dm %02ds", m, s)
end

function Library:_conn(signal, fn)
    local c = signal:Connect(fn)
    table.insert(self._conns, c)
    return c
end

function Library:_color(key)
    if key == "Accent" then
        return self.Accent
    end
    return self.Theme[key]
end

function Library:_bind(obj, prop, key)
    table.insert(self._bound, { obj, prop, key })
    obj[prop] = self:_color(key)
end

function Library:_painter(fn)
    table.insert(self._painters, fn)
    fn()
    return fn
end

function Library:_tintIcon(obj, isImage, color)
    if isImage then
        obj.ImageColor3 = color
    else
        obj.TextColor3 = color
    end
end

function Library:_makeIcon(parent, spec, name, size)
    local kind, value = resolveIcon(self.Icons, spec, name)
    local obj
    if kind == "image" then
        obj = new("ImageLabel", {
            Name = "Icon",
            Size = UDim2.fromOffset(size, size),
            Image = value,
            ScaleType = Enum.ScaleType.Fit,
            Parent = parent,
        })
    else
        obj = new("TextLabel", {
            Name = "Icon",
            Size = UDim2.fromOffset(size, size),
            Text = value,
            Font = Enum.Font.GothamBold,
            TextSize = math.max(10, math.floor(size * 0.8)),
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = parent,
        })
    end
    return obj, kind == "image"
end

function Library:_hover(btn)
    self:_conn(btn.MouseEnter, function()
        tw(btn, 0.15, { BackgroundColor3 = self.Theme.ElementHover })
    end)
    self:_conn(btn.MouseLeave, function()
        tw(btn, 0.15, { BackgroundColor3 = self.Theme.Element })
    end)
    self:_conn(btn.MouseButton1Down, function()
        tw(btn, 0.08, { BackgroundColor3 = self.Theme.Stroke })
    end)
    self:_conn(btn.MouseButton1Up, function()
        tw(btn, 0.12, { BackgroundColor3 = self.Theme.ElementHover })
    end)
end

function Library:_dragify(target, onMove, onStart)
    local dragging = false
    local moveConn, endConn
    target.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            if onStart then
                onStart(input)
            end
            onMove(input)
            if moveConn then
                moveConn:Disconnect()
            end
            if endConn then
                endConn:Disconnect()
            end
            moveConn = UserInputService.InputChanged:Connect(function(i)
                if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    onMove(i)
                end
            end)
            endConn = UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                    if moveConn then
                        moveConn:Disconnect()
                        moveConn = nil
                    end
                    if endConn then
                        endConn:Disconnect()
                        endConn = nil
                    end
                end
            end)
        end
    end)
end

function Library:_button(parent, text, style, props)
    style = style or "outline"
    local btn = new("TextButton", {
        Text = text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
        Parent = parent,
    })
    for k, v in pairs(props or {}) do
        btn[k] = v
    end
    corner(btn, 8)
    local st = stroke(btn, 1, 0.3)
    local function base()
        if style == "accent" then
            return self.Accent
        elseif style == "danger" then
            return self.Theme.Error
        end
        return self.Theme.Element
    end
    local function hoverColor()
        if style == "outline" then
            return self.Theme.ElementHover
        end
        return base():Lerp(Color3.new(1, 1, 1), 0.14)
    end
    self:_painter(function()
        btn.BackgroundColor3 = base()
        btn.TextColor3 = style == "outline" and self.Theme.Text or Color3.new(1, 1, 1)
        st.Color = self.Theme.Stroke
        st.Enabled = style == "outline"
    end)
    self:_conn(btn.MouseEnter, function()
        tw(btn, 0.15, { BackgroundColor3 = hoverColor() })
    end)
    self:_conn(btn.MouseLeave, function()
        tw(btn, 0.15, { BackgroundColor3 = base() })
    end)
    return btn
end

function Library.new(opts)
    opts = opts or {}
    local self = setmetatable({}, Library)

    self.Name = opts.Name or "Humidity Hub"
    self.Subtitle = opts.Subtitle or ""
    self.Destroyed = false
    self.Visible = false
    self.Inited = false
    self.StartHidden = opts.StartHidden == true
    self.SettingsEnabled = opts.Settings ~= false
    self.ConfigFolder = opts.ConfigFolder or "HumidityHub/configs"

    self._vis = 0
    self._conns = {}
    self._bound = {}
    self._painters = {}
    self._keybinds = {}
    self._notifs = {}
    self._notifId = 0
    self._destroyCallbacks = {}
    self.Tabs = {}
    self.Flags = {}

    self.Icons = {}
    mergeIcons(self.Icons, Library.Icons)
    if opts.Icons then
        mergeIcons(self.Icons, opts.Icons)
    end

    local themeName = opts.Theme or "Dark"
    if not Library.Themes[themeName] then
        themeName = "Dark"
    end
    self.ThemeName = themeName
    self.Theme = Library.Themes[themeName]
    self.Accent = opts.Accent or self.Theme.Accent
    self.CustomAccent = opts.Accent ~= nil

    self.UserScale = clamp(tonumber(opts.Scale) or Library.DefaultScale, 0.6, 1.6)
    self.ToggleKey = toKeyCode(opts.ToggleKey or Enum.KeyCode.RightShift)
    if self.ToggleKey == Enum.KeyCode.Unknown then
        self.ToggleKey = Enum.KeyCode.RightShift
    end
    self.BackdropEnabled = opts.Backdrop ~= false
    self.BackdropTransparency = opts.BackdropTransparency or 0.45
    self.BlurEnabled = opts.Blur == true
    self.BlurSize = opts.BlurSize or 14

    self.KeyEnabled = false
    self.Unlocked = true
    self.KeyFile = "HumidityHub/key.txt"
    self.RememberKey = false
    self.KeyPrompt = {
        Title = "Key required",
        Subtitle = "Enter your key to unlock the hub.",
        Placeholder = "Paste your key",
        Submit = "Unlock",
        Link = "Get key",
    }

    self.WatermarkEnabled = false
    self.WatermarkText = self.Name
    self._fps = 60

    local env = (getgenv and getgenv()) or _G
    if env.__HumidityHubInstance and env.__HumidityHubInstance ~= self and env.__HumidityHubInstance.Destroy then
        pcall(function()
            env.__HumidityHubInstance:Destroy()
        end)
    end
    env.__HumidityHubInstance = self

    local size = opts.Size or UDim2.fromOffset(640, 420)

    local gui = new("ScreenGui", {
        Name = randomName(),
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 1000,
    })
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(gui)
        end
    end)
    gui.Parent = safeParent()
    self.Gui = gui

    self.BlurObj = new("BlurEffect", { Name = randomName(), Size = 0, Enabled = false, Parent = Lighting })

    self.Backdrop = new("Frame", {
        Name = "Backdrop",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 1,
        Parent = gui,
    })

    self.Holder = new("Frame", {
        Name = "Holder",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = size,
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 2,
        Parent = gui,
    })

    self.Main = new("CanvasGroup", {
        Name = "Main",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        GroupTransparency = 1,
        Parent = self.Holder,
    })
    self:_bind(self.Main, "BackgroundColor3", "Background")
    corner(self.Main, 12)
    local mainStroke = stroke(self.Main, 1, 0.2)
    self:_bind(mainStroke, "Color", "Stroke")
    self.Scaler = new("UIScale", { Scale = self.UserScale, Parent = self.Main })

    local top = new("Frame", {
        Name = "Topbar",
        Size = UDim2.new(1, 0, 0, 44),
        Parent = self.Main,
    })
    self:_bind(top, "BackgroundColor3", "Surface")
    local topLine = new("Frame", {
        Position = UDim2.new(0, 0, 1, -1),
        Size = UDim2.new(1, 0, 0, 1),
        Parent = top,
    })
    self:_bind(topLine, "BackgroundColor3", "Stroke")

    self.LogoImage = new("ImageLabel", {
        Name = "Logo",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 12, 0.5, 0),
        Size = UDim2.fromOffset(26, 26),
        Image = toAsset(opts.Logo or Library.DefaultLogo),
        Parent = top,
    })
    corner(self.LogoImage, 7)

    self.TitleLabel = new("TextLabel", {
        Text = self.Name,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = top,
    })
    self:_bind(self.TitleLabel, "TextColor3", "Text")
    self.SubtitleLabel = new("TextLabel", {
        Text = self.Subtitle,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = top,
    })
    self:_bind(self.SubtitleLabel, "TextColor3", "SubText")
    self:_layoutTitle()

    local closeBtn = new("TextButton", {
        Name = "Close",
        Text = "",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(28, 28),
        BackgroundTransparency = 1,
        Parent = top,
    })
    corner(closeBtn, 7)
    local closeIcon, closeIsImage = self:_makeIcon(closeBtn, "x", "x", 16)
    closeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    closeIcon.Position = UDim2.fromScale(0.5, 0.5)
    self:_painter(function()
        self:_tintIcon(closeIcon, closeIsImage, self.Theme.SubText)
    end)
    self:_conn(closeBtn.MouseEnter, function()
        tw(closeBtn, 0.15, { BackgroundTransparency = 0, BackgroundColor3 = self.Theme.Element })
    end)
    self:_conn(closeBtn.MouseLeave, function()
        tw(closeBtn, 0.15, { BackgroundTransparency = 1 })
    end)
    self:_conn(closeBtn.MouseButton1Click, function()
        self:Hide()
    end)

    local dragStartPointer, dragStartPos
    self:_dragify(top, function(input)
        if not dragStartPointer then
            return
        end
        local delta = pointer(input) - dragStartPointer
        self.Holder.Position = UDim2.new(dragStartPos.X.Scale, dragStartPos.X.Offset + delta.X, dragStartPos.Y.Scale, dragStartPos.Y.Offset + delta.Y)
    end, function(input)
        dragStartPointer = pointer(input)
        dragStartPos = self.Holder.Position
    end)

    local body = new("Frame", {
        Name = "Body",
        Position = UDim2.fromOffset(0, 44),
        Size = UDim2.new(1, 0, 1, -44),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = self.Main,
    })

    self.App = new("Frame", {
        Name = "App",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Parent = body,
    })

    local sidebar = new("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 156, 1, 0),
        Parent = self.App,
    })
    self:_bind(sidebar, "BackgroundColor3", "Surface")
    local sideLine = new("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        Parent = sidebar,
    })
    self:_bind(sideLine, "BackgroundColor3", "Stroke")

    self.TabList = new("ScrollingFrame", {
        Name = "Tabs",
        Position = UDim2.fromOffset(8, 8),
        Size = UDim2.new(1, -16, 1, -16),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = sidebar,
    })
    listLayout(self.TabList, 4)

    self.Countdown = new("Frame", {
        Name = "Countdown",
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 8, 1, -8),
        Size = UDim2.new(1, -16, 0, 34),
        Visible = false,
        Parent = sidebar,
    })
    self:_bind(self.Countdown, "BackgroundColor3", "Element")
    corner(self.Countdown, 8)
    local pillStroke = stroke(self.Countdown, 1, 0.4)
    self:_bind(pillStroke, "Color", "Stroke")
    self.PillIcon, self.PillIconIsImage = self:_makeIcon(self.Countdown, "key", "K", 16)
    self.PillIcon.AnchorPoint = Vector2.new(0, 0.5)
    self.PillIcon.Position = UDim2.new(0, 10, 0.5, 0)
    self.PillLabel = new("TextLabel", {
        Text = "--",
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        Position = UDim2.fromOffset(34, 0),
        Size = UDim2.new(1, -40, 1, 0),
        Parent = self.Countdown,
    })
    self:_setPill("--", "Accent")

    self.Content = new("Frame", {
        Name = "Content",
        Position = UDim2.fromOffset(156, 0),
        Size = UDim2.new(1, -156, 1, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = self.App,
    })

    self.KeyFrame = new("Frame", {
        Name = "KeyFrame",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = body,
    })
    self:_buildKeyPage()

    self.NotifHolder = new("Frame", {
        Name = "Notifications",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -16, 1, -16),
        Size = UDim2.new(0, 310, 1, -32),
        BackgroundTransparency = 1,
        ZIndex = 40,
        Parent = gui,
    })
    new("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Parent = self.NotifHolder,
    })

    self.Watermark = new("Frame", {
        Name = "Watermark",
        Position = UDim2.fromOffset(12, 12),
        Size = UDim2.fromOffset(0, 28),
        AutomaticSize = Enum.AutomaticSize.X,
        Visible = false,
        ZIndex = 30,
        Parent = gui,
    })
    self:_bind(self.Watermark, "BackgroundColor3", "Surface")
    self.Watermark.BackgroundTransparency = 0.1
    corner(self.Watermark, 8)
    local wmStroke = stroke(self.Watermark, 1, 0.3)
    self:_bind(wmStroke, "Color", "Stroke")
    padding(self.Watermark, 8, 0, 10, 0)
    new("UIListLayout", {
        Padding = UDim.new(0, 6),
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.Watermark,
    })
    self.WatermarkLogo = new("ImageLabel", {
        Size = UDim2.fromOffset(16, 16),
        Image = toAsset(opts.Logo or Library.DefaultLogo),
        LayoutOrder = 1,
        Parent = self.Watermark,
    })
    corner(self.WatermarkLogo, 4)
    self.WatermarkLabel = new("TextLabel", {
        Text = self.WatermarkText,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        Size = UDim2.fromOffset(0, 28),
        AutomaticSize = Enum.AutomaticSize.X,
        LayoutOrder = 2,
        Parent = self.Watermark,
    })
    self:_bind(self.WatermarkLabel, "TextColor3", "Text")

    local frames, last = 0, os.clock()
    self:_conn(RunService.Heartbeat, function()
        frames = frames + 1
        local now = os.clock()
        if now - last >= 0.5 then
            self._fps = math.floor(frames / (now - last) + 0.5)
            frames = 0
            last = now
            if self.WatermarkEnabled then
                self.WatermarkLabel.Text = self.WatermarkText .. "  |  " .. tostring(self._fps) .. " fps"
            end
        end
    end)

    self:_conn(UserInputService.InputBegan, function(input, processed)
        if self._listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local cb = self._listening
                self._listening = nil
                cb(input.KeyCode)
            end
            return
        end
        if processed then
            return
        end
        if input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode == self.ToggleKey then
            self:Toggle()
            return
        end
        for _, kb in ipairs(self._keybinds) do
            if kb.Key ~= Enum.KeyCode.Unknown and kb.Key == input.KeyCode then
                fire(kb.Callback)
            end
        end
    end)

    if opts.Watermark ~= nil then
        self:SetWatermark(opts.Watermark)
    end

    task.defer(function()
        if not self.Inited and not self.Destroyed then
            self:Init()
        end
    end)

    return self
end

function Library:_layoutTitle()
    if self.Subtitle == "" then
        self.TitleLabel.Position = UDim2.fromOffset(46, 0)
        self.TitleLabel.Size = UDim2.new(1, -120, 1, 0)
        self.SubtitleLabel.Visible = false
    else
        self.TitleLabel.Position = UDim2.fromOffset(46, 7)
        self.TitleLabel.Size = UDim2.new(1, -120, 0, 18)
        self.SubtitleLabel.Position = UDim2.fromOffset(46, 24)
        self.SubtitleLabel.Size = UDim2.new(1, -120, 0, 12)
        self.SubtitleLabel.Visible = true
    end
end

function Library:SetTitle(text)
    self.Name = tostring(text)
    self.TitleLabel.Text = self.Name
end

function Library:SetSubtitle(text)
    self.Subtitle = tostring(text or "")
    self.SubtitleLabel.Text = self.Subtitle
    self:_layoutTitle()
end

function Library:SetLogo(id)
    local asset = toAsset(id)
    if not asset then
        return
    end
    self.LogoImage.Image = asset
    self.WatermarkLogo.Image = asset
end

function Library:_setPill(text, colorKey)
    self.PillLabel.Text = text
    local color = colorKey == "Accent" and self.Accent or self.Theme[colorKey] or self.Accent
    self.PillLabel.TextColor3 = self.Theme.Text
    self:_tintIcon(self.PillIcon, self.PillIconIsImage, color)
    self._pillColorKey = colorKey
end

function Library:_buildKeyPage()
    local center = new("Frame", {
        Name = "Center",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(340, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = self.KeyFrame,
    })
    new("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Parent = center,
    })

    local lockIcon, lockIsImage = self:_makeIcon(center, "lock", "K", 34)
    lockIcon.LayoutOrder = 1
    self:_painter(function()
        self:_tintIcon(lockIcon, lockIsImage, self.Accent)
    end)

    self.KeyTitle = new("TextLabel", {
        Text = self.KeyPrompt.Title,
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        Size = UDim2.new(1, 0, 0, 26),
        TextXAlignment = Enum.TextXAlignment.Center,
        LayoutOrder = 2,
        Parent = center,
    })
    self:_bind(self.KeyTitle, "TextColor3", "Text")

    self.KeySub = new("TextLabel", {
        Text = self.KeyPrompt.Subtitle,
        TextSize = 13,
        TextWrapped = true,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        TextXAlignment = Enum.TextXAlignment.Center,
        LayoutOrder = 3,
        Parent = center,
    })
    self:_bind(self.KeySub, "TextColor3", "SubText")

    local inputRow = new("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        LayoutOrder = 4,
        Parent = center,
    })
    self:_bind(inputRow, "BackgroundColor3", "Element")
    corner(inputRow, 8)
    local inputStroke = stroke(inputRow, 1, 0.3)
    self:_bind(inputStroke, "Color", "Stroke")
    local keyIcon, keyIsImage = self:_makeIcon(inputRow, "key", "K", 16)
    keyIcon.AnchorPoint = Vector2.new(0, 0.5)
    keyIcon.Position = UDim2.new(0, 12, 0.5, 0)
    self:_painter(function()
        self:_tintIcon(keyIcon, keyIsImage, self.Theme.SubText)
    end)
    self.KeyBox = new("TextBox", {
        Text = "",
        PlaceholderText = self.KeyPrompt.Placeholder,
        ClearTextOnFocus = false,
        BackgroundTransparency = 1,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.fromOffset(38, 0),
        Size = UDim2.new(1, -48, 1, 0),
        Parent = inputRow,
    })
    self:_bind(self.KeyBox, "TextColor3", "Text")
    self:_bind(self.KeyBox, "PlaceholderColor3", "SubText")

    self.KeyStatus = new("TextLabel", {
        Text = "",
        TextSize = 12,
        Size = UDim2.new(1, 0, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Center,
        LayoutOrder = 5,
        Parent = center,
    })
    self:_bind(self.KeyStatus, "TextColor3", "SubText")

    local buttons = new("Frame", {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundTransparency = 1,
        LayoutOrder = 6,
        Parent = center,
    })
    new("UIListLayout", {
        Padding = UDim.new(0, 10),
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = buttons,
    })
    self.KeyLinkBtn = self:_button(buttons, self.KeyPrompt.Link, "outline", {
        Size = UDim2.new(0.5, -5, 1, 0),
        LayoutOrder = 1,
        Visible = false,
    })
    self.KeySubmit = self:_button(buttons, self.KeyPrompt.Submit, "accent", {
        Size = UDim2.new(1, 0, 1, 0),
        LayoutOrder = 2,
    })

    self:_conn(self.KeySubmit.MouseButton1Click, function()
        self:_submitKey(self.KeyBox.Text)
    end)
    self:_conn(self.KeyBox.FocusLost, function(enter)
        if enter then
            self:_submitKey(self.KeyBox.Text)
        end
    end)
    self:_conn(self.KeyLinkBtn.MouseButton1Click, function()
        local link = self._keyLink
        if type(link) == "function" then
            task.spawn(link, self)
        elseif type(link) == "string" and link ~= "" then
            local ok = pcall(function()
                (setclipboard or toclipboard)(link)
            end)
            if ok then
                self:Notify({ Title = "Link copied", Content = "Paste it into your browser.", Type = "success" })
            else
                self:Notify({ Title = "Key link", Content = link, Type = "info", Duration = 10 })
            end
        else
            self:Notify({ Title = "No link", Content = "No key link has been set.", Type = "warning" })
        end
    end)
end

function Library:_layoutKeyButtons()
    if self.KeyLinkBtn.Visible then
        self.KeySubmit.Size = UDim2.new(0.5, -5, 1, 0)
    else
        self.KeySubmit.Size = UDim2.new(1, 0, 1, 0)
    end
end

function Library:SetKey(validate, onUnlock, onExpire)
    self._validate = validate
    self._onUnlock = onUnlock
    self._onExpire = onExpire
    self.KeyEnabled = type(validate) == "function"
    self.Unlocked = not self.KeyEnabled
    self._timerId = (self._timerId or 0) + 1
    self:_refreshLock()
end

function Library:SetKeyLink(link)
    self._keyLink = link
    self.KeyLinkBtn.Visible = link ~= nil
    self:_layoutKeyButtons()
end

function Library:SetKeyPrompt(prompt)
    if type(prompt) ~= "table" then
        return
    end
    local p = self.KeyPrompt
    p.Title = prompt.Title or p.Title
    p.Subtitle = prompt.Subtitle or prompt.Description or prompt.Text or p.Subtitle
    p.Placeholder = prompt.Placeholder or p.Placeholder
    p.Submit = prompt.Submit or prompt.SubmitText or prompt.Button or prompt.ButtonText or p.Submit
    p.Link = prompt.Link or prompt.LinkText or prompt.GetKeyText or prompt.GetKey or p.Link
    self.KeyTitle.Text = p.Title
    self.KeySub.Text = p.Subtitle
    self.KeyBox.PlaceholderText = p.Placeholder
    self.KeySubmit.Text = p.Submit
    self.KeyLinkBtn.Text = p.Link
end

function Library:SetRememberKey(value)
    if type(value) == "string" then
        self.KeyFile = value
        self.RememberKey = true
    else
        self.RememberKey = value == true
    end
end

function Library:SetKeyText(text)
    self.KeyBox.Text = tostring(text or "")
end

function Library:SetKeyStatus(text, kind)
    kind = tostring(kind or "info"):lower()
    local color = self.Theme.SubText
    if kind == "success" then
        color = self.Theme.Success
    elseif kind == "error" then
        color = self.Theme.Error
    elseif kind == "warning" then
        color = self.Theme.Warning
    elseif kind == "info" then
        color = self.Accent
    end
    self.KeyStatus.Text = tostring(text or "")
    self.KeyStatus.TextColor3 = color
end

function Library:GetKeyInfo()
    if not self.KeyInfo then
        return nil
    end
    local info = self.KeyInfo
    return {
        Key = info.Key,
        ExpiresAt = info.ExpiresAt,
        SecondsLeft = info.ExpiresAt and math.max(0, info.ExpiresAt - os.time()) or nil,
        Raw = info.Raw,
    }
end

function Library:_refreshLock()
    if not self.KeyFrame then
        return
    end
    local locked = self.KeyEnabled and not self.Unlocked
    self.KeyFrame.Visible = locked
    self.App.Visible = not locked
    local showPill = self.KeyEnabled and self.Unlocked
    self.Countdown.Visible = showPill
    self.TabList.Size = showPill and UDim2.new(1, -16, 1, -58) or UDim2.new(1, -16, 1, -16)
end

function Library:_submitKey(key, silent)
    if self._busy or not self._validate then
        return
    end
    key = (tostring(key or ""):gsub("^%s+", ""))
    key = (key:gsub("%s+$", ""))
    if key == "" then
        self:SetKeyStatus("Enter a key first.", "warning")
        return
    end
    self._busy = true
    self:SetKeyStatus("Checking key...", "info")
    task.spawn(function()
        local ok, good, info = pcall(self._validate, key)
        self._busy = false
        if self.Destroyed then
            return
        end
        if not ok then
            warn("[HumidityHub] validator error: " .. tostring(good))
            self:SetKeyStatus("Could not check the key. Try again.", "error")
            return
        end
        if type(good) == "table" then
            local t = good
            info = info or t
            if t.valid ~= nil then
                good = t.valid
            elseif t.ok ~= nil then
                good = t.ok
            elseif t.success ~= nil then
                good = t.success
            else
                good = false
            end
        end
        if good then
            self:_unlock(key, info, silent)
        else
            local msg = extractMessage(info, "Invalid key.")
            self:SetKeyStatus(msg, "error")
            if not silent then
                self:Notify({ Title = "Key rejected", Content = msg, Type = "error" })
            end
        end
    end)
end

function Library:_unlock(key, info, quiet)
    local expires = extractExpiry(info)
    self.KeyInfo = { Key = key, ExpiresAt = expires, Raw = info }
    self.Unlocked = true
    if self.RememberKey then
        writeFile(self.KeyFile, key)
    end
    self:SetKeyStatus("Key accepted.", "success")
    self:_refreshLock()
    if not self.ActiveTab then
        self:_selectFirst()
    end
    self:_startTimer()
    if not quiet then
        self:Notify({
            Title = "Key accepted",
            Content = expires and ("Expires in " .. formatTime(expires - os.time()) .. ".") or "No expiry on this key.",
            Type = "success",
        })
    end
    if self._onUnlock then
        task.spawn(self._onUnlock, self:GetKeyInfo())
    end
end

function Library:Lock(message, kind)
    self.Unlocked = false
    self.KeyInfo = nil
    self._timerId = (self._timerId or 0) + 1
    if self.RememberKey then
        deleteFile(self.KeyFile)
    end
    self:_refreshLock()
    self:SetKeyStatus(message or "Locked.", kind or "warning")
end

function Library:_expire()
    self:Lock("Your key expired. Get a new one.", "warning")
    self:Notify({ Title = "Key expired", Content = "Get a new key to keep using the hub.", Type = "warning", Duration = 8 })
    if self._onExpire then
        task.spawn(self._onExpire)
    end
    if not self.Visible then
        self:Show()
    end
end

function Library:_startTimer()
    self._timerId = (self._timerId or 0) + 1
    local id = self._timerId
    local warned = false
    task.spawn(function()
        while self._timerId == id and not self.Destroyed and self.Unlocked do
            local info = self.KeyInfo
            if not info or not info.ExpiresAt then
                self:_setPill("No expiry", "Success")
                return
            end
            local left = info.ExpiresAt - os.time()
            if left <= 0 then
                self:_expire()
                return
            end
            local colorKey = "Accent"
            if left < 300 then
                colorKey = "Error"
            elseif left < 3600 then
                colorKey = "Warning"
            end
            self:_setPill(formatTime(left), colorKey)
            if left < 300 and not warned then
                warned = true
                self:Notify({ Title = "Key expiring", Content = "Less than 5 minutes left on your key.", Type = "warning", Duration = 6 })
            end
            task.wait(1)
        end
    end)
end

function Library:_paintTab(tab, animate)
    local active = self.ActiveTab == tab
    local iconColor = active and self.Accent or self.Theme.SubText
    local textColor = active and self.Theme.Text or self.Theme.SubText
    local iconProp = tab.IconIsImage and "ImageColor3" or "TextColor3"
    if animate then
        tw(tab.IconObj, 0.2, { [iconProp] = iconColor })
        tw(tab.Label, 0.2, { TextColor3 = textColor })
        tw(tab.Button, 0.2, { BackgroundTransparency = active and 0 or 1, BackgroundColor3 = self.Theme.Element })
        tw(tab.Bar, 0.2, { BackgroundTransparency = active and 0 or 1, BackgroundColor3 = self.Accent })
    else
        tab.IconObj[iconProp] = iconColor
        tab.Label.TextColor3 = textColor
        tab.Button.BackgroundTransparency = active and 0 or 1
        tab.Button.BackgroundColor3 = self.Theme.Element
        tab.Bar.BackgroundTransparency = active and 0 or 1
        tab.Bar.BackgroundColor3 = self.Accent
    end
end

function Library:_paintTabs()
    for _, tab in ipairs(self.Tabs) do
        self:_paintTab(tab, false)
    end
end

function Library:_buildTabIcon(tab)
    if tab.IconObj then
        tab.IconObj:Destroy()
    end
    local obj, isImage = self:_makeIcon(tab.Button, tab.IconSpec, tab.Name, 18)
    obj.AnchorPoint = Vector2.new(0, 0.5)
    obj.Position = UDim2.new(0, 12, 0.5, 0)
    tab.IconObj = obj
    tab.IconIsImage = isImage
end

function Library:AddTab(opts, iconArg)
    if type(opts) == "string" then
        opts = { Name = opts, Icon = iconArg }
    end
    opts = opts or {}
    local tab = setmetatable({}, Tab)
    tab.Window = self
    tab.Name = opts.Name or "Tab"
    tab.IconSpec = opts.Icon
    tab.Order = opts.Order or (#self.Tabs + 1)
    tab._order = 0

    tab.Button = new("TextButton", {
        Name = tab.Name,
        Text = "",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        LayoutOrder = tab.Order,
        Parent = self.TabList,
    })
    corner(tab.Button, 8)
    tab.Bar = new("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(3, 16),
        BackgroundTransparency = 1,
        Parent = tab.Button,
    })
    corner(tab.Bar, 2)
    tab.Label = new("TextLabel", {
        Text = tab.Name,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Position = UDim2.fromOffset(38, 0),
        Size = UDim2.new(1, -44, 1, 0),
        Parent = tab.Button,
    })
    self:_buildTabIcon(tab)

    tab.Page = new("ScrollingFrame", {
        Name = tab.Name,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = self.Content,
    })
    self:_bind(tab.Page, "ScrollBarImageColor3", "SubText")
    padding(tab.Page, 10, 10, 12, 10)
    listLayout(tab.Page, 6)

    self:_conn(tab.Button.MouseButton1Click, function()
        self:SelectTab(tab)
    end)
    self:_conn(tab.Button.MouseEnter, function()
        if self.ActiveTab ~= tab then
            tw(tab.Label, 0.15, { TextColor3 = self.Theme.Text })
        end
    end)
    self:_conn(tab.Button.MouseLeave, function()
        if self.ActiveTab ~= tab then
            tw(tab.Label, 0.15, { TextColor3 = self.Theme.SubText })
        end
    end)

    table.insert(self.Tabs, tab)
    self:_paintTab(tab, false)
    if not self.ActiveTab and self.Inited then
        self:SelectTab(tab, true)
    end
    return tab
end

function Library:_selectFirst()
    local first
    for _, t in ipairs(self.Tabs) do
        if not first or t.Order < first.Order then
            first = t
        end
    end
    if first then
        self:SelectTab(first, true)
    end
end

function Library:SelectTab(tab, instant)
    if not tab then
        return
    end
    self.ActiveTab = tab
    for _, t in ipairs(self.Tabs) do
        t.Page.Visible = t == tab
        self:_paintTab(t, not instant)
    end
    if not instant then
        tab.Page.Position = UDim2.fromOffset(0, 10)
        tw(tab.Page, 0.25, { Position = UDim2.fromOffset(0, 0) })
    end
end

function Library:SetIconPack(pack)
    mergeIcons(self.Icons, pack)
    for _, tab in ipairs(self.Tabs) do
        self:_buildTabIcon(tab)
    end
    self:_paintTabs()
end

function Tab:SetIcon(icon)
    self.IconSpec = icon
    self.Window:_buildTabIcon(self)
    self.Window:_paintTab(self, false)
end

function Tab:SetName(name)
    self.Name = tostring(name)
    self.Label.Text = self.Name
end

function Tab:Select()
    self.Window:SelectTab(self)
end

function Tab:_row(height, interactive)
    local win = self.Window
    self._order = self._order + 1
    local row = new(interactive and "TextButton" or "Frame", {
        Size = UDim2.new(1, 0, 0, height),
        LayoutOrder = self._order,
        Parent = self.Page,
    })
    if interactive then
        row.Text = ""
    end
    win:_bind(row, "BackgroundColor3", "Element")
    corner(row, 8)
    local st = stroke(row, 1, 0.45)
    win:_bind(st, "Color", "Stroke")
    return row
end

function Tab:_autoRow()
    local win = self.Window
    self._order = self._order + 1
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = self._order,
        Parent = self.Page,
    })
    win:_bind(row, "BackgroundColor3", "Element")
    corner(row, 8)
    local st = stroke(row, 1, 0.45)
    win:_bind(st, "Color", "Stroke")
    padding(row, 12, 9, 12, 9)
    listLayout(row, 4)
    return row
end

function Element:SetVisible(v)
    self.Row.Visible = v and true or false
end

function Element:Destroy()
    if self._onDestroy then
        self._onDestroy()
    end
    self.Row:Destroy()
end

local function newElement(typeName, row)
    return setmetatable({ Type = typeName, Row = row }, Element)
end

function Tab:_flag(opts, el)
    if opts.Flag then
        self.Window.Flags[opts.Flag] = el
    end
end

function Tab:AddSection(name)
    if type(name) == "table" then
        name = name.Name
    end
    local win = self.Window
    self._order = self._order + 1
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        LayoutOrder = self._order,
        Parent = self.Page,
    })
    local label = new("TextLabel", {
        Text = string.upper(tostring(name or "")),
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        Position = UDim2.fromOffset(4, 0),
        Size = UDim2.new(1, -4, 1, -2),
        TextYAlignment = Enum.TextYAlignment.Bottom,
        Parent = row,
    })
    win:_bind(label, "TextColor3", "Accent")
    local el = newElement("section", row)
    function el:SetText(t)
        label.Text = string.upper(tostring(t))
    end
    return el
end

function Tab:AddLabel(text)
    if type(text) == "table" then
        text = text.Text or text.Name
    end
    local win = self.Window
    local row = self:_autoRow()
    local label = new("TextLabel", {
        Text = tostring(text or ""),
        TextSize = 14,
        TextWrapped = true,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = row,
    })
    win:_bind(label, "TextColor3", "Text")
    local el = newElement("label", row)
    function el:SetText(t)
        label.Text = tostring(t)
    end
    return el
end

function Tab:AddParagraph(opts, content)
    if type(opts) == "string" then
        opts = { Title = opts, Content = content }
    end
    opts = opts or {}
    local win = self.Window
    local row = self:_autoRow()
    local titleLabel = new("TextLabel", {
        Text = tostring(opts.Title or ""),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextWrapped = true,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        TextYAlignment = Enum.TextYAlignment.Top,
        Visible = (opts.Title or "") ~= "",
        LayoutOrder = 1,
        Parent = row,
    })
    win:_bind(titleLabel, "TextColor3", "Text")
    local body = new("TextLabel", {
        Text = tostring(opts.Content or ""),
        TextSize = 13,
        TextWrapped = true,
        RichText = true,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        TextYAlignment = Enum.TextYAlignment.Top,
        LayoutOrder = 2,
        Parent = row,
    })
    win:_bind(body, "TextColor3", "SubText")
    local el = newElement("paragraph", row)
    function el:SetTitle(t)
        titleLabel.Text = tostring(t)
        titleLabel.Visible = tostring(t) ~= ""
    end
    function el:SetContent(t)
        body.Text = tostring(t)
    end
    return el
end

function Tab:AddDivider()
    local win = self.Window
    self._order = self._order + 1
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 10),
        BackgroundTransparency = 1,
        LayoutOrder = self._order,
        Parent = self.Page,
    })
    local line = new("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0, 1),
        Parent = row,
    })
    win:_bind(line, "BackgroundColor3", "Stroke")
    return newElement("divider", row)
end

function Tab:AddButton(opts, cb)
    opts = norm(opts, cb)
    local win = self.Window
    local row = self:_row(38, true)
    local label = new("TextLabel", {
        Text = opts.Name or "Button",
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(1, -48, 1, 0),
        Parent = row,
    })
    win:_bind(label, "TextColor3", "Text")
    local icon, isImage = win:_makeIcon(row, opts.Icon or "mouse-pointer-click", ">", 16)
    icon.AnchorPoint = Vector2.new(1, 0.5)
    icon.Position = UDim2.new(1, -12, 0.5, 0)
    win:_painter(function()
        win:_tintIcon(icon, isImage, win.Theme.SubText)
    end)
    win:_hover(row)
    local el = newElement("button", row)
    self._lastCallback = opts.Callback
    win:_conn(row.MouseButton1Click, function()
        fire(opts.Callback)
    end)
    function el:SetText(t)
        label.Text = tostring(t)
    end
    return el
end

function Tab:AddToggle(opts, cb)
    opts = norm(opts, cb)
    local win = self.Window
    local state = opts.Default == true
    local row = self:_row(38, true)
    local label = new("TextLabel", {
        Text = opts.Name or "Toggle",
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(1, -66, 1, 0),
        Parent = row,
    })
    win:_bind(label, "TextColor3", "Text")
    local track = new("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(38, 20),
        Parent = row,
    })
    corner(track, 10)
    local knob = new("Frame", {
        Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = track,
    })
    corner(knob, 7)
    local function render(animate)
        local color = state and win.Accent or win.Theme.Stroke
        local pos = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        if animate then
            tw(track, 0.2, { BackgroundColor3 = color })
            tw(knob, 0.2, { Position = pos })
        else
            track.BackgroundColor3 = color
            knob.Position = pos
        end
    end
    win:_painter(function()
        render(false)
    end)
    win:_hover(row)
    local el = newElement("toggle", row)
    function el:Set(v, silent)
        v = v and true or false
        if v == state then
            return
        end
        state = v
        render(true)
        if not silent then
            fire(opts.Callback, state)
        end
    end
    function el:Get()
        return state
    end
    function el:Serialize()
        return state
    end
    function el:Deserialize(v)
        self:Set(v == true)
    end
    win:_conn(row.MouseButton1Click, function()
        el:Set(not state)
    end)
    self:_flag(opts, el)
    return el
end

function Tab:AddSlider(opts, cb)
    opts = norm(opts, cb)
    local win = self.Window
    local min = tonumber(opts.Min) or 0
    local max = tonumber(opts.Max) or 100
    if max <= min then
        max = min + 1
    end
    local inc = tonumber(opts.Increment) or 1
    if inc <= 0 then
        inc = 1
    end
    local suffix = opts.Suffix or ""
    local decimals = 0
    local frac = tostring(inc):match("%.(%d+)")
    if frac then
        decimals = #frac
    end
    local function snap(v)
        v = clamp(v, min, max)
        v = math.floor((v - min) / inc + 0.5) * inc + min
        return round(clamp(v, min, max), decimals)
    end
    local value = snap(tonumber(opts.Default) or min)

    local row = self:_row(54, false)
    local label = new("TextLabel", {
        Text = opts.Name or "Slider",
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        Position = UDim2.fromOffset(12, 8),
        Size = UDim2.new(1, -110, 0, 16),
        Parent = row,
    })
    win:_bind(label, "TextColor3", "Text")
    local valueLabel = new("TextLabel", {
        Text = "",
        TextSize = 13,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -12, 0, 8),
        Size = UDim2.fromOffset(90, 16),
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = row,
    })
    win:_bind(valueLabel, "TextColor3", "SubText")
    local track = new("Frame", {
        Position = UDim2.fromOffset(12, 35),
        Size = UDim2.new(1, -24, 0, 6),
        Parent = row,
    })
    win:_bind(track, "BackgroundColor3", "Stroke")
    corner(track, 3)
    local fill = new("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        Parent = track,
    })
    win:_bind(fill, "BackgroundColor3", "Accent")
    corner(fill, 3)
    local knob = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(12, 12),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = fill,
    })
    corner(knob, 6)
    local hit = new("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(6, 24),
        Size = UDim2.new(1, -12, 0, 28),
        Parent = row,
    })

    local function render()
        local a = (value - min) / (max - min)
        fill.Size = UDim2.new(a, 0, 1, 0)
        valueLabel.Text = string.format("%." .. decimals .. "f", value) .. suffix
    end
    render()

    local el = newElement("slider", row)
    function el:Set(v, silent)
        local nv = snap(tonumber(v) or value)
        if nv == value then
            return
        end
        value = nv
        render()
        if not silent then
            fire(opts.Callback, value)
        end
    end
    function el:Get()
        return value
    end
    function el:Serialize()
        return value
    end
    function el:Deserialize(v)
        self:Set(v)
    end
    win:_dragify(hit, function(input)
        local p = pointer(input)
        local a = clamp((p.X - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X), 0, 1)
        el:Set(min + (max - min) * a)
    end)
    self:_flag(opts, el)
    return el
end

function Tab:AddTextbox(opts, cb)
    opts = norm(opts, cb)
    local win = self.Window
    local row = self:_row(38, false)
    local label = new("TextLabel", {
        Text = opts.Name or "Textbox",
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(1, -178, 1, 0),
        Parent = row,
    })
    win:_bind(label, "TextColor3", "Text")
    local box = new("TextBox", {
        Text = tostring(opts.Default or ""),
        PlaceholderText = opts.Placeholder or "",
        ClearTextOnFocus = opts.ClearOnFocus == true,
        TextSize = 13,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(150, 26),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    win:_bind(box, "BackgroundColor3", "Background")
    win:_bind(box, "TextColor3", "Text")
    win:_bind(box, "PlaceholderColor3", "SubText")
    padding(box, 8, 0, 8, 0)
    corner(box, 6)
    local bst = stroke(box, 1, 0.4)
    win:_bind(bst, "Color", "Stroke")
    local el = newElement("textbox", row)
    function el:Set(v, silent)
        box.Text = tostring(v or "")
        if not silent then
            fire(opts.Callback, box.Text)
        end
    end
    function el:Get()
        return box.Text
    end
    function el:Serialize()
        return box.Text
    end
    function el:Deserialize(v)
        self:Set(v)
    end
    win:_conn(box.FocusLost, function()
        fire(opts.Callback, box.Text)
    end)
    self:_flag(opts, el)
    return el
end

function Tab:AddDropdown(opts, cb)
    opts = norm(opts, cb)
    local win = self.Window
    local HEAD = 38
    local OPT_H = 28
    local multi = opts.Multi == true
    local options = {}
    for _, o in ipairs(opts.Options or opts.Values or {}) do
        table.insert(options, tostring(o))
    end
    local selected = nil
    local chosen = {}
    if multi then
        if type(opts.Default) == "table" then
            for _, v in ipairs(opts.Default) do
                chosen[tostring(v)] = true
            end
        end
    elseif opts.Default ~= nil then
        selected = tostring(opts.Default)
    end

    local row = self:_row(HEAD, false)
    row.ClipsDescendants = true
    local head = new("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, HEAD),
        Parent = row,
    })
    local label = new("TextLabel", {
        Text = opts.Name or "Dropdown",
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(0.5, -12, 1, 0),
        Parent = head,
    })
    win:_bind(label, "TextColor3", "Text")
    local valueLabel = new("TextLabel", {
        Text = "",
        TextSize = 13,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Right,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -36, 0, 0),
        Size = UDim2.new(0.5, -40, 1, 0),
        Parent = head,
    })
    win:_bind(valueLabel, "TextColor3", "SubText")
    local arrow, arrowIsImage = win:_makeIcon(head, "chevron-down", "v", 16)
    arrow.AnchorPoint = Vector2.new(1, 0.5)
    arrow.Position = UDim2.new(1, -12, 0, HEAD / 2)
    win:_painter(function()
        win:_tintIcon(arrow, arrowIsImage, win.Theme.SubText)
    end)

    local listFrame = new("ScrollingFrame", {
        Position = UDim2.fromOffset(8, HEAD + 2),
        Size = UDim2.new(1, -16, 0, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = row,
    })
    win:_bind(listFrame, "ScrollBarImageColor3", "SubText")
    listLayout(listFrame, 3)

    local open = false
    local buttons = {}

    local function isSelected(opt)
        if multi then
            return chosen[opt] == true
        end
        return selected == opt
    end

    local function getValue()
        if multi then
            local out = {}
            for _, o in ipairs(options) do
                if chosen[o] then
                    table.insert(out, o)
                end
            end
            return out
        end
        return selected
    end

    local function updateDisplay()
        if multi then
            local v = getValue()
            valueLabel.Text = #v > 0 and table.concat(v, ", ") or "None"
        else
            valueLabel.Text = selected or "None"
        end
    end

    local function styleOptions()
        for opt, b in pairs(buttons) do
            local sel = isSelected(opt)
            b.BackgroundColor3 = sel and win.Theme.ElementHover or win.Theme.Surface
            b.TextColor3 = sel and win.Accent or win.Theme.Text
        end
    end

    local function openHeight()
        local visible = math.min(#options, 5)
        return HEAD + 4 + visible * (OPT_H + 3) + 6
    end

    local function applySize(animate)
        local h = open and openHeight() or HEAD
        local lh = math.min(#options, 5) * (OPT_H + 3)
        listFrame.Size = UDim2.new(1, -16, 0, lh)
        if animate then
            tw(row, 0.25, { Size = UDim2.new(1, 0, 0, h) })
            tw(arrow, 0.25, { Rotation = open and 180 or 0 })
        else
            row.Size = UDim2.new(1, 0, 0, h)
            arrow.Rotation = open and 180 or 0
        end
    end

    local el = newElement("dropdown", row)

    local function build()
        for _, b in pairs(buttons) do
            b:Destroy()
        end
        buttons = {}
        for i, opt in ipairs(options) do
            local b = new("TextButton", {
                Text = opt,
                TextSize = 13,
                Font = Enum.Font.GothamMedium,
                Size = UDim2.new(1, -4, 0, OPT_H),
                LayoutOrder = i,
                Parent = listFrame,
            })
            corner(b, 6)
            buttons[opt] = b
            win:_conn(b.MouseButton1Click, function()
                if multi then
                    chosen[opt] = not chosen[opt] or nil
                    styleOptions()
                    updateDisplay()
                    fire(opts.Callback, getValue())
                else
                    selected = opt
                    styleOptions()
                    updateDisplay()
                    open = false
                    applySize(true)
                    fire(opts.Callback, selected)
                end
            end)
        end
        styleOptions()
        updateDisplay()
        applySize(false)
    end

    win:_painter(styleOptions)
    build()

    win:_conn(head.MouseButton1Click, function()
        open = not open
        applySize(true)
    end)

    function el:Get()
        return getValue()
    end
    function el:Set(v, silent)
        if multi then
            chosen = {}
            if type(v) == "table" then
                for _, x in ipairs(v) do
                    chosen[tostring(x)] = true
                end
            end
        else
            selected = v ~= nil and tostring(v) or nil
        end
        styleOptions()
        updateDisplay()
        if not silent then
            fire(opts.Callback, getValue())
        end
    end
    function el:Refresh(newOptions, keep)
        options = {}
        for _, o in ipairs(newOptions or {}) do
            table.insert(options, tostring(o))
        end
        if not keep then
            chosen = {}
            selected = nil
        else
            local valid = {}
            for _, o in ipairs(options) do
                valid[o] = true
            end
            if not multi and selected and not valid[selected] then
                selected = nil
            end
            for k in pairs(chosen) do
                if not valid[k] then
                    chosen[k] = nil
                end
            end
        end
        build()
    end
    function el:Serialize()
        return getValue()
    end
    function el:Deserialize(v)
        self:Set(v)
    end
    self:_flag(opts, el)
    return el
end

function Tab:AddKeybind(opts, cb)
    opts = norm(opts, cb)
    local win = self.Window
    local key = toKeyCode(opts.Default)
    local row = self:_row(38, true)
    local label = new("TextLabel", {
        Text = opts.Name or "Keybind",
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(1, -140, 1, 0),
        Parent = row,
    })
    win:_bind(label, "TextColor3", "Text")
    local pill = new("TextLabel", {
        Text = "",
        TextSize = 12,
        Font = Enum.Font.GothamSemibold,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(0, 24),
        AutomaticSize = Enum.AutomaticSize.X,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = row,
    })
    win:_bind(pill, "BackgroundColor3", "Background")
    pill.BackgroundTransparency = 0
    win:_bind(pill, "TextColor3", "Text")
    padding(pill, 10, 0, 10, 0)
    corner(pill, 6)
    local pst = stroke(pill, 1, 0.4)
    win:_bind(pst, "Color", "Stroke")
    win:_hover(row)

    local kb = { Key = key, Callback = opts.Callback }
    table.insert(win._keybinds, kb)

    local el = newElement("keybind", row)
    local function show()
        pill.Text = key == Enum.KeyCode.Unknown and "None" or key.Name
    end
    show()
    function el:Set(code, silent)
        key = toKeyCode(code)
        kb.Key = key
        show()
        if not silent then
            fire(opts.ChangedCallback, key)
        end
    end
    function el:Get()
        return key
    end
    function el:Serialize()
        return key.Name
    end
    function el:Deserialize(v)
        self:Set(v)
    end
    el._onDestroy = function()
        for i, k in ipairs(win._keybinds) do
            if k == kb then
                table.remove(win._keybinds, i)
                break
            end
        end
    end
    win:_conn(row.MouseButton1Click, function()
        if win._listening then
            return
        end
        pill.Text = "..."
        win._listening = function(code)
            if code == Enum.KeyCode.Escape then
                code = Enum.KeyCode.Unknown
            end
            el:Set(code)
        end
    end)
    self:_flag(opts, el)
    return el
end

function Tab:AddColorPicker(opts, cb)
    opts = norm(opts, cb)
    local win = self.Window
    local HEAD = 38
    local PANEL = 126
    local color = typeof(opts.Default) == "Color3" and opts.Default or win.Accent
    local h, s, v = color:ToHSV()

    local row = self:_row(HEAD, false)
    row.ClipsDescendants = true
    local head = new("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, HEAD),
        Parent = row,
    })
    local label = new("TextLabel", {
        Text = opts.Name or "Color",
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(1, -70, 1, 0),
        Parent = head,
    })
    win:_bind(label, "TextColor3", "Text")
    local swatch = new("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(36, 18),
        BackgroundColor3 = color,
        Parent = head,
    })
    corner(swatch, 5)
    local sst = stroke(swatch, 1, 0.3)
    win:_bind(sst, "Color", "Stroke")

    local panel = new("Frame", {
        Position = UDim2.fromOffset(12, HEAD + 4),
        Size = UDim2.new(1, -24, 0, PANEL - 8),
        BackgroundTransparency = 1,
        Parent = row,
    })
    local sv = new("Frame", {
        Size = UDim2.new(1, -28, 0, 100),
        BackgroundColor3 = Color3.fromHSV(h, 1, 1),
        Parent = panel,
    })
    corner(sv, 6)
    local white = new("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = sv,
    })
    corner(white, 6)
    new("UIGradient", { Transparency = NumberSequence.new(0, 1), Parent = white })
    local black = new("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        Parent = sv,
    })
    corner(black, 6)
    new("UIGradient", { Transparency = NumberSequence.new(1, 0), Rotation = 90, Parent = black })
    local svCursor = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(10, 10),
        BackgroundTransparency = 1,
        Parent = sv,
    })
    corner(svCursor, 5)
    local svCursorStroke = stroke(svCursor, 2, 0)
    svCursorStroke.Color = Color3.new(1, 1, 1)

    local hueBar = new("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.fromOffset(18, 100),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = panel,
    })
    corner(hueBar, 6)
    local keypoints = {}
    for i = 0, 6 do
        table.insert(keypoints, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6 % 1 == 0 and (i == 6 and 0 or 0) or i / 6, 1, 1)))
    end
    new("UIGradient", { Color = ColorSequence.new(keypoints), Rotation = 90, Parent = hueBar })
    local hueCursor = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0, 0),
        Size = UDim2.new(1, 4, 0, 4),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = hueBar,
    })
    corner(hueCursor, 2)
    local hueStroke = stroke(hueCursor, 1, 0)
    hueStroke.Color = Color3.new(0, 0, 0)

    local hexLabel = new("TextLabel", {
        Text = "",
        TextSize = 12,
        Position = UDim2.fromOffset(0, 106),
        Size = UDim2.new(1, 0, 0, 14),
        Parent = panel,
    })
    win:_bind(hexLabel, "TextColor3", "SubText")

    local el = newElement("colorpicker", row)
    local function render()
        color = Color3.fromHSV(h, s, v)
        swatch.BackgroundColor3 = color
        sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        svCursor.Position = UDim2.fromScale(s, 1 - v)
        hueCursor.Position = UDim2.new(0.5, 0, h, 0)
        hexLabel.Text = string.format("#%02X%02X%02X", math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5))
    end
    render()

    local open = false
    win:_conn(head.MouseButton1Click, function()
        open = not open
        tw(row, 0.25, { Size = UDim2.new(1, 0, 0, open and (HEAD + PANEL) or HEAD) })
    end)
    win:_dragify(sv, function(input)
        local p = pointer(input)
        s = clamp((p.X - sv.AbsolutePosition.X) / math.max(1, sv.AbsoluteSize.X), 0, 1)
        v = 1 - clamp((p.Y - sv.AbsolutePosition.Y) / math.max(1, sv.AbsoluteSize.Y), 0, 1)
        render()
        fire(opts.Callback, color)
    end)
    win:_dragify(hueBar, function(input)
        local p = pointer(input)
        h = clamp((p.Y - hueBar.AbsolutePosition.Y) / math.max(1, hueBar.AbsoluteSize.Y), 0, 0.999)
        render()
        fire(opts.Callback, color)
    end)

    function el:Set(c, silent)
        if typeof(c) ~= "Color3" then
            return
        end
        h, s, v = c:ToHSV()
        render()
        if not silent then
            fire(opts.Callback, color)
        end
    end
    function el:Get()
        return color
    end
    function el:Serialize()
        return { math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5) }
    end
    function el:Deserialize(t)
        if type(t) == "table" and #t >= 3 then
            self:Set(Color3.fromRGB(t[1], t[2], t[3]))
        end
    end
    self:_flag(opts, el)
    return el
end

function Library:GetFlag(flag)
    local el = self.Flags[flag]
    if el and el.Get then
        return el:Get()
    end
    return nil
end

function Library:_applyTheme()
    for i = #self._bound, 1, -1 do
        local entry = self._bound[i]
        local obj = entry[1]
        if obj.Parent == nil then
            table.remove(self._bound, i)
        else
            tw(obj, 0.25, { [entry[2]] = self:_color(entry[3]) })
        end
    end
    for _, fn in ipairs(self._painters) do
        pcall(fn)
    end
    self:_paintTabs()
    if self._pillColorKey and self.Countdown.Visible then
        self:_setPill(self.PillLabel.Text, self._pillColorKey)
    end
end

function Library:SetTheme(name)
    local theme = Library.Themes[name]
    if not theme then
        return false
    end
    self.ThemeName = name
    self.Theme = theme
    if not self.CustomAccent then
        self.Accent = theme.Accent
    end
    self:_applyTheme()
    if self._accentPicker and not self.CustomAccent then
        self._accentPicker:Set(self.Accent, true)
    end
    return true
end

function Library:SetAccent(color)
    if typeof(color) ~= "Color3" then
        return
    end
    self.Accent = color
    self.CustomAccent = true
    self:_applyTheme()
end

function Library:SetScale(scale)
    self.UserScale = clamp(tonumber(scale) or Library.DefaultScale, 0.6, 1.6)
    if self.Visible then
        tw(self.Scaler, 0.2, { Scale = self.UserScale })
    else
        self.Scaler.Scale = self.UserScale
    end
end

function Library:_applyBackdrop()
    if not self.Visible then
        return
    end
    self.Backdrop.Visible = true
    tw(self.Backdrop, 0.3, { BackgroundTransparency = self.BackdropEnabled and self.BackdropTransparency or 1 })
    self.BlurObj.Enabled = true
    tw(self.BlurObj, 0.3, { Size = self.BlurEnabled and self.BlurSize or 0 })
end

function Library:SetBackdrop(enabled, transparency)
    self.BackdropEnabled = enabled ~= false
    if transparency then
        self.BackdropTransparency = clamp(transparency, 0, 1)
    end
    self:_applyBackdrop()
end

function Library:SetBlur(enabled, size)
    self.BlurEnabled = enabled == true
    if size then
        self.BlurSize = clamp(size, 0, 56)
    end
    self:_applyBackdrop()
end

function Library:SetWatermark(value)
    if type(value) == "string" then
        self.WatermarkText = value
        self.WatermarkEnabled = true
    elseif value == true then
        self.WatermarkEnabled = true
    else
        self.WatermarkEnabled = false
    end
    self.Watermark.Visible = self.WatermarkEnabled
    if self.WatermarkEnabled then
        self.WatermarkLabel.Text = self.WatermarkText .. "  |  " .. tostring(self._fps) .. " fps"
    end
end

function Library:Show()
    if self.Destroyed or self.Visible then
        return
    end
    self._vis = self._vis + 1
    self.Visible = true
    self.Holder.Visible = true
    self.Main.GroupTransparency = 1
    self.Scaler.Scale = self.UserScale * 0.93
    tw(self.Main, 0.3, { GroupTransparency = 0 })
    tw(self.Scaler, 0.35, { Scale = self.UserScale }, Enum.EasingStyle.Back)
    self:_applyBackdrop()
end

function Library:Hide()
    if self.Destroyed or not self.Visible then
        return
    end
    self._vis = self._vis + 1
    local id = self._vis
    self.Visible = false
    tw(self.Main, 0.25, { GroupTransparency = 1 })
    tw(self.Scaler, 0.25, { Scale = self.UserScale * 0.95 })
    tw(self.Backdrop, 0.25, { BackgroundTransparency = 1 })
    tw(self.BlurObj, 0.25, { Size = 0 })
    task.delay(0.3, function()
        if self.Destroyed or self._vis ~= id then
            return
        end
        self.Holder.Visible = false
        self.Backdrop.Visible = false
        self.BlurObj.Enabled = false
    end)
end

function Library:Toggle()
    if self.Visible then
        self:Hide()
    else
        self:Show()
    end
end

function Library:IsVisible()
    return self.Visible
end

function Library:Notify(opts, content, duration, kind)
    if type(opts) ~= "table" then
        opts = { Title = tostring(opts), Content = content, Duration = duration, Type = kind }
    end
    if self.Destroyed then
        return nil
    end
    local theme = self.Theme
    local title = tostring(opts.Title or opts.Name or self.Name)
    local text = tostring(opts.Content or opts.Text or opts.Description or "")
    local dur = tonumber(opts.Duration or opts.Time) or 4
    local typeName = tostring(opts.Type or opts.Kind or "info"):lower()
    if typeName == "warn" then
        typeName = "warning"
    elseif typeName == "err" then
        typeName = "error"
    elseif typeName == "ok" then
        typeName = "success"
    end
    local colors = { info = self.Accent, success = theme.Success, warning = theme.Warning, error = theme.Error }
    local icons = { info = "info", success = "check-circle", warning = "alert-triangle", error = "x-circle" }
    local color = colors[typeName] or self.Accent
    local iconName = opts.Icon or icons[typeName] or "info"

    while #self._notifs >= 5 do
        self._notifs[1].Dismiss()
    end

    local CW = 310
    local textW = CW - 48 - 30
    local contentH = 0
    if text ~= "" then
        contentH = TextService:GetTextSize(text, 13, Enum.Font.Gotham, Vector2.new(textW, 10000)).Y
    end
    local height = math.max(54, 10 + 18 + (contentH > 0 and (contentH + 3) or 0) + 16)

    self._notifId = self._notifId + 1
    local slot = new("Frame", {
        Size = UDim2.fromOffset(CW, 0),
        BackgroundTransparency = 1,
        LayoutOrder = self._notifId,
        Parent = self.NotifHolder,
    })
    local card = new("CanvasGroup", {
        Size = UDim2.fromScale(1, 1),
        Position = UDim2.fromOffset(60, 0),
        BackgroundColor3 = theme.Surface,
        GroupTransparency = 1,
        Parent = slot,
    })
    corner(card, 10)
    local cst = stroke(card, 1, 0.2)
    cst.Color = theme.Stroke
    new("Frame", {
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = color,
        Parent = card,
    })
    local icon, isImage = self:_makeIcon(card, iconName, "!", 20)
    icon.Position = UDim2.fromOffset(16, 10)
    self:_tintIcon(icon, isImage, color)
    new("TextLabel", {
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = theme.Text,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Position = UDim2.fromOffset(48, 10),
        Size = UDim2.new(1, -78, 0, 18),
        Parent = card,
    })
    if text ~= "" then
        new("TextLabel", {
            Text = text,
            TextSize = 13,
            TextColor3 = theme.SubText,
            TextWrapped = true,
            TextYAlignment = Enum.TextYAlignment.Top,
            Position = UDim2.fromOffset(48, 30),
            Size = UDim2.new(1, -78, 0, contentH),
            Parent = card,
        })
    end
    local closeBtn = new("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -6, 0, 6),
        Size = UDim2.fromOffset(20, 20),
        Parent = card,
    })
    local cIcon, cIsImage = self:_makeIcon(closeBtn, "x", "x", 12)
    cIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    cIcon.Position = UDim2.fromScale(0.5, 0.5)
    self:_tintIcon(cIcon, cIsImage, theme.SubText)

    local bar
    if dur > 0 then
        bar = new("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 0, 1, 0),
            Size = UDim2.new(1, 0, 0, 2),
            BackgroundColor3 = color,
            BackgroundTransparency = 0.3,
            Parent = card,
        })
    end

    local note = { Closed = false }
    note.Dismiss = function()
        if note.Closed then
            return
        end
        note.Closed = true
        for i, n in ipairs(self._notifs) do
            if n == note then
                table.remove(self._notifs, i)
                break
            end
        end
        tw(card, 0.25, { Position = UDim2.fromOffset(60, 0), GroupTransparency = 1 })
        task.delay(0.22, function()
            if slot.Parent then
                tw(slot, 0.2, { Size = UDim2.fromOffset(CW, 0) })
            end
            task.delay(0.25, function()
                slot:Destroy()
            end)
        end)
    end
    table.insert(self._notifs, note)

    tw(slot, 0.3, { Size = UDim2.fromOffset(CW, height) })
    tw(card, 0.35, { Position = UDim2.fromOffset(0, 0), GroupTransparency = 0 })
    if bar then
        tw(bar, dur, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)
        task.delay(dur, note.Dismiss)
    end
    closeBtn.MouseButton1Click:Connect(note.Dismiss)

    return note
end

function Library:ClearNotifications()
    local copy = {}
    for _, n in ipairs(self._notifs) do
        table.insert(copy, n)
    end
    for _, n in ipairs(copy) do
        n.Dismiss()
    end
end

function Library:Dialog(opts)
    opts = opts or {}
    local theme = self.Theme
    local overlay = new("TextButton", {
        Name = "Dialog",
        Text = "",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = 60,
        Parent = self.Gui,
    })
    local card = new("CanvasGroup", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(340, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme.Surface,
        GroupTransparency = 1,
        Parent = overlay,
    })
    corner(card, 12)
    local cst = stroke(card, 1, 0.2)
    cst.Color = theme.Stroke
    local scale = new("UIScale", { Scale = 0.92, Parent = card })
    padding(card, 18, 16, 18, 16)
    listLayout(card, 10)

    new("TextLabel", {
        Text = tostring(opts.Title or self.Name),
        Font = Enum.Font.GothamBold,
        TextSize = 17,
        TextColor3 = theme.Text,
        Size = UDim2.new(1, 0, 0, 22),
        LayoutOrder = 1,
        Parent = card,
    })
    local contentLabel
    if opts.Content and tostring(opts.Content) ~= "" then
        contentLabel = new("TextLabel", {
            Text = tostring(opts.Content),
            TextSize = 13,
            TextColor3 = theme.SubText,
            TextWrapped = true,
            RichText = true,
            TextYAlignment = Enum.TextYAlignment.Top,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 2,
            Parent = card,
        })
    end

    local inputBox
    if opts.Input then
        local cfg = type(opts.Input) == "table" and opts.Input or {}
        local holder = new("Frame", {
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = theme.Element,
            LayoutOrder = 3,
            Parent = card,
        })
        corner(holder, 8)
        local ist = stroke(holder, 1, 0.3)
        ist.Color = theme.Stroke
        inputBox = new("TextBox", {
            Text = tostring(cfg.Default or ""),
            PlaceholderText = cfg.Placeholder or "",
            PlaceholderColor3 = theme.SubText,
            TextColor3 = theme.Text,
            ClearTextOnFocus = false,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.fromOffset(12, 0),
            Size = UDim2.new(1, -24, 1, 0),
            Parent = holder,
        })
    end

    local specs = opts.Buttons
    if type(specs) ~= "table" or #specs == 0 then
        specs = { { Text = "OK", Style = "accent" } }
    end
    local btnRow = new("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        LayoutOrder = 4,
        Parent = card,
    })
    new("UIListLayout", {
        Padding = UDim.new(0, 8),
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = btnRow,
    })

    local dlg = { Closed = false }
    function dlg.Close()
        if dlg.Closed then
            return
        end
        dlg.Closed = true
        tw(card, 0.2, { GroupTransparency = 1 })
        tw(scale, 0.2, { Scale = 0.94 })
        tw(overlay, 0.2, { BackgroundTransparency = 1 })
        task.delay(0.25, function()
            overlay:Destroy()
        end)
    end
    function dlg.GetInput()
        return inputBox and inputBox.Text or nil
    end
    function dlg.SetContent(t)
        if contentLabel then
            contentLabel.Text = tostring(t)
        end
    end

    local n = #specs
    for i, spec in ipairs(specs) do
        local style = spec.Style or (i == n and "accent" or "outline")
        local width = UDim2.new(1 / n, -(8 * (n - 1)) / n, 1, 0)
        local b = self:_button(btnRow, tostring(spec.Text or spec.Name or spec.Title or "OK"), style, {
            Size = width,
            LayoutOrder = i,
        })
        b.MouseButton1Click:Connect(function()
            local value = inputBox and inputBox.Text or nil
            if not spec.KeepOpen then
                dlg.Close()
            end
            fire(spec.Callback, value)
        end)
    end

    tw(overlay, 0.25, { BackgroundTransparency = 0.45 })
    tw(card, 0.25, { GroupTransparency = 0 })
    tw(scale, 0.3, { Scale = 1 }, Enum.EasingStyle.Back)
    return dlg
end

function Library:SaveConfig(name)
    name = (tostring(name or "default"):gsub("[^%w_%- ]", ""))
    if name == "" then
        return false, "empty name"
    end
    local data = {}
    for flag, el in pairs(self.Flags) do
        if el.Serialize then
            data[flag] = el:Serialize()
        end
    end
    local ok, json = pcall(function()
        return HttpService:JSONEncode(data)
    end)
    if not ok then
        return false, "encode failed"
    end
    if not writeFile(self.ConfigFolder .. "/" .. name .. ".json", json) then
        return false, "file functions not available"
    end
    return true
end

function Library:LoadConfig(name)
    name = (tostring(name or "default"):gsub("[^%w_%- ]", ""))
    local raw = readFile(self.ConfigFolder .. "/" .. name .. ".json")
    if not raw then
        return false, "config not found"
    end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(raw)
    end)
    if not ok or type(data) ~= "table" then
        return false, "config is corrupted"
    end
    for flag, value in pairs(data) do
        local el = self.Flags[flag]
        if el and el.Deserialize then
            pcall(el.Deserialize, el, value)
        end
    end
    return true
end

function Library:ListConfigs()
    local names = {}
    if type(listfiles) ~= "function" then
        return names
    end
    local ok, files = pcall(listfiles, self.ConfigFolder)
    if not ok or type(files) ~= "table" then
        return names
    end
    for _, path in ipairs(files) do
        local n = tostring(path):match("([^/\\]+)%.json$")
        if n then
            table.insert(names, n)
        end
    end
    table.sort(names)
    return names
end

function Library:OnDestroy(fn)
    table.insert(self._destroyCallbacks, fn)
end

function Library:_buildSettings()
    local tab = self:AddTab({ Name = "Settings", Icon = "settings", Order = 1000 })

    local themeNames = { "Dark", "Midnight", "Crimson", "Light" }
    local extra = {}
    for name in pairs(Library.Themes) do
        if not table.find(themeNames, name) then
            table.insert(extra, name)
        end
    end
    table.sort(extra)
    for _, n in ipairs(extra) do
        table.insert(themeNames, n)
    end

    tab:AddSection("Interface")
    tab:AddDropdown({
        Name = "Theme",
        Options = themeNames,
        Default = self.ThemeName,
        Flag = "HH_Theme",
        Callback = function(v)
            self:SetTheme(v)
        end,
    })
    self._accentPicker = tab:AddColorPicker({
        Name = "Accent color",
        Default = self.Accent,
        Flag = "HH_Accent",
        Callback = function(c)
            self:SetAccent(c)
        end,
    })
    tab:AddSlider({
        Name = "UI scale",
        Min = 0.7,
        Max = 1.4,
        Increment = 0.05,
        Default = self.UserScale,
        Flag = "HH_Scale",
        Callback = function(v)
            self:SetScale(v)
        end,
    })
    tab:AddKeybind({
        Name = "Toggle key",
        Default = self.ToggleKey,
        Flag = "HH_ToggleKey",
        ChangedCallback = function(code)
            if code ~= Enum.KeyCode.Unknown then
                self.ToggleKey = code
            end
        end,
    })

    tab:AddSection("Effects")
    tab:AddToggle({
        Name = "Dark backdrop",
        Default = self.BackdropEnabled,
        Flag = "HH_Backdrop",
        Callback = function(v)
            self:SetBackdrop(v)
        end,
    })
    tab:AddSlider({
        Name = "Backdrop strength",
        Min = 0,
        Max = 90,
        Increment = 5,
        Suffix = "%",
        Default = math.floor((1 - self.BackdropTransparency) * 100 / 5 + 0.5) * 5,
        Flag = "HH_BackdropAmount",
        Callback = function(v)
            self:SetBackdrop(self.BackdropEnabled, 1 - v / 100)
        end,
    })
    tab:AddToggle({
        Name = "Background blur",
        Default = self.BlurEnabled,
        Flag = "HH_Blur",
        Callback = function(v)
            self:SetBlur(v)
        end,
    })
    tab:AddSlider({
        Name = "Blur size",
        Min = 0,
        Max = 40,
        Increment = 1,
        Default = self.BlurSize,
        Flag = "HH_BlurSize",
        Callback = function(v)
            self:SetBlur(self.BlurEnabled, v)
        end,
    })
    tab:AddToggle({
        Name = "Watermark",
        Default = self.WatermarkEnabled,
        Flag = "HH_Watermark",
        Callback = function(v)
            self:SetWatermark(v)
        end,
    })

    tab:AddSection("Config")
    local nameBox = tab:AddTextbox({ Name = "Config name", Default = "default", Placeholder = "name" })
    local list
    local function refreshList()
        if list then
            list:Refresh(self:ListConfigs(), false)
        end
    end
    list = tab:AddDropdown({
        Name = "Saved configs",
        Options = self:ListConfigs(),
        Callback = function(v)
            nameBox:Set(v, true)
        end,
    })
    tab:AddButton({
        Name = "Save config",
        Callback = function()
            local ok, err = self:SaveConfig(nameBox:Get())
            if ok then
                self:Notify({ Title = "Config saved", Content = nameBox:Get(), Type = "success" })
                refreshList()
            else
                self:Notify({ Title = "Could not save", Content = tostring(err), Type = "error" })
            end
        end,
    })
    tab:AddButton({
        Name = "Load config",
        Callback = function()
            local ok, err = self:LoadConfig(nameBox:Get())
            if ok then
                self:Notify({ Title = "Config loaded", Content = nameBox:Get(), Type = "success" })
            else
                self:Notify({ Title = "Could not load", Content = tostring(err), Type = "error" })
            end
        end,
    })
    tab:AddButton({
        Name = "Refresh list",
        Callback = refreshList,
    })

    tab:AddSection("Misc")
    tab:AddButton({
        Name = "Clear notifications",
        Callback = function()
            self:ClearNotifications()
        end,
    })
    tab:AddButton({
        Name = "Unload UI",
        Callback = function()
            self:Dialog({
                Title = "Unload " .. self.Name .. "?",
                Content = "This removes the UI. Run the script again to bring it back.",
                Buttons = {
                    { Text = "Cancel", Style = "outline" },
                    {
                        Text = "Unload",
                        Style = "danger",
                        Callback = function()
                            self:Destroy()
                        end,
                    },
                },
            })
        end,
    })
    self.SettingsTab = tab
end

function Library:Init()
    if self.Inited or self.Destroyed then
        return self
    end
    self.Inited = true
    if self.SettingsEnabled then
        self:_buildSettings()
    end
    if not self.ActiveTab then
        self:_selectFirst()
    end
    self:_refreshLock()
    if not self.StartHidden then
        self:Show()
    end
    if self.KeyEnabled and self.RememberKey and not self.Unlocked then
        local saved = readFile(self.KeyFile)
        if saved then
            saved = (saved:gsub("%s+", ""))
            if saved ~= "" then
                self:SetKeyText(saved)
                self:_submitKey(saved, true)
            end
        end
    end
    return self
end

function Library:Destroy()
    if self.Destroyed then
        return
    end
    self.Destroyed = true
    self._timerId = (self._timerId or 0) + 1
    for _, fn in ipairs(self._destroyCallbacks) do
        pcall(fn)
    end
    for _, c in ipairs(self._conns) do
        pcall(function()
            c:Disconnect()
        end)
    end
    pcall(function()
        self.BlurObj:Destroy()
    end)
    pcall(function()
        self.Gui:Destroy()
    end)
    local env = (getgenv and getgenv()) or _G
    if env.__HumidityHubInstance == self then
        env.__HumidityHubInstance = nil
    end
end

return Library
