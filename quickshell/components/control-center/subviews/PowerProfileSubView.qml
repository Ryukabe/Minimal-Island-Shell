pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../../styles"
import "../../../services"

Item {
    id: root
    implicitWidth: 580
    implicitHeight: Math.min(contentColumn.implicitHeight + 32, 460)

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
                text: "Power Profile"
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSize15
                font.bold: true
                color: Colors.fg
                anchors.centerIn: parent
            }
        }

        Text {
            text: "State shown is what was last set, not read back from the system"
            font.pixelSize: Dimens.fontSizeXSm
            color: Colors.fgMuted
            wrapMode: Text.WordWrap
            width: parent.width
        }

        Column {
            width: parent.width
            spacing: 8

            Repeater {
                model: PowerProfileService.profiles

                delegate: Rectangle {
                    required property var modelData
                    readonly property bool isSelected: PowerProfileService.activeProfile === modelData.id

                    width: parent.width
                    height: 52
                    radius: Dimens.radiusLarge
                    color: isSelected ? Colors.bgSurface : Colors.surface
                    border.width: 1
                    border.color: isSelected ? Colors.accent : Colors.border

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 12

                        Column {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: modelData.name
                                font.family: Fonts.text
                                font.pixelSize: Dimens.fontSizeMd
                                font.weight: Font.Medium
                                color: Colors.fg
                            }

                            Text {
                                text: modelData.desc
                                font.pixelSize: Dimens.fontSizeXSm
                                color: Colors.fgMuted
                            }
                        }

                        Text {
                            text: "check"
                            font.family: Fonts.icon
                            font.variableAxes: Fonts.iconAxesFilled
                            font.pixelSize: Dimens.fontSizeMd
                            color: Colors.accent
                            visible: isSelected
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: PowerProfileService.setProfile(modelData.id)
                    }
                }
            }
        }
    }
}