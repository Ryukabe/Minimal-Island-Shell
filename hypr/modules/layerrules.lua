-- ============================================================
-- Layer rules
--
-- One animator per window:
--   * AGS animates it (revealer inside)  -> no_anim here
--   * Hyprland animates it               -> no revealer inside the widget
-- ============================================================


-- ---------- AGS: animated by AGS, Hyprland stays out ----------

hl.layer_rule({
    match        = { namespace = "^ags-top-bar$" },
    blur         = true,
    ignore_alpha = 0.5,
    no_anim      = true,
})

hl.layer_rule({
    match   = { namespace = "^ags-island-panel$" },
    no_anim = true,
})

hl.layer_rule({
    match   = { namespace = "^ags-logo-menu$" },
    no_anim = true,
})

-- ---------- AGS: animated by Hyprland, from their own edge ----------

hl.layer_rule({
    match     = { namespace = "^dashboard$" },
    animation = "slide left",
})

hl.layer_rule({
    match     = { namespace = "^quicksettings$" },
    animation = "slide right",
})

hl.layer_rule({
    match     = { namespace = "notification-popups" },
    animation = "slide right",
})


-- ---------- AGS: centered dialogs ----------

hl.layer_rule({
    match     = { namespace = "^ags-polkit$" },
    animation = "popin 80%",
})

hl.layer_rule({
    match     = { namespace = "^powermenu$" },
    animation = "popin 80%",
})

hl.layer_rule({
    match   = { namespace = "^ags-battery-panel$" },
    no_anim = true,
})

hl.layer_rule({
    match     = { namespace = "^ags-settings$" },
    animation = "popin 80%",
})

-- ---------- Quickshell ----------

hl.layer_rule({
    match        = { namespace = "quickshell:island" },
    blur         = true,
    ignore_alpha = 0.5,
    animation    = "slide down",
})


-- ---------- Waybar ----------

hl.layer_rule({
    match        = { namespace = "waybar" },
    blur         = true,
    ignore_alpha = 0.5,
    no_anim      = true,
})


-- ---------- Swaync ----------

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


-- ---------- Wlogout ----------

hl.layer_rule({
    match     = { namespace = "logout_dialog" },
    animation = "fade",
    blur      = true,
})


-- ---------- Rofi ----------

hl.layer_rule({
    match     = { namespace = "rofi" },
    -- blur         = true,
    -- ignore_alpha = 0.5,
    animation = "popin 80%",
})