// pages/lockscreen/LockScreenPage.qml — Lock Screen. Every control binds to LockScreenSettings.
// The password placeholder text needs a text-input row, which does not exist yet.
import QtQuick
import QtQuick.Layouts
import "../../components"
import "../../../services"
import "../../../styles"

PageScroll {
    id: root

    SectionLabel { text: "Clock and identity" }

    GroupCard {
        ToggleRow {
            label: "24-hour clock"
            checked: LockScreenSettings.clockFormat24h
            onToggled: (val) => LockScreenSettings.clockFormat24h = val
        }

        ToggleRow {
            label: "Show date"
            checked: LockScreenSettings.showDate
            onToggled: (val) => LockScreenSettings.showDate = val
        }

        ToggleRow {
            label: "Show username"
            checked: LockScreenSettings.showUsername
            onToggled: (val) => LockScreenSettings.showUsername = val
            showDivider: false
        }
    }

    SectionLabel { text: "Password field" }

    GroupCard {
        ToggleRow {
            label: "Use accent colour for errors"
            description: "Wrong passwords flash the accent colour instead of red"
            checked: LockScreenSettings.errorUsesAccent
            onToggled: (val) => LockScreenSettings.errorUsesAccent = val
            showDivider: false
        }
    }

    SectionLabel { text: "Background" }

    GroupCard {
        ToggleRow {
            label: "Frosted glass blur"
            checked: LockScreenSettings.frostedBlurEnabled
            onToggled: (val) => LockScreenSettings.frostedBlurEnabled = val
        }

        SliderRow {
            label: "Blur strength"
            from: 0; to: 64; stepSize: 1
            value: LockScreenSettings.frostedBlurRadius
            enabled: LockScreenSettings.frostedBlurEnabled
            onMoved: (val) => LockScreenSettings.frostedBlurRadius = val
        }

        SliderRow {
            label: "Wallpaper dim"
            from: 0; to: 0.8; stepSize: 0.01
            value: LockScreenSettings.wallpaperDimOpacity
            onMoved: (val) => LockScreenSettings.wallpaperDimOpacity = val
            showDivider: false
        }
    }

    SectionLabel { text: "Corner actions" }

    GroupCard {
        ToggleRow {
            label: "Hyprland"
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
}