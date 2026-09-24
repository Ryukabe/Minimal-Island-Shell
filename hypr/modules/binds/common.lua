local mainMod = require("modules.binds.mainmod")

--- System ---

-- System reload script
hl.bind(mainMod .. " + CTRL + ALT + RETURN", hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/system_reload.sh"))

-- Hyprland reload
hl.bind("SUPER + SHIFT + R",             hl.dsp.exec_cmd("hyprctl reload"))

-- Shell switching (toggle Quickshell / toggle AGS)
hl.bind("SUPER + CTRL + ALT + Q",            hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/switch-shell.sh qs"))
hl.bind(mainMod .. " + CTRL + ALT + A",      hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/switch-shell.sh ags"))

-- Reload AGS
hl.bind("SUPER + ALT + R",      hl.dsp.exec_cmd("$HOME/.config/ags/reload.sh"))

--- Window management ---

hl.bind(mainMod .. " + SHIFT + F",           hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + P",           hl.dsp.window.pseudo())

-- Change layout
hl.bind(mainMod .. " + ALT + K",             hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/changeLayout3.sh"))

-- Focus
hl.bind(mainMod .. " + left",                hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right",               hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",                  hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",                hl.dsp.focus({ direction = "down" }))

-- Workspaces
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Window switcher
hl.bind("ALT + Tab", function() hl.dispatch(hl.dsp.window.cycle_next()) hl.dispatch(hl.dsp.window.bring_to_top()) end)

-- Move/resize with mouse
hl.bind(mainMod .. " + mouse:272",           hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273",           hl.dsp.window.resize(), { mouse = true })

-- Kill & close
hl.bind("CTRL + ALT + DELETE",               hl.dsp.exec_cmd("hyprctl kill"))
hl.bind("ALT + F4",                          hl.dsp.window.close())

--- Media ---

hl.bind("XF86AudioNext",                     hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPlay",                     hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",                     hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

--- Apps ---

-- Terminal
hl.bind(mainMod .. " + RETURN",              hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + ALT + RETURN",        hl.dsp.exec_cmd("alacritty"))

-- File manager
hl.bind(mainMod .. " + F",                   hl.dsp.exec_cmd("nautilus"))
hl.bind(mainMod .. " + ALT + F",             hl.dsp.exec_cmd("thunar"))

-- Browser
hl.bind(mainMod .. " + B",                   hl.dsp.exec_cmd("zen-browser"))
hl.bind(mainMod .. " + ALT + B",             hl.dsp.exec_cmd("helium-browser"))

-- Editor
hl.bind(mainMod .. " + E",                   hl.dsp.exec_cmd("code"))

-- Notes
hl.bind(mainMod .. " + O",                   hl.dsp.exec_cmd("obsidian"))

-- Music
hl.bind(mainMod .. " + S",                   hl.dsp.exec_cmd("spotify"))

--- Look & power ---

hl.bind(mainMod .. " + F4",                  hl.dsp.exec_cmd("$HOME/.config/wlogout/scripts/wlogout.sh"))
hl.bind("SHIFT + ALT + L",                   hl.dsp.exec_cmd("hyprlock -c $HOME/.config/hypr/hyprlock/hyprlock.conf"))

-- Clear clipboard history
hl.bind(mainMod .. " + SHIFT + V",           hl.dsp.exec_cmd("cliphist wipe"))

-- Screenshots
hl.bind(mainMod .. " + Print",               hl.dsp.exec_cmd("hyprshot -m output -m eDP-1 -o $HOME/Pictures/Screenshot"))
hl.bind(mainMod .. " + SHIFT + Print",       hl.dsp.exec_cmd("hyprshot -m region -o $HOME/Pictures/Screenshot"))

-- Color picker
hl.bind(mainMod .. " + P",                   hl.dsp.exec_cmd("hyprpicker -a -f hex"))
