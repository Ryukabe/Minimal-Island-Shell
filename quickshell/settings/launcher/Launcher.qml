// settings/launcher/Launcher.qml
import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../../services"
import "../common"

Item {
    id: root

    SettingsScrollView {

        SettingsGroup {
            title: "Search"
            description: "How results are found and ranked"
            icon: "search"
            expanded: true

            SettingsSliderRow {
                label: "Maximum search results"
                from: 3
                to: 15
                stepSize: 1
                value: LauncherSettings.maxResults
                onMoved: (v) => LauncherSettings.maxResults = Math.round(v)
            }

            SettingsSegmentedRow {
                Layout.leftMargin: Dimens.paddingMedium
                Layout.rightMargin: Dimens.paddingMedium
                label: "Match mode"
                options: ["Fuzzy", "Prefix"]
                selectedValue: LauncherSettings.matchMode
                onOptionSelected: (v) => LauncherSettings.matchMode = v
            }

            SettingsToggleRow {
                label: "Search app descriptions"
                checked: LauncherSettings.searchDescriptions
                showDivider: false
                onToggled: (val) => LauncherSettings.searchDescriptions = val
            }
        }

        SettingsGroup {
            title: "Recent apps"
            description: "Rank recently launched apps first"
            icon: "history"
            expanded: true

            SettingsToggleRow {
                label: "Show recent apps first"
                checked: LauncherSettings.showRecentsFirst
                showDivider: LauncherSettings.showRecentsFirst
                onToggled: (val) => LauncherSettings.showRecentsFirst = val
            }

            SettingsSliderRow {
                visible: LauncherSettings.showRecentsFirst
                label: "Recent apps to remember"
                from: 3
                to: 20
                stepSize: 1
                value: LauncherSettings.recentLimit
                showDivider: false
                onMoved: (v) => LauncherSettings.recentLimit = Math.round(v)
            }

            SettingsButton {
                Layout.leftMargin: Dimens.paddingMedium
                Layout.topMargin: Dimens.spacingSmall
                text: "Clear recent history"
                onClicked: LauncherSettings.clearRecents()
            }
        }

        SettingsGroup {
            title: "Appearance"
            description: "Size, icons and animation"
            icon: "palette"
            expanded: true

            SettingsToggleRow {
                label: "Show app icons"
                checked: LauncherSettings.showIcons
                onToggled: (val) => LauncherSettings.showIcons = val
            }

            SettingsToggleRow {
                label: "Animate results"
                checked: LauncherSettings.animateResults
                onToggled: (val) => LauncherSettings.animateResults = val
            }

            SettingsToggleRow {
                label: "Shrink panel for few results"
                checked: LauncherSettings.shrinkForFewResults
                onToggled: (val) => LauncherSettings.shrinkForFewResults = val
            }

            SettingsSegmentedRow {
                Layout.leftMargin: Dimens.paddingMedium
                Layout.rightMargin: Dimens.paddingMedium
                label: "Launcher width"
                options: ["Compact", "Normal", "Wide"]
                selectedValue: LauncherSettings.launcherWidth
                onOptionSelected: (v) => LauncherSettings.launcherWidth = v
            }
        }

        SettingsGroup {
            title: "Extras"
            description: "Calculator and clipboard history"
            icon: "calculate"
            expanded: true

            SettingsToggleRow {
                label: "Inline calculator"
                checked: LauncherSettings.inlineCalculator
                onToggled: (val) => LauncherSettings.inlineCalculator = val
            }

            SettingsToggleRow {
                label: "Clipboard history (type : in the launcher)"
                checked: LauncherSettings.clipboardHistory
                showDivider: LauncherSettings.clipboardHistory
                onToggled: (val) => LauncherSettings.clipboardHistory = val
            }

            SettingsSliderRow {
                visible: LauncherSettings.clipboardHistory
                label: "Clipboard entries shown"
                from: 10
                to: 100
                stepSize: 10
                value: LauncherSettings.clipboardLimit
                showDivider: false
                onMoved: (v) => LauncherSettings.clipboardLimit = Math.round(v)
            }
        }
    }
}