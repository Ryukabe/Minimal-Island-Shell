// pages/launcher/LauncherPage.qml — Launcher. Every control binds to LauncherSettings / LauncherData.
// Not here yet: the trigger text for Emoji / Snippets / Quick notes, and the notes / snippets path
// fields. Both need a text-input row.
import QtQuick
import QtQuick.Layouts
import "../../components"
import "../../../services"
import "../../../styles"

PageScroll {
    id: root

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

        SliderRow {
            visible: LauncherSettings.showRecentsFirst
            label: "Recent apps to remember"
            from: 3; to: 20; stepSize: 1
            value: LauncherSettings.recentLimit
            onMoved: (v) => LauncherSettings.recentLimit = Math.round(v)
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Dimens.paddingMedium
            Layout.rightMargin: Dimens.paddingMedium
            Layout.topMargin: Dimens.spacingSmall
            Layout.bottomMargin: Dimens.spacingSmall

            Text {
                Layout.fillWidth: true
                text: "Recent history"
                color: Colors.fg
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeBase
            }

            ActionButton {
                text: "Clear"
                onClicked: LauncherSettings.clearRecents()
            }
        }
    }

    SectionLabel { text: "Appearance" }

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
            checked: LauncherSettings.shrinkForFewResults
            onToggled: (val) => LauncherSettings.shrinkForFewResults = val
        }

        SegmentRow {
            label: "Launcher width"
            options: ["Compact", "Normal", "Wide"]
            selectedValue: LauncherSettings.launcherWidth
            onOptionSelected: (name) => LauncherSettings.launcherWidth = name
            showDivider: false
        }
    }

    SectionLabel { text: "Features" }

    GroupCard {
        ToggleRow {
            label: "Inline calculator"
            description: "2+2, sqrt(16)"
            checked: LauncherSettings.inlineCalculator
            onToggled: (val) => LauncherSettings.inlineCalculator = val
        }

        ToggleRow {
            label: "Unit conversion"
            description: "10 km to mi"
            checked: LauncherSettings.feature("units")
            onToggled: (val) => LauncherSettings.setFeature("units", val)
        }

        ToggleRow {
            label: "Web search"
            description: "g cats, yt lofi, ? cats"
            checked: LauncherSettings.feature("web")
            onToggled: (val) => LauncherSettings.setFeature("web", val)
        }

        ToggleRow {
            label: "Run commands"
            description: "> command"
            checked: LauncherSettings.feature("commands")
            onToggled: (val) => LauncherSettings.setFeature("commands", val)
        }

        ToggleRow {
            label: "File search"
            description: "/ name"
            checked: LauncherSettings.feature("files")
            onToggled: (val) => LauncherSettings.setFeature("files", val)
        }

        ToggleRow {
            label: "System commands"
            description: "lock, sleep, restart"
            checked: LauncherSettings.feature("system")
            onToggled: (val) => LauncherSettings.setFeature("system", val)
        }

        ToggleRow {
            label: "Emoji picker"
            checked: LauncherSettings.feature("emoji")
            onToggled: (val) => LauncherSettings.setFeature("emoji", val)
        }

        ToggleRow {
            label: "Snippets"
            checked: LauncherSettings.feature("snippets")
            onToggled: (val) => LauncherSettings.setFeature("snippets", val)
        }

        ToggleRow {
            label: "Quick notes"
            checked: LauncherSettings.feature("notes")
            onToggled: (val) => LauncherSettings.setFeature("notes", val)
            showDivider: false
        }
    }

    SectionLabel { text: "Clipboard" }

    GroupCard {
        ToggleRow {
            label: "Clipboard history"
            description: "Type : in the launcher"
            checked: LauncherSettings.clipboardHistory
            onToggled: (val) => LauncherSettings.clipboardHistory = val
        }

        SliderRow {
            visible: LauncherSettings.clipboardHistory
            label: "Entries shown"
            from: 10; to: 100; stepSize: 10
            value: LauncherSettings.clipboardLimit
            onMoved: (v) => LauncherSettings.clipboardLimit = Math.round(v)
            showDivider: false
        }
    }

    SectionLabel { text: "Notes" }

    GroupCard {
        SegmentRow {
            label: "Storage"
            options: ["One file", "Per day", "Per capture"]
            selectedValue: LauncherData.notesMode === "running" ? "One file"
                         : LauncherData.notesMode === "daily" ? "Per day" : "Per capture"
            onOptionSelected: (name) => LauncherData.setNotesMode(
                name === "One file" ? "running" : name === "Per day" ? "daily" : "capture")
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Dimens.paddingMedium
            Layout.rightMargin: Dimens.paddingMedium
            Layout.topMargin: Dimens.spacingSmall
            Layout.bottomMargin: Dimens.spacingSmall

            Text {
                Layout.fillWidth: true
                text: "Notes location"
                color: Colors.fg
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeBase
            }

            ActionButton {
                text: "Open"
                onClicked: LauncherData.openNotesFolder()
            }
        }
    }

    SectionLabel { text: "Snippets and aliases" }

    GroupCard {
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Dimens.paddingMedium
            Layout.rightMargin: Dimens.paddingMedium
            Layout.topMargin: Dimens.spacingSmall
            Layout.bottomMargin: Dimens.spacingSmall

            Text {
                Layout.fillWidth: true
                text: "Snippets folder"
                color: Colors.fg
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeBase
            }

            ActionButton {
                text: "Open"
                onClicked: LauncherData.openSnippetsFolder()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Dimens.paddingMedium
            Layout.rightMargin: Dimens.paddingMedium
            Layout.topMargin: Dimens.spacingSmall
            Layout.bottomMargin: Dimens.spacingSmall

            Text {
                Layout.fillWidth: true
                text: "Aliases, pinned apps and search engines"
                color: Colors.fg
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeBase
            }

            ActionButton {
                text: "Open launcher-data.json"
                onClicked: LauncherData.openFile()
            }
        }
    }
}