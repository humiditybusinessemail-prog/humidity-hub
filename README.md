# Humidity Hub

A UI library for Roblox executors, written in Luau. Rounded edges, smooth animations, a dark backdrop with optional blur, themes, notifications, dialogs, config saving, a built-in settings tab and a per-user key system hook.

Current version: **2.4.1**

---

## Contents

- [Example](#Example-Image-Of-Humidity-Hub)
- [Install](#install)
- [Quick start](#quick-start)
- [Window options](#window-options)
- [Tabs](#tabs)
- [Elements](#elements)
- [Keybinds](#keybinds)
- [Flags and configs](#flags-and-configs)
- [Icons](#icons)
- [Themes](#themes)
- [Notifications](#notifications)
- [Dialogs](#dialogs)
- [Key system](#key-system)
- [Built-in Settings tab](#built-in-settings-tab)
- [Window methods](#window-methods)
- [Executor functions used](#executor-functions-used)
- [Notes](#notes)

## Example image of Humidity Hub

<img width="1163" height="742" alt="image" src="https://github.com/user-attachments/assets/44ea9aee-efa3-4965-b121-146cd1fb41f2" />

<img width="1120" height="720" alt="image" src="https://github.com/user-attachments/assets/d73bc4bd-9911-471a-97d4-242264b813ed" />

---

## Install

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/humiditybusinessemail-prog/humidity-hub/refs/heads/main/HumidityHub.lua"))()
```

---

## Quick start

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/humiditybusinessemail-prog/humidity-hub/refs/heads/main/HumidityHub.lua"))()

local Window = Library.new{
    Name = "Humidity Hub",
    Subtitle = "v1.0",
    Theme = "Dark",
    ToggleKey = Enum.KeyCode.RightShift,
    Blur = true,
}

local Main = Window:AddTab{ Name = "Main", Icon = "home", Order = 1 }

Main:AddSection("Example")

Main:AddToggle{
    Name = "Enabled",
    Default = false,
    Flag = "enabled",
    Callback = function(value)
        print("enabled:", value)
    end,
}

Main:AddSlider{
    Name = "Speed",
    Min = 0,
    Max = 100,
    Increment = 1,
    Default = 25,
    Suffix = "%",
    Flag = "speed",
    Callback = function(value)
        print("speed:", value)
    end,
}

Main:AddButton{
    Name = "Say hi",
    Callback = function()
        Window:Notify{ Title = "Hello", Content = "It works.", Type = "success" }
    end,
}

Window:Init()
```

If you forget `Window:Init()`, the library calls it for you on the next frame.

Only one Humidity Hub window exists at a time. Running a new `Library.new` destroys the previous one.

---

## Window options

`Library.new{ ... }` accepts:

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `Name` | string | `"Humidity Hub"` | Title in the top bar. |
| `Subtitle` | string | `""` | Small text under the title. Hidden when empty. |
| `Theme` | string | `"Dark"` | `Dark`, `Midnight`, `Crimson`, `Light`, or a custom theme name. |
| `Accent` | Color3 | theme accent | Overrides the accent color. |
| `Scale` | number | `1.25` | UI scale, clamped to 0.6 - 1.6. |
| `ToggleKey` | KeyCode | `RightShift` | Key that shows and hides the window. |
| `Backdrop` | boolean | `true` | Dark fade behind the window while it is open. |
| `BackdropTransparency` | number | `0.45` | 0 is solid black, 1 is invisible. |
| `Blur` | boolean | `false` | Blur the game behind the window while it is open. |
| `BlurSize` | number | `14` | Blur strength. |
| `Logo` | number or string | built-in logo | Asset id or `rbxassetid://` string. Default is `127590426518205`. |
| `Size` | UDim2 | `640 x 420` offset | Window size before scaling. |
| `Watermark` | boolean or string | off | Shows a small watermark with FPS. A string sets its text. |
| `Settings` | boolean | `true` | Set `false` to skip the built-in Settings tab. |
| `ConfigFolder` | string | `"HumidityHub/configs"` | Folder for saved configs. |
| `StartHidden` | boolean | `false` | Start with the window closed. |
| `Icons` | table | none | Extra icon names, `{ name = assetId }`. |

---

## Tabs

```lua
local Tab = Window:AddTab{ Name = "Combat", Icon = "combat", Order = 2 }
```

`AddTab` also accepts `Window:AddTab("Name", "icon")`.

- `Order` decides the sidebar position. Lower comes first.
- The first tab (lowest order) is selected on start.

Tab methods:

| Method | Description |
| --- | --- |
| `Tab:SetIcon(icon)` | Change the tab icon. |
| `Tab:SetName(name)` | Rename the tab. |
| `Tab:Select()` | Switch to this tab. |

`Window:SelectTab(tab)` also works.

---

## Elements

All elements are added to a tab and return an element object.

### Section

```lua
Tab:AddSection("Aimbot")
```

Small accent-colored heading. Text is shown uppercase. Returns an element with `SetText`.

### Label

```lua
local label = Tab:AddLabel("Some text")
label:SetText("New text")
```

### Paragraph

```lua
local p = Tab:AddParagraph{ Title = "Info", Content = "Longer text. <b>Rich text</b> works." }
p:SetTitle("New title")
p:SetContent("New content")
```

### Divider

```lua
Tab:AddDivider()
```

### Button

```lua
Tab:AddButton{
    Name = "Do thing",
    Icon = "mouse-pointer-click",
    Callback = function() end,
}
```

`Icon` is optional. A shorthand also works: `Tab:AddButton("Do thing", function() end)`. Returns an element with `SetText`.

### Toggle

```lua
local toggle = Tab:AddToggle{
    Name = "ESP",
    Default = false,
    Flag = "esp",
    Callback = function(value) end,
}
toggle:Set(true)
toggle:Set(false, true)
print(toggle:Get())
```

The second argument of `Set` is `silent`. When `true`, the callback is not fired. Setting the value it already has does nothing.

### Slider

```lua
local slider = Tab:AddSlider{
    Name = "FOV",
    Min = 20,
    Max = 600,
    Increment = 5,
    Default = 80,
    Suffix = " px",
    Flag = "fov",
    Callback = function(value) end,
}
```

Decimal increments work, for example `Increment = 0.05`. Values snap to the increment.

### Textbox

```lua
local box = Tab:AddTextbox{
    Name = "Name",
    Default = "",
    Placeholder = "type here",
    ClearOnFocus = false,
    Flag = "name",
    Callback = function(text) end,
}
```

The callback fires when the box loses focus.

### Dropdown

Single select:

```lua
local dd = Tab:AddDropdown{
    Name = "Mode",
    Options = { "One", "Two", "Three" },
    Default = "One",
    Flag = "mode",
    Callback = function(value)
        print(value)
    end,
}
dd:Set("Two")
```

Multi select:

```lua
local multi = Tab:AddDropdown{
    Name = "Parts",
    Options = { "Head", "Torso", "Legs" },
    Default = { "Head" },
    Multi = true,
    Flag = "parts",
    Callback = function(list)
        print(table.concat(list, ", "))
    end,
}
```

- Single select gives and takes a string. Multi select gives and takes a table of strings.
- `dd:Refresh(newOptions, keepSelection)` replaces the option list. Pass `true` as the second argument to keep selections that still exist.
- The list shows five options at a time and scrolls after that.

### Color picker

```lua
local picker = Tab:AddColorPicker{
    Name = "ESP color",
    Default = Color3.fromRGB(255, 80, 80),
    Flag = "esp_color",
    Callback = function(color) end,
}
picker:Set(Color3.fromRGB(0, 255, 0))
```

Click the row to open the saturation/value box and the hue bar. The hex code is shown underneath.

### Common element methods

| Method | Description |
| --- | --- |
| `el:Set(value, silent)` | Set the value. Not available on buttons, labels, sections, paragraphs, dividers. |
| `el:Get()` | Read the value. |
| `el:Serialize()` | Value in a JSON-safe form (used by configs). |
| `el:Deserialize(data)` | Apply a serialized value. |
| `el:SetVisible(bool)` | Show or hide the row. |
| `el:Destroy()` | Remove the element. |

---

## Keybinds

```lua
local bind = Tab:AddKeybind{
    Name = "Toggle ESP",
    Default = Enum.KeyCode.Unknown,
    Flag = "esp_key",
    Callback = function()
        print("pressed")
    end,
    ChangedCallback = function(key)
        print("rebound to", key)
    end,
}
```

- Click the row, then press a key to bind it.
- **Press Escape while listening to clear the bind.** It then shows `None`.
- `Default = Enum.KeyCode.Unknown` starts unbound. A string such as `"F"` also works.
- `Callback` fires when the bound key is pressed, as long as the game did not already use the key (for example while typing in chat).
- `ChangedCallback` fires when the key is rebound or cleared, and receives the new `KeyCode`.
- `bind:Get()` returns the `KeyCode`. `bind:Set(code, silent)` changes it. `silent` skips `ChangedCallback`.
- `Serialize` stores the key name, so keybinds save with configs.

If you handle the key press yourself, read `bind:Get()` and ignore `Enum.KeyCode.Unknown`.

---

## Flags and configs

Give any element a `Flag` and it is stored in `Window.Flags[flag]`.

```lua
Window:GetFlag("speed")
Window.Flags.speed:Set(50)
```

Configs save every flagged element to JSON:

```lua
local ok, err = Window:SaveConfig("legit")
local ok2, err2 = Window:LoadConfig("legit")
local names = Window:ListConfigs()
```

- Files are written to `ConfigFolder/<name>.json`. Names are cleaned to letters, numbers, spaces, `_` and `-`.
- Saving needs the executor's file functions. Without them `SaveConfig` returns `false, "file functions not available"`.
- Loading calls each element's `Deserialize`, so callbacks fire for the loaded values.
- The Settings tab uses flags that start with `HH_`.

---

## Icons

About 300 icons are built in, by lowercase name (`home`, `settings`, `eye`, `crosshair`, `shield`, `lock`, `key`, `bell`, `gamepad`, `palette`, `user`, `users`, `sliders`, `command`, `gavel`, `building`, and many more). The full list is the `Library.Icons` table in `HumidityHub.lua`.

A tab, button or notification icon can be:

| Value | Result |
| --- | --- |
| `"home"` | Built-in or custom pack name. |
| `7733960981` | A number is treated as an asset id. |
| `"rbxassetid://7733960981"` | Full asset string. |
| `"7733960981"` | A string of 4 or more digits is treated as an asset id. |
| any other string | The first 2 characters are shown as text, for example `"P"`. |
| `nil` | The first letter of the tab name is shown. |

A name that is not found also falls back to text, so a typo shows as a letter instead of an error.

Add your own icons:

```lua
local Window = Library.new{
    Name = "Hub",
    Icons = { mything = 1234567890 },
}

Window:SetIconPack({ another = "rbxassetid://1234567891" })
```

`SetIconPack` rebuilds the existing tab icons.

---

## Themes

Built-in: `Dark`, `Midnight`, `Crimson`, `Light`.

```lua
Window:SetTheme("Midnight")
Window:SetAccent(Color3.fromRGB(255, 120, 0))
```

`SetTheme` returns `false` if the theme does not exist. If you never set a custom accent, changing theme also changes the accent.

Custom theme, added before `Library.new`:

```lua
Library.Themes.Ocean = {
    Background = Color3.fromRGB(8, 18, 28),
    Surface = Color3.fromRGB(12, 26, 40),
    Element = Color3.fromRGB(17, 34, 52),
    ElementHover = Color3.fromRGB(24, 46, 68),
    Stroke = Color3.fromRGB(34, 60, 86),
    Text = Color3.fromRGB(232, 240, 248),
    SubText = Color3.fromRGB(130, 156, 180),
    Accent = Color3.fromRGB(64, 196, 255),
    Success = Color3.fromRGB(72, 199, 128),
    Warning = Color3.fromRGB(255, 184, 77),
    Error = Color3.fromRGB(240, 84, 84),
}
```

All eleven keys are required. Custom themes show up in the Settings theme dropdown automatically.

---

## Notifications

```lua
Window:Notify{
    Title = "Saved",
    Content = "Config saved.",
    Duration = 4,
    Type = "success",
    Icon = "check-circle",
}
```

| Field | Description |
| --- | --- |
| `Title` | Bold heading. Defaults to the window name. |
| `Content` | Body text. Wraps and sizes the card to fit. |
| `Duration` | Seconds before it closes. Default `4`. `0` keeps it until dismissed. |
| `Type` | `info`, `success`, `warning`, `error`. `ok`, `warn` and `err` also work. |
| `Icon` | Optional icon name or asset. Each type has a default icon. |

- Notifications stack in the bottom-right corner, with a progress bar and a close button.
- At most 5 show at once. The oldest is dismissed to make room.
- `Notify` returns a handle with `Dismiss()`.
- `Window:ClearNotifications()` closes all of them.
- Positional form: `Window:Notify("Title", "Content", 4, "info")`.

---

## Dialogs

```lua
local dlg = Window:Dialog{
    Title = "Delete config?",
    Content = "This cannot be undone.",
    Buttons = {
        { Text = "Cancel", Style = "outline" },
        { Text = "Delete", Style = "danger", Callback = function() end },
    },
}
```

Button fields:

| Field | Description |
| --- | --- |
| `Text` | Button label. |
| `Style` | `outline`, `accent` or `danger`. If left out, the last button is `accent` and the others are `outline`. |
| `Callback` | Called when clicked. Receives the input text if the dialog has an input. |
| `KeepOpen` | `true` keeps the dialog open after the click. |

Dialog with a text input:

```lua
local dlg
dlg = Window:Dialog{
    Title = "Paste token",
    Content = "Paste the token below.",
    Input = { Placeholder = "token", Default = "" },
    Buttons = {
        {
            Text = "Submit",
            Style = "accent",
            KeepOpen = true,
            Callback = function(text)
                dlg.SetContent("Checking " .. text)
            end,
        },
        { Text = "Cancel", Style = "outline" },
    },
}
```

`Input = true` gives a plain input box.

The returned handle uses **dot calls, not colon calls**:

| Call | Description |
| --- | --- |
| `dlg.Close()` | Close the dialog. |
| `dlg.GetInput()` | Current text of the input box, or `nil` without an input. |
| `dlg.SetContent(text)` | Replace the body text. Only works if the dialog was created with `Content`. |

---

## Key system

The library handles the key screen, the saved key, the countdown and expiry. You supply a validate function, so any backend works.

```lua
Window:SetKeyPrompt{
    Title = "My Hub",
    Subtitle = "Enter your key to continue",
    Placeholder = "XXXX-XXXX",
    Submit = "Unlock",
    Link = "Get key",
}

Window:SetKeyLink("https://example.com/getkey")

Window:SetRememberKey(true)

Window:SetKey(function(key)
    if key == "demo" then
        return true, 86400
    end
    return false, "That key isn't valid."
end, function(info)
    print("unlocked, seconds left:", info.SecondsLeft)
end, function()
    print("key expired")
end)

Window:Init()
```

Call all of these before `Window:Init()`.

**Validate function** gets the key string and returns `ok, info`. It can also return a table with `valid`, `ok` or `success`. On failure, `info` can be a message string, or a table with `message`, `reason` or `error`.

**Expiry** is read from `info` on success:

- a number: unix seconds, unix milliseconds, or seconds from now
- an ISO-8601 string such as `2025-01-31T12:00:00Z`
- a table with `expires_at`, `ExpiresAt`, `expires`, `expiry`, or a seconds-left field such as `SecondsLeft` or `ttl`
- nothing: the key never expires

**What the library does:**

- Shows the key page instead of the tabs until a key is accepted.
- Shows a countdown pill in the sidebar. It changes color under 1 hour and under 5 minutes, and warns once at 5 minutes.
- On expiry it locks the window again, deletes the saved key, calls `onExpire` and shows the window.
- With `SetRememberKey(true)` the accepted key is saved to `HumidityHub/key.txt` and checked silently on the next start. Pass a string to use a different file: `SetRememberKey("MyHub/key.txt")`.

**Key functions:**

| Method | Description |
| --- | --- |
| `Window:SetKey(validate, onUnlock, onExpire)` | Turns the key system on. `onUnlock` receives the key info table. |
| `Window:SetKeyLink(link)` | A string copies the link. A function is called with the window, so you can open your own flow. |
| `Window:SetKeyPrompt(table)` | Texts on the key page. |
| `Window:SetRememberKey(bool or path)` | Save the key between runs. |
| `Window:SetKeyText(text)` | Fill the key box. |
| `Window:SetKeyStatus(text, kind)` | Status line. `kind` is `info`, `success`, `warning` or `error`. |
| `Window:GetKeyInfo()` | `{ Key, ExpiresAt, SecondsLeft, Raw }` or `nil`. |
| `Window:Lock(message, kind)` | Lock the window again. |

A common pattern is to create the tabs inside `onUnlock`, so nothing exists until the key is valid.

---

## Built-in Settings tab

Added automatically (order 1000) unless you pass `Settings = false`.

- **Interface:** theme, accent color, UI scale (0.7 - 1.4), toggle key
- **Effects:** dark backdrop, backdrop strength, background blur, blur size, watermark
- **Config:** config name, saved configs list, save, load, refresh
- **Misc:** clear notifications, unload UI

The toggle key cannot be cleared there. Pressing Escape on it leaves the current key in place.

---

## Window methods

| Method | Description |
| --- | --- |
| `Window:Init()` | Builds the Settings tab, shows the window and checks a saved key. |
| `Window:Show()` / `Hide()` / `Toggle()` | Open, close, flip. |
| `Window:IsVisible()` | Current state. |
| `Window:SetTitle(text)` / `SetSubtitle(text)` | Change the top bar text. |
| `Window:SetLogo(id)` | Change the logo in the top bar and watermark. |
| `Window:SetTheme(name)` / `SetAccent(color)` | Theme and accent. |
| `Window:SetScale(n)` | UI scale, 0.6 - 1.6. |
| `Window:SetBackdrop(enabled, transparency)` | Backdrop on or off, optional transparency. |
| `Window:SetBlur(enabled, size)` | Blur on or off, size 0 - 56. |
| `Window:SetWatermark(value)` | `true`, `false` or a text string. |
| `Window:GetFlag(flag)` | Value of a flagged element. |
| `Window:SaveConfig(name)` / `LoadConfig(name)` / `ListConfigs()` | Configs. |
| `Window:OnDestroy(fn)` | Run a function when the UI is unloaded. |
| `Window:Destroy()` | Remove the UI and disconnect everything. |

Use `OnDestroy` to clean up anything your script created (connections, ESP objects, render steps), so unloading leaves nothing behind.

---

## Executor functions used

All of these are optional. The library checks for each one and falls back when it is missing.

| Function | Used for |
| --- | --- |
| `gethui` | Parenting the UI. Falls back to `CoreGui`, then `PlayerGui`. |
| `syn.protect_gui` | Protecting the UI where available. |
| `getgenv` | Tracking the single running instance. Falls back to `_G`. |
| `writefile`, `readfile`, `isfile` | Configs and the remembered key. |
| `makefolder`, `isfolder` | Creating folders. |
| `listfiles` | Listing saved configs. |
| `delfile` | Removing the saved key on lock. |
| `setclipboard` / `toclipboard` | Copying the key link when `SetKeyLink` is a string. |

Without the file functions the UI works, but configs and remembered keys do not.

---

## Notes

- Touch input is supported for dragging the window, sliders and the color picker.
- Drag the window by its top bar.
- The window scales with `Scale`. The default of 1.25 is larger than most libraries, so lower it if you want a compact UI.
- Saved configs store flagged values, including the Settings tab flags (scale, blur, theme), so an old config can override new defaults until you save again.
- `Dialog` handles use dot calls (`dlg.Close()`), not colon calls.
- Notifications use `TextService` to size cards, so very long content is cut at the five-notification limit rather than scrolling.
