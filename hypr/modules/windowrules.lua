-- Suppress maximize for all windows
hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix XWayland drag issues
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- Polkit authentication agent
hl.window_rule({
    name   = "polkit-gnome",
    match  = { class = "^(polkit-gnome-authentication-agent-1|Polkit-gnome-authentication-agent-1)$" },
    float  = true,
    center = true,
})

-- hyprland-run popup
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move  = "20 monitor_h-120",
    float = true,
})

-- File picker
hl.window_rule({
    name   = "file-picker",
    match  = { title = "^(Open File|Open Folder|Open|Save|Save As|Export|Choose File|Rename|script%-fu)$" },
    float  = true,
    center = true,
    size   = "600 300",
})

-- xdg-desktop-portal-gtk
hl.window_rule({
    name   = "xdg-desktop-portal-gtk",
    match  = { class = "xdg-desktop-portal-gtk" },
    float  = true,
    center = true,
    size   = "800 500",
})

-- xdg-desktop-portal-hyprland
hl.window_rule({
    name   = "xdg-desktop-portal-hyprland",
    match  = { class = "xdg-desktop-portal-hyprland" },
    float  = true,
    center = true,
    size   = "900 600",
})

-- Float all modal/dialog windows
hl.window_rule({
    match  = { modal = true },
    float  = true,
    center = true,
    size   = "400 600",
})

hl.window_rule({
    match  = { title = "KDE Connect URL handler" },
    float  = true,
    center = true,
    size   = "400 200",
})

-- Font switcher
hl.window_rule({
    name   = "font-switcher",
    match  = { title = "font-switcher" },
    float  = true,
    center = true,
    size   = "200 300",
})

-- Browser
hl.window_rule({
    match     = { class = "^(zen|firefox|brave|helium-browser|chromium|chromium%-browser|chrome%-browser|microsoft%-edge)$" },
--    workspaces= 1,
--    silent    = true,
})
-- Picture-in-Picture
hl.window_rule({
    name             = "Picture-in-Picture",
    match            = { title = "^(Picture%-in%-Picture)$" },
    float            = true,
    pin              = true,
    no_initial_focus = true,
    size             = "540 300",
    move             = "850 450",
    opacity          = 1.0,
})

-- File managers
hl.window_rule({
    name        = "file-explorer",
    match       = { class = "^(org%.gnome%.Nautilus|thunar|dolphin)$" },
--    workspace   = 3,
    float       = true,
    center      = true,
    size        = "1100 600",
    border_size = 0,
})

-- Code editors
hl.window_rule({
    name        = "code-editors",
    match       = { class = "^(code|codium)$" },
--    workspace   = 2,
--    float       = true,
--    center      = true,
--    size        = "1200 650",
    border_size = 0,
})

-- Terminal emulators
hl.window_rule({
    name        = "terminal-emulators",
    match       = { class = "^(kitty|ghoty|arlacity)$" },
--    workspace   = 4,
--    float       = true,
--    center      = true,
--    size        = "1100 600",
})
