// pages/launcher/ClipboardSettings.qml — Launcher > Clipboard.
import QtQuick
import QtQuick.Layouts
import "../settings/components"
import "../launcher"
import "../../core/shell"
import "../../core/styles"

PageScroll {
    id: root

    SectionLabel { text: "History" }

    GroupCard {
        ToggleRow {
            label: "Clipboard history"
            description: "Type : in the launcher to browse it"
            checked: LauncherState.clipboardHistory
            onToggled: (val) => LauncherState.clipboardHistory = val
            showDivider: LauncherState.clipboardHistory
        }

        Reveal {
            shown: LauncherState.clipboardHistory

            SliderRow {
                label: "Entries shown"
                from: 10; to: 100; stepSize: 10
                value: LauncherState.clipboardLimit
                onMoved: (v) => LauncherState.clipboardLimit = Math.round(v)
                showDivider: false
            }
        }
    }

    SectionLabel { text: "Panel size" }

    GroupCard {
        SliderRow {
            label: "Width"
            from: 300; to: 800; stepSize: 10
            value: ShellState.clipboardWidth
            unit: " px"
            onMoved: (val) => ShellState.clipboardWidth = val
        }

        SliderRow {
            label: "Visible rows"
            from: 3; to: 12; stepSize: 1
            value: ShellState.clipboardMaxRows
            unit: " rows"
            onMoved: (val) => ShellState.clipboardMaxRows = val
            showDivider: false
        }
    }
}