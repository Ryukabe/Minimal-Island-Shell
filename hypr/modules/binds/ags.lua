
-- Brightness Control (Triggers AGS OSD)
hl.bind("XF86MonBrightnessUp",              hl.dsp.exec_cmd("brightnessctl s +5%"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",            hl.dsp.exec_cmd("brightnessctl s 5%-"), { locked = true, repeating = true })

-- Volume Control (Triggers AGS OSD)
hl.bind("XF86AudioRaiseVolume",             hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",             hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),        { locked = true, repeating = true })
hl.bind("XF86AudioMute",                    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),      { locked = true, repeating = true })