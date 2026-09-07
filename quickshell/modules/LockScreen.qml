// modules/LockScreen.qml
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import Quickshell.Io
import "../services"
import "../styles"

WlSessionLock {
    id: sessionLock

    locked: typeof ShellState !== "undefined" && ShellState.activePage === "lock"

    surface: Component {
        WlSessionLockSurface {
            id: lockSurface

            PamContext {
                id: pam
                config: "quickshell"

                Component.onCompleted: pam.start()

                onCompleted: (result) => {
                    if (result === PamResult.Success) {
                        errorMessage.visible = false
                        passwordInput.text = ""
                        if (typeof ShellState !== "undefined") {
                            ShellState.showPage("clock")
                        }
                    } else {
                        errorMessage.text = "Incorrect password"
                        errorMessage.visible = true
                        passwordInput.text = ""
                        passwordInput.forceActiveFocus()
                        pam.start()
                    }
                }

                onError: (err) => {
                    errorMessage.text = "PAM Error"
                    errorMessage.visible = true
                    passwordInput.text = ""
                    passwordInput.forceActiveFocus()
                    pam.start()
                }
            }

            // System commands
            Process { id: powerOffProc; command: ["systemctl", "poweroff"] }
            Process { id: rebootProc; command: ["systemctl", "reboot"] }
            Process { id: exitHyprlandProc; command: ["hyprctl", "dispatch", "exit"] }

            // Background focus handling
            MouseArea {
                anchors.fill: parent
                onClicked: passwordInput.forceActiveFocus()

                Rectangle {
                    anchors.fill: parent
                    color: Colors.bg

                    Image {
                        id: wallpaper
                        anchors.fill: parent
                        source: WallpaperService.currentWallpaper ? "file://" + WallpaperService.currentWallpaper : ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: Colors.darkMode ? Qt.rgba(0, 0, 0, 0.35) : Qt.rgba(255, 255, 255, 0.35)
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: Dimens.spacingLg * 1.5

                        // Clock Header
                        Column {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: Dimens.spacingSmall

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: Qt.formatDateTime(new Date(), "HH:mm")
                                font.family: Fonts.display
                                font.pixelSize: Dimens.fontSizeDisplay
                                font.weight: Font.Bold
                                color: Colors.fg
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: Qt.formatDateTime(new Date(), "dddd, MMMM d").toLowerCase()
                                font.family: Fonts.text
                                font.pixelSize: Dimens.fontSizeBase
                                color: Colors.fgMuted
                            }
                        }

                        // Password Field & User
                        Column {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: Dimens.spacingMedium

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: Qt.userName || "user"
                                font.family: Fonts.text
                                font.pixelSize: Dimens.fontSizeSm
                                font.weight: Font.Medium
                                color: Colors.fgMuted
                            }

                            Row {
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: 8

                                Rectangle {
                                    width: 200
                                    height: 38
                                    radius: Dimens.radiusFull
                                    color: Qt.rgba(Colors.bgsur.r, Colors.bgsur.g, Colors.bgsur.b, Colors.micaBeta)
                                    border.color: errorMessage.visible ? Colors.red : Colors.border
                                    border.width: 1

                                    TextInput {
                                        id: passwordInput
                                        anchors.fill: parent
                                        anchors.leftMargin: Dimens.paddingMedium
                                        anchors.rightMargin: Dimens.paddingMedium
                                        verticalAlignment: TextInput.AlignVCenter
                                        echoMode: TextInput.Password
                                        font.family: Fonts.text
                                        font.pixelSize: Dimens.fontSizeBase
                                        color: Colors.fg
                                        focus: true

                                        Component.onCompleted: passwordInput.forceActiveFocus()

                                        onTextChanged: {
                                            if (errorMessage.visible) errorMessage.visible = false
                                        }

                                        Keys.onReturnPressed: submitPassword()
                                        Keys.onEnterPressed: submitPassword()

                                        function submitPassword() {
                                            if (passwordInput.text.length === 0) return

                                            if (!pam.active) {
                                                pam.start()
                                            }

                                            pam.respond(passwordInput.text)
                                        }
                                    }
                                }

                                Rectangle {
                                    width: 38
                                    height: 38
                                    radius: Dimens.radiusFull
                                    color: submitBtnArea.pressed ? Colors.accent : Qt.rgba(Colors.bgsur.r, Colors.bgsur.g, Colors.bgsur.b, Colors.micaBeta)
                                    border.color: Colors.border
                                    border.width: 1

                                    Text {
                                        anchors.centerIn: parent
                                        text: "➔"
                                        font.pixelSize: Dimens.fontSizeLg
                                        color: submitBtnArea.pressed ? Colors.bg : Colors.fg
                                    }

                                    MouseArea {
                                        id: submitBtnArea
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: passwordInput.submitPassword()
                                    }
                                }
                            }

                            Text {
                                id: errorMessage
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Incorrect password"
                                font.family: Fonts.text
                                font.pixelSize: Dimens.fontSizeSm
                                color: Colors.red
                                visible: false
                            }
                        }

                        // Navigation Actions
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: Dimens.spacingLg

                            Text {
                                id: hyprlandBtn
                                text: "HYPRLAND"
                                font.family: Fonts.mono
                                font.pixelSize: Dimens.fontSizeXs
                                color: hyprlandArea.containsMouse ? Colors.fg : Colors.fgMuted

                                MouseArea {
                                    id: hyprlandArea
                                    anchors.fill: parent
                                    anchors.margins: -8
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: exitHyprlandProc.running = true
                                }
                            }

                            Text {
                                text: "•"
                                font.pixelSize: Dimens.fontSizeXs
                                color: Colors.fgMuted
                            }

                            Text {
                                id: rebootBtn
                                text: "REBOOT"
                                font.family: Fonts.mono
                                font.pixelSize: Dimens.fontSizeXs
                                color: rebootArea.containsMouse ? Colors.fg : Colors.fgMuted

                                MouseArea {
                                    id: rebootArea
                                    anchors.fill: parent
                                    anchors.margins: -8
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: rebootProc.running = true
                                }
                            }

                            Text {
                                text: "•"
                                font.pixelSize: Dimens.fontSizeXs
                                color: Colors.fgMuted
                            }

                            Text {
                                id: powerBtn
                                text: "POWER"
                                font.family: Fonts.mono
                                font.pixelSize: Dimens.fontSizeXs
                                color: powerArea.containsMouse ? Colors.red : Colors.fgMuted

                                MouseArea {
                                    id: powerArea
                                    anchors.fill: parent
                                    anchors.margins: -8
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: powerOffProc.running = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}