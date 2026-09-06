// settings/keybinds/Keybinds.qml
import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../../services"
import "../common"

Item {
    id: root
    property bool addingNew: false
    property string newKeyText: ""
    property string newCommandText: ""

    readonly property var modifierOptions: ["SUPER", "CTRL", "ALT"]
    readonly property var categories: ["Hyprland", "Quickshell", "Media & System"]

    function getBindsForCategory(catName) {
        return HyprlandKeybindsService.binds.filter(b => b.category === catName)
    }

    SettingsScrollView {
        SettingsHeader {
            icon: "keyboard"
            title: "Keybinds"
            subtitle: "Rebind any Hyprland shortcut, or add a new app/command bind."
        }

        SettingsSectionLabel { label: "Modifier Key" }

        SettingsSegmentedRow {
            label: "Main Modifier Key"
            options: root.modifierOptions
            selectedValue: HyprlandKeybindsService.mainMod
            onOptionSelected: (value) => HyprlandKeybindsService.setMainMod(value)
        }

        Repeater {
            model: root.categories
            delegate: ColumnLayout {
                required property string modelData
                property var catBinds: root.getBindsForCategory(modelData)

                Layout.fillWidth: true
                spacing: Dimens.spacingSmall
                visible: catBinds.length > 0

                SettingsSectionLabel { label: parent.modelData + " Binds" }

                Repeater {
                    model: parent.catBinds
                    delegate: KeybindRow {
                        required property var modelData
                        Layout.fillWidth: true
                        label: HyprlandKeybindsService.friendlyName(modelData)
                        isAutoLabel: HyprlandKeybindsService.isAutoNamed(modelData)
                        actionPreview: modelData.actionPreview
                        keyDisplay: modelData.keyDisplay
                        isCustom: modelData.isCustom
                        isMultiline: modelData.isMultiline
                        hasConflict: (HyprlandKeybindsService.conflictCounts[modelData.keyDisplay] || 0) > 1
                        onRebindRequested: (newKey) => HyprlandKeybindsService.rebindKey(modelData.id, newKey)
                        onRemoveRequested: HyprlandKeybindsService.removeCustomBind(modelData.id)
                        onFlattenRequested: HyprlandKeybindsService.flattenBind(modelData.id)
                        onRenameRequested: (newLabel) => HyprlandKeybindsService.setLabel(modelData.actionKey, newLabel)
                    }
                }
            }
        }

        SettingsSectionLabel { label: "Add New Bind" }

        SettingsButton {
            visible: !root.addingNew
            text: "Add App/Command Bind"
            onClicked: root.addingNew = true
        }

        ColumnLayout {
            visible: root.addingNew
            Layout.fillWidth: true
            spacing: Dimens.spacingSmall

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 32
                radius: Dimens.radiusSmall
                color: Colors.subBgMica
                border.color: Colors.border
                border.width: 1
                TextInput {
                    anchors.fill: parent
                    anchors.margins: 8
                    color: Colors.fg
                    font.family: Fonts.mono
                    font.pixelSize: Dimens.fontSizeSm
                    onTextChanged: root.newKeyText = text
                    Text {
                        visible: parent.text.length === 0
                        text: "Key combo, e.g. SUPER + SHIFT + G"
                        color: Colors.subtext
                        font: parent.font
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 32
                radius: Dimens.radiusSmall
                color: Colors.subBgMica
                border.color: Colors.border
                border.width: 1
                TextInput {
                    anchors.fill: parent
                    anchors.margins: 8
                    color: Colors.fg
                    font.family: Fonts.mono
                    font.pixelSize: Dimens.fontSizeSm
                    onTextChanged: root.newCommandText = text
                    Text {
                        visible: parent.text.length === 0
                        text: "Command, e.g. spotify"
                        color: Colors.subtext
                        font: parent.font
                    }
                }
            }

            RowLayout {
                spacing: Dimens.spacingSmall
                SettingsButton {
                    primary: true
                    text: "Add"
                    enabled: root.newKeyText.trim().length > 0 && root.newCommandText.trim().length > 0
                    onClicked: {
                        HyprlandKeybindsService.addExecBind(root.newKeyText.trim(), root.newCommandText.trim())
                        root.newKeyText = ""
                        root.newCommandText = ""
                        root.addingNew = false
                    }
                }
                SettingsButton {
                    text: "Cancel"
                    onClicked: root.addingNew = false
                }
            }
        }
    }
}