-- Load the library via HttpGet
local Ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/i3wf/GlassUILibrary/main/source.lua"))()
-- Alternative: ModuleScript in ReplicatedStorage
-- local Ui = require(game.ReplicatedStorage.GlassUILibrary.source)

-- Track load time
local LoadTime = tick()

-- Create window: title, subtitle
-- Add { encrypted = true } as 3rd arg to hide GUI in gethui/CoreGui and randomize names
local win = Ui.New("Title Here", "Text Here")

-- Optional: change accent color (affects tab highlight + future elements)
-- Ui.SetTheme({ ACCENT = Color3.fromRGB(175, 82, 222) })

-- Create tab (shows top navigation when 2+ tabs exist)
local Tab1 = win:Tab("Tab1")

-- Create section inside tab (groups elements with a title)
local Section1 = Tab1:Section("Section1")

-- Toggle: name, default state, callback(value)
-- Returns handle with :Set(bool) and :Get() to control programmatically
Section1:Toggle("Toggle1", false, function(v)
	print("Value = " .. tostring(v))
end)

-- Keybind: name, default key, callback(newKey)
-- Captures next key press; Escape cancels
Section1:Keybind("KeybindToggle1", Enum.KeyCode.P, function(key)
	print("KeybindToggle1 = " .. key.Name)
end)

-- Another toggle example
Section1:Toggle("Toggle2", false, function(v)
	print("Toggle2 = " .. tostring(v))
end)

-- Slider: name, min, max, default, callback(value)
-- Rounded to whole numbers, fires while dragging
Section1:Slider("Slider1", 0, 20, 0, function(v)
	print("Value = " .. tostring(v))
end)

-- Dropdown: name, options, default, callback(selected)
-- List renders in overlay above all GUI
Section1:Dropdown("Dropdown1", { "1", "2", "3" }, "1", function(v)
	print("Value = " .. tostring(v))
end)

-- Button: name, callback
Section1:Button("Button1", function()
	print("Pressed!")
end)

-- TextBox: name, placeholder, callback(text, enterPressed)
-- Fires when focus is lost; enterPressed = true if user pressed Enter
Section1:Box("Box1", "Enter text...", function(text, enterPressed)
	print("Box1 =", text, "| enterPressed:", enterPressed)
end)

-- Settings tab example
local SettingsTab = win:Tab("Settings")
local WindowSec = SettingsTab:Section("Window")

-- Destroy: removes GUI and disconnects all input listeners
-- Also called automatically by the window X button
WindowSec:Button("Destroy UI", function()
	win:Destroy()
end)

-- Print load time and GUI name (randomized when encrypted = true)
LoadTime = math.floor((tick() - LoadTime) * 1000)
print("[GlassUI] Loaded in " .. LoadTime .. "ms | Gui name: " .. win.Gui.Name)
