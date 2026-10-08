// pages/general/GeneralSettings.qml — General.
// Startup apps are real (AutostartService). The light/dark switch is a placeholder: I haven't seen how
// LightModeToggleTile flips the mode.
import QtQuick
import QtQuick.Layouts
import "../../components"
import "../../../services"
import "../../../styles"

PageScroll {
    id: root

    SectionLabel { text: "Startup apps" }

    GroupCard {
        TextRow {
            label: "Add an app"
            description: "Type the command, then press Enter"
            placeholderText: "e.g. spotify"
            fieldWidth: 240
            monospace: true
            clearOnCommit: true
            onCommitted: (v) => AutostartService.addApp(v)
        }

        InfoRow {
            visible: startupRepeater.count === 0
            label: "No startup apps yet"
            showDivider: false
        }

        Repeater {
            id: startupRepeater
            model: AutostartService.apps

            delegate: ButtonRow {
                required property var modelData
                required property int index

                label: modelData.command
                buttonText: "Remove"
                showDivider: index < startupRepeater.count - 1
                onClicked: AutostartService.removeApp(modelData.command)
            }
        }
    }

    SectionLabel { text: "Appearance mode" }

    GroupCard {
        ToggleRow {
            label: "Light mode"
            description: "Switch the whole shell between light and dark"
            placeholder: true
            showDivider: false
        }
    }
}