// modules/PolkitAgent.qml
import QtQuick
import QtQuick.Layouts
import "../styles"
import "../services"

Item {
    id: root
    implicitWidth: 420
    implicitHeight: mainColumn.implicitHeight + 32

    focus: true

    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Escape) {
            PolkitService.cancel()
            event.accepted = true
        }
    }

    Timer {
        id: focusTimer
        interval: 100
        running: true
        repeat: false
        onTriggered: {
            root.forceActiveFocus()
            passInput.forceActiveFocus()
        }
    }

    Component.onCompleted: revealTimer.restart()

    Timer {
        id: revealTimer
        interval: 30
        onTriggered: {
            contentWrapper.opacity = 1.0
            contentWrapper.scale = 1.0
        }
    }

    Item {
        id: contentWrapper
        anchors.fill: parent
        opacity: 0.0
        scale: 0.94

        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
        Behavior on scale {
            NumberAnimation { duration: 260; easing.type: Easing.OutBack; easing.overshoot: 1.15 }
        }

        ColumnLayout {
            id: mainColumn
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 16
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "\uf023"
                    font.family: Fonts.mono
                    font.pixelSize: Dimens.fontSizeLg
                    color: Colors.accent
                }

                Text {
                    text: "Authentication Required"
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSize15
                    font.bold: true
                    color: Colors.fg
                }
            }

            Text {
                Layout.fillWidth: true
                text: PolkitService.currentFlow ? PolkitService.currentFlow.message : "System Privilege Escalation"
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeBase
                color: Colors.fgMuted
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: PolkitService.agent.actionId || "org.freedesktop.policykit"
                font.family: Fonts.mono
                font.pixelSize: Dimens.fontSizeXSm
                color: Colors.fgMuted
                opacity: 0.6
                elide: Text.ElideRight
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 38
                radius: Dimens.radiusMedium
                color: Colors.surface
                border.width: 1
                border.color: passInput.activeFocus ? Colors.accent : Colors.surface

                Behavior on border.color {
                    ColorAnimation { duration: 150 }
                }

                TextInput {
                    id: passInput
                    anchors.fill: parent
                    anchors.margins: 10
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeBase
                    color: Colors.fg
                    echoMode: TextInput.Password
                    focus: true

                    onAccepted: {
                        let enteredPass = passInput.text
                        if (enteredPass.length > 0) {
                            PolkitService.submitPassword(enteredPass)
                        }
                    }

                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Escape) {
                            PolkitService.cancel()
                            event.accepted = true
                        }
                    }

                    Text {
                        text: "Enter password..."
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeBase
                        color: Colors.fgMuted
                        visible: passInput.text.length === 0
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: PolkitService.errorMessage
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeXSm
                color: Colors.red
                visible: PolkitService.errorMessage.length > 0
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Item { Layout.fillWidth: true }

                Rectangle {
                    implicitWidth: 80
                    implicitHeight: 30
                    radius: Dimens.radiusTiny
                    color: Colors.surface

                    scale: cancelBtnMouse.pressed ? 0.95 : 1.0
                    Behavior on scale {
                        NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        font.pixelSize: Dimens.fontSizeSm
                        color: Colors.fg
                    }

                    MouseArea {
                        id: cancelBtnMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            passInput.text = ""
                            PolkitService.cancel()
                        }
                    }
                }

                Rectangle {
                    implicitWidth: 95
                    implicitHeight: 30
                    radius: Dimens.radiusTiny
                    color: Colors.accent

                    scale: authBtnMouse.pressed ? 0.95 : 1.0
                    Behavior on scale {
                        NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "Authenticate"
                        font.pixelSize: Dimens.fontSizeSm
                        font.bold: true
                        color: Colors.black
                    }

                    MouseArea {
                        id: authBtnMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            let enteredPass = passInput.text
                            if (enteredPass.length > 0) {
                                PolkitService.submitPassword(enteredPass)
                            }
                        }
                    }
                }
            }
        }
    }
}