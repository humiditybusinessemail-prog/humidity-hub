# Humidity Hub

A Roblox executor UI library with a built-in key system. Rounded, animated, themeable, and generic: the library knows nothing about your backend, your hub script supplies it.

- Dark backdrop fade behind the UI while it's open, optional blur
- Animated window, tabs, dropdowns and color picker
- Notifications with icons, action buttons, hover-pause and a progress bar
- Dialogs with buttons and an optional text input
- Four themes plus custom colors, live accent switching
- Config saving and loading
- Mobile toggle button and automatic scaling to the screen
- Key system with async validation, countdown pill and an expiry lock
- Optional free key flow: Supabase + work.ink, 24h for 1 checkpoint, 48h for 2

<img width="1163" height="742" alt="image" src="https://github.com/user-attachments/assets/44ea9aee-efa3-4965-b121-146cd1fb41f2" />

<img width="1120" height="720" alt="image" src="https://github.com/user-attachments/assets/d73bc4bd-9911-471a-97d4-242264b813ed" />


## Files

| File | What it is |
| --- | --- |
| `HumidityHub.lua` | The UI library |
| `Hub.lua` | A complete hub script with the Supabase + work.ink key flow |
| `token.html` | The page work.ink sends users to, shows the token with a copy button |
| `README.md` | This file |

## Quick start

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/humiditybusinessemail-prog/humidity-hub/refs/heads/main/HumidityHub.lua"))()

local Hub = Library.new{
    HubName = "Humidity Hub",
    GameName = "My Game",
    Theme = "Dark",
    ToggleKey = Enum.KeyCode.RightShift,
}

local main = Hub:AddTab{Name = "Main", Icon = "M"}

main:AddSection("Combat")

main:AddToggle{
    Name = "Auto farm",
    Description = "farms for you",
    Flag = "auto_farm",
    Default = false,
    Callback = function(state)
        print("auto farm", state)
    end,
}

main:AddSlider{
    Name = "Speed",
    Flag = "speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Callback = function(value)
        print("speed", value)
    end,
}

Hub:Init()
```

`Init()` builds the Settings tab and opens the hub. If a key validator was set with `SetKey`, it opens the key window first.

## Library.new options

| Option | Type | Default | Notes |
| --- | --- | --- | --- |
| `HubName` | string | `"Humidity Hub"` | Shown in the top bar |
| `GameName` | string | `""` | Small subtitle under the name |
| `Size` | UDim2 | `640 x 430` | Shrinks automatically on small screens |
| `Theme` | string or table | `"Dark"` | A preset name, or a table that overrides colors |
| `Accent` | Color3 | theme accent | Overrides the accent color |
| `LogoId` | number or string | `127590426518205` | Decal or image asset id |
| `Scale` | number | `1` | UI scale, 0.6 to 1.6 |
| `ToggleKey` | KeyCode | `RightShift` | Show or hide key |
| `MobileButton` | boolean | auto | Floating toggle button, on by default for touch-only devices |
| `Settings` | boolean | `true` | Set `false` to skip the built-in Settings tab |

### Themes

`Dark`, `Midnight`, `Crimson`, `Light`.

A custom theme overrides any of these keys: `Background`, `Panel`, `Element`, `ElementHover`, `Stroke`, `Text`, `SubText`, `Accent`.

```lua
local Hub = Library.new{
    Theme = {
        Background = Color3.fromRGB(10, 10, 10),
        Accent = Color3.fromRGB(255, 120, 60),
    },
}
```

## Tabs and elements

```lua
local tab = Hub:AddTab{Name = "Visuals", Icon = "V", Order = 3}
```

`Icon` can be a short string (a letter or symbol), an asset id number, or an `rbxassetid://` string. `Order` controls sidebar position.

Every element takes a table. Elements that have a `Flag` are stored in `Hub.Flags` and included in saved configs.

| Element | Options | Methods |
| --- | --- | --- |
| `AddSection(name)` | | |
| `AddDivider()` | | |
| `AddLabel(text)` | `Text` | `Set`, `Destroy` |
| `AddParagraph{}` | `Title`, `Content` | `SetTitle`, `SetContent`, `Set`, `Destroy` |
| `AddButton{}` | `Name`, `Description`, `Callback` | `SetText`, `Destroy` |
| `AddToggle{}` | `Name`, `Description`, `Flag`, `Default`, `Callback` | `Set(value, silent)`, `Get`, `Destroy` |
| `AddSlider{}` | `Name`, `Description`, `Flag`, `Min`, `Max`, `Increment`, `Default`, `Suffix`, `Callback` | `Set(value, silent)`, `Get`, `Destroy` |
| `AddTextbox{}` | `Name`, `Description`, `Flag`, `Default`, `Placeholder`, `Callback` | `Set(value, silent)`, `Get`, `Destroy` |
| `AddDropdown{}` | `Name`, `Description`, `Flag`, `Options`, `Default`, `Multi`, `Callback` | `Set(value, silent)`, `Get`, `Refresh(options)`, `Destroy` |
| `AddKeybind{}` | `Name`, `Description`, `Flag`, `Default`, `Callback`, `Changed` | `Set(key, silent)`, `Get`, `Destroy` |
| `AddColorPicker{}` | `Name`, `Description`, `Flag`, `Default`, `Callback` | `Set(color, silent)`, `Get`, `Destroy` |

Notes:

- `silent = true` updates the element without firing its callback.
- A textbox fires its callback when it loses focus.
- A multi dropdown's default and result are lists.
- A keybind fires `Callback` when the key is pressed, and `Changed` when the user rebinds it. Backspace clears it, Escape cancels.

```lua
local mode = tab:AddDropdown{
    Name = "Target",
    Options = {"Closest", "Lowest health", "Random"},
    Default = "Closest",
    Flag = "target",
    Callback = function(choice)
        print(choice)
    end,
}

mode:Refresh({"Closest", "Random"})
```

## Notifications

```lua
Hub:Notify("Title", "Some text")
Hub:Notify("Title", "Some text", 8)
Hub:Notify("Title", "Some text", "success")

Hub:Notify{
    Title = "Update available",
    Content = "a new version is out",
    Type = "info",
    Duration = 10,
    Action = {
        Text = "Open",
        Callback = function()
            print("clicked")
        end,
    },
}
```

| Field | Notes |
| --- | --- |
| `Title`, `Content` | Text |
| `Type` | `info`, `success`, `warning`, `error` |
| `Duration` | Seconds, default `5`. `0` keeps it until dismissed |
| `Color` | Overrides the type color |
| `Action` | `{Text, Callback}` adds a button, clicking it dismisses the notification |

`Notify` returns a handle with `Dismiss()`. At most 5 notifications show at once, the oldest is removed first. The progress bar pauses while the mouse is over a notification. `Hub:ClearNotifications()` removes them all.

## Dialogs

```lua
Hub:Dialog{
    Title = "Rename",
    Content = "pick a new name",
    Input = {Placeholder = "name", Default = ""},
    Buttons = {
        {Text = "Cancel", Primary = false},
        {
            Text = "Save",
            Primary = true,
            Callback = function(text)
                print(text)
            end,
        },
    },
}
```

- Button callbacks receive the input text (or `nil` when there's no input).
- Return `false` from a callback to keep the dialog open.
- The last button is primary unless you set `Primary` yourself.
- `Dialog` returns `{Close, SetContent}`.

## Hub methods

| Method | What it does |
| --- | --- |
| `Init()` | Builds Settings and opens the hub (or the key window) |
| `Show()`, `Hide()`, `Toggle()` | Visibility |
| `SetBackdrop(enabled, transparency)` | Dark fade behind the UI, transparency 0 to 1 |
| `SetBlur(enabled, size)` | Background blur |
| `SetScale(n)` | UI scale |
| `SetTheme(name)` | Switch to a preset |
| `SetAccent(color)` | Change the accent color live |
| `SetLogo(id)` | Change the logo everywhere |
| `SetWatermark(text)` | Small corner watermark with FPS. `true` uses the hub name, `nil` hides it |
| `SaveConfig(name)`, `LoadConfig(name)` | Save or load every element that has a `Flag` |
| `Destroy()` | Removes the UI and disconnects everything |

Configs are saved to `HumidityHub/configs/<name>.json`, so the executor needs file access.

## Key system

The library has a generic key window. You give it a validator and it handles the rest: loading state, shake on a wrong key, countdown pill in the sidebar, and a lock screen when the key expires.

```lua
Hub:SetKey(validator, onUnlock, onExpire)
Hub:SetKeyLink(link)
Hub:SetKeyPrompt(title, subtitle)
Hub:SetRememberKey(true)
```

### SetKey

`validator` can be:

- a string: one fixed key
- a list of strings: several accepted keys
- a function: receives the typed key, may yield (web requests are fine)

A function validator returns `true` or `false`, or a table:

```lua
return {
    valid = true,
    tier = "24h",
    seconds_left = 86343,
    reason = "expired",
    message = "custom text to show",
}
```

- `seconds_left` starts the countdown pill. When it reaches 0 the hub hides, the key window reopens as "Key expired" and `onExpire` fires.
- `reason` maps to a built-in message: `invalid_key`, `revoked`, `hwid_mismatch`, `expired`, `rate_limited`, `missing_input`, `error`. `message` overrides it.
- If the function throws, the window shows "could not reach the server".
- `onUnlock` receives `Hub:GetKeyInfo()`.

### Other key methods

| Method | What it does |
| --- | --- |
| `SetKeyLink(string)` | Get Key button copies that link to the clipboard |
| `SetKeyLink(function)` | Get Key button runs your function. A returned string shows as status text |
| `SetKeyPrompt(title, subtitle)` | Changes the key window text |
| `SetRememberKey(true)` | Saves the key to `HumidityHub/key.txt` and re-checks it on the next launch. A saved key that comes back invalid is deleted |
| `SetKeyText(text)` | Fills the key box |
| `SetKeyStatus(text, kind)` | Sets the status line, kind is `info`, `success`, `warning` or `error` |
| `GetKeyInfo()` | Returns `{Valid, Tier, SecondsLeft}` |

## Free key flow (Supabase + work.ink)

`Hub.lua` is a complete example of the full flow. The library never contains backend info, only your hub script does.

### How it works

1. The user presses **Get Key** and picks 24h or 48h.
2. The hub script calls the `hub-keys` edge function with `start`. The function creates a session and returns the first work.ink link.
3. The user finishes the link, work.ink sends them to `token.html?token=...`, which shows the token.
4. The user pastes the token into the hub. The script calls `complete`. The function verifies the token with work.ink using the secret API key, then records the checkpoint.
5. 48h needs a second checkpoint with a second link. After the last one, the function returns the key.
6. The key is saved to `HumidityHub/key.txt`, copied and filled in. The user presses **Unlock**.
7. Every launch calls `validate_key`, which checks the key against the device id and expiry.

### Rules enforced by the backend

- One active key per device
- Keys are locked to the device that earned them
- 24h = 1 checkpoint, 48h = 2 checkpoints
- A token works once
- A checkpoint submitted less than 10 seconds after the previous step is refused
- Sessions expire after 2 hours
- 10 failed key checks per 10 minutes per device, then a cooldown
- A key is only shown once, when it's issued. That's why the hub saves it immediately

### Backend setup

You need a Supabase project, a work.ink account and GitHub Pages for `token.html`.

1. **Database.** Run the schema in the Supabase SQL editor. It creates the tables `key_tiers`, `keys`, `key_sessions`, `checkpoint_log` and `validation_failures`, turns on row level security and revokes anon access. Only `validate_key` is callable by the anon role. Everything else is service role only.
2. **Edge function.** Deploy a function named `hub-keys` with the entry file named `index.ts`. Turn **Verify JWT off** for it.
3. **Secrets.** In the edge function secrets set:
   - `WORKINK_LINKS`: a JSON array of your work.ink links, in checkpoint order
   - `WORKINK_API_KEY`: your work.ink API key

   `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` are provided by Supabase automatically.
4. **work.ink links.** Create one link per checkpoint. For every link, the destination must be:

   ```
   https://<your-github-username>.github.io/<repo>/token.html?token={TOKEN}
   ```

   work.ink only appends a token when the destination contains `{TOKEN}`.
5. **Token page.** Enable GitHub Pages for the repo so `token.html` is served.
6. **Hub script.** Open `Hub.lua` and fill in `Config.SupabaseUrl` and `Config.AnonKey` (the publishable key, from Project Settings > API Keys).

### Keep these private

Never put either of these in a Lua file, the repo, an HTML page or a chat:

- the **work.ink API key**
- the Supabase **service_role** key

They only belong in the edge function secrets. The anon/publishable key is meant to be public and is safe in `Hub.lua`.

### Admin helpers

Run these in the SQL editor as the project owner:

```sql
select public.admin_grant_key('device-id-here', '24h', null);
select public.admin_revoke_key('HUM-XXXX-XXXX-XXXX-XXXX', 'reason');
select public.purge_expired();
```

## Troubleshooting

| Problem | Likely cause |
| --- | --- |
| Nothing shows up at all | The anon key is still the placeholder, or the library link doesn't load. Check the console for a red error |
| "could not reach the server" | Wrong project url or key. The hub prints the raw response to the console |
| No token on `token.html` | The work.ink destination is missing `?token={TOKEN}` |
| Edge function deploy says entrypoint not found | The entry file must be named `index.ts` |
| Every request from the executor gets a 401 | Verify JWT is still on for `hub-keys` |
| "work.ink says that token isn't valid" | Token expired (they last about 7 minutes), was already used, or came from a link that isn't yours |
| "wait N more seconds" | The token was submitted within 10 seconds of the previous step |
| "you already have an active key" | The device already earned one. It loads from `HumidityHub/key.txt` if it was saved, otherwise it works again after it expires |
| Config or key won't save | The executor has no `writefile` |
| Get Key link doesn't copy | The executor has no `setclipboard`, the link is put in the dialog box instead |

PowerShell testing on Windows:

```powershell
Invoke-RestMethod -Method Post -Uri "https://<project-ref>.supabase.co/functions/v1/hub-keys" -ContentType "application/json" -Body '{"action":"start","hwid":"test-hwid-12345","tier":"24h","roblox_user_id":1}'
```

## Executor support

The library uses these when they exist and falls back gracefully when they don't:

| Function | Used for |
| --- | --- |
| `gethui`, `syn.protect_gui` | Hiding the UI from the game |
| `request`, `http_request`, `syn.request` | Web requests in the hub script |
| `gethwid` | Device id, falls back to `RbxAnalyticsService:GetClientId()` |
| `writefile`, `readfile`, `isfile`, `isfolder`, `makefolder`, `delfile` | Configs and the saved key |
| `setclipboard` | Copying links and keys |
| `game:GetObjects` | Resolving the logo decal to its image |

## Credits

Made by Larpbase.
