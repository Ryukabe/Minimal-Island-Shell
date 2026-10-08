// components/KeybindRow.qml — one shortcut: friendly name with the raw action underneath, and the key pill.
// Hover the name and click to rename (stores an override, never touches binds.lua).
// Click the key pill to rebind: capture is live, the combo is staged until Save, Escape cancels.
// Conflict warning, Flatten for multi-line binds, Remove for custom-added binds.
import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../../services"

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
    property bool showDivider: true

    signal rebindRequested(string newKeyDisplay)
    signal removeRequested()
    signal flattenRequested()
    signal renameRequested(string newLabel)

    onEditingChanged: {
        if (editing) {
            captureField.reset()
            captureField.activate()
        } else {
            // Every close path (Save, Cancel, Escape) ends up here, so disarm, submap reset and wipe happen together.
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
    implicitHeight: Math.max(54, mainCol.implicitHeight + Dimens.paddingSmall * 2)

    ColumnLayout {
        id: mainCol
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Dimens.paddingMedium
        anchors.rightMargin: Dimens.paddingMedium
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        RowLayout {
            Layout.fillWidth: true
            spacing: Dimens.spacingMedium

            // Name and raw action
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1
                visible: !root.renaming

                Item {
                    id: labelBox
                    Layout.fillWidth: true
                    implicitHeight: labelRow.implicitHeight

                    RowLayout {
                        id: labelRow
                        spacing: 6

                        Text {
                            Layout.maximumWidth: labelBox.width - 30
                            text: root.label
                            color: root.isAutoLabel ? Colors.fg : Colors.accent
                            font.family: Fonts.text
                            font.pixelSize: Dimens.fontSizeBase
                            font.weight: Font.Medium
                            elide: Text.ElideRight
                        }

                        SymbolIcon {
                            name: "edit"
                            size: Dimens.fontSizeSm
                            color: Colors.subtext
                            opacity: labelMouse.containsMouse ? 1 : 0

                            Behavior on opacity {
                                NumberAnimation { duration: ShellState.motionDuration(Motion.hoverMs) }
                            }
                        }
                    }

                    MouseArea {
                        id: labelMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.renaming = true
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: root.actionPreview
                    color: Colors.subtext
                    font.family: Fonts.mono
                    font.pixelSize: Dimens.fontSizeXs
                    elide: Text.ElideRight
                }
            }

            // Rename mode
            RowLayout {
                visible: root.renaming
                Layout.fillWidth: true
                spacing: Dimens.spacingSmall

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 34
                    radius: Dimens.settingsControlRadius
                    color: Colors.elevatedBg
                    border.color: Colors.accent
                    border.width: 1

                    TextInput {
                        id: renameField
                        anchors.fill: parent
                        anchors.leftMargin: Dimens.paddingMedium
                        anchors.rightMargin: Dimens.paddingMedium
                        verticalAlignment: TextInput.AlignVCenter
                        color: Colors.fg
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeBase
                        selectByMouse: true
                        clip: true
                        onAccepted: {
                            root.renameRequested(text)
                            root.renaming = false
                        }
                        Keys.onEscapePressed: root.renaming = false
                    }
                }

                ActionButton {
                    primary: true
                    text: "Save"
                    onClicked: {
                        root.renameRequested(renameField.text)
                        root.renaming = false
                    }
                }

                ActionButton {
                    text: "Cancel"
                    onClicked: root.renaming = false
                }
            }

            SymbolIcon {
                visible: root.hasConflict && !root.renaming
                name: "warning"
                size: Dimens.fontSizeLg
                color: Colors.yellow
            }

            // Key pill
            Rectangle {
                visible: !root.editing && !root.renaming
                implicitWidth: keyText.implicitWidth + Dimens.paddingMedium * 2
                implicitHeight: 30
                radius: Dimens.radiusChip
                color: pillMouse.containsMouse ? Colors.elevatedBg : Colors.subBgMica
                border.color: root.hasConflict ? Colors.yellow : Colors.border
                border.width: 1

                Behavior on color {
                    ColorAnimation { duration: ShellState.motionDuration(Motion.hoverMs) }
                }

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

            // Rebind mode
            RowLayout {
                visible: root.editing
                spacing: Dimens.spacingSmall

                KeyCaptureField {
                    id: captureField
                    onCancelled: root.editing = false
                }

                ActionButton {
                    primary: true
                    text: "Save"
                    enabled: captureField.resultCombo.length > 0
                    onClicked: {
                        root.rebindRequested(captureField.resultCombo)
                        root.editing = false
                    }
                }

                ActionButton {
                    text: "Cancel"
                    onClicked: root.editing = false
                }
            }

            ActionButton {
                visible: root.isMultiline && !root.editing && !root.renaming
                text: "Flatten"
                onClicked: root.flattenRequested()
            }

            ActionButton {
                visible: root.isCustom && !root.editing && !root.renaming
                text: "Remove"
                onClicked: root.removeRequested()
            }
        }
    }

    Rectangle {
        visible: root.showDivider
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Dimens.paddingMedium
        anchors.rightMargin: Dimens.paddingMedium
        height: 1
        color: Colors.border
        opacity: 0.35
    }
}