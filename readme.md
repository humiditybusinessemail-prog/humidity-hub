# Humidity Hub UI Library

A lightweight Roblox UI library for building script hubs. Sidebar tabs, sections, a full set of controls, a live accent color switcher, toast notifications, and an optional key gate.

- Dark theme with a changeable accent color
- Draggable window with open/close animations
- Toggle the window with `RightShift` (rebindable)
- Optional key system (string or custom validator function)

---

## Table of Contents

1. [Loading the Library](#loading-the-library)
2. [Quick Start](#quick-start)
3. [Creating a Window](#creating-a-window)
4. [Key System](#key-system)
5. [Tabs and Sections](#tabs-and-sections)
6. [Elements](#elements)
7. [Notifications](#notifications)
8. [Theming](#theming)
9. [Full Example](#full-example)
10. [Gotchas](#gotchas)
11. [API Reference](#api-reference)

---

## Loading the Library

```lua
local VLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/humiditybusinessemail-prog/humidity-hub/refs/heads/main/src.lua"))()
```

`VLib` is the library table. You create windows with `VLib.new(config)`.

> The URL must point directly at the raw file. Open the link in a browser first: you should see plain Lua code, not a 404.

---

## Quick Start

```lua
local VLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/humiditybusinessemail-prog/humidity-hub/refs/heads/main/src.lua"))()

local hub = VLib.new({
    HubName  = "Humidity Hub",
    GameName = "My Game",
})

hub:Init()

local main = hub:AddTab("Main")
local sec  = hub:AddSection(main, "Player")

hub:AddToggle(sec, "God Mode", false, function(state)
    print("God Mode:", state)
end)
```

Order matters: **create the window, call `Init()`, then add tabs and elements.**

---

## Creating a Window

```lua
local hub = VLib.new(config)
```

All config fields are optional.

| Field      | Type   | Default                   | Description                                      |
|------------|--------|---------------------------|--------------------------------------------------|
| `HubName`  | string | `"Humidity Hub"`          | Title shown under the logo in the sidebar        |
| `GameName` | string | `"Universal"`             | Subtitle shown under the hub name                |
| `LogoId`   | string | `rbxassetid://6031075938` | Sidebar logo. Use an `rbxassetid://` string      |
| `Accent`   | Color3 | Blue (66, 135, 245)       | Accent color. The dim variant is derived from it |
| `Theme`    | table  | built-in dark theme       | Override any theme key (see [Theming](#theming)) |

```lua
local hub = VLib.new({
    HubName  = "Humidity Hub",
    GameName = "Some Game",
    LogoId   = "rbxassetid://1234567890",
    Accent   = Color3.fromRGB(0, 195, 180),
})
```

Then call `hub:Init()` to build and show the window.

---

## Key System

Call `SetKey` **before** `Init()`. A key gate shows first, and the hub only builds after a correct key. The gate text reads "Enter your key to access" followed by your `HubName`.

```lua
-- Fixed string key
hub:SetKey("MY-SECRET-KEY", function(enteredKey)
    print("Unlocked with:", enteredKey)
end)

-- Or a validator function
hub:SetKey(function(entered)
    return entered == "abc" or entered == "def"
end)

hub:Init()
```

- `validKey`: a string (exact match) or a function `(entered) -> boolean`
- `onUnlock(enteredKey)`: optional, called when the key is accepted

> With a key gate, the window is built *after* the user unlocks, so you must wait for it before adding tabs. See [Gotchas](#gotchas).

---

## Tabs and Sections

```lua
local tab = hub:AddTab(name, icon)
```

- `name`: string shown in the sidebar and title bar
- `icon`: optional `rbxassetid://` string
- Returns a tab object. The first tab you add is selected automatically.

```lua
local section = hub:AddSection(tab, name)
```

- `tab`: the object returned by `AddTab`
- `name`: header text shown above the section's rows (pass `""` or `nil` for no header)
- Returns a section object, which you pass into every element method.

```lua
local combat = hub:AddTab("Combat")
local aim    = hub:AddSection(combat, "Aim Assist")
local misc   = hub:AddSection(combat, "Misc")
```

Elements appear in the order you create them, grouped under their section.

---

## Elements

Every element method is called on the hub with a colon and takes a `section` as its first argument.

### Label

```lua
local lbl = hub:AddLabel(section, "Some text")
lbl.Text = "Updated text"   -- returns the TextLabel
```

### Paragraph

A title plus wrapped body text.

```lua
hub:AddParagraph(section, "Info", "Longer description that wraps across multiple lines.")
```

### Button

```lua
hub:AddButton(section, "Do Thing", function()
    print("clicked")
end)
```

Returns the TextButton.

### Toggle

```lua
local tgl = hub:AddToggle(section, "Auto Farm", false, function(state)
    print(state)
end)

tgl.value        -- current boolean
tgl.Set(true)    -- set state (fires the callback)
```

The callback does **not** fire at creation, only on change.

### Slider

```lua
local sld = hub:AddSlider(section, "WalkSpeed", 16, 100, 16, false, function(value)
    print(value)
end)

sld.value
sld.Set(50)      -- moves the slider (does NOT fire the callback)
```

Arguments: `section, text, min, max, default, isFloat, callback`

- `isFloat = true` rounds to 2 decimals, `false` rounds to integers.
- The callback fires continuously while dragging.

### Textbox

```lua
local box = hub:AddTextbox(section, "Target", "player name...", "", function(text, enterPressed)
    print(text, enterPressed)
end)
```

The callback fires when the box loses focus. Returns the TextBox.

### Dropdown

```lua
local dd = hub:AddDropdown(section, "Mode", {"Easy", "Normal", "Hard"}, "Normal", function(choice)
    print(choice)
end)

dd.value
dd.Set("Hard")   -- updates display (does NOT fire the callback)
```

### Keybind

```lua
local kb = hub:AddKeybind(section, "Fly Key", Enum.KeyCode.F, function(newKey)
    print("Bound to", newKey)
end)

kb.value           -- current Enum.KeyCode
kb.Set(Enum.KeyCode.G)
```

Click the key box, then press a key to rebind. `Escape` cancels, and the red `x` clears the bind (`Enum.KeyCode.Unknown`).

> The callback fires when the **binding changes**, not when the key is pressed. To actually act on the key, listen yourself:
>
> ```lua
> local UserInputService = game:GetService("UserInputService")
>
> UserInputService.InputBegan:Connect(function(input, gp)
>     if gp then return end
>     if input.KeyCode == kb.value then
>         -- do the thing
>     end
> end)
> ```

### Color Picker (accent switcher)

Shows a row of preset swatches and live-recolors the hub on click.

```lua
hub:AddColorPicker(section, "Accent Color", function(color, name)
    print("Picked", name)
end)
```

Presets live in `VLib.AccentPresets` (Blue, Amber, Green, Red, Teal, White). Edit or extend that table before adding the color picker to change the swatches.

---

## Notifications

```lua
hub:Notify(text, color, duration)
```

- `text`: string
- `color`: optional Color3 for the text (default: primary text color)
- `duration`: optional seconds (default `1.8`)

```lua
hub:Notify("Auto Farm enabled", Color3.fromRGB(80, 210, 120))
hub:Notify("Something broke", Color3.fromRGB(220, 70, 70), 3)
```

Only one toast is shown at a time, and a new one replaces the text of the current one. `Notify` only works once the window exists (see [Gotchas](#gotchas)).

---

## Theming

Pass overrides in `config.Theme`, or set a single `Accent`:

```lua
local hub = VLib.new({
    Accent = Color3.fromRGB(220, 70, 70),
    Theme = {
        Background = Color3.fromRGB(10, 10, 12),
        Surface    = Color3.fromRGB(18, 18, 20),
    },
})
```

Available theme keys:

`Background`, `Surface`, `Raised`, `Border`, `Accent`, `AccentDim`, `TextPrimary`, `TextSecondary`, `TextDisabled`, `Success`, `Warning`, `Error`, `TabBar`, `Sidebar`

Change the accent at runtime:

```lua
hub:SetAccent(Color3.fromRGB(240, 165, 0))
```

This recolors the top bar, the active tab indicator and the scrollbars. Elements created afterwards also use the new accent.

Change the window toggle key (default `RightShift`):

```lua
hub:SetToggleKey(Enum.KeyCode.Insert)
```

The window's red `x` button hides it, and the toggle key brings it back.

---

## Full Example

```lua
local VLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/humiditybusinessemail-prog/humidity-hub/refs/heads/main/src.lua"))()
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local hub = VLib.new({
    HubName  = "Humidity Hub",
    GameName = "Universal",
    Accent   = Color3.fromRGB(66, 135, 245),
})

-- optional key gate
hub:SetKey("HUMIDITY-KEY", function(k)
    print("Key accepted:", k)
end)

hub:Init()

-- wait for the window (needed when a key gate is used, harmless otherwise)
while not hub._toast do task.wait() end

-- Player tab
local playerTab = hub:AddTab("Player")
local movement  = hub:AddSection(playerTab, "Movement")

hub:AddSlider(movement, "WalkSpeed", 16, 100, 16, false, function(v)
    local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = v end
end)

hub:AddToggle(movement, "Infinite Jump", false, function(on)
    hub:Notify("Infinite Jump " .. (on and "ON" or "OFF"))
end)

hub:AddKeybind(movement, "Toggle UI Key", Enum.KeyCode.RightShift, function(kc)
    hub:SetToggleKey(kc)
end)

-- Misc tab
local miscTab = hub:AddTab("Misc")
local tools   = hub:AddSection(miscTab, "Tools")

hub:AddDropdown(tools, "Mode", {"Easy", "Normal", "Hard"}, "Normal", function(choice)
    print("Selected", choice)
end)

hub:AddButton(tools, "Run Action", function()
    hub:Notify("Done")
end)

-- Settings tab
local settingsTab = hub:AddTab("Settings")
local ui = hub:AddSection(settingsTab, "Interface")

hub:AddColorPicker(ui, "Accent Color")
hub:AddParagraph(ui, "About", "Press RightShift to hide or show the hub.")
```

---

## Gotchas

- **Add tabs after the window exists.** Without a key, `Init()` builds immediately. With `SetKey`, the window is built after the correct key is entered, so `AddTab` or `Notify` straight after `Init()` will error. Use `while not hub._toast do task.wait() end` before adding tabs.
- **Setters don't always fire callbacks.** `Toggle.Set` fires its callback, but `Slider.Set` and `Dropdown.Set` do not. Creation never fires callbacks.
- **Keybind callbacks fire on rebind**, not on key press.
- **Logos must be Roblox assets.** `ImageLabel` can't load external URLs, so use `rbxassetid://ID`.
- **Use a section from the right tab.** Rows are placed on the page of the tab the section belongs to, so passing a section from a different tab puts the element on that other tab.
- **`SetAccent` doesn't repaint everything.** Static pieces like existing slider fills and value labels keep their original color. Pick the accent in `VLib.new` if you want it fully consistent.
- **Raw URL must be a file.** `raw.githubusercontent.com` links have to end in the filename, the repo must be public, and edits can take a few minutes to show up because of caching.

---

## API Reference

| Method | Returns | Notes |
|--------|---------|-------|
| `VLib.new(config)` | hub | Creates the ScreenGui, does not show the window yet |
| `hub:SetKey(key, onUnlock)` | | Call before `Init()` |
| `hub:Init()` | hub | Shows key gate or builds window |
| `hub:AddTab(name, icon)` | tab | First tab auto-selects |
| `hub:AddSection(tab, name)` | section | |
| `hub:AddLabel(section, text)` | TextLabel | |
| `hub:AddParagraph(section, title, content)` | | |
| `hub:AddButton(section, text, cb)` | TextButton | |
| `hub:AddToggle(section, text, default, cb)` | `{value, Set}` | |
| `hub:AddSlider(section, text, min, max, default, isFloat, cb)` | `{value, Set}` | |
| `hub:AddTextbox(section, text, placeholder, default, cb)` | TextBox | `cb(text, enterPressed)` |
| `hub:AddDropdown(section, text, options, default, cb)` | `{value, Set}` | |
| `hub:AddKeybind(section, text, default, cb)` | `{value, Set}` | |
| `hub:AddColorPicker(section, text, cb)` | | `cb(color, presetName)` |
| `hub:Notify(text, color, duration)` | | |
| `hub:SetAccent(color)` | | Live recolor |
| `hub:SetToggleKey(keyCode)` | | Default `RightShift` |
| `VLib.AccentPresets` | table | `{name, color}` list used by the color picker |
