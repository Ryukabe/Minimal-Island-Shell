// pages/launcher/LauncherPage.qml — the Launcher menu. Its own options sit here;
// Search tools, Clipboard and Notes & snippets open from the list at the bottom.
import QtQuick
import QtQuick.Layouts
import "../../components"
import "../../../services"
import "../../../styles"

PageScroll {
    id: root

    SectionLabel { text: "Size" }

    GroupCard {
        SliderRow {
            label: "Width"
            description: "Multiplied by the preset below"
            from: 300; to: 800; stepSize: 10
            value: ShellState.launcherWidth
            unit: " px"
            onMoved: (val) => ShellState.launcherWidth = val
        }

        SegmentRow {
            label: "Width preset"
            options: ["Compact", "Normal", "Wide"]
            selectedValue: LauncherSettings.launcherWidth
            onOptionSelected: (name) => LauncherSettings.launcherWidth = name
        }

        SliderRow {
            label: "Visible rows"
            from: 3; to: 12; stepSize: 1
            value: ShellState.launcherMaxRows
            unit: " rows"
            onMoved: (val) => ShellState.launcherMaxRows = val
            showDivider: false
        }
    }

    SectionLabel { text: "Search" }

    GroupCard {
        SliderRow {
            label: "Maximum results"
            from: 3; to: 15; stepSize: 1
            value: LauncherSettings.maxResults
            onMoved: (v) => LauncherSettings.maxResults = Math.round(v)
        }

        SegmentRow {
            label: "Match mode"
            options: ["Fuzzy", "Prefix"]
            selectedValue: LauncherSettings.matchMode
            onOptionSelected: (name) => LauncherSettings.matchMode = name
        }

        ToggleRow {
            label: "Search app descriptions"
            checked: LauncherSettings.searchDescriptions
            onToggled: (val) => LauncherSettings.searchDescriptions = val
            showDivider: false
        }
    }

    SectionLabel { text: "Recent apps" }

    GroupCard {
        ToggleRow {
            label: "Show recent apps first"
            checked: LauncherSettings.showRecentsFirst
            onToggled: (val) => LauncherSettings.showRecentsFirst = val
        }

        Reveal {
            shown: LauncherSettings.showRecentsFirst

            SliderRow {
                label: "Recent apps to remember"
                from: 3; to: 20; stepSize: 1
                value: LauncherSettings.recentLimit
                onMoved: (v) => LauncherSettings.recentLimit = Math.round(v)
            }
        }

        ButtonRow {
            label: "Recent history"
            buttonText: "Clear"
            onClicked: LauncherSettings.clearRecents()
            showDivider: false
        }
    }

    SectionLabel { text: "Look" }

    GroupCard {
        ToggleRow {
            label: "Show app icons"
            checked: LauncherSettings.showIcons
            onToggled: (val) => LauncherSettings.showIcons = val
        }

        ToggleRow {
            label: "Animate results"
            checked: LauncherSettings.animateResults
            onToggled: (val) => LauncherSettings.animateResults = val
        }

        ToggleRow {
            label: "Shrink panel for few results"
            description: "A single match gets a compact panel"
            checked: LauncherSettings.shrinkForFewResults
            onToggled: (val) => LauncherSettings.shrinkForFewResults = val
            showDivider: false
        }
    }

    SectionLabel { text: "More launcher settings" }

    ViewList {}
}