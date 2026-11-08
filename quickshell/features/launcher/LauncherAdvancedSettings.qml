// features/launcher/LauncherAdvancedSettings.qml — Launcher > Advanced: result limits, icon theme and trigger marks.
// No Reset row: the Launcher page resets the whole menu.
import QtQuick
import QtQuick.Layouts
import "../settings/components"
import "."
import "../theme"
import "../../core/shell"
import "../../core/styles"

PageScroll {
    id: root

    SectionLabel { text: "Results" }

    GroupCard {
        SliderRow {
            label: "Maximum results"
            description: "Most results shown for a typed search. The list with nothing typed is not limited"
            from: 3; to: 15; stepSize: 1
            value: LauncherState.maxResults
            onMoved: (v) => LauncherState.maxResults = Math.round(v)
            showDivider: LauncherState.showRecentsFirst
        }

        Reveal {
            shown: LauncherState.showRecentsFirst

            SliderRow {
                label: "Recent apps to remember"
                from: 3; to: 20; stepSize: 1
                value: LauncherState.recentLimit
                onMoved: (v) => LauncherState.recentLimit = Math.round(v)
                showDivider: false
            }
        }
    }

    SectionLabel { text: "Icons" }

    GroupCard {
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
            showDivider: false
            onCommitted: (v) => ShellState.appIconTheme = v
        }
    }

    SectionLabel { text: "Trigger marks" }

    GroupCard {
        TextRow {
            label: "Emoji trigger"
            description: "One character. Type it first, then a word"
            value: LauncherState.triggerEmoji
            fieldWidth: 60
            maximumLength: 1
            onCommitted: (v) => LauncherState.setTrigger("emoji", v)
        }

        TextRow {
            label: "Snippets trigger"
            description: "One character. Type it first, then a snippet name"
            value: LauncherState.triggerSnippets
            fieldWidth: 60
            maximumLength: 1
            onCommitted: (v) => LauncherState.setTrigger("snippets", v)
        }

        TextRow {
            label: "Quick notes trigger"
            description: "One character. Type it first, then your note"
            value: LauncherState.triggerNotes
            fieldWidth: 60
            maximumLength: 1
            showDivider: false
            onCommitted: (v) => LauncherState.setTrigger("notes", v)
        }
    }
}