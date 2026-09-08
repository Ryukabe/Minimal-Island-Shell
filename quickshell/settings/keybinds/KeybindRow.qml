// settings/keybinds/KeybindRow.qml — friendly name (bold, primary) with raw
// action code shown small underneath for reference. Rename via pencil icon
// (stores an override, never touches binds.lua). Key combo pill click enters
// edit mode with live key-press capture, staged until Save; Escape cancels.
// Conflict badge, Flatten for multi-line binds, Remove for custom-added binds.
import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../common"

Item {
    id: root

    property string label: ""
    property bool isAutoLabel: true
    property string actionPreview: ""
    property string keyDisplay: ""
    property bool hasConflict: false
    property bool isCustom: false
    property bool isMultiline: false
    property bool editing: false
    property bool renaming: false

    signal rebindRequested(string newKeyDisplay)
    signal removeRequested()
    signal flattenRequested()
    signal renameRequested(string newLabel)

    onEditingChanged: {
        if (editing) {
            captureField.reset()
            captureField.activate()
        } else {
            // Explicit exit on every close path (Save, Cancel, or
            // Escape via the cancelled() connection below) — always goes
            // through deactivateAndClear() so disarm + submap reset +
            // wipe happen together, in one place.
            captureField.deactivateAndClear()
        }
    }

    onRenamingChanged: {
        if (renaming) {
            renameField.text = root.isAutoLabel ? "" : root.label
            renameField.forceActiveFocus()
            renameField.selectAll()
        }
    }

    Layout.fillWidth: true
    implicitHeight: mainCol.implicitHeight + Dimens.paddingSmall * 2

    ColumnLayout {
        id: mainCol
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        RowLayout {
            Layout.fillWidth: true
            spacing: Dimens.spacingMedium

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1
                visible: !root.renaming

                RowLayout {
                    spacing: 6
                    Text {
                        text: root.label
                        color: root.isAutoLabel ? Colors.fg : Colors.accent
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeBase
                        font.weight: Font.Medium
                        elide: Text.ElideRight
                    }
                    Text {
                        text: "edit"
                        visible: renameMouse.containsMouse
                        color: Colors.subtext
                        font.family: Fonts.icon
                        font.pixelSize: Dimens.fontSizeSm
                    }
                    MouseArea {
                        id: renameMouse
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: 16
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.renaming = true
                    }
                }

                Text {
                    text: root.actionPreview
                    color: Colors.subtext
                    font.family: Fonts.mono
                    font.pixelSize: Dimens.fontSizeXs
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }

            RowLayout {
                visible: root.renaming
                Layout.fillWidth: true
                spacing: Dimens.spacingSmall

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 28
                    radius: Dimens.radiusSmall
                    color: Colors.subBgMica
                    border.color: Colors.accent
                    border.width: 1

                    TextInput {
                        id: renameField
                        anchors.fill: parent
                        anchors.margins: 8
                        color: Colors.fg
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeSm
                        selectByMouse: true
                        onAccepted: {
                            root.renameRequested(text)
                            root.renaming = false
                        }
                        Keys.onEscapePressed: root.renaming = false
                    }
                }

                SettingsButton {
                    primary: true
                    text: "Save"
                    onClicked: {
                        root.renameRequested(renameField.text)
                        root.renaming = false
                    }
                }
                SettingsButton {
                    text: "Cancel"
                    onClicked: root.renaming = false
                }
            }

            Text {
                visible: root.hasConflict && !root.renaming
                text: "warning"
                color: Colors.yellow
                font.family: Fonts.icon
                font.pixelSize: Dimens.fontSizeSm
            }

            Rectangle {
                visible: !root.editing && !root.renaming
                implicitWidth: keyText.implicitWidth + Dimens.paddingMedium * 2
                implicitHeight: 28
                radius: Dimens.radiusSmall
                color: pillMouse.containsMouse ? Colors.elevatedBg : Colors.subBgMica
                border.color: root.hasConflict ? Colors.yellow : Colors.border
                border.width: 1

                Text {
                    id: keyText
                    anchors.centerIn: parent
                    text: root.keyDisplay
                    color: Colors.fg
                    font.family: Fonts.mono
                    font.pixelSize: Dimens.fontSizeSm
                }

                MouseArea {
                    id: pillMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.editing = true
                }
            }

            RowLayout {
                visible: root.editing
                spacing: Dimens.spacingSmall

                KeyCaptureField {
                    id: captureField
                }

                SettingsButton {
                    primary: true
                    text: "Save"
                    enabled: captureField.resultCombo.length > 0
                    onClicked: {
                        root.rebindRequested(captureField.resultCombo)
                        root.editing = false
                    }
                }

                SettingsButton {
                    text: "Cancel"
                    onClicked: root.editing = false
                }
            }

            SettingsButton {
                visible: root.isMultiline && !root.editing && !root.renaming
                text: "Flatten"
                onClicked: root.flattenRequested()
            }

            SettingsButton {
                visible: root.isCustom && !root.editing && !root.renaming
                text: "Remove"
                onClicked: root.removeRequested()
            }
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: Colors.border
        opacity: 0.35
    }

    Connections {
        target: captureField
        function onCancelled() { root.editing = false }
    }
}