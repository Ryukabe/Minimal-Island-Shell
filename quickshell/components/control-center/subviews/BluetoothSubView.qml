// components/control-center/subviews/BluetoothSubView.qml
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

    readonly property var deviceList: BluetoothService.availableDevices.concat(BluetoothService.connectedDevices)
    readonly property var connectedList: root.deviceList.filter(function(d) { return d.connected })
    readonly property var availableList: root.deviceList.filter(function(d) { return !d.connected })

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
                    text: "Bluetooth"
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSize15
                    font.bold: true
                    color: Colors.fg
                    anchors.left: backBtn.right
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 14
                        color: Colors.subBgMica
                        border.width: 1
                        border.color: Colors.border

                        Text {
                            anchors.centerIn: parent
                            text: "bluetooth"
                            font.family: Fonts.icon
                            font.pixelSize: Dimens.fontSizeSm
                            color: BluetoothService.enabled ? Colors.accent : Colors.fgMuted
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: BluetoothService.toggle()
                        }
                    }

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 14
                        color: Colors.subBgMica
                        border.width: 1
                        border.color: Colors.border
                        visible: BluetoothService.enabled

                        Text {
                            anchors.centerIn: parent
                            text: "refresh"
                            font.family: Fonts.icon
                            font.pixelSize: Dimens.fontSizeSm
                            color: Colors.fg
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: BluetoothService.refresh()
                        }
                    }
                }
            }

            Text {
                text: "Bluetooth is turned off"
                font.pixelSize: Dimens.fontSizeSm
                color: Colors.fgMuted
                visible: !BluetoothService.enabled
                anchors.horizontalCenter: parent.horizontalCenter
                topPadding: 20
                bottomPadding: 20
            }

            Column {
                width: parent.width
                spacing: 10
                visible: BluetoothService.enabled

                Column {
                    width: parent.width
                    spacing: 6
                    visible: root.connectedList.length > 0

                    Text {
                        text: "CONNECTED"
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeXSm
                        font.bold: true
                        color: Colors.fgMuted
                    }

                    Repeater {
                        model: root.connectedList

                        delegate: Rectangle {
                            required property var modelData
                            width: parent.width
                            height: 52
                            radius: Dimens.radiusLarge
                            color: Colors.bgSurface
                            border.width: 1
                            border.color: Colors.border

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 14
                                anchors.rightMargin: 14
                                spacing: 10

                                Text {
                                    text: "bluetooth_connected"
                                    font.family: Fonts.icon
                                    font.pixelSize: Dimens.fontSizeMd
                                    color: Colors.accent
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    width: parent.width - 120
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2

                                    Text {
                                        text: modelData.name || "Unknown Device"
                                        font.family: Fonts.text
                                        font.pixelSize: Dimens.fontSizeMd
                                        font.weight: Font.Medium
                                        color: Colors.fg
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }

                                    Text {
                                        text: "Connected"
                                        font.pixelSize: Dimens.fontSizeXSm
                                        color: Colors.accent
                                    }
                                }

                                Rectangle {
                                    width: 84
                                    height: 28
                                    radius: 14
                                    color: Colors.subBgMica
                                    border.width: 1
                                    border.color: Colors.border
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        anchors.centerIn: parent
                                        text: "Disconnect"
                                        font.pixelSize: Dimens.fontSizeXSm
                                        font.bold: true
                                        color: Colors.fg
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: BluetoothService.disconnectDevice(modelData.mac)
                                    }
                                }
                            }
                        }
                    }
                }

                Column {
                    width: parent.width
                    spacing: 6

                    Text {
                        text: "AVAILABLE"
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeXSm
                        font.bold: true
                        color: Colors.fgMuted
                        visible: root.availableList.length > 0
                    }

                    Column {
                        width: parent.width
                        spacing: 8

                        Repeater {
                            model: root.availableList

                            delegate: Rectangle {
                                required property var modelData
                                width: parent.width
                                height: 48
                                radius: Dimens.radiusLarge
                                color: Colors.subBgMica
                                border.width: 1
                                border.color: Colors.border

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 14
                                    anchors.rightMargin: 10
                                    spacing: 10

                                    Text {
                                        text: "bluetooth"
                                        font.family: Fonts.icon
                                        font.pixelSize: Dimens.fontSizeSm
                                        color: Colors.fgMuted
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        width: parent.width - 110
                                        text: modelData.name || "Unknown Device"
                                        font.family: Fonts.text
                                        font.pixelSize: Dimens.fontSizeSm
                                        color: Colors.fg
                                        elide: Text.ElideRight
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Rectangle {
                                        width: 74
                                        height: 28
                                        radius: 14
                                        color: Colors.accent
                                        anchors.verticalCenter: parent.verticalCenter

                                        Text {
                                            anchors.centerIn: parent
                                            text: "Connect"
                                            font.pixelSize: Dimens.fontSizeXSm
                                            font.bold: true
                                            color: Colors.bg
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: BluetoothService.connectDevice(modelData.mac)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Text {
                        text: "No devices found"
                        font.pixelSize: Dimens.fontSizeSm
                        color: Colors.fgMuted
                        visible: root.deviceList.length === 0
                        anchors.horizontalCenter: parent.horizontalCenter
                        topPadding: 12
                        bottomPadding: 12
                    }
                }
            }
        }
    }
}