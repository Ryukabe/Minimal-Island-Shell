// pages/lockscreen/LockScreenPage.qml — Lock Screen. Real: everything bound to LockScreenSettings,
// plus the lock timer, which lives in hypridle.conf (LockTimerService).
// The lid row stays a greyed placeholder: it belongs to logind / a Hyprland bind, not to the shell.
import QtQuick
import QtQuick.Layouts
import "../../components"
import "../../../services"
import "../../../styles"

PageScroll {
    id: root

    SectionLabel { text: "Wallpaper" }

    GroupCard {
        ToggleRow {
            label: "Frosted glass"
            description: "Blur the wallpaper behind the lock screen"
            checked: LockScreenSettings.frostedBlurEnabled
            onToggled: (val) => LockScreenSettings.frostedBlurEnabled = val
            showDivider: LockScreenSettings.frostedBlurEnabled
        }

        Reveal {
            shown: LockScreenSettings.frostedBlurEnabled

            SliderRow {
                label: "Blur strength"
                from: 0; to: 64; stepSize: 1
                value: LockScreenSettings.frostedBlurRadius
                onMoved: (val) => LockScreenSettings.frostedBlurRadius = val
            }
        }

        SliderRow {
            label: "Dimming"
            description: "Darkens the wallpaper so the text stays readable"
            from: 0; to: 0.8; stepSize: 0.01
            value: LockScreenSettings.wallpaperDimOpacity
            onMoved: (val) => LockScreenSettings.wallpaperDimOpacity = val
        }

        ToggleRow {
            label: "Entrance animation"
            description: "Fade and slide the lock screen in. Off: it appears fully drawn"
            checked: LockScreenSettings.playEntranceAnimation
            onToggled: (val) => LockScreenSettings.playEntranceAnimation = val
            showDivider: false
        }
    }

    SectionLabel { text: "Clock and name" }

    GroupCard {
        ToggleRow {
            label: "24-hour clock"
            checked: LockScreenSettings.clockFormat24h
            onToggled: (val) => LockScreenSettings.clockFormat24h = val
        }

        ToggleRow {
            label: "Show the date"
            checked: LockScreenSettings.showDate
            onToggled: (val) => LockScreenSettings.showDate = val
        }

        ToggleRow {
            label: "Show your username"
            checked: LockScreenSettings.showUsername
            onToggled: (val) => LockScreenSettings.showUsername = val
            showDivider: false
        }
    }

    SectionLabel { text: "Notifications" }

    GroupCard {
        ToggleRow {
            label: "Show notifications on the lock screen"
            description: "A count and the latest few, under the clock. Respects Show previews"
            checked: LockScreenSettings.showNotifications
            onToggled: (val) => LockScreenSettings.showNotifications = val
            showDivider: LockScreenSettings.showNotifications
        }

        Reveal {
            shown: LockScreenSettings.showNotifications

            SliderRow {
                label: "Notifications shown"
                from: 1; to: 6; stepSize: 1
                value: LockScreenSettings.notificationLimit
                onMoved: (val) => LockScreenSettings.notificationLimit = val
                showDivider: false
            }
        }
    }

    SectionLabel { text: "Password box" }

    GroupCard {
        TextRow {
            label: "Hint text"
            description: "Shown inside the empty password box"
            value: LockScreenSettings.passwordPlaceholder
            fieldWidth: 220
            onCommitted: (v) => LockScreenSettings.passwordPlaceholder = v
        }

        ToggleRow {
            label: "Shake on wrong password"
            checked: LockScreenSettings.shakeOnWrongPassword
            onToggled: (val) => LockScreenSettings.shakeOnWrongPassword = val
        }

        ToggleRow {
            label: "Accent colour for wrong passwords"
            description: "Flash the accent colour instead of red"
            checked: LockScreenSettings.errorUsesAccent
            onToggled: (val) => LockScreenSettings.errorUsesAccent = val
            showDivider: false
        }
    }

    SectionLabel { text: "Buttons" }

    GroupCard {
        ToggleRow {
            label: "Hyprland"
            description: "Leave the lock screen and go back to Hyprland"
            checked: LockScreenSettings.showHyprlandAction
            onToggled: (val) => LockScreenSettings.showHyprlandAction = val
        }

        ToggleRow {
            label: "Reboot"
            checked: LockScreenSettings.showRebootAction
            onToggled: (val) => LockScreenSettings.showRebootAction = val
        }

        ToggleRow {
            label: "Power"
            checked: LockScreenSettings.showPowerAction
            onToggled: (val) => LockScreenSettings.showPowerAction = val
            showDivider: false
        }
    }

    SectionLabel { text: "Locking" }

    GroupCard {
        SliderRow {
            label: "Lock after idle"
            description: LockTimerService.available
                ? "Changes the lock timer in your hypridle.conf and restarts hypridle. Screen-off keeps its delay after locking"
                : LockTimerService.status
            from: 1; to: 25; stepSize: 1
            value: LockTimerService.lockMinutes
            unit: " min"
            enabled: LockTimerService.available
            onMoved: (val) => LockTimerService.setLockMinutes(val)
        }

        ToggleRow {
            label: "Lock when the lid closes"
            checked: true
            placeholder: true
            showDivider: false
        }
    }
}