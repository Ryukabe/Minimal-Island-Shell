// pages/language/LanguageSettings.qml — Language & Region.
// System language is a readout. Clock format and both temperature units live on ShellState,
// so they persist and every module reads the same value.
import QtQuick
import QtQuick.Layouts
import "../../components"
import "../../../services"
import "../../../styles"

PageScroll {
    id: root

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
            selectedValue: ShellState.weatherUnit
            onOptionSelected: (name) => ShellState.weatherUnit = name
        }

        SegmentRow {
            label: "CPU and GPU temperature"
            options: ["°C", "°F"]
            selectedValue: ShellState.systemTempUnit
            onOptionSelected: (name) => ShellState.systemTempUnit = name
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