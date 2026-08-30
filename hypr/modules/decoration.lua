hl.config({
    general = {
        gaps_in  = 4,
        gaps_out = 8,

        border_size = 0,

        col = {
            
            active_border   = "rgba(0a0a0add)",
            inactive_border = "rgba(0a0a0add)",
        },

        resize_on_border = true,
        allow_tearing    = false,
    },

    decoration = {
        rounding       = 10,
        rounding_power = 4,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 15,
            render_power = 2,
            color        = "rgba(0a0a0add)",
        },

        blur = {
            enabled             = true,
            size                = 5,
            passes              = 2,
            ignore_opacity      = true,
            vibrancy            = 0.5,
            --noise               = 0.08,
            --contrast            = 1,
            brightness          = 0.8,
            xray                = false,
            new_optimizations   = true,
            --dim_inactive      = false,
            --inactive_opacity  = 0.8, 
        },
    },
})