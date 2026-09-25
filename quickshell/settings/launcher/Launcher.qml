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
            title: "Features"
            description: "Turn launcher powers on or off"
            icon: "bolt"
            expanded: true

            SettingsToggleRow {
                label: "Inline calculator  (2+2, sqrt(16))"
                checked: LauncherSettings.inlineCalculator
                onToggled: (val) => LauncherSettings.inlineCalculator = val
            }

            SettingsToggleRow {
                label: "Unit conversion  (10 km to mi)"
                checked: LauncherSettings.feature("units")
                onToggled: (val) => LauncherSettings.setFeature("units", val)
            }

            SettingsToggleRow {
                label: "Web search  (g cats, yt lofi, ? cats)"
                checked: LauncherSettings.feature("web")
                onToggled: (val) => LauncherSettings.setFeature("web", val)
            }

            SettingsToggleRow {
                label: "Run commands  (> command)"
                checked: LauncherSettings.feature("commands")
                onToggled: (val) => LauncherSettings.setFeature("commands", val)
            }

            SettingsToggleRow {
                label: "File search  (/ name)"
                checked: LauncherSettings.feature("files")
                onToggled: (val) => LauncherSettings.setFeature("files", val)
            }

            SettingsToggleRow {
                label: "System commands  (lock, sleep, restart)"
                checked: LauncherSettings.feature("system")
                onToggled: (val) => LauncherSettings.setFeature("system", val)
            }

            SettingsTriggerToggleRow {
                label: "Emoji picker"
                hint: "smile"
                checked: LauncherSettings.feature("emoji")
                trigger: LauncherSettings.triggerEmoji
                onToggled: (val) => LauncherSettings.setFeature("emoji", val)
                onTriggerCommitted: (val) => LauncherSettings.setTrigger("emoji", val)
            }

            SettingsTriggerToggleRow {
                label: "Snippets"
                hint: "email"
                checked: LauncherSettings.feature("snippets")
                trigger: LauncherSettings.triggerSnippets
                onToggled: (val) => LauncherSettings.setFeature("snippets", val)
                onTriggerCommitted: (val) => LauncherSettings.setTrigger("snippets", val)
            }

            SettingsTriggerToggleRow {
                label: "Quick notes"
                hint: "buy milk"
                checked: LauncherSettings.feature("notes")
                trigger: LauncherSettings.triggerNotes
                showDivider: false
                onToggled: (val) => LauncherSettings.setFeature("notes", val)
                onTriggerCommitted: (val) => LauncherSettings.setTrigger("notes", val)
            }
        }

        SettingsGroup {
            title: "Clipboard"
            description: "History from cliphist"
            icon: "content_paste"
            expanded: true

            SettingsToggleRow {
                label: "Clipboard history  (type : in the launcher)"
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

        SettingsGroup {
            title: "Notes"
            description: "Where quick notes are saved"
            icon: "edit_note"
            expanded: true

            SettingsSegmentedRow {
                Layout.leftMargin: Dimens.paddingMedium
                Layout.rightMargin: Dimens.paddingMedium
                label: "Storage"
                options: ["One file", "Per day", "Per capture"]
                selectedValue: LauncherData.notesMode === "running" ? "One file"
                             : LauncherData.notesMode === "daily" ? "Per day" : "Per capture"
                onOptionSelected: (v) => {
                    LauncherData.setNotesMode(v === "One file" ? "running" : v === "Per day" ? "daily" : "capture")
                }
            }

            SettingsPathRow {
                visible: LauncherData.notesMode === "running"
                Layout.topMargin: Dimens.spacingSmall
                label: "Notes file"
                value: LauncherData.notesFile
                showDivider: false
                onCommitted: (v) => LauncherData.setNotesFile(v)
                onOpenRequested: LauncherData.openNotesFolder()
            }

            SettingsPathRow {
                visible: LauncherData.notesMode !== "running"
                Layout.topMargin: Dimens.spacingSmall
                label: "Notes folder"
                value: LauncherData.notesFolder
                showDivider: false
                onCommitted: (v) => LauncherData.setNotesFolder(v)
                onOpenRequested: LauncherData.openNotesFolder()
            }
        }

        SettingsGroup {
            title: "Snippets"
            description: "Folder of snippet files, one subfolder per category"
            icon: "text_snippet"
            expanded: true

            SettingsPathRow {
                label: "Snippets folder"
                value: LauncherData.snippetsFolder
                showDivider: false
                onCommitted: (v) => LauncherData.setSnippetsFolder(v)
                onOpenRequested: LauncherData.openSnippetsFolder()
            }
        }

        SettingsGroup {
            title: "Aliases, pinned apps & search engines"
            description: "Hand-edited JSON"
            icon: "data_object"
            expanded: true

            SettingsButton {
                Layout.leftMargin: Dimens.paddingMedium
                text: "Open launcher-data.json"
                onClicked: LauncherData.openFile()
            }
        }
    }
}