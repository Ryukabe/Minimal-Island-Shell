// components/NotificationStylePicker.qml — "Notification popup style": three mock-up cards in the style of
// Windows 11's Taskbar position picker. The mock-ups are static drawings, not live previews.
import QtQuick
import QtQuick.Layouts
import "../../../core/styles"
import "../../../core/shell"

Item {
    id: root

    property bool showDivider: true

    Layout.fillWidth: true
    implicitHeight: column.implicitHeight + Dimens.paddingMedium * 2

    // ---- Building blocks for the mock-ups ----
    component MockWallpaper: Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.darker(Colors.accent, 2.4) }
            GradientStop { position: 1.0; color: Colors.bg }
        }
    }

    component MockLine: Rectangle {
        height: 3
        radius: 1.5
        color: Colors.fg
        opacity: 0.55
    }

    component MockButton: Rectangle {
        property bool primary: false
        height: 8
        radius: 4
        color: primary ? Colors.accent : Colors.fg
        opacity: primary ? 0.95 : 0.3
    }

    ColumnLayout {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Dimens.paddingMedium
        spacing: Dimens.spacingMedium

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: "Notification popup style"
                color: Colors.fg
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeBase
            }

            Text {
                Layout.fillWidth: true
                text: "Choose how notification popups look on the island"
                color: Colors.fgMuted
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeSm
                wrapMode: Text.WordWrap
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Dimens.spacingMedium

            // Compact: the small pill with a bell and the title
            PreviewCard {
                Layout.fillWidth: true
                label: "Compact"
                selected: ShellState.notificationPopupStyle === "Compact"
                onClicked: ShellState.notificationPopupStyle = "Compact"

                MockWallpaper {}

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 6
                    width: 62
                    height: 12
                    radius: 6
                    color: Colors.mainBgMica

                    Rectangle {
                        x: 6
                        anchors.verticalCenter: parent.verticalCenter
                        width: 5
                        height: 5
                        radius: 2.5
                        color: Colors.accent
                    }

                    MockLine {
                        x: 16
                        anchors.verticalCenter: parent.verticalCenter
                        width: 38
                    }
                }
            }

            // Detailed: a bigger card with the app, the time, the title and the message
            PreviewCard {
                Layout.fillWidth: true
                label: "Detailed"
                selected: ShellState.notificationPopupStyle === "Detailed"
                onClicked: ShellState.notificationPopupStyle = "Detailed"

                MockWallpaper {}

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 6
                    width: 98
                    height: 52
                    radius: 8
                    color: Colors.mainBgMica

                    Rectangle { x: 7; y: 7; width: 10; height: 10; radius: 3; color: Colors.accent }
                    MockLine { x: 21; y: 10; width: 30; opacity: 0.35 }
                    MockLine { x: 72; y: 10; width: 18; opacity: 0.25 }
                    MockLine { x: 7; y: 24; width: 64 }
                    MockLine { x: 7; y: 33; width: 84; opacity: 0.35 }
                    MockLine { x: 7; y: 39; width: 72; opacity: 0.35 }
                    MockLine { x: 7; y: 45; width: 50; opacity: 0.35 }
                }
            }

            // Interactive: the app's own buttons plus Snooze and Dismiss
            PreviewCard {
                Layout.fillWidth: true
                label: "Interactive"
                selected: ShellState.notificationPopupStyle === "Interactive"
                onClicked: ShellState.notificationPopupStyle = "Interactive"

                MockWallpaper {}

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 6
                    width: 98
                    height: 48
                    radius: 8
                    color: Colors.mainBgMica

                    Rectangle { x: 7; y: 7; width: 10; height: 10; radius: 3; color: Colors.accent }
                    MockLine { x: 21; y: 10; width: 30; opacity: 0.35 }
                    MockLine { x: 7; y: 22; width: 64 }
                    MockButton { x: 7; y: 33; width: 26; primary: true }
                    MockButton { x: 37; y: 33; width: 24 }
                    MockButton { x: 65; y: 33; width: 24 }
                }
            }
        }
    }

    Rectangle {
        visible: root.showDivider
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Dimens.paddingMedium
        anchors.rightMargin: Dimens.paddingMedium
        height: 1
        color: Colors.border
        opacity: 0.35
    }
}