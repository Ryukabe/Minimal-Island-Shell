hl.config({ animations = { enabled = true } })

-- Animation curves
hl.bezier({ name = "hobbyist", points = { 0.8, 1.4, 0.0, 1.2 } })
hl.bezier({ name = "alien",    points = { 1.2, 0, 0.0, 1.4 } })
hl.bezier({ name = "cat",      points = { 0.38, 0.04, 1, 0.07 } })

-- Windows
hl.animation({ leaf = "windows",     enabled = true, speed = 3,   bezier = "hobbyist", style = "slide" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 3,   bezier = "hobbyist", style = "slide" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 3,   bezier = "hobbyist", style = "slide" })

-- Border
hl.animation({ leaf = "border", enabled = true, speed = 6, bezier = "default" })

-- Fade
hl.animation({ leaf = "fade",          enabled = true, speed = 2,   bezier = "hobbyist" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 2,   bezier = "hobbyist" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 3,   bezier = "cat" })

-- Layers
hl.animation({ leaf = "layers",    enabled = true, speed = 2,   bezier = "hobbyist", style = "slide" })
hl.animation({ leaf = "layersIn",  enabled = true, speed = 3,   bezier = "hobbyist", style = "slide" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.2, bezier = "cat" })

-- Workspaces
hl.animation({ leaf = "workspaces",       enabled = true, speed = 4, bezier = "alien",    style = "slidevert" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "hobbyist", style = "slidefadevert 20%" })