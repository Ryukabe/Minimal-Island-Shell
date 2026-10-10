hl.config({
    input = {
        kb_layout     = "us",
        follow_mouse  = 1,
        sensitivity   = -0.1499999999999999,
        scroll_factor = 2.5000000000000004,
        touchpad = {
            natural_scroll = false,
            scroll_factor  = 2.5,
        },
    },
})

-- Gestures
hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

hl.gesture({
    fingers = 3,
    direction = "down",
    action = "close",
})

-- Per-device config
hl.device({
    name        = "synps/2-synaptics-touchpad",
    sensitivity = 0,
})




