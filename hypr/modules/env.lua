-- Cursor
hl.env("XCURSOR_SIZE",                    "24")
hl.env("HYPRCURSOR_SIZE",                 "24")

-- Toolkit Backend
hl.env("GDK_BACKEND",                     "wayland,x11,*")
hl.env("QT_QPA_PLATFORM",                 "wayland")
hl.env("SDL_VIDEODRIVER",                 "wayland")
hl.env("CLUTTER_BACKEND",                 "wayland")

-- XDG Specification
hl.env("XDG_CURRENT_DESKTOP",             "Hyprland")
hl.env("XDG_SESSION_TYPE",                "wayland")
hl.env("XDG_SESSION_DESKTOP",             "Hyprland")

-- Qt & Rendering Options
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR",     "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_QPA_PLATFORMTHEME",            "qt5ct")
hl.env("QSG_RHI_BACKEND",                 "opengl")
--hl.env("QSG_RHI_BACKEND",                 "vulkan")