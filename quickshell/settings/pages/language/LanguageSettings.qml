// pages/language/LanguageSettings.qml — Language & Region.
// System language is a readout. Location is one picked place that feeds both weather and the
// time on every clock (LocationService). Clock format and both temperature units live on
// ShellState, so they persist and every module reads the same value.
import QtQuick
import QtQuick.Layouts
import "../../components"
import "../../../services"
import "../../../core/styles"
import "../../../core/state"

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

    SectionLabel { text: "Location" }

    GroupCard {
        PickerRow {
            label: "Location"
            description: "Every clock shows this place's time, and weather uses it"
            pickerTitle: "Location"
            searchHint: "Search for a city..."
            hint: "Search for a city"
            searchable: true
            value: ShellState.locationLabel
            searchHandler: (query, done) => LocationService.search(query, done)
            onCommitted: (v) => LocationService.choose(v)
        }

        ButtonRow {
            label: "Detect automatically"
            description: LocationService.detectStatus !== ""
                ? LocationService.detectStatus
                : "Guesses your city from your internet connection. A VPN can make it wrong"
            buttonText: LocationService.detecting ? "Detecting..." : "Detect"
            enabled: !LocationService.detecting
            onClicked: LocationService.detect()
        }

        Reveal {
            shown: LocationService.hasLocation

            ButtonRow {
                label: "Use system time and no weather location"
                buttonText: "Clear"
                onClicked: LocationService.clear()
            }
        }

        InfoRow {
            label: "Time zone"
            value: ShellState.locationTimezone === ""
                ? "System default"
                : ShellState.locationTimezone
                  + (LocationService.offsetLabel !== "" ? " (" + LocationService.offsetLabel + ")" : "")
            showDivider: false
        }
    }

    SectionLabel { text: "Units" }

    GroupCard {
        SegmentRow {
            label: "Weather temperature"
            description: "Temperature for weather forecasts"
            options: ["°C", "°F"]
            selectedValue: ShellState.weatherUnit
            onOptionSelected: (name) => ShellState.weatherUnit = name
        }

        SegmentRow {
            label: "CPU and GPU temperature"
            description: "Temperature for system monitoring"
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