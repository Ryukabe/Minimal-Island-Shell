// modules/settings/BarSettingsView.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"

Item {
    id: root
    // Fix: Let StackLayout manage the size instead of anchors
    Layout.fillWidth: true
    Layout.fillHeight: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 20

        Text {
            text: "Bar & Island Configuration"
            color: Colors.fg
            font.pixelSize: 20
            font.weight: Font.Bold
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                Layout.fillWidth: true
                height: 64
                color: Colors.surface
                radius: 12
                border.color: Colors.border
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    spacing: 16

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: "Dynamic Island Behavior"
                            color: Colors.fg
                            font.pixelSize: 15
                            font.weight: Font.Medium
                        }

                        Text {
                            text: "Automatically expand island on incoming notifications"
                            color: Colors.fg
                            opacity: 0.7
                            font.pixelSize: 12
                        }
                    }

                    Switch {
                        id: islandSwitch
                        checked: true

                        indicator: Rectangle {
                            implicitWidth: 48
                            implicitHeight: 24
                            x: islandSwitch.leftPadding
                            y: parent.height / 2 - height / 2
                            radius: height / 2
                            color: islandSwitch.checked ? Colors.accent : Colors.border
                            border.color: Colors.border
                            border.width: 1

                            Rectangle {
                                x: islandSwitch.checked ? parent.width - width - 3 : 3
                                y: 3
                                width: 18
                                height: 18
                                radius: 9
                                color: Colors.fg
                            }
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}