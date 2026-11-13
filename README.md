# Humidity Hub

A customizable Roblox Luau UI library with a dark interface, rounded components, smooth transitions, and a simple tab and section system.

## Features

- Smooth window show and hide animations.
- Fading background overlay while the window is visible.
- No overlay while the window is hidden.
- Draggable window with minimize and close controls.
- RightShift as the default visibility toggle.
- Tabs and sections for organizing controls.
- Buttons, toggles, sliders, textboxes, dropdowns, and keybinds.
- Accent color presets and custom accent colors.
- Notifications.
- Optional key gate.
- Cleanup method that disconnects library-owned input connections.

## Installation

Load the library from the raw GitHub URL:

```lua
local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/humiditybusinessemail-prog/humidity-hub/refs/heads/main/HumidityHub.lua"
))()
```

## Quick start

Call `Hub:Init()` before creating tabs or sections.

```lua
local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/humiditybusinessemail-prog/humidity-hub/refs/heads/main/HumidityHub.lua"
))()

local Hub = Library.new({
    HubName = "Humidity Hub",
    GameName = "Example Game",
    ToggleKey = Enum.KeyCode.RightShift,
})

Hub:Init()

local MainTab = Hub:AddTab("Main")
local MainSection = Hub:AddSection(MainTab, "Main Controls")

Hub:AddLabel(MainSection, "Welcome to Humidity Hub")

Hub:AddButton(MainSection, "Print Message", function()
    print("Humidity Hub is working!")
end)

Hub:AddToggle(MainSection, "Example Toggle", false, function(enabled)
    print("Toggle:", enabled)
end)
```

## Full example UI

This example creates a small settings interface with multiple tabs and common controls. Replace the example callbacks with your own game logic.

```lua
local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/humiditybusinessemail-prog/humidity-hub/refs/heads/main/HumidityHub.lua"
))()

local Hub = Library.new({
    HubName = "Humidity Hub",
    GameName = "Universal",
    ToggleKey = Enum.KeyCode.RightShift,
    -- LogoId = "rbxassetid://127590426518205", -- Default logo
    -- Accent = Color3.fromRGB(116, 151, 255),
    -- WindowSize = Vector2.new(720, 490),
})

-- Optional key gate. Remove this block if you do not need a key.
-- Hub:SetKey("your-key", function()
--     print("Key accepted")
-- end)

Hub:Init()

-- Main tab
local MainTab = Hub:AddTab("Main")
local General = Hub:AddSection(MainTab, "General")

Hub:AddLabel(General, "Welcome to your Humidity Hub interface")
Hub:AddParagraph(
    General,
    "Getting Started",
    "Use the controls below to test the library. Add your own logic inside each callback."
)

Hub:AddButton(General, "Send Notification", function()
    Hub:Notify("Humidity Hub is ready!", Color3.fromRGB(91, 204, 143), 3)
end)

local enabledToggle = Hub:AddToggle(General, "Example Feature", false, function(enabled)
    print("Example Feature:", enabled)
end)

local speedSlider = Hub:AddSlider(
    General,
    "Example Value",
    0,
    100,
    25,
    false,
    function(value)
        print("Slider value:", value)
    end
)

Hub:AddTextbox(General, "Player Name", "Enter a name...", "", function(value, enterPressed)
    if enterPressed then
        print("Entered name:", value)
    end
end)

Hub:AddDropdown(
    General,
    "Select Option",
    {"Option A", "Option B", "Option C"},
    "Option A",
    function(selected)
        print("Selected:", selected)
    end
)

-- Settings tab
local SettingsTab = Hub:AddTab("Settings")
local Settings = Hub:AddSection(SettingsTab, "Interface")

Hub:AddKeybind(Settings, "Example Keybind", Enum.KeyCode.G, function(key)
    print("New keybind:", key.Name)
end)

Hub:AddColorPicker(Settings, "Accent Color", function(color, presetName)
    print("Accent preset:", presetName, color)
end)

Hub:AddButton(Settings, "Change Accent", function()
    Hub:SetAccent(Color3.fromRGB(168, 130, 255))
end)

Hub:AddButton(Settings, "Show Notification", function()
    Hub:Notify("This is a Humidity Hub notification.")
end)

-- The visibility key defaults to RightShift.
-- You can change it at any time:
-- Hub:SetToggleKey(Enum.KeyCode.Insert)

-- Example of changing returned control values later:
-- enabledToggle:Set(true)
-- print(enabledToggle:Get())
-- speedSlider:Set(50)
-- print(speedSlider:Get())
```

## API reference

### Create the library

```lua
local Hub = Library.new(config)
```

`config` is optional. Supported fields:

| Field | Type | Default | Description |
|---|---|---|---|
| `HubName` | string | `"Humidity Hub"` | Main hub title. |
| `GameName` | string | `"Universal"` | Small game or subtitle label. |
| `ToggleKey` | Enum.KeyCode | `RightShift` | Key used to show or hide the UI. |
| `LogoId` | string | `rbxassetid://127590426518205` | Image asset used as the hub logo. |
| `Accent` | Color3 | Blue | Initial accent color. |
| `WindowSize` | Vector2 | `Vector2.new(720, 490)` | Initial window size. |
| `Theme` | table | Built-in dark theme | Overrides matching theme color fields. |

### Window methods

| Method | Description |
|---|---|
| `Hub:Init()` | Builds and displays the interface. Call this before adding tabs. |
| `Hub:SetVisible(true/false)` | Shows or hides the interface. |
| `Hub:Toggle()` | Toggles interface visibility. |
| `Hub:SetToggleKey(Enum.KeyCode.Insert)` | Changes the visibility key. |
| `Hub:SetAccent(Color3)` | Changes the accent color. |
| `Hub:Notify(message, color, duration)` | Displays a notification. Color and duration are optional. |
| `Hub:Destroy()` | Disconnects library-owned connections and removes the UI. |

### Optional key gate

```lua
Hub:SetKey("your-key", function()
    print("The user entered the correct key")
end)
```

Call `SetKey` before `Hub:Init()`. The callback runs after the user enters the correct key.

### Tabs and sections

```lua
local Tab = Hub:AddTab("Main")
local Section = Hub:AddSection(Tab, "General")
```

`AddTab(name, icon)` accepts an optional image asset ID as `icon`.

### UI components

#### Label

```lua
Hub:AddLabel(Section, "Status: Ready")
```

#### Paragraph

```lua
Hub:AddParagraph(Section, "Information", "Add a longer description here.")
```

#### Button

```lua
Hub:AddButton(Section, "Run", function()
    print("Button clicked")
end)
```

#### Toggle

```lua
local Toggle = Hub:AddToggle(Section, "Enabled", false, function(value)
    print("Enabled:", value)
end)

Toggle:Set(true)
print(Toggle:Get())
```

`Set(value)` updates the toggle and runs its callback. `Get()` returns the current boolean value.

#### Slider

```lua
local Slider = Hub:AddSlider(Section, "Amount", 0, 100, 25, false, function(value)
    print("Amount:", value)
end)

Slider:Set(50)
print(Slider:Get())
```

Arguments: `section, text, minimum, maximum, default, isFloat, callback`.

Set `isFloat` to `true` to allow decimal values. The slider requires numeric bounds, and `maximum` must exceed `minimum`.

#### Textbox

```lua
local Textbox = Hub:AddTextbox(
    Section,
    "Username",
    "Enter username...",
    "",
    function(value, enterPressed)
        print(value, enterPressed)
    end
)
```

The callback runs when the textbox loses focus. `enterPressed` tells you whether the user pressed Enter.

#### Dropdown

```lua
local Dropdown = Hub:AddDropdown(
    Section,
    "Mode",
    {"Easy", "Normal", "Hard"},
    "Normal",
    function(value)
        print("Mode:", value)
    end
)

Dropdown:Set("Hard")
print(Dropdown:Get())
```

The dropdown returns an object with `Set(value)` and `Get()` methods.

#### Keybind

```lua
local Keybind = Hub:AddKeybind(Section, "Action Key", Enum.KeyCode.G, function(key)
    print("Selected key:", key.Name)
end)

Keybind:Set(Enum.KeyCode.H)
print(Keybind:Get().Name)
```

Click the key field, then press a keyboard key to assign it. Press Escape to cancel the change.

#### Color picker

```lua
Hub:AddColorPicker(Section, "Accent", function(color, presetName)
    print("Selected:", presetName)
end)
```

The color picker displays the built-in accent presets. Selecting a preset also updates the hub accent color.

## Built-in accent presets

- Blue
- Purple
- Cyan
- Green
- Orange
- Red
- White

## Theme customization

You can override supported theme colors when creating the hub:

```lua
local Hub = Library.new({
    HubName = "Humidity Hub",
    Theme = {
        Background = Color3.fromRGB(13, 15, 19),
        Sidebar = Color3.fromRGB(16, 18, 23),
        Surface = Color3.fromRGB(20, 23, 29),
        Surface2 = Color3.fromRGB(25, 29, 36),
        Raised = Color3.fromRGB(31, 36, 44),
        Hover = Color3.fromRGB(39, 45, 55),
        Border = Color3.fromRGB(48, 55, 67),
        Accent = Color3.fromRGB(116, 151, 255),
        TextPrimary = Color3.fromRGB(239, 242, 248),
        TextSecondary = Color3.fromRGB(153, 162, 177),
        TextMuted = Color3.fromRGB(105, 115, 132),
    },
})
```

Theme fields not listed above retain their built-in defaults. You can also set the accent after initialization with `Hub:SetAccent(Color3)`.

## Notes

- Run the library from a client-side environment with access to `Players.LocalPlayer` and `PlayerGui`.
- The library uses `loadstring` and `game:HttpGet` in the installation example. These functions depend on the environment running the script.
- Call `Hub:Init()` once before creating tabs and sections.
- Call `Hub:Destroy()` when you no longer need the interface.
- Use callbacks to connect UI controls to your own scripts. The example UI does not implement game-specific features.
