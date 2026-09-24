local mainMod = require("modules.binds.mainmod")

-- Settings
hl.bind(mainMod .. " + COMMA",               hl.dsp.exec_cmd("qs ipc call settings toggle"))

-- Workspace switcher
hl.bind(mainMod .. " + TAB",                 hl.dsp.exec_cmd("qs ipc call workspaces toggle"))

-- App launcher
hl.bind(mainMod .. " + Space",               hl.dsp.exec_cmd("qs ipc call launcher toggle"), { locked = true })

-- Clipboard
hl.bind(mainMod .. " + V",                   hl.dsp.exec_cmd("qs ipc call clipboard toggle"))

-- Control center / quick settings
hl.bind(mainMod .. " + A",                   hl.dsp.exec_cmd("qs ipc call controlcenter toggle"))

-- Notification center
hl.bind(mainMod .. " + N",                   hl.dsp.exec_cmd("qs ipc call notificationcenter toggle"))

-- Power menu
hl.bind(mainMod .. " + Escape",              hl.dsp.exec_cmd("qs ipc call power toggle"))

-- Lock screen
hl.bind(mainMod .. " + L",                   hl.dsp.exec_cmd("quickshell ipc call lock lock"))

-- Theme switcher
hl.bind(mainMod .. " + T",                   hl.dsp.exec_cmd("qs ipc call themeswitcher toggle"))

-- Wallpaper switcher
hl.bind(mainMod .. " + W",                   hl.dsp.exec_cmd("qs ipc call wallpaper toggle"))

-- Brightness
hl.bind("XF86MonBrightnessUp",               hl.dsp.exec_cmd("qs ipc call brightness increase"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",             hl.dsp.exec_cmd("qs ipc call brightness decrease"), { locked = true, repeating = true })

-- Volume
hl.bind("XF86AudioRaiseVolume",              hl.dsp.exec_cmd("qs ipc call volume increase"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",              hl.dsp.exec_cmd("qs ipc call volume decrease"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",                     hl.dsp.exec_cmd("qs ipc call volume toggle"),   { locked = true, repeating = true })