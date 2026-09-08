// settings/keybinds/Keybinds.qml
import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../../services"
import "../common"

Item {
    id: root
    property string newKeyText: ""
    property string newCommandText: ""
    property bool addExpanded: false

    readonly property var modifierOptions: ["SUPER", "CTRL", "ALT"]
    readonly property var categories: ["Hyprland", "Quickshell", "Media & System"]

    function getBindsForCategory(catName) {
        return HyprlandKeybindsService.binds.filter(b => b.category === catName)
    }

    onAddExpandedChanged: {
        if (!addExpanded) {
            // Collapsing the section safely exits capture mode and clears all inputs
            newBindCapture.exitCapture()
            newBindCapture.reset()
            root.newKeyText = ""
            root.newCommandText = ""
            newCommandInput.text = ""
        }
    }

    SettingsScrollView {
        SettingsHeader {
            icon: "keyboard"
            title: "Keybinds"
            subtitle: "Rebind any Hyprland shortcut, or add a new app/command bind."
        }

        // --- Add New Bind (Everything contained inside the Box) ---
        Rectangle {
            id: formBackground
            Layout.fillWidth: true
            implicitHeight: contentCol.implicitHeight + (Dimens.paddingMedium * 2)
            color: Colors.elevatedBg
            border.color: Colors.border
            border.width: 1
            radius: Dimens.radiusMedium

            ColumnLayout {
                id: contentCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Dimens.paddingMedium
                spacing: Dimens.spacingSmall

                // 1. Header Row (Label + Chevron) 
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    SettingsSectionLabel { 
                        label: "Add New Bind" 
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        id: chevronHit
                        implicitWidth: 28
                        implicitHeight: 28
                        radius: Dimens.radiusSmall
                        color: chevronMouse.containsMouse ? Colors.subBgMica : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "expand_more"
                            color: Colors.subtext
                            font.family: Fonts.icon
                            font.pixelSize: Dimens.fontSizeLg
                            rotation: root.addExpanded ? 180 : 0
                            Behavior on rotation {
                                NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
                            }
                        }

                        MouseArea {
                            id: chevronMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.addExpanded = !root.addExpanded
                        }
                    }
                }

                // 2. Collapsible Form Section
                Item {
                    Layout.fillWidth: true
                    clip: true
                    implicitHeight: root.addExpanded ? addBindCol.implicitHeight + Dimens.paddingSmall : 0
                    opacity: root.addExpanded ? 1 : 0

                    Behavior on implicitHeight {
                        NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
                    }
                    Behavior on opacity {
                        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                    }

                    ColumnLayout {
                        id: addBindCol
                        width: parent.width
                        anchors.top: parent.top
                        anchors.topMargin: Dimens.paddingSmall
                        spacing: Dimens.spacingSmall

                        KeyCaptureField {
                            id: newBindCapture
                            Layout.fillWidth: true
                            onComboChanged: (combo) => root.newKeyText = combo

                            // Click-to-capture: Field only activates when you explicitly click it
                            MouseArea {
                                anchors.fill: parent
                                onClicked: newBindCapture.forceActiveFocus()
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
                                id: newCommandInput
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
                            Layout.fillWidth: true
                            spacing: Dimens.spacingSmall

                            Item { Layout.fillWidth: true }

                            SettingsButton {
                                text: "Cancel"
                                onClicked: {
                                    // Triggering collapse handles the field clean-ups automatically
                                    root.addExpanded = false
                                }
                            }

                            Rectangle {
                                id: addButton
                                property bool enabledState: newBindCapture.resultCombo.trim().length > 0 && root.newCommandText.trim().length > 0
                                implicitWidth: addBtnText.implicitWidth + Dimens.paddingLarge * 2
                                implicitHeight: addBtnText.implicitHeight + Dimens.paddingSmall * 2
                                radius: height / 2
                                color: !enabledState
                                    ? Colors.subBgMica
                                    : (addMouse.pressed ? Qt.darker(Colors.accent, 1.15) : (addMouse.containsMouse ? Qt.lighter(Colors.accent, 1.1) : Colors.accent))
                                opacity: enabledState ? 1.0 : 0.45

                                Behavior on color { ColorAnimation { duration: 120 } }

                                Text {
                                    id: addBtnText
                                    anchors.centerIn: parent
                                    text: "Add"
                                    color: addButton.enabledState ? Colors.accentText : Colors.fg
                                    font.family: Fonts.text
                                    font.pixelSize: Dimens.fontSizeSm
                                    font.weight: Font.Medium
                                }

                                MouseArea {
                                    id: addMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    enabled: addButton.enabledState
                                    cursorShape: addButton.enabledState ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    onClicked: {
                                        HyprlandKeybindsService.addExecBind(newBindCapture.resultCombo.trim(), root.newCommandText.trim())
                                        // Triggering collapse handles the field clean-ups automatically
                                        root.addExpanded = false
                                    }
                                }
                            }
                        }
                    }
                }
            }
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
    }
}