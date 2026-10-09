// pages/services/ServicesSettings.qml — Services.
// Refresh rates are greyed placeholders until the services read ShellState values.
import QtQuick
import QtQuick.Layouts
import "../../components"
import "../../../services"
import "../../../styles"

PageScroll {
    id: root

    SectionLabel { text: "Refresh rates" }

    GroupCard {
        SliderRow {
            label: "Media position"
            description: "How often the progress bar moves"
            from: 100; to: 2000; stepSize: 100
            value: 500
            unit: " ms"
            placeholder: true
        }

        SliderRow {
            label: "System stats"
            description: "CPU, memory and GPU readings"
            from: 1; to: 10; stepSize: 1
            value: 1
            unit: " s"
            placeholder: true
        }

        SliderRow {
            label: "Wi-Fi scan"
            description: "How often nearby networks are looked up"
            from: 5; to: 60; stepSize: 5
            value: 15
            unit: " s"
            placeholder: true
            showDivider: false
        }
    }
}