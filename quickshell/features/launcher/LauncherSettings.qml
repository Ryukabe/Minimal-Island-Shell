// features/launcher/LauncherSettings.qml — the Launcher menu. Size, search, recent apps and look sit here;
// Search tools, Clipboard, Notes & snippets and Advanced open from the list near the bottom.
import QtQuick
import QtQuick.Layouts
import "../settings/components"
import "."
import "../../core/shell"
import "../../core/styles"

PageScroll {
    id: root

    // Every ShellState key in the Launcher menu, sub-pages included (used by the Reset row at the bottom).
    // The icon theme is left out: Appearance shares that key.
    readonly property var resetKeys: [
        "launcherWidth", "launcherMaxRows", "clipboardWidth", "clipboardMaxRows"
    ]

    SectionLabel { text: "Size" }

    GroupCard {
        SliderRow {
            label: "Width"
            description: "How wide the launcher is when it opens"
            from: 300; to: 1000; stepSize: 10
            value: ShellState.launcherWidth
            unit: " px"
            onMoved: (val) => ShellState.launcherWidth = val
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
        SegmentRow {
            label: "Match mode"
            options: ["Fuzzy", "Prefix"]
            selectedValue: LauncherState.matchMode
            onOptionSelected: (name) => LauncherState.matchMode = name
        }

        ToggleRow {
            label: "Search app descriptions"
            checked: LauncherState.searchDescriptions
            onToggled: (val) => LauncherState.searchDescriptions = val
            showDivider: false
        }
    }

    SectionLabel { text: "Recent apps" }

    GroupCard {
        ToggleRow {
            label: "Show recent apps first"
            checked: LauncherState.showRecentsFirst
            onToggled: (val) => LauncherState.showRecentsFirst = val
        }

        ButtonRow {
            label: "Recent history"
            buttonText: "Clear"
            onClicked: LauncherState.clearRecents()
            showDivider: false
        }
    }

    SectionLabel { text: "Look" }

    GroupCard {
        SegmentRow {
            label: "App layout"
            description: "Emoji picker is always a grid"
            options: ["List", "Grid"]
            selectedValue: LauncherState.viewMode
            onOptionSelected: (name) => LauncherState.viewMode = name
        }

        Reveal {
            shown: LauncherState.viewMode === "Grid"

            SliderRow {
                label: "Grid columns"
                from: 3; to: 6; stepSize: 1
                value: LauncherState.gridColumns
                unit: " columns"
                onMoved: (v) => LauncherState.gridColumns = Math.round(v)
            }
        }

        ToggleRow {
            label: "Show app icons"
            checked: LauncherState.showIcons
            onToggled: (val) => LauncherState.showIcons = val
        }

        ToggleRow {
            label: "Animate results"
            description: "Results fade in as you type"
            checked: LauncherState.animateResults
            onToggled: (val) => LauncherState.animateResults = val
        }

        ToggleRow {
            label: "Shrink panel for few results"
            description: "A single match gets a narrower panel (list layout only)"
            checked: LauncherState.shrinkForFewResults
            onToggled: (val) => LauncherState.shrinkForFewResults = val
            showDivider: false
        }
    }

    SectionLabel { text: "More launcher settings" }

    ViewList {}

    SectionLabel { text: "Reset" }

    GroupCard {
        ResetRow {
            menuName: "Launcher"
            keys: root.resetKeys
            onResetDone: {
                LauncherState.resetToDefaults()
                LauncherData.resetStorageDefaults()
            }
        }
    }
}