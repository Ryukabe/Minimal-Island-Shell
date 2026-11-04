// pages/launcher/LauncherSettings.qml — the Launcher menu. Its own options sit here;
// Search tools, Clipboard and Notes & snippets open from the list at the bottom.
import QtQuick
import QtQuick.Layouts
import "../settings/components"
import "."
import "../theme"
import "../../core/shell"
import "../../core/styles"

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
            selectedValue: LauncherState.launcherWidth
            onOptionSelected: (name) => LauncherState.launcherWidth = name
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
            value: LauncherState.maxResults
            onMoved: (v) => LauncherState.maxResults = Math.round(v)
        }

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

        Reveal {
            shown: LauncherState.showRecentsFirst

            SliderRow {
                label: "Recent apps to remember"
                from: 3; to: 20; stepSize: 1
                value: LauncherState.recentLimit
                onMoved: (v) => LauncherState.recentLimit = Math.round(v)
            }
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

        PickerRow {
            label: "Icon theme"
            description: "Icon set used for apps in the launcher"
            pickerTitle: "Icon Theme"
            searchHint: "Search icon themes..."
            hint: "System default"
            items: IconThemeService.pickerItems
            value: ShellState.appIconTheme
            strict: true
            enabled: LauncherState.showIcons
            onCommitted: (v) => ShellState.appIconTheme = v
        }

        ToggleRow {
            label: "Animate results"
            checked: LauncherState.animateResults
            onToggled: (val) => LauncherState.animateResults = val
        }

        ToggleRow {
            label: "Shrink panel for few results"
            description: "A single match gets a compact panel (list layout only)"
            checked: LauncherState.shrinkForFewResults
            onToggled: (val) => LauncherState.shrinkForFewResults = val
            showDivider: false
        }
    }

    SectionLabel { text: "More launcher settings" }

    ViewList {}
}