pragma ComponentBehavior: Bound

import QtQuick
import "../../../styles"
import "../../../services"

Item {
    id: root
    implicitWidth: 580
    implicitHeight: contentColumn.implicitHeight + 32

    signal backRequested()

    Column {
        id: contentColumn
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 16
        spacing: 12

        Item {
            width: parent.width
            height: 32

            Text {
                id: backBtn
                text: "arrow_back"
                font.family: Fonts.icon
                font.pixelSize: Dimens.fontSizeLg
                color: Colors.fg
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -8
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.backRequested()
                }
            }

            Text {
                text: "Audio Output"
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSize15
                font.bold: true
                color: Colors.fg
                anchors.left: backBtn.right
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // ---- Empty state ----
        Text {
            visible: VolumeService.outputSinks.length === 0
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: "No output devices found"
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeSm
            color: Colors.fgMuted
        }

        // ---- Device list ----
        Repeater {
            model: VolumeService.outputSinks

            delegate: Rectangle {
                id: row
                required property var modelData
                readonly property bool isDefault: VolumeService.isDefaultSink(row.modelData)

                width: contentColumn.width
                height: 56
                radius: ShellState.islandCornerRadius
                color: Colors.subBgMica
                border.width: row.isDefault ? 2 : 1
                border.color: row.isDefault ? Colors.accent : Colors.border

                Behavior on border.color {
                    ColorAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: VolumeService.setDefaultSink(row.modelData)
                }

                Text {
                    id: deviceIcon
                    text: row.isDefault ? "radio_button_checked" : "radio_button_unchecked"
                    font.family: Fonts.icon
                    font.pixelSize: Dimens.fontSizeXl
                    font.variableAxes: Fonts.iconAxes
                    color: row.isDefault ? Colors.accent : Colors.fgMuted
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: VolumeService.sinkLabel(row.modelData)
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeSm
                    font.bold: row.isDefault
                    color: Colors.fg
                    elide: Text.ElideRight
                    anchors.left: deviceIcon.right
                    anchors.leftMargin: 12
                    anchors.right: defaultLabel.left
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    id: defaultLabel
                    visible: row.isDefault
                    text: "Default"
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeXs
                    color: Colors.accent
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}