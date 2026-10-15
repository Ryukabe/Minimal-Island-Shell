// pages/launcher/ClipboardPage.qml — Launcher > Clipboard.
import QtQuick
import QtQuick.Layouts
import "../../components"
import "../../../services"
import "../../../styles"

PageScroll {
    id: root

    SectionLabel { text: "History" }

    GroupCard {
        ToggleRow {
            label: "Clipboard history"
            description: "Type : in the launcher to browse it"
            checked: LauncherSettings.clipboardHistory
            onToggled: (val) => LauncherSettings.clipboardHistory = val
            showDivider: LauncherSettings.clipboardHistory
        }

        Reveal {
            shown: LauncherSettings.clipboardHistory

            SliderRow {
                label: "Entries shown"
                from: 10; to: 100; stepSize: 10
                value: LauncherSettings.clipboardLimit
                onMoved: (v) => LauncherSettings.clipboardLimit = Math.round(v)
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