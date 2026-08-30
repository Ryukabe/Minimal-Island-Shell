-- Waybar
hl.layer_rule({
    match        = { namespace = "quickshell:island" },
    blur         = true,
    ignore_alpha = 0.5,
    no_anim      = true,
})
-- Waybar
hl.layer_rule({
    match        = { namespace = "waybar" },
    blur         = true,
    ignore_alpha = 0.5,
    no_anim      = true,
})

-- Swaync
hl.layer_rule({
    match        = { namespace = "swaync-control-center" },
    blur         = true,
    ignore_alpha = 0.5,
})
hl.layer_rule({
    match        = { namespace = "swaync-notification-window" },
    blur         = true,
    ignore_alpha = 0.5,
})

-- Notification popups
hl.layer_rule({
    match     = { namespace = "notification-popups" },
    animation = "fade",
})

-- Wlogout
hl.layer_rule({
    match     = { namespace = "logout_dialog" },
    animation = "fade",
    blur      = true,
})

-- Rofi
hl.layer_rule({
    match        = { namespace = "rofi" },
--    blur         = true,
--    ignore_alpha = 0.5,
    animation    = "popin 80%",
})