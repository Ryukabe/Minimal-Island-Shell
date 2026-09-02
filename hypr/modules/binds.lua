local mainMod = "SUPER"
local subMod = "CTRL + ALT"

--- System ---

-- Window management
hl.bind(mainMod .. " + SHIFT + F",            hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + P",            hl.dsp.window.pseudo())

-- Focus
hl.bind(mainMod .. " + left",                 hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right",                hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",                   hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",                 hl.dsp.focus({ direction = "down" }))

-- 3-Way Layout Switcher
hl.bind(subMod .. " + K", hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/changeLayout3.sh"))

-- Workspaces
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,          hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key,  hl.dsp.window.move({ workspace = i }))
end

-- Scroll through workspaces
--hl.bind(mainMod .. " + mouse_down",    hl.dsp.focus({ workspace = "e+1" }))
--hl.bind(mainMod .. " + mouse_up",      hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize with mouse
hl.bind(mainMod .. " + mouse:272",     hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273",     hl.dsp.window.resize(), { mouse = true })

-- Laptop Brightness & Volume (With Fn keys)
--hl.bind("XF86MonBrightnessUp",    hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/brightness.sh --inc"), { locked = true, repeating = true })
--hl.bind("XF86MonBrightnessDown",  hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/brightness.sh --dec"), { locked = true, repeating = true })
--hl.bind("XF86AudioRaiseVolume",   hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/volume_wpctl.sh --inc"), { locked = true, repeating = true })
--hl.bind("XF86AudioLowerVolume",   hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/volume_wpctl.sh --dec"),      { locked = true, repeating = true })
--hl.bind("XF86AudioMute",          hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/volume_wpctl.sh --toggle"),     { locked = true, repeating = true })
--hl.bind("XF86AudioMicMute",       hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/volume_wpctl.sh --toggle"),   { locked = true, repeating = true })

-- External Keyboard Brightness & Volume Control (With Fn keys)
--hl.bind("F3",    hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/brightness.sh --inc"), { locked = true, repeating = true })
--hl.bind("F2",    hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/brightness.sh --dec"), { locked = true, repeating = true })
--hl.bind("F8",    hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/volume_wpctl.sh --inc"), { locked = true, repeating = true })
--hl.bind("F7",    hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/volume_wpctl.sh --dec"),      { locked = true, repeating = true })
--hl.bind("F6",    hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/volume_wpctl.sh --toggle"),     { locked = true, repeating = true })
--hl.bind("F4",    hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/volume_wpctl.sh --toggle"),   { locked = true, repeating = true })

-- Media
hl.bind("XF86AudioNext",                    hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause",                   hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",                    hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",                    hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Kill & Close Apps
hl.bind("CTRL + ALT + DELETE",              hl.dsp.exec_cmd("hyprctl kill"))
hl.bind("ALT + F4",                         hl.dsp.window.close())


--- QuickShell ---

-- Workspaces Switcer
hl.bind(mainMod .. " + TAB ",               hl.dsp.exec_cmd("qs ipc call workspaces toggle"))

-- App Launcher
hl.bind(mainMod .. " + Space ",             hl.dsp.exec_cmd("qs ipc call launcher toggle"), { locked = true })

-- Clipboard
hl.bind( mainMod .. " + V ",                hl.dsp.exec_cmd("qs ipc call clipboard toggle"))

-- Control Panel / Quick Settings
hl.bind( mainMod .. " + A ",                hl.dsp.exec_cmd("qs ipc call controlcenter toggle"))

-- Notification Center
hl.bind(mainMod .. " + N ",                 hl.dsp.exec_cmd("qs ipc call notificationcenter toggle"))

-- Power Menu
hl.bind(mainMod .. " + Escape ",            hl.dsp.exec_cmd("qs ipc call power toggle"))

-- Lock
hl.bind(mainMod .. " + L ",                 hl.dsp.exec_cmd("quickshell ipc call lock open"))

-- Theme Switcher
hl.bind(mainMod .. " + T ",                 hl.dsp.exec_cmd("qs ipc call themeswitcher toggle"))

-- Wallpaper Switcher
hl.bind(mainMod .. " + W ",                 hl.dsp.exec_cmd("qs ipc call wallpaper toggle"))

-- Brightness Control
hl.bind("XF86MonBrightnessUp",              hl.dsp.exec_cmd("qs ipc call brightness increase"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",            hl.dsp.exec_cmd("qs ipc call brightness decrease"), { locked = true, repeating = true })

-- Volume Control
hl.bind("XF86AudioRaiseVolume",             hl.dsp.exec_cmd("qs ipc call volume increase"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",             hl.dsp.exec_cmd("qs ipc call volume decrease"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",                    hl.dsp.exec_cmd("qs ipc call volume toggle"),   { locked = true, repeating = true })


--- Apps ---

--Terminal
hl.bind(mainMod .. " + RETURN",             hl.dsp.exec_cmd("kitty"))
--hl.bind(mainMod .. " + ALT + RETURN",     hl.dsp.exec_cmd("foot"))

--File Manager
hl.bind(mainMod .. " + F",                  hl.dsp.exec_cmd("nautilus"))
hl.bind(mainMod .. " + ALT + F",            hl.dsp.exec_cmd("thunar"))

--Browser
hl.bind(mainMod .. " + B",                  hl.dsp.exec_cmd("zen-browser"))
hl.bind(mainMod .. " + ALT + B",            hl.dsp.exec_cmd("helium-browser"))
--hl.bind(mainMod .. " + ALT + SHIFT + B",      hl.dsp.exec_cmd("brave"))

--Editor
hl.bind(mainMod .. " + E",                  hl.dsp.exec_cmd("code"))
--hl.bind(mainMod .. " + ALT + E",          hl.dsp.exec_cmd("coddium"))

--Note App
hl.bind(mainMod .. " + O",                  hl.dsp.exec_cmd("obsidian"))

--Music Streaming
hl.bind(mainMod .. " + S",                  hl.dsp.exec_cmd("spotify"))

-- Look & Powermenu
hl.bind(mainMod .. " + F4",                 hl.dsp.exec_cmd("$HOME/.config/wlogout/scripts/wlogout.sh")) --For powermenu
hl.bind(mainMod .. " + L",                  hl.dsp.exec_cmd("hyprlock -c $HOME/.config/hypr/hyprlock/hyprlock.conf")) --To lock

-- Clipboard 
--hl.bind(mainMod .. " + V",                  hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/clipboard-toggle.sh"))
hl.bind(mainMod .. " + SHIFT + V",          hl.dsp.exec_cmd("cliphist wipe")) -- to clear clipboard

-- Screenshots
hl.bind(mainMod .. " + Print",              hl.dsp.exec_cmd("hyprshot -m output -m eDP-1 -o $HOME/Pictures/Screenshot"))
hl.bind(mainMod .. " + SHIFT + Print",      hl.dsp.exec_cmd("hyprshot -m region -o $HOME/Pictures/Screenshot"))

-- Color Picker
hl.bind(mainMod .. " + P",                  hl.dsp.exec_cmd("hyprpicker -a -f hex"))
