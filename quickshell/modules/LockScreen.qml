// modules/LockScreen.qml
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import "../services"
import "../styles"

WlSessionLock {
    id: sessionLock

    locked: ShellState.activePage === "lock"

    surface: Component {
        WlSessionLockSurface {
            id: lockSurface

            // Instantiate PAM service for quickshell
            Pam {
                id: pam
                service: "quickshell"

                onAuthenticated: {
                    errorMessage.visible = false
                    passwordInput.text = ""
                    sessionLock.locked = false
                    if (typeof ShellState !== "undefined") {
                        ShellState.showPage("clock")
                    }
                }

                onAuthenticationFailed: {
                    errorMessage.visible = true
                    passwordInput.text = ""
                    passwordInput.forceActiveFocus()
                }
            }

            Rectangle {
                anchors.fill: parent
                color: Colors.bg

                Column {
                    anchors.centerIn: parent
                    spacing: 20

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Qt.formatDateTime(new Date(), "hh:mm A")
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeDisplay
                        font.weight: Font.Bold
                        color: Colors.fg
                    }

                    Rectangle {
                        width: 280
                        height: 44
                        radius: Dimens.radiusLarge
                        color: Colors.bgSurface
                        border.color: errorMessage.visible ? "#ff5555" : "transparent"
                        border.width: errorMessage.visible ? 1 : 0
                        anchors.horizontalCenter: parent.horizontalCenter

                        TextInput {
                            id: passwordInput
                            anchors.fill: parent
                            anchors.margins: 10
                            verticalAlignment: TextInput.AlignVCenter
                            echoMode: TextInput.Password
                            font.family: Fonts.text
                            font.pixelSize: Dimens.fontSizeLg
                            color: Colors.fg
                            focus: true

                            Component.onCompleted: passwordInput.forceActiveFocus()

                            onTextChanged: {
                                if (errorMessage.visible) errorMessage.visible = false
                            }

                            Keys.onReturnPressed: {
                                if (text.length > 0 && !pam.authenticating) {
                                    pam.authenticate(text)
                                }
                            }
                        }
                    }

                    Text {
                        id: errorMessage
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Incorrect password"
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeBase
                        color: Colors.red
                        visible: false
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: pam.authenticating ? "Authenticating..." : "Enter password to unlock"
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeLg
                        color: Colors.fgMuted
                    }
                }
            }
        }
    }
}