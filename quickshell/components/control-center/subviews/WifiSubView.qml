import QtQuick
import "../../../styles"
import "../../../services"

Item {
    id: root
    implicitWidth: 580
    implicitHeight: contentColumn.implicitHeight + 32

    signal backRequested()

    property string selectedSsid: ""
    property bool showingPasswordInput: false
    readonly property var availableNetworks: WifiService.networks.filter(function(n) { return n.ssid !== WifiService.ssid })
    readonly property var connectedNetworkInfo: {
        for (const n of WifiService.networks) {
            if (n.ssid === WifiService.ssid) return n
        }
        return null
    }

    // Auto-close the password sheet once a connect attempt finishes
    // successfully; on failure it stays open so the error text (bound to
    // WifiService.lastError) is visible right where the user is.
    Connections {
        target: WifiService
        function onConnectingChanged() {
            if (!WifiService.connecting && WifiService.lastError === "") {
                root.showingPasswordInput = false
            }
        }
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
                    onClicked: {
                        if (root.showingPasswordInput) {
                            WifiService.clearError()
                            root.showingPasswordInput = false
                        } else {
                            root.backRequested()
                        }
                    }
                }
            }

            Text {
                text: root.showingPasswordInput ? "Connect to " + root.selectedSsid : "Wi-Fi"
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSize15
                font.bold: true
                color: Colors.fg
                anchors.left: backBtn.right
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                elide: Text.ElideRight
                width: parent.width - 140
            }

            Row {
                visible: !root.showingPasswordInput
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Rectangle {
                    width: 28
                    height: 28
                    radius: ShellState.islandCornerRadius
                    color: Colors.subBgMica
                    border.width: 1
                    border.color: Colors.border

                    Text {
                        anchors.centerIn: parent
                        text: "power_settings_new"
                        font.family: Fonts.icon
                        font.pixelSize: Dimens.fontSizeSm
                        color: WifiService.enabled ? Colors.accent : Colors.fgMuted
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: WifiService.toggle()
                    }
                }

                Rectangle {
                    width: 28
                    height: 28
                    radius: ShellState.islandCornerRadius
                    color: Colors.subBgMica
                    border.width: 1
                    border.color: Colors.border
                    visible: WifiService.enabled && !WifiService.adapterMissing

                    Text {
                        anchors.centerIn: parent
                        text: "refresh"
                        font.family: Fonts.icon
                        font.pixelSize: Dimens.fontSizeSm
                        color: WifiService.scanning ? Colors.accent : Colors.fg
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: WifiService.scanNetworks()
                    }
                }
            }
        }

        Text {
            text: WifiService.lastError
            color: Colors.red
            font.pixelSize: Dimens.fontSizeXSm
            visible: WifiService.lastError !== "" && !root.showingPasswordInput
            width: parent.width
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            text: WifiService.adapterMissing ? "No Wi-Fi adapter found" : "Wi-Fi is turned off"
            font.pixelSize: Dimens.fontSizeSm
            color: Colors.fgMuted
            visible: (!WifiService.enabled || WifiService.adapterMissing) && !root.showingPasswordInput
            anchors.horizontalCenter: parent.horizontalCenter
            topPadding: 20
            bottomPadding: 20
        }

        Column {
            width: parent.width
            spacing: 10
            visible: WifiService.enabled && !WifiService.adapterMissing && !root.showingPasswordInput

            Column {
                width: parent.width
                spacing: 6
                visible: WifiService.ssid !== ""

                Text {
                    text: "CONNECTED"
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeXSm
                    font.bold: true
                    color: Colors.fgMuted
                }

                Rectangle {
                    width: parent.width
                    height: 52
                    radius: ShellState.islandCornerRadius
                    color: Colors.subBgMica
                    border.width: 1
                    border.color: Colors.border

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 10

                        Column {
                            width: parent.width - 120
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: WifiService.ssid
                                font.family: Fonts.text
                                font.pixelSize: Dimens.fontSizeMd
                                font.weight: Font.Medium
                                color: Colors.fg
                                elide: Text.ElideRight
                                width: parent.width
                            }

                            Text {
                                text: WifiService.hasInternet ? "Connected" : "No Internet"
                                font.pixelSize: Dimens.fontSizeXSm
                                color: WifiService.hasInternet ? Colors.accent : Colors.fgMuted
                            }
                        }

                        Row {
                            spacing: 2
                            visible: root.connectedNetworkInfo !== null
                            anchors.verticalCenter: parent.verticalCenter

                            Repeater {
                                model: 4
                                delegate: Rectangle {
                                    required property int index
                                    width: 3
                                    height: 5 + index * 3
                                    radius: 1
                                    anchors.bottom: parent.bottom
                                    color: (root.connectedNetworkInfo && index < root.connectedNetworkInfo.signalBars) ? Colors.accent : Colors.border
                                }
                            }
                        }

                        Rectangle {
                            width: 84
                            height: 28
                            radius: ShellState.islandCornerRadius
                            color: Colors.accent
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                anchors.centerIn: parent
                                text: "Disconnect"
                                font.pixelSize: Dimens.fontSizeXSm
                                font.bold: true
                                color: Colors.bg
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: WifiService.disconnect()
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
                    visible: root.availableNetworks.length > 0
                }

                Flickable {
                    width: parent.width
                    height: Math.min(listColumn.implicitHeight, 280)
                    contentWidth: width
                    contentHeight: listColumn.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    Column {
                        id: listColumn
                        width: parent.width
                        spacing: 8

                        Repeater {
                            model: root.availableNetworks

                            delegate: Rectangle {
                                required property var modelData
                                width: listColumn.width
                                height: 48
                                radius: ShellState.islandCornerRadius
                                color: Colors.subBgMica
                                border.width: 1
                                border.color: Colors.border

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 14
                                    anchors.rightMargin: 10
                                    spacing: 10

                                    Row {
                                        spacing: 2
                                        anchors.verticalCenter: parent.verticalCenter

                                        Repeater {
                                            model: 4
                                            delegate: Rectangle {
                                                required property int index
                                                width: 3
                                                height: 5 + index * 3
                                                radius: 1
                                                anchors.bottom: parent.bottom
                                                color: index < modelData.signalBars ? Colors.accent : Colors.border
                                            }
                                        }
                                    }

                                    Text {
                                        text: modelData.secured ? "lock" : ""
                                        font.family: Fonts.icon
                                        font.pixelSize: Dimens.fontSizeXSm
                                        color: Colors.fgMuted
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        width: parent.width - 130
                                        text: modelData.ssid
                                        font.family: Fonts.text
                                        font.pixelSize: Dimens.fontSizeSm
                                        color: Colors.fg
                                        elide: Text.ElideRight
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Rectangle {
                                        width: 74
                                        height: 28
                                        radius: ShellState.islandCornerRadius
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
                                            onClicked: {
                                                WifiService.clearError()
                                                root.selectedSsid = modelData.ssid
                                                if (modelData.secured) {
                                                    passwordInput.text = ""
                                                    root.showingPasswordInput = true
                                                    passwordInput.forceActiveFocus()
                                                } else {
                                                    WifiService.connectToNetwork(modelData.ssid, "")
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Text {
                    text: WifiService.scanning ? "Scanning..." : "No networks found"
                    font.pixelSize: Dimens.fontSizeSm
                    color: Colors.fgMuted
                    visible: root.availableNetworks.length === 0
                    anchors.horizontalCenter: parent.horizontalCenter
                    topPadding: 12
                    bottomPadding: 12
                }
            }
        }

        Column {
            width: parent.width
            visible: root.showingPasswordInput
            spacing: 12

            Text {
                text: "Enter Wi-Fi Password"
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeSm
                color: Colors.fgMuted
            }

            Rectangle {
                width: parent.width
                height: 40
                radius: ShellState.islandCornerRadius
                color: Colors.subBgMica
                border.width: 1
                border.color: Colors.border

                TextInput {
                    id: passwordInput
                    anchors.fill: parent
                    anchors.margins: 10
                    echoMode: TextInput.Password
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeSm
                    color: Colors.fg
                    clip: true
                    onAccepted: connectBtn.click()
                }
            }

            Text {
                text: WifiService.lastError
                color: Colors.red
                font.pixelSize: Dimens.fontSizeXSm
                visible: WifiService.lastError !== ""
                width: parent.width
                wrapMode: Text.Wrap
            }

            Row {
                width: parent.width
                spacing: 10

                Rectangle {
                    width: (parent.width - 10) / 2
                    height: 38
                    radius: ShellState.islandCornerRadius
                    color: Colors.subBgMica

                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        color: Colors.fg
                        font.pixelSize: Dimens.fontSizeSm
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            WifiService.clearError()
                            root.showingPasswordInput = false
                        }
                    }
                }

                Rectangle {
                    id: connectBtn
                    width: (parent.width - 10) / 2
                    height: 38
                    radius: ShellState.islandCornerRadius
                    color: Colors.accent
                    opacity: WifiService.connecting ? 0.6 : 1.0

                    signal click()
                    onClick: {
                        if (WifiService.connecting) return
                        WifiService.connectToNetwork(root.selectedSsid, passwordInput.text)
                    }

                    Text {
                        anchors.centerIn: parent
                        text: WifiService.connecting ? "Connecting…" : "Connect"
                        color: Colors.bg
                        font.bold: true
                        font.pixelSize: Dimens.fontSizeSm
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        enabled: !WifiService.connecting
                        onClicked: connectBtn.click()
                    }
                }
            }
        }
    }
}