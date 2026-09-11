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
                        shakeAnim.start()
                        pam.start()
                    }
                }

                onError: (err) => {
                    errorMessage.text = "pam error"
                    errorMessage.visible = true
                    passwordInput.text = ""
                    passwordInput.forceActiveFocus()
                    shakeAnim.start()
                    pam.start()
                }
            }

            // System commands
            Process { id: powerOffProc; command: ["systemctl", "poweroff"] }
            Process { id: rebootProc; command: ["systemctl", "reboot"] }
            Process { id: exitHyprlandProc; command: ["hyprctl", "dispatch", "exit"] }

            // ---- ENTRANCE ANIMATION ----
            // Fires once per lock (this component is re-created every time
            // the surface locks). Staggers a soft fade+slide-up on the
            // clock, hyprland action, and identity/password block, plus a
            // slow Ken-Burns-style zoom-fade on the wallpaper itself.
            // Respects ShellState.motionReduced via motionDuration() —
            // durations collapse to 0 (i.e. instant) when reduced motion
            // is on, same convention as the rest of the shell.
            ParallelAnimation {
                id: entranceAnim

                NumberAnimation {
                    target: wallpaperScale
                    property: "xScale"
                    from: 1.06; to: 1.0
                    duration: ShellState.motionDuration(1400)
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: wallpaperScale
                    property: "yScale"
                    from: 1.06; to: 1.0
                    duration: ShellState.motionDuration(1400)
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: wallpaperFade
                    property: "opacity"
                    from: 0; to: 1
                    duration: ShellState.motionDuration(500)
                    easing.type: Easing.OutCubic
                }

                SequentialAnimation {
                    PauseAnimation { duration: ShellState.motionDuration(120) }
                    ParallelAnimation {
                        NumberAnimation {
                            target: clockBlock
                            property: "opacity"
                            from: 0; to: 1
                            duration: ShellState.motionDuration(420)
                            easing.type: Easing.OutCubic
                        }
                        NumberAnimation {
                            target: clockBlockTranslate
                            property: "y"
                            from: 18; to: 0
                            duration: ShellState.motionDuration(520)
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                SequentialAnimation {
                    PauseAnimation { duration: ShellState.motionDuration(220) }
                    ParallelAnimation {
                        NumberAnimation {
                            target: authBlock
                            property: "opacity"
                            from: 0; to: 1
                            duration: ShellState.motionDuration(420)
                            easing.type: Easing.OutCubic
                        }
                        NumberAnimation {
                            target: authBlockTranslate
                            property: "y"
                            from: 18; to: 0
                            duration: ShellState.motionDuration(520)
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                SequentialAnimation {
                    PauseAnimation { duration: ShellState.motionDuration(320) }
                    NumberAnimation {
                        target: hyprlandBtn
                        property: "opacity"
                        from: 0; to: 1
                        duration: ShellState.motionDuration(400)
                        easing.type: Easing.OutCubic
                    }
                }
            }

            // Wrong-password feedback: a short horizontal shake on the
            // identity/password block. Amplitude tapers off each leg so it
            // reads as a "no" shake rather than a jitter. Triggered from
            // pam.onCompleted (failure branch) and pam.onError above.
            SequentialAnimation {
                id: shakeAnim
                NumberAnimation { target: authBlockShake; property: "x"; to: -10; duration: 45; easing.type: Easing.OutCubic }
                NumberAnimation { target: authBlockShake; property: "x"; to: 8;   duration: 45; easing.type: Easing.OutCubic }
                NumberAnimation { target: authBlockShake; property: "x"; to: -6;  duration: 45; easing.type: Easing.OutCubic }
                NumberAnimation { target: authBlockShake; property: "x"; to: 4;   duration: 45; easing.type: Easing.OutCubic }
                NumberAnimation { target: authBlockShake; property: "x"; to: 0;   duration: 45; easing.type: Easing.OutCubic }
            }

            Component.onCompleted: entranceAnim.start()

            // Background focus handling
            MouseArea {
                anchors.fill: parent
                onClicked: passwordInput.forceActiveFocus()

                Rectangle {
                    anchors.fill: parent
                    color: Colors.mainBgMica

                    Image {
                        id: wallpaper
                        anchors.fill: parent
                        source: WallpaperService.currentWallpaper ? "file://" + WallpaperService.currentWallpaper : ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                        visible: !LockScreenSettings.frostedBlurEnabled
                        opacity: wallpaperFade.opacity

                        transform: Scale {
                            id: wallpaperScale
                            origin.x: wallpaper.width / 2
                            origin.y: wallpaper.height / 2
                            xScale: 1.0
                            yScale: 1.0
                        }
                    }

                    // Dummy opacity holder driven by entranceAnim — kept
                    // separate from wallpaper.opacity's own property so the
                    // animation target stays valid even if
                    // frostedBlurEnabled swaps visibility.
                    Item {
                        id: wallpaperFade
                        opacity: 0
                    }

                    FastBlur {
                        anchors.fill: wallpaper
                        source: wallpaper
                        radius: LockScreenSettings.frostedBlurRadius
                        visible: LockScreenSettings.frostedBlurEnabled
                        opacity: wallpaperFade.opacity
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
                        opacity: 0

                        transform: Translate {
                            id: clockBlockTranslate
                            y: 18
                        }

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
                        opacity: 0

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
                        opacity: 0

                        transform: [
                            Translate { id: authBlockTranslate; y: 18 },
                            Translate { id: authBlockShake; x: 0 }
                        ]

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