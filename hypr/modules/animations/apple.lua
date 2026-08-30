hl.config({ animations = { enabled = true } })

-- Curve definitions (The "Apple" feel)
hl.bezier({ name = "md3_decel",  points = { 0.05, 0.7, 0.1, 1 } })
hl.bezier({ name = "overshot",   points = { 0.05, 0.9, 0.1, 1.05 } })
hl.bezier({ name = "hyprcurve",  points = { 0.05, 0.9, 0.1, 1.1 } })

-- Window Animations
hl.animation({ leaf = "windows",     enabled = true, speed = 7, bezier = "overshot",   style = "popin 80%" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 7, bezier = "md3_decel",  style = "popin 80%" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 5, bezier = "md3_decel",  style = "popin 80%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 6, bezier = "md3_decel",  style = "slide" })

-- Layer/UI Animations (Waybar, Wofi)
hl.animation({ leaf = "layers", enabled = true, speed = 4,  bezier = "md3_decel", style = "slide right" })
hl.animation({ leaf = "fade",   enabled = true, speed = 10, bezier = "default" })

-- Workspace transitions (Smooth & snappy)
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "md3_decel", style = "slidefade 20%" })