// features/bar/ClockSettings.qml — Bar > Clock. Time and date format, and how the time changes.
// Which items sit in the clock, and in what order, is edited on the Bar page (Layout).
import QtQuick
import "../settings/components"
import "."
import "../../core/shell"

PageScroll {
    id: root

    readonly property var dateLabels: ["Short", "Long"]
    readonly property var ampmLabels: ["AM", "am"]

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

    SectionLabel { text: "Animation" }

    GroupCard {
        SegmentRow {
            label: "Time change"
            description: ShellState.clockAnimation === "Flip"
                ? "Digits flip like the cards of a flip clock"
                : "The time changes without animation"
            options: ["None", "Flip"]
            selectedValue: ShellState.clockAnimation
            onOptionSelected: (name) => ShellState.clockAnimation = name
            showDivider: ShellState.clockAnimation === "Flip"
        }

        Reveal {
            shown: ShellState.clockAnimation === "Flip"

            SliderRow {
                label: "Flip speed"
                description: "How long one flip takes"
                from: 150; to: 800; stepSize: 10
                value: ShellState.clockFlipMs
                unit: " ms"
                enabled: !ShellState.motionReduced
                onMoved: (val) => ShellState.clockFlipMs = val
            }

            ToggleRow {
                label: "Card look"
                description: "Draw each digit on a small card with a centre line"
                checked: ShellState.clockFlipCards
                onToggled: (val) => ShellState.clockFlipCards = val
                showDivider: false
            }
        }
    }
}