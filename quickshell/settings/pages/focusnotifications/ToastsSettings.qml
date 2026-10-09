// pages/focusnotifications/ToastsSettings.qml — Focus & Notifications > Toasts.
// Everything here is bound to ShellState and read by the island / EventToastService.
import QtQuick
import QtQuick.Layouts
import "../../components"
import "../../../services"
import "../../../styles"

PageScroll {
    id: root

    SectionLabel { text: "Pop-ups" }

    GroupCard {
        SliderRow {
            label: "Maximum text width"
            description: "Longer notification titles are cut off with an ellipsis"
            from: 160; to: 480; stepSize: 10
            value: ShellState.notificationToastMaxWidth
            unit: " px"
            onMoved: (val) => ShellState.notificationToastMaxWidth = val
        }

        SliderRow {
            label: "Event toast duration"
            description: "How long the short system toasts below stay up"
            from: 1000; to: 6000; stepSize: 250
            value: ShellState.eventToastMs
            unit: " ms"
            onMoved: (val) => ShellState.eventToastMs = val
        }

        ToggleRow {
            label: "Show over fullscreen apps"
            description: "Lifts the island above fullscreen windows while a toast is showing"
            checked: ShellState.notificationOverFullscreen
            onToggled: (val) => ShellState.notificationOverFullscreen = val
            showDivider: false
        }
    }

    SectionLabel { text: "Show a toast when" }

    GroupCard {
        ToggleRow {
            label: "Charging starts or stops"
            checked: ShellState.eventToastCharging
            onToggled: (val) => ShellState.eventToastCharging = val
        }

        ToggleRow {
            label: "Do not disturb changes"
            checked: ShellState.eventToastDnd
            onToggled: (val) => ShellState.eventToastDnd = val
        }

        ToggleRow {
            label: "Audio output changes"
            checked: ShellState.eventToastAudioOutput
            onToggled: (val) => ShellState.eventToastAudioOutput = val
        }

        ToggleRow {
            label: "Audio input changes"
            checked: ShellState.eventToastAudioInput
            onToggled: (val) => ShellState.eventToastAudioInput = val
            showDivider: false
        }
    }
}