// features/bar/components/ClockItemPreview.qml — how one clock item looks on the bar. The layout editor in
// Settings uses it so the row shows the real look instead of names. Items that normally hide until they have
// something to show (visualizer, timer, the dots) are drawn as if active.
import QtQuick
import "../../../core/shell"
import "../../../core/styles"

Item {
    id: root

    property string type: ""
    // Time source for the time and date items.
    property var now: new Date()

    implicitWidth: content.item ? Math.max(content.item.implicitWidth, content.item.width) : 0
    implicitHeight: content.item ? Math.max(content.item.implicitHeight, content.item.height) : 0
    width: implicitWidth
    height: implicitHeight

    Loader {
        id: content
        anchors.centerIn: parent
        sourceComponent: {
            switch (root.type) {
            case "workspaces": return workspacesLook
            case "visualizer": return visualizerLook
            case "date": return dateLook
            case "time": return timeLook
            case "timer": return timerLook
            case "privacy": return privacyLook
            case "recording": return recordingLook
            default: return null
            }
        }
    }

    // The workspace pill follows the Workspaces settings (count, dot size, active capsule, accent).
    Component {
        id: workspacesLook

        Row {
            spacing: 5

            Repeater {
                model: ShellState.workspaceShownCount

                delegate: Rectangle {
                    id: dot
                    required property int index
                    readonly property bool active: dot.index === Math.min(2, ShellState.workspaceShownCount - 1)

                    width: (dot.active && ShellState.workspaceActiveIndicator)
                        ? ShellState.workspaceActiveWidth : ShellState.workspaceDotSize
                    height: ShellState.workspaceDotSize
                    radius: height / 2
                    color: dot.active ? (ShellState.workspaceUseAccent ? Colors.accent : Colors.fg) : Colors.fgMuted
                    opacity: dot.active ? 1.0 : 0.55
                }
            }
        }
    }

    Component {
        id: visualizerLook

        ClockVisualizer {
            running: root.visible
        }
    }

    Component {
        id: dateLook

        Text {
            text: Qt.formatDateTime(root.now, ShellState.clockDateFormat)
            color: Colors.fgMuted
            font {
                family: Fonts.display
                pixelSize: Dimens.fontSizeBase
                weight: 500
            }
        }
    }

    Component {
        id: timeLook

        Text {
            text: Qt.formatDateTime(root.now, ShellState.clockTimeFormat)
            color: Colors.fg
            font {
                family: Fonts.display
                pixelSize: Dimens.fontSizeBase
                weight: 700
            }
        }
    }

    Component {
        id: timerLook

        Text {
            text: "timer"
            font.family: Fonts.icon
            font.pixelSize: Dimens.fontSizeMd
            color: Colors.accent
        }
    }

    // Camera = green, microphone = yellow; the camera wins when both are on.
    Component {
        id: privacyLook

        Item {
            implicitWidth: 6
            implicitHeight: 6

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: Colors.green
            }
        }
    }

    Component {
        id: recordingLook

        Item {
            implicitWidth: 6
            implicitHeight: 6

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: Colors.red
            }
        }
    }
}
