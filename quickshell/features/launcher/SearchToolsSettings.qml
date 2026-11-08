// features/launcher/SearchToolsSettings.qml — Launcher > Search tools.
// Each tool is a switch. The trigger marks for the quick pickers are in Launcher > Advanced.
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
            description: "Starts with the emoji trigger mark"
            checked: LauncherState.feature("emoji")
            onToggled: (val) => LauncherState.setFeature("emoji", val)
        }

        ToggleRow {
            label: "Snippets"
            description: "Starts with the snippets trigger mark"
            checked: LauncherState.feature("snippets")
            onToggled: (val) => LauncherState.setFeature("snippets", val)
        }

        ToggleRow {
            label: "Quick notes"
            description: "Starts with the quick notes trigger mark"
            checked: LauncherState.feature("notes")
            onToggled: (val) => LauncherState.setFeature("notes", val)
            showDivider: false
        }
    }
}