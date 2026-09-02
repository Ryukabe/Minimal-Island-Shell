// modules/settings/SettingsApp.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../styles"

Scope {
    id: root

    property bool isOpen: false

    IpcHandler {
        target: "settings"
        function toggle(): void { root.isOpen = !root.isOpen }
        function open(): void { root.isOpen = true }
        function close(): void { root.isOpen = false }
    }

    PanelWindow {
        id: window

        WlrLayershell.namespace: "quickshell:settings"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        color: "transparent"
        visible: root.isOpen

        anchors.top: true
        anchors.left: true
        anchors.right: true
        anchors.bottom: true

        Item {
            id: windowContainer
            anchors.fill: parent

            Shortcut {
                sequence: "Escape"
                enabled: root.isOpen
                onActivated: root.isOpen = false
            }

            Rectangle {
                id: appWindow
                anchors.centerIn: parent
                width: 860
                height: 600
                color: Colors.bg
                border.color: Colors.border
                border.width: 1
                radius: 16

                // Top Header / Titlebar
                Item {
                    id: titleBar
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.topMargin: 20
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    height: 40

                    RowLayout {
                        anchors.fill: parent
                        spacing: 12

                        Text {
                            text: "󰒓"
                            color: Colors.accent
                            font.family: "monospace"
                            font.pixelSize: 18
                        }

                        Text {
                            text: "Settings"
                            color: Colors.fg
                            font.pixelSize: 16
                            font.weight: Font.Bold
                            Layout.fillWidth: true
                        }
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: 32
                        height: 32
                        radius: 8
                        color: closeMouse.containsMouse ? Colors.surface : "transparent"
                        border.color: closeMouse.containsMouse ? Colors.border : "transparent"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            color: Colors.fg
                            font.pixelSize: 14
                        }

                        MouseArea {
                            id: closeMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.isOpen = false
                        }
                    }
                }

                // Main Content Area (Sidebar + Stack)
                Item {
                    anchors.top: titleBar.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 20
                    anchors.topMargin: 10

                    RowLayout {
                        anchors.fill: parent
                        spacing: 20

                        ListView {
                            id: sectionList
                            Layout.preferredWidth: 220
                            Layout.fillHeight: true
                            clip: true
                            spacing: 6

                            model: ListModel {
                                ListElement { sectionName: "Bar & Island"; icon: "󱂬" }
                                ListElement { sectionName: "Appearance"; icon: "󰏘" }
                                ListElement { sectionName: "System"; icon: "󰒓" }
                            }

                            delegate: Item {
                                width: sectionList.width
                                height: 42
                                property bool isSelected: ListView.isCurrentItem

                                Rectangle {
                                    anchors.fill: parent
                                    color: isSelected ? Colors.accent : "transparent"
                                    opacity: isSelected ? 0.15 : 1.0
                                    radius: 8
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 14
                                    anchors.rightMargin: 14
                                    spacing: 12

                                    Text {
                                        text: model.icon
                                        color: isSelected ? Colors.accent : Colors.fg
                                        font.family: "monospace"
                                        font.pixelSize: 15
                                    }

                                    Text {
                                        text: model.sectionName
                                        color: isSelected ? Colors.accent : Colors.fg
                                        font.pixelSize: 14
                                        font.weight: isSelected ? Font.Bold : Font.Normal
                                        Layout.fillWidth: true
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: sectionList.currentIndex = index
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "transparent"

                            StackLayout {
                                anchors.fill: parent
                                currentIndex: sectionList.currentIndex

                                BarSettingsView {}
                                AppearanceSettingsView {}
                                SystemSettingsView {}
                            }
                        }
                    }
                }
            }
        }
    }
}