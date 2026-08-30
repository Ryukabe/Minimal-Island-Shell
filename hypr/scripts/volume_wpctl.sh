#!/bin/bash
iDIR="$HOME/.config/swaync/icons"
sDIR="$HOME/.config/hypr/scripts"

# ----------- Volume helpers -----------
get_volume_num() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%d", $2 * 100}'
}

is_muted() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q '\[MUTED\]'
}

get_volume_label() {
    if is_muted; then
        printf "Muted"
    else
        printf "%s%%" "$(get_volume_num)"
    fi
}

get_icon() {
    if is_muted; then
        echo "$iDIR/volume-mute.png"
    else
        v="$(get_volume_num)"
        if   (( v <= 30 )); then echo "$iDIR/volume-low.png"
        elif (( v <= 60 )); then echo "$iDIR/volume-mid.png"
        else                     echo "$iDIR/volume-high.png"
        fi
    fi
}

notify_user() {
    local val label
    if is_muted; then
        val=0
    else
        val="$(get_volume_num)"
    fi
    label="$(get_volume_label)"
    notify-send -e \
        -h int:value:"$val" \
        -h string:x-canonical-private-synchronous:osd \
        -u low \
        -i "$(get_icon)" \
        "Volume" "$label"
}

# ----------- Volume controls -----------
inc_volume() {
    if is_muted; then
        toggle_mute
    else
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ --limit 1.0
        notify_user
    fi
}

dec_volume() {
    if is_muted; then
        toggle_mute
    else
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        notify_user
    fi
}

toggle_mute() {
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    notify_user
}

# ----------- Microphone helpers -----------
get_mic_num() {
    wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | awk '{printf "%d", $2 * 100}'
}

is_mic_muted() {
    wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q '\[MUTED\]'
}

get_mic_label() {
    if is_mic_muted; then
        printf "Muted"
    else
        printf "%s%%" "$(get_mic_num)"
    fi
}

get_mic_icon() {
    if is_mic_muted; then
        echo "$iDIR/microphone-mute.png"
    else
        echo "$iDIR/microphone.png"
    fi
}

notify_mic_user() {
    local val label
    if is_mic_muted; then
        val=0
    else
        val="$(get_mic_num)"
    fi
    label="$(get_mic_label)"
    notify-send -e \
        -h int:value:"$val" \
        -h string:x-canonical-private-synchronous:mic_notif \
        -u low \
        -i "$(get_mic_icon)" \
        "Microphone" "$label"
}

# ----------- Microphone controls -----------
toggle_mic() {
    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
    notify_mic_user
}

inc_mic_volume() {
    if is_mic_muted; then
        toggle_mic
    else
        wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%+
        notify_mic_user
    fi
}

dec_mic_volume() {
    if is_mic_muted; then
        toggle_mic
    else
        wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%-
        notify_mic_user
    fi
}

# ----------- CLI -----------
case "$1" in
    --get)          get_volume_label ;;
    --inc)          inc_volume ;;
    --dec)          dec_volume ;;
    --toggle)       toggle_mute ;;
    --toggle-mic)   toggle_mic ;;
    --get-icon)     get_icon ;;
    --get-mic-icon) get_mic_icon ;;
    --mic-inc)      inc_mic_volume ;;
    --mic-dec)      dec_mic_volume ;;
    *)              get_volume_label ;;
esac