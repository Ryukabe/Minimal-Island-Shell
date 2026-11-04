// pages/launcher/SearchToolsSettings.qml — Launcher > Search tools.
// Each tool is a switch. The three quick pickers also get a trigger character that appears when they are on.
import QtQuick
import QtQuick.Layouts
import "../settings/components"
import "."
import "../../core/styles"

PageScroll {
    id: root

    SectionLabel { text: "Built-in tools" }

    GroupCard {
        ToggleRow {
            label: "Calculator"
            description: "Type 2+2 or sqrt(16)"
            checked: LauncherState.inlineCalculator
            onToggled: (val) => LauncherState.inlineCalculator = val
        }

        ToggleRow {
            label: "Unit conversion"
            description: "Type 10 km to mi"
            checked: LauncherState.feature("units")
            onToggled: (val) => LauncherState.setFeature("units", val)
        }

        ToggleRow {
            label: "Web search"
            description: "Type g cats, yt lofi or ? cats"
            checked: LauncherState.feature("web")
            onToggled: (val) => LauncherState.setFeature("web", val)
        }

        ToggleRow {
            label: "Run commands"
            description: "Start with >"
            checked: LauncherState.feature("commands")
            onToggled: (val) => LauncherState.setFeature("commands", val)
        }

        ToggleRow {
            label: "File search"
            description: "Start with /"
            checked: LauncherState.feature("files")
            onToggled: (val) => LauncherState.setFeature("files", val)
        }

        ToggleRow {
            label: "System commands"
            description: "Lock, sleep, restart"
            checked: LauncherState.feature("system")
            onToggled: (val) => LauncherState.setFeature("system", val)
            showDivider: false
        }
    }

    SectionLabel { text: "Quick pickers" }

    GroupCard {
        ToggleRow {
            label: "Emoji picker"
            checked: LauncherState.feature("emoji")
            onToggled: (val) => LauncherState.setFeature("emoji", val)
        }

        Reveal {
            shown: LauncherState.feature("emoji")

            TextRow {
                label: "Emoji trigger"
                description: "Type this first, then a word"
                value: LauncherState.triggerEmoji
                fieldWidth: 80
                maximumLength: 3
                onCommitted: (v) => LauncherState.setTrigger("emoji", v)
            }
        }

        ToggleRow {
            label: "Snippets"
            checked: LauncherState.feature("snippets")
            onToggled: (val) => LauncherState.setFeature("snippets", val)
        }

        Reveal {
            shown: LauncherState.feature("snippets")

            TextRow {
                label: "Snippets trigger"
                description: "Type this first, then a snippet name"
                value: LauncherState.triggerSnippets
                fieldWidth: 80
                maximumLength: 3
                onCommitted: (v) => LauncherState.setTrigger("snippets", v)
            }
        }

        ToggleRow {
            label: "Quick notes"
            checked: LauncherState.feature("notes")
            onToggled: (val) => LauncherState.setFeature("notes", val)
            showDivider: LauncherState.feature("notes")
        }

        Reveal {
            shown: LauncherState.feature("notes")

            TextRow {
                label: "Quick notes trigger"
                description: "Type this first, then your note"
                value: LauncherState.triggerNotes
                fieldWidth: 80
                maximumLength: 3
                showDivider: false
                onCommitted: (v) => LauncherState.setTrigger("notes", v)
            }
        }
    }
}