-- M3 Standard spatial
hl.curve("md3_spatial_fast",    { type = "spring", mass = 1, stiffness = 600, dampening = 49 })
hl.curve("md3_spatial_default", { type = "spring", mass = 1, stiffness = 300, dampening = 30 })
hl.curve("md3_spatial_slow",    { type = "spring", mass = 1, stiffness = 160, dampening = 25 })

-- Effects springs
hl.curve("md3_effects_fast",    { type = "spring", mass = 1, stiffness = 3800, dampening = 123 }) -- ratio 1.0
hl.curve("md3_effects_default", { type = "spring", mass = 1, stiffness = 1600, dampening = 80 })  -- ratio 1.0
hl.curve("md3_effects_slow",    { type = "spring", mass = 1, stiffness = 800,  dampening = 57 })  -- ratio 1.0

-- Beziers for layers
hl.curve("md3_standard",       { type = "bezier", points = { {0.2, 0.0}, {0.0, 1.0} } })
hl.curve("md3_emphasized_accel", { type = "bezier", points = { {0.3, 0.0}, {0.8, 0.15} } })

-- Animations
hl.animation({ leaf = "windows",     enabled = true, speed = 5, spring = "md3_spatial_default" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 5, spring = "md3_spatial_default", style = "popin 92%" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 2, spring = "md3_spatial_default", style = "popin 92%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, spring = "md3_spatial_default" })

hl.animation({ leaf = "layers",      enabled = true, speed = 3,   bezier = "md3_standard", style = "fade" })
hl.animation({ leaf = "layersIn",    enabled = true, speed = 3,   bezier = "md3_standard", style = "fade" })
hl.animation({ leaf = "layersOut",   enabled = true, speed = 2.5, bezier = "md3_emphasized_accel", style = "fade" })

hl.animation({ leaf = "fade",        enabled = true, speed = 2, spring = "md3_effects_default" })
hl.animation({ leaf = "fadeOut",     enabled = true, speed = 2, spring = "md3_spatial_default" })

hl.animation({ leaf = "workspaces",       enabled = true, speed = 5,   spring = "md3_spatial_default", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3.5, spring = "md3_spatial_default", style = "slidevert" })