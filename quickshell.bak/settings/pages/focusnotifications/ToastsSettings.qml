// pages/focusnotifications/ToastsSettings.qml — Focus & Notifications > Toasts.
// Placeholders until the toast system reads these values.
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
            label: "Visible toasts"
            description: "Most that can be on screen at once"
            from: 1; to: 8; stepSize: 1
            value: 4
            placeholder: true
        }

        ToggleRow {
            label: "Show over fullscreen apps"
            placeholder: true
            showDivider: false
        }
    }

    SectionLabel { text: "Show a toast when" }

    GroupCard {
        ToggleRow { label: "Charging starts or stops"; checked: true; placeholder: true }
        ToggleRow { label: "Game mode changes"; checked: true; placeholder: true }
        ToggleRow { label: "Do not disturb changes"; checked: true; placeholder: true }
        ToggleRow { label: "Audio output changes"; checked: true; placeholder: true }
        ToggleRow { label: "Audio input changes"; checked: true; placeholder: true; showDivider: false }
    }
}