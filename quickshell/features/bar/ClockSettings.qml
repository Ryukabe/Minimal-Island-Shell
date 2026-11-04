// features/bar/ClockSettings.qml — Bar > Clock. Time and date format only.
// Which items sit in the clock, and in what order, is edited on the Bar page (Layout).
import QtQuick
import "../settings/components"
import "."
import "../../core/shell"

PageScroll {
    id: root

    readonly property var dateLabels: ["Short", "Long"]
    readonly property var ampmLabels: ["AM", "am"]

    // ShellState keys this page owns (used by "Reset this page").
    readonly property var resetKeys: [
        "clockUse24Hour", "clockShowSeconds", "clockLeadingZero", "clockLowercaseAmPm", "clockDateStyle"
    ]

    SectionLabel { text: "Time" }

    GroupCard {
        ToggleRow {
            label: "24-hour clock"
            checked: ShellState.clockUse24Hour
            onToggled: (val) => ShellState.clockUse24Hour = val
        }

        ToggleRow {
            label: "Show seconds"
            checked: ShellState.clockShowSeconds
            onToggled: (val) => ShellState.clockShowSeconds = val
        }

        ToggleRow {
            label: "Leading zero on hour"
            checked: ShellState.clockLeadingZero
            onToggled: (val) => ShellState.clockLeadingZero = val
            showDivider: !ShellState.clockUse24Hour
        }

        SegmentRow {
            visible: !ShellState.clockUse24Hour
            label: "AM/PM style"
            options: root.ampmLabels
            selectedValue: ShellState.clockLowercaseAmPm ? "am" : "AM"
            onOptionSelected: (name) => ShellState.clockLowercaseAmPm = (name === "am")
            showDivider: false
        }
    }

    SectionLabel { text: "Date" }

    GroupCard {
        SegmentRow {
            label: "Date style"
            description: ClockLayoutService.indexForId("date") >= 0
                ? "How the date reads on the island"
                : "The date is not on the island. Add it from the Bar page"
            options: root.dateLabels
            selectedValue: ShellState.clockDateStyle === 2 ? "Long" : "Short"
            onOptionSelected: (name) => ShellState.clockDateStyle = (name === "Long" ? 2 : 1)
            showDivider: false
        }
    }

    SectionLabel { text: "Reset" }

    GroupCard {
        ResetRow { keys: root.resetKeys }
    }
}