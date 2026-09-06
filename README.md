# Glass UI Library

Simple dark liquid glass UI library for Roblox. Clean, responsive, and lightweight — one `CanvasGroup` window with top bar, sliding navigation, and overlay dropdowns.

## Features

- Window with draggable top bar, minimize / close, floating reopen button
- Tabs with auto-hiding top navigation (hidden with 1 tab, sliding with 2+)
- Sections with auto-sizing
- Elements: `Button`, `Toggle`, `Slider`, `Dropdown`, `Box` (TextBox), `Keybind`
- Theming via `UI.SetTheme`
- Encrypted mode (`{ encrypted = true }`) — randomizes instance names + hides in `gethui()`/`CoreGui`
- Responsive scaling + blur background
- Fully destroys on close (`win:Destroy()`)

## Installation

**Loadstring (executor / HttpGet):**
```lua
local Ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/i3wF/GlassUILibrary/refs/heads/main/source.lua"))()
```

**ModuleScript:**
1. Put `source.lua` in `ReplicatedStorage` as `GlassUILibrary`
2. ```lua
   local Ui = require(game.ReplicatedStorage.GlassUILibrary)
   ```

## Quick Start

```lua
local Ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/i3wF/GlassUILibrary/refs/heads/main/source.lua"))()

local win = Ui.New("Title Here", "Text Here")

local Tab1 = win:Tab("Tab1")
local Section1 = Tab1:Section("Section1")

Section1:Toggle("Toggle1", false, function(v)
    print("Value = " .. tostring(v))
end)

Section1:Slider("Slider1", 0, 20, 0, function(v)
    print(v)
end)

Section1:Dropdown("Dropdown1", {"1","2","3"}, "1", function(v)
    print(v)
end)

Section1:Button("Button1", function()
    print("Pressed!")
end)

Section1:Box("Box1", "Enter text...", function(text, enterPressed)
    print(text, enterPressed)
end)

Section1:Keybind("KeybindToggle1", Enum.KeyCode.P, function(key)
    print(key.Name)
end)
```

See [`example.lua`](example.lua) for full boilerplate.

## API

### `Ui.New(title, subtitle, opts)`
Create window. `opts.encrypted = true` enables stealth mode (sticky for all future windows).
Returns `win` with `win.Gui`, `win.Main`, `win:Destroy()`.

### `win:Tab(name)`
Create tab. Returns `tab`. First tab auto-selected.

### `tab:Section(title)`
Create section. Returns `S`.

### Elements (`S:`)

| Method | Args | Notes |
|---|---|---|
| `Button` | `name, callback` | |
| `Toggle` | `name, default(bool), callback(bool)` | Returns `{ Set(bool), Get() }` |
| `Slider` | `name, min, max, default, callback(number)` | Rounded to int, fires while dragging |
| `Dropdown` | `name, list, default, callback(value)` | Overlay renders above all GUI |
| `Box` | `name, placeholder, callback(text, enterPressed)` | Fires on `FocusLost` |
| `Keybind` | `name, default(Enum.KeyCode), callback(KeyCode)` | `...` capture, `Escape` cancels |

### `win:Destroy()`
Disconnects all inputs and destroys `ScreenGui`. Also called by X button.

### `Ui.SetTheme({ ACCENT = Color3 })`
Override palette. Call before creating elements for full effect. Keys: `ACCENT`, `ACCENT_HOVER`, `BG_MAIN`, `BG_TOPBAR`, `BG_CONTROL`, `BG_INPUT`, `BG_LIST`, `TEXT_*`, `TOGGLE_ON`, `STROKE`.

## Encrypted Mode

```lua
local win = Ui.New("Hub", "Stealth", { encrypted = true })
```
Randomizes every instance name and parents to `gethui()`/`CoreGui` (falls back to `PlayerGui`). Once enabled, all future windows are encrypted.

## License

MIT — do what you want, credit appreciated.
