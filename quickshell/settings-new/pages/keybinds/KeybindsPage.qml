// pages/keybinds/KeybindsPage.qml — the Keybinds menu. Main modifier, a form to add a shortcut,
// and a conflict count sit here; each category of shortcuts opens from the list at the bottom.
import QtQuick
import QtQuick.Layouts
import "../../components"
import "../../../services"
import "../../../styles"

PageScroll {
    id: root

    property bool addOpen: false
    property string newCombo: ""
    property string newCommand: ""

    readonly property var modifierOptions: ["SUPER", "CTRL", "ALT"]
    readonly property int conflictCount: {
        const counts = HyprlandKeybindsService.conflictCounts || {}
        return Object.keys(counts).filter(k => counts[k] > 1).length
    }

    // Closing always disarms capture and wipes the staged combo and command.
    function closeAdd() {
        root.addOpen = false
        newBindCapture.deactivateAndClear()
        root.newCombo = ""
        root.newCommand = ""
    }

    SectionLabel { text: "Main key" }

    GroupCard {
        SegmentRow {
            label: "Main modifier"
            options: root.modifierOptions
            selectedValue: HyprlandKeybindsService.mainMod
            onOptionSelected: (name) => HyprlandKeybindsService.setMainMod(name)
            showDivider: false
        }
    }

    SectionLabel { text: "New shortcut" }

    GroupCard {
        ButtonRow {
            label: "Add a shortcut"
            description: "Run any command from a key combination"
            buttonText: root.addOpen ? "Close" : "New"
            primary: !root.addOpen
            showDivider: root.addOpen
            onClicked: root.addOpen ? root.closeAdd() : root.addOpen = true
        }

        Reveal {
            shown: root.addOpen

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 54
                Layout.leftMargin: Dimens.paddingMedium
                Layout.rightMargin: Dimens.paddingMedium
                spacing: Dimens.spacingMedium

                Text {
                    Layout.fillWidth: true
                    text: "Shortcut"
                    color: Colors.fg
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeBase
                }

                KeyCaptureField {
                    id: newBindCapture
                    Layout.preferredWidth: 220
                    onComboChanged: (combo) => root.newCombo = combo
                    onCancelled: newBindCapture.deactivateAndClear()
                }
            }

            TextRow {
                label: "Command"
                placeholderText: "e.g. spotify"
                value: root.newCommand
                fieldWidth: 280
                monospace: true
                onEdited: (t) => root.newCommand = t
                onCommitted: (v) => root.newCommand = v
            }

            ButtonRow {
                label: root.newCombo.length > 0 ? root.newCombo : "No shortcut set yet"
                description: "Click the shortcut field above and press the keys"
                buttonText: "Add"
                primary: true
                enabled: root.newCombo.trim().length > 0 && root.newCommand.trim().length > 0
                showDivider: false
                onClicked: {
                    HyprlandKeybindsService.addExecBind(root.newCombo.trim(), root.newCommand.trim())
                    root.closeAdd()
                }
            }
        }
    }

    SectionLabel { text: "Health" }

    GroupCard {
        InfoRow {
            label: "Shortcut conflicts"
            value: root.conflictCount === 0 ? "None" : root.conflictCount + " found"
            showDivider: false
        }
    }

    SectionLabel { text: "Shortcuts" }

    ViewList {}
}