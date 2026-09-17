// components/control-center/subviews/FocusSubView.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import "../../../styles"
import "../../../services"

Item {
    id: root
    implicitWidth: 580
    implicitHeight: Math.min(contentColumn.implicitHeight + 32, ShellState.controlCenterHeight)

    signal backRequested()

    readonly property var focusModes: [
        { name: "Do Not Disturb", icon: "do_not_disturb_on", desc: "Silence all notifications", color: "#8E8E93" },
        { name: "Work",           icon: "work",              desc: "Disable animations & flatten bar", color: "#0A84FF" },
        { name: "Personal",       icon: "person",            desc: "For personal time",         color: "#FF9F0A" },
        { name: "Sleep",          icon: "bedtime",           desc: "Rest & relaxation",         color: "#BF5AF2" },
        { name: "Gaming",         icon: "sports_esports",    desc: "Minimize distractions",     color: "#30D158" }
    ]

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentColumn.implicitHeight + 32
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }

        Column {
            id: contentColumn
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 16
            spacing: 14

            Item {
                id: headerRow
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
                    text: "Focus Modes"
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSize15
                    font.bold: true
                    color: Colors.fg
                    anchors.left: backBtn.right
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                }
            }            Rectangle {
                width: parent.width
                height: 48
                radius: ShellState.islandCornerRadius
                color: Colors.subBgMica
                border.width: 1
                border.color: Colors.border

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12

                    Text {
                        text: "do_not_disturb_on"
                        font.family: Fonts.icon
                        font.pixelSize: Dimens.fontSizeLg
                        color: ShellState.focusModeEnabled ? Colors.accent : Colors.fgMuted
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Column {
                        width: parent.width - 80
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Text {
                            text: "Focus Mode"
                            font.family: Fonts.text
                            font.pixelSize: Dimens.fontSizeMd
                            font.weight: Font.Medium
                            color: Colors.fg
                        }

                        Text {
                            text: ShellState.focusModeEnabled ? "Active (" + ShellState.activeFocusMode + ")" : "Off"
                            font.pixelSize: Dimens.fontSizeXSm
                            color: ShellState.focusModeEnabled ? Colors.accent : Colors.fgMuted
                        }
                    }

                    Rectangle {
                        width: 40
                        height: 22
                        radius: ShellState.islandCornerRadius
                        color: ShellState.focusModeEnabled ? Colors.accent : Colors.subBgMica
                        border.width: 1
                        border.color: Colors.border
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            width: 16
                            height: 16
                            radius: ShellState.islandCornerRadius
                            color: Colors.fg
                            anchors.verticalCenter: parent.verticalCenter
                            x: ShellState.focusModeEnabled ? parent.width - width - 3 : 3

                            Behavior on x {
                                enabled: !ShellState.isWorkMode
                                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: ShellState.toggleFocusMode()
                        }
                    }
                }
            }

            Text {
                text: "Select Profile"
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeSm
                font.bold: true
                color: Colors.fgMuted
                topPadding: 4
            }

            Column {
                width: parent.width
                spacing: 8

                Repeater {
                    model: root.focusModes

                    delegate: Rectangle {
                        required property var modelData

                        readonly property bool isSelected: ShellState.focusModeEnabled && ShellState.activeFocusMode === modelData.name

                        width: parent.width
                        height: 52
                        radius: ShellState.islandCornerRadius
                        color: isSelected ? Qt.rgba(Colors.accent.r, Colors.accent.g, Colors.accent.b, 0.15) 
                             : (modeMa.containsMouse ? Colors.bgSurface : Colors.subBgMica)
                        border.width: 1
                        border.color: isSelected ? Colors.accent : Colors.border

                        Behavior on color {
                            enabled: !ShellState.isWorkMode
                            ColorAnimation { duration: 120 }
                        }

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            spacing: 12

                            Rectangle {
                                width: 32
                                height: 32
                                radius: ShellState.islandCornerRadius
                                color: isSelected ? Colors.accent : Qt.rgba(1, 1, 1, 0.08)
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    text: modelData.icon
                                    font.family: Fonts.icon
                                    font.pixelSize: Dimens.fontSizeMd
                                    color: isSelected ? "#FFFFFF" : modelData.color
                                    anchors.centerIn: parent
                                }
                            }

                            Column {
                                width: parent.width - 80
                                anchors.verticalCenter: parent.verticalCenter
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
                                font.pixelSize: Dimens.fontSizeMd
                                color: Colors.accent
                                visible: isSelected
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            id: modeMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: ShellState.setFocusMode(modelData.name)
                        }
                    }
                }
            }
        }
    }
}