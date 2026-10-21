// Dashboard > Calendar.
import QtQuick
import "../settings/components"
import "."
import "../../core/shell"
import "../../core/styles"

PageScroll {
    id: root

    SectionLabel { text: "Month view" }

    GroupCard {
        SegmentRow {
            label: "Week starts on"
            options: ["Sunday", "Monday", "Saturday"]
            selectedValue: ShellState.dashboardCalendarWeekStart
            onOptionSelected: (name) => ShellState.dashboardCalendarWeekStart = name
        }

        ToggleRow {
            label: "Days from other months"
            description: "Show the greyed days before and after this month"
            checked: ShellState.dashboardCalendarShowOutsideDays
            onToggled: ShellState.dashboardCalendarShowOutsideDays = !ShellState.dashboardCalendarShowOutsideDays
        }
    }
}