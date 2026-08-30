// components/control-center/subviews/FocusSubView.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../../styles"
import "../../../services"

Item {
    id: root
    implicitWidth: 580
    implicitHeight: Math.min(contentColumn.implicitHeight + 32, 540)

    signal backRequested()

    // Preset Focus Modes
    readonly property var focusModes: [
        { name: "Do Not Disturb", icon: "do_not_disturb_on", desc: "Silence all notifications", color: "#8E8E93" },
        { name: "Work",           icon: "work",              desc: "Disable animations & flatten bar", color: "#0A84FF" },
        { name: "Personal",       icon: "person",            desc: "For personal time",         color: "#FF9F0A" },
        { name: "Sleep",          icon: "bedtime",           desc: "Rest & relaxation",         color: "#BF5AF2" },
        { name: "Gaming",         icon: "sports_esports",    desc: "Minimize distractions",     color: "#30D158" }
    ]

    Column {
        id: contentColumn
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 16
        spacing: 14

        // Header Row
        Item {
            id: headerRow
            width: parent.width
            height: 28

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
                anchors.centerIn: parent
            }
        }

        // Main Focus Toggle Card
        Rectangle {
            width: parent.width
            height: 48
            radius: Dimens.radiusLarge
            color: Colors.surface
            border.width: 1
            border.color: Colors.border

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12

                Text {
                    text: "do_not_disturb_on"
                    font.family: Fonts.icon
                    font.pixelSize: Dimens.fontSizeLg
                    color: ShellState.focusModeEnabled ? Colors.accent : Colors.fgMuted
                }

                Column {
                    Layout.fillWidth: true
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

                // Switch Indicator
                Rectangle {
                    width: 40
                    height: 22
                    radius: 11
                    color: ShellState.focusModeEnabled ? Colors.accent : Colors.bgMica
                    border.width: 1
                    border.color: Colors.border

                    Rectangle {
                        width: 16
                        height: 16
                        radius: 8
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

        // Focus Mode Presets Grid
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
                    radius: Dimens.radiusLarge
                    color: isSelected ? Qt.rgba(Colors.accent.r, Colors.accent.g, Colors.accent.b, 0.15) 
                         : (modeMa.containsMouse ? Colors.bgSurface : Colors.surface)
                    border.width: 1
                    border.color: isSelected ? Colors.accent : Colors.border

                    Behavior on color {
                        enabled: !ShellState.isWorkMode
                        ColorAnimation { duration: 120 }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 12

                        Rectangle {
                            width: 32
                            height: 32
                            radius: 16
                            color: isSelected ? Colors.accent : Qt.rgba(1, 1, 1, 0.08)

                            Text {
                                text: modelData.icon
                                font.family: Fonts.icon
                                font.pixelSize: Dimens.fontSizeMd
                                color: isSelected ? "#FFFFFF" : modelData.color
                                anchors.centerIn: parent
                            }
                        }

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
                            font.pixelSize: Dimens.fontSizeMd
                            color: Colors.accent
                            visible: isSelected
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