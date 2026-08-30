hl.config({
    input = {
        kb_layout    = "us",
        follow_mouse = 1,
        sensitivity  = 0,
        touchpad = {
            natural_scroll = false,
        },
    },
})

-- Gestures
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 3, direction = "down",       action = "close" })

-- Per-device config
--hl.device({
--    name        = "epic-mouse-v1",
--    sensitivity = -0.3,
--})