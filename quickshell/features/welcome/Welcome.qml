// features/welcome/Welcome.qml — one-time welcome window (centered floating window).
// Shown automatically on first run; reopen with: qs ipc call welcome show
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../settings/components"
import "../settings/core"
import "../../core/shell"
import "../../core/styles"

Scope {
    id: root

    // Reading this creates the singleton at shell start, so the first-run check actually runs.
    readonly property bool serviceReady: WelcomeService.ready

    IpcHandler {
        target: "welcome"

        function show(): void { WelcomeService.show() }
        function close(): void { WelcomeService.finish() }
        // Clears the saved flag and shows the screen again (for testing).
        function reset(): void { WelcomeService.reset() }
    }

    FloatingWindow {
        id: window
        title: "Welcome to Panacea"
        visible: WelcomeService.open
        color: Colors.mainBgMica
        implicitWidth: 720
        implicitHeight: 480
        // Fixed size: Hyprland floats windows that cannot be resized.
        minimumSize: Qt.size(720, 480)
        maximumSize: Qt.size(720, 480)

        onVisibleChanged: {
            if (visible) {
                contentRoot.index = 0
                focusDelay.start()
            } else {
                // Closed by the compositor, Escape or Get started: remember it was seen.
                WelcomeService.finish()
            }
        }

        Timer {
            id: focusDelay
            interval: 50
            onTriggered: contentRoot.forceActiveFocus()
        }

        Item {
            id: contentRoot
            anchors.fill: parent
            focus: true

            property int index: 0

            readonly property var pages: [
                {
                    icon: "waving_hand",
                    title: "Welcome to Panacea",
                    body: "Panacea is a desktop shell built around one floating island. It is the clock, the launcher, the media controls, the power menu and more, all in one place that grows when you need it and shrinks back when you don't.",
                    actions: []
                },
                {
                    icon: "touch_app",
                    title: "Meet the island",
                    body: "Click the clock to open the dashboard. Scroll over the top half of the island to change the volume, and over the bottom half to change the brightness. Press Escape at any time to go back to the clock.",
                    actions: []
                },
                {
                    icon: "palette",
                    title: "Make it yours",
                    body: "Pick a theme and a wallpaper and the whole shell follows, along with the apps you've enabled templates for. You can change all of it later.",
                    actions: [
                        { text: "Open theme switcher", kind: "theme" },
                        { text: "Open settings", kind: "settings" }
                    ]
                },
                {
                    icon: "keyboard",
                    title: "Learn the shortcuts",
                    body: "Every shortcut for the launcher, clipboard, control center and the rest is listed in Settings, and you can rebind any of them there.",
                    actions: [
                        { text: "Open keybinds", kind: "keybinds" }
                    ]
                },
                {
                    icon: "rocket_launch",
                    title: "You're all set",
                    body: "That's the tour. You won't see this screen again, but you can bring it back any time with: qs ipc call welcome show",
                    actions: []
                }
            ]

            readonly property var current: pages[index]
            readonly property bool isFirst: index === 0
            readonly property bool isLast: index === pages.length - 1

            function next() {
                if (isLast) WelcomeService.finish()
                else index++
            }

            function back() {
                if (!isFirst) index--
            }

            function run(kind) {
                if (kind === "theme") {
                    ShellState.showPage("theme")
                } else if (kind === "settings") {
                    ShellState.openSettings()
                } else if (kind === "keybinds") {
                    ShellState.openSettings()
                    SettingsNav.openByName("keybinds")
                }
            }

            onIndexChanged: pageFade.restart()

            NumberAnimation {
                id: pageFade
                target: pageContent
                property: "opacity"
                from: 0
                to: 1
                duration: ShellState.motionDuration(Motion.fadeMs)
                easing.type: Easing.OutCubic
            }

            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Right || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    contentRoot.next()
                    event.accepted = true
                } else if (event.key === Qt.Key_Left) {
                    contentRoot.back()
                    event.accepted = true
                } else if (event.key === Qt.Key_Escape) {
                    WelcomeService.finish()
                    event.accepted = true
                }
            }

            // Drag the window by its top edge.
            MouseArea {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: Dimens.paddingLarge * 2
                z: 10
                acceptedButtons: Qt.LeftButton
                onPressed: window.startSystemMove()
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Dimens.paddingLarge * 2
                spacing: Dimens.spacingLarge

                // ── Page ──────────────────────────────────────
                ColumnLayout {
                    id: pageContent
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: Dimens.spacingLarge

                    Item { Layout.fillHeight: true }

                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: Dimens.fontSizeHuge * 2
                        Layout.preferredHeight: Dimens.fontSizeHuge * 2
                        radius: Dimens.radiusFull
                        color: Colors.elevatedBg

                        SymbolIcon {
                            anchors.centerIn: parent
                            name: contentRoot.current.icon
                            size: Dimens.fontSizeXxl
                            color: Colors.accent
                            animated: true
                            playOnLoad: true
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: contentRoot.current.title
                        color: Colors.fg
                        font.family: Fonts.display
                        font.pixelSize: Dimens.fontSizeXxl
                        font.weight: Font.Bold
                        wrapMode: Text.WordWrap
                    }

                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: contentRoot.current.body
                        color: Colors.subtext
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeMd
                        wrapMode: Text.WordWrap
                        lineHeight: 1.2
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: Dimens.spacingMedium
                        visible: contentRoot.current.actions.length > 0

                        Repeater {
                            model: contentRoot.current.actions

                            delegate: ActionButton {
                                required property var modelData
                                text: modelData.text
                                onClicked: contentRoot.run(modelData.kind)
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }
                }

                // ── Footer: back · dots · next ────────────────
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Dimens.spacingMedium

                    Item {
                        Layout.preferredWidth: skipRow.implicitWidth
                        Layout.preferredHeight: skipRow.implicitHeight

                        RowLayout {
                            id: skipRow
                            spacing: Dimens.spacingSmall

                            ActionButton {
                                text: "Back"
                                visible: !contentRoot.isFirst
                                onClicked: contentRoot.back()
                            }

                            ActionButton {
                                text: "Skip"
                                visible: contentRoot.isFirst
                                onClicked: WelcomeService.finish()
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Row {
                        spacing: Dimens.spacingSmall

                        Repeater {
                            model: contentRoot.pages.length

                            delegate: Rectangle {
                                required property int index
                                readonly property bool active: index === contentRoot.index

                                height: Dimens.spacingSmall
                                width: active ? Dimens.paddingLarge : Dimens.spacingSmall
                                radius: Dimens.radiusFull
                                color: active ? Colors.accent : Colors.border

                                Behavior on width {
                                    NumberAnimation {
                                        duration: ShellState.motionDuration(Motion.hoverMs)
                                        easing.type: Easing.OutCubic
                                    }
                                }
                                Behavior on color {
                                    ColorAnimation { duration: ShellState.motionDuration(Motion.hoverMs) }
                                }
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    ActionButton {
                        text: contentRoot.isLast ? "Get started" : "Next"
                        primary: true
                        onClicked: contentRoot.next()
                    }
                }
            }
        }
    }
}