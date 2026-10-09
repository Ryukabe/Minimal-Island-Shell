// pages/focusnotifications/AlertsSettings.qml — Focus & Notifications > Alerts.
// Placeholders until NotificationService reads these values.
import QtQuick
import QtQuick.Layouts
import "../../components"
import "../../../services"
import "../../../styles"

PageScroll {
    id: root

    SectionLabel { text: "Lifetime" }

    GroupCard {
        ToggleRow {
            label: "Expire automatically"
            description: "Dismiss notifications after their timeout"
            checked: true
            placeholder: true
        }

        SliderRow {
            label: "Timeout"
            description: "How long a notification stays before it is dismissed"
            from: 1000; to: 15000; stepSize: 500
            value: 5000
            unit: " ms"
            placeholder: true
            showDivider: false
        }
    }

    SectionLabel { text: "Layout" }

    GroupCard {
        ToggleRow {
            label: "Open expanded"
            description: "Show notifications fully open by default"
            placeholder: true
        }

        SliderRow {
            label: "Group preview count"
            description: "Notifications shown per app before the group collapses"
            from: 1; to: 8; stepSize: 1
            value: 3
            placeholder: true
            showDivider: false
        }
    }

    SectionLabel { text: "Fullscreen" }

    GroupCard {
        ToggleRow {
            label: "Show over fullscreen apps"
            checked: true
            placeholder: true
            showDivider: false
        }
    }
}