hl.config({ animations = { enabled = false } })

-- Bezier curves
hl.bezier({ name = "smoothOut",      points = { 0.36, 0, 0.66, -0.56 } })
hl.bezier({ name = "smoothIn",       points = { 0.25, 1, 0.5, 1 } })
hl.bezier({ name = "overshot",       points = { 0.05, 0.9, 0.1, 1.05 } })
hl.bezier({ name = "softSnap",       points = { 0.4, 0.0, 0.2, 1 } })
hl.bezier({ name = "fluent",         points = { 0.0, 0.0, 0.2, 1.0 } })
hl.bezier({ name = "easeInOutExpo",  points = { 0.87, 0, 0.13, 1 } })

-- Windows
hl.animation({ leaf = "windows",     enabled = true, speed = 5, bezier = "overshot",  style = "popin 80%" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 5, bezier = "overshot",  style = "popin 80%" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 4, bezier = "smoothOut", style = "popin 95%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, bezier = "softSnap" })

-- Layers
hl.animation({ leaf = "layersIn",  enabled = true, speed = 7, bezier = "smoothIn",  style = "slide right" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 8, bezier = "softSnap",  style = "slide right" })

-- Fade
hl.animation({ leaf = "fade",        enabled = true, speed = 4, bezier = "smoothIn" })
hl.animation({ leaf = "fadeIn",      enabled = true, speed = 4, bezier = "smoothIn" })
hl.animation({ leaf = "fadeOut",     enabled = true, speed = 4, bezier = "smoothOut" })
hl.animation({ leaf = "fadeSwitch",  enabled = true, speed = 4, bezier = "smoothIn" })
hl.animation({ leaf = "fadeShadow",  enabled = true, speed = 4, bezier = "smoothIn" })
hl.animation({ leaf = "fadeDim",     enabled = true, speed = 4, bezier = "smoothIn" })
 hl.animation({ leaf = "fadeDpms", enabled = true, speed = 4, bezier = "smoothIn" })
hl.animation({ leaf = "fadeLayers",  enabled = true, speed = 3, bezier = "softSnap" })

-- Workspaces
hl.animation({ leaf = "workspaces",       enabled = true, speed = 5, bezier = "overshot", style = "slidefade 30%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 5, bezier = "overshot", style = "slidefadevert 30%" })