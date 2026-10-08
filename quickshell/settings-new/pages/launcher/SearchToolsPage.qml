// pages/launcher/SearchToolsPage.qml — Launcher > Search tools.
// Each tool is a switch. The three quick pickers also get a trigger character that appears when they are on.
import QtQuick
import QtQuick.Layouts
import "../../components"
import "../../../services"
import "../../../styles"

PageScroll {
    id: root

    SectionLabel { text: "Built-in tools" }

    GroupCard {
        ToggleRow {
            label: "Calculator"
            description: "Type 2+2 or sqrt(16)"
            checked: LauncherSettings.inlineCalculator
            onToggled: (val) => LauncherSettings.inlineCalculator = val
        }

        ToggleRow {
            label: "Unit conversion"
            description: "Type 10 km to mi"
            checked: LauncherSettings.feature("units")
            onToggled: (val) => LauncherSettings.setFeature("units", val)
        }

        ToggleRow {
            label: "Web search"
            description: "Type g cats, yt lofi or ? cats"
            checked: LauncherSettings.feature("web")
            onToggled: (val) => LauncherSettings.setFeature("web", val)
        }

        ToggleRow {
            label: "Run commands"
            description: "Start with >"
            checked: LauncherSettings.feature("commands")
            onToggled: (val) => LauncherSettings.setFeature("commands", val)
        }

        ToggleRow {
            label: "File search"
            description: "Start with /"
            checked: LauncherSettings.feature("files")
            onToggled: (val) => LauncherSettings.setFeature("files", val)
        }

        ToggleRow {
            label: "System commands"
            description: "Lock, sleep, restart"
            checked: LauncherSettings.feature("system")
            onToggled: (val) => LauncherSettings.setFeature("system", val)
            showDivider: false
        }
    }

    SectionLabel { text: "Quick pickers" }

    GroupCard {
        ToggleRow {
            label: "Emoji picker"
            checked: LauncherSettings.feature("emoji")
            onToggled: (val) => LauncherSettings.setFeature("emoji", val)
        }

        Reveal {
            shown: LauncherSettings.feature("emoji")

            TextRow {
                label: "Emoji trigger"
                description: "Type this first, then a word"
                value: LauncherSettings.triggerEmoji
                fieldWidth: 80
                maximumLength: 3
                onCommitted: (v) => LauncherSettings.setTrigger("emoji", v)
            }
        }

        ToggleRow {
            label: "Snippets"
            checked: LauncherSettings.feature("snippets")
            onToggled: (val) => LauncherSettings.setFeature("snippets", val)
        }

        Reveal {
            shown: LauncherSettings.feature("snippets")

            TextRow {
                label: "Snippets trigger"
                description: "Type this first, then a snippet name"
                value: LauncherSettings.triggerSnippets
                fieldWidth: 80
                maximumLength: 3
                onCommitted: (v) => LauncherSettings.setTrigger("snippets", v)
            }
        }

        ToggleRow {
            label: "Quick notes"
            checked: LauncherSettings.feature("notes")
            onToggled: (val) => LauncherSettings.setFeature("notes", val)
            showDivider: LauncherSettings.feature("notes")
        }

        Reveal {
            shown: LauncherSettings.feature("notes")

            TextRow {
                label: "Quick notes trigger"
                description: "Type this first, then your note"
                value: LauncherSettings.triggerNotes
                fieldWidth: 80
                maximumLength: 3
                showDivider: false
                onCommitted: (v) => LauncherSettings.setTrigger("notes", v)
            }
        }
    }
}