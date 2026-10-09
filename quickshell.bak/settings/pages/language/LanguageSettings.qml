// pages/language/LanguageSettings.qml — Language & Region.
// Real: system language readout and clock format (ShellState.clockUse24Hour, shared with the bar clock).
// Temperature units live on the page until a backend exists.
import QtQuick
import QtQuick.Layouts
import "../../components"
import "../../../services"
import "../../../styles"

PageScroll {
    id: root

    property string weatherUnit: "°C"
    property string systemTempUnit: "°C"

    SectionLabel { text: "Language" }

    GroupCard {
        InfoRow {
            label: "System language"
            value: Qt.locale().nativeLanguageName + " (" + Qt.locale().name + ")"
            showDivider: false
        }
    }

    SectionLabel { text: "Weather" }

    GroupCard {
        InfoRow {
            label: "Location"
            value: "Location picker coming soon"
            showDivider: false
        }
    }

    SectionLabel { text: "Units" }

    GroupCard {
        SegmentRow {
            label: "Weather temperature"
            options: ["°C", "°F"]
            selectedValue: root.weatherUnit
            onOptionSelected: (name) => root.weatherUnit = name
        }

        SegmentRow {
            label: "CPU and GPU temperature"
            options: ["°C", "°F"]
            selectedValue: root.systemTempUnit
            onOptionSelected: (name) => root.systemTempUnit = name
            showDivider: false
        }
    }

    SectionLabel { text: "Time" }

    GroupCard {
        SegmentRow {
            label: "Clock format"
            options: ["12-hour", "24-hour"]
            selectedValue: ShellState.clockUse24Hour ? "24-hour" : "12-hour"
            onOptionSelected: (name) => ShellState.clockUse24Hour = (name === "24-hour")
            showDivider: false
        }
    }
}