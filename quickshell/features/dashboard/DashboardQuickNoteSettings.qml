// Dashboard > Quick note.
import QtQuick
import "../settings/components"
import "."
import "../../core/shell"
import "../../core/styles"

PageScroll {
    id: root

    SectionLabel { text: "Editor" }

    GroupCard {
        ToggleRow {
            label: "Formatting toolbar"
            description: "Heading, bullet list, numbered list, bold and italic buttons while editing"
            checked: ShellState.dashboardNoteShowToolbar
            onToggled: ShellState.dashboardNoteShowToolbar = !ShellState.dashboardNoteShowToolbar
        }

        SliderRow {
            label: "Text size"
            from: 11
            to: 20
            stepSize: 1
            value: ShellState.dashboardNoteFontSize
            unit: "px"
            onMoved: (v) => ShellState.dashboardNoteFontSize = v
        }
    }

    SectionLabel { text: "Storage" }

    GroupCard {
        InfoRow {
            label: "Note file"
            value: QuickNoteService.path
        }

        ButtonRow {
            label: "Open note file"
            description: "Saved as Markdown, so any editor can open it"
            buttonText: "Open"
            showDivider: false
            onClicked: QuickNoteService.openFile()
        }
    }
}