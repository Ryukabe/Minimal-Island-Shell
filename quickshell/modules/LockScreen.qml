// modules/LockScreen.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
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
                        errorMessage.text = "incorrect password"
                        errorMessage.visible = true
                        passwordInput.text = ""
                        passwordInput.forceActiveFocus()
                        pam.start()
                    }
                }

                onError: (err) => {
                    errorMessage.text = "pam error"
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
                        visible: !LockScreenSettings.frostedBlurEnabled
                    }

                    FastBlur {
                        anchors.fill: wallpaper
                        source: wallpaper
                        radius: LockScreenSettings.frostedBlurRadius
                        visible: LockScreenSettings.frostedBlurEnabled
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: Colors.darkMode
                            ? Qt.rgba(0, 0, 0, LockScreenSettings.wallpaperDimOpacity)
                            : Qt.rgba(1, 1, 1, LockScreenSettings.wallpaperDimOpacity)
                    }

                    // ---- TOP-LEFT: clock ----
                    Column {
                        id: clockBlock
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.topMargin: parent.height * 0.06
                        anchors.leftMargin: parent.width * 0.05
                        spacing: Dimens.spacingSmall

                        Text {
                            text: Qt.formatDateTime(new Date(), LockScreenSettings.clockFormat24h ? "HH:mm" : "h:mm AP")
                            font.family: Fonts.display
                            font.pixelSize: Dimens.fontSizeDisplay
                            font.weight: Font.Bold
                            color: Colors.fg
                        }

                        Text {
                            visible: LockScreenSettings.showDate
                            text: Qt.formatDateTime(new Date(), "dddd, MMMM d").toUpperCase()
                            font.family: Fonts.text
                            font.pixelSize: Dimens.fontSizeXs
                            font.letterSpacing: 2
                            color: Colors.fgMuted
                        }
                    }

                    // ---- BOTTOM-LEFT: hyprland action ----
                    Text {
                        id: hyprlandBtn
                        visible: LockScreenSettings.showHyprlandAction
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: parent.width * 0.05
                        anchors.bottomMargin: parent.height * 0.06
                        text: "HYPRLAND"
                        font.family: Fonts.mono
                        font.pixelSize: Dimens.fontSizeXs
                        font.letterSpacing: 1.5
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

                    // ---- BOTTOM-RIGHT: identity + password + actions ----
                    ColumnLayout {
                        id: authBlock
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.rightMargin: parent.width * 0.05
                        anchors.bottomMargin: parent.height * 0.06
                        spacing: Dimens.spacingSmall

                        Text {
                            id: usernameLabel
                            Layout.alignment: Qt.AlignRight
                            visible: LockScreenSettings.showUsername
                            text: (Quickshell.env("USER") || Qt.userName || "user").toUpperCase()
                            font.family: Fonts.display
                            font.pixelSize: Dimens.fontSizeMd
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                            rightPadding: -font.letterSpacing / 2
                            color: Colors.fg
                        }

                        Item {
                            id: passwordField
                            Layout.alignment: Qt.AlignRight
                            Layout.topMargin: Dimens.spacingMedium
                            width: 220
                            height: 30

                            Text {
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 8
                                visible: passwordInput.text.length === 0
                                text: LockScreenSettings.passwordPlaceholder.toUpperCase()
                                font.family: Fonts.text
                                font.pixelSize: Dimens.fontSizeXs
                                font.letterSpacing: 1.5
                                color: Colors.fgMuted
                                opacity: 0.7
                            }

                            TextInput {
                                id: passwordInput
                                anchors.left: parent.left
                                anchors.right: submitArrow.left
                                anchors.rightMargin: Dimens.spacingSmall
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 8
                                horizontalAlignment: TextInput.AlignRight
                                echoMode: TextInput.Password
                                passwordCharacter: "•"
                                font.family: Fonts.text
                                font.pixelSize: Dimens.fontSizeSm
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

                            Text {
                                id: submitArrow
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 8
                                text: "➔"
                                font.pixelSize: Dimens.fontSizeSm
                                color: submitArrowArea.pressed ? Colors.accent : Colors.fgMuted
                                opacity: passwordInput.text.length > 0 ? 1.0 : 0.0
                                Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                                MouseArea {
                                    id: submitArrowArea
                                    anchors.fill: parent
                                    anchors.margins: -6
                                    enabled: passwordInput.text.length > 0
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: passwordInput.submitPassword()
                                }
                            }

                            Rectangle {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: 1
                                color: errorMessage.visible
                                    ? (LockScreenSettings.errorUsesAccent ? Colors.accent : Colors.red)
                                    : (passwordInput.activeFocus ? Colors.accent : Colors.border)
                                opacity: passwordInput.activeFocus || errorMessage.visible ? 0.9 : 0.4
                            }
                        }

                        Text {
                            id: errorMessage
                            Layout.alignment: Qt.AlignRight
                            text: "incorrect password"
                            font.family: Fonts.text
                            font.pixelSize: Dimens.fontSizeXs
                            color: LockScreenSettings.errorUsesAccent ? Colors.accent : Colors.red
                            visible: false
                        }

                        Row {
                            Layout.alignment: Qt.AlignRight
                            Layout.topMargin: Dimens.spacingMedium
                            spacing: Dimens.spacingLg

                            Text {
                                id: rebootBtn
                                visible: LockScreenSettings.showRebootAction
                                text: "RESTART"
                                font.family: Fonts.mono
                                font.pixelSize: Dimens.fontSizeXs
                                font.letterSpacing: 1.5
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
                                id: powerBtn
                                visible: LockScreenSettings.showPowerAction
                                text: "SHUT DOWN"
                                font.family: Fonts.mono
                                font.pixelSize: Dimens.fontSizeXs
                                font.letterSpacing: 1.5
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