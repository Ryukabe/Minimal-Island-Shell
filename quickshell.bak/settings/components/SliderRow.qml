// components/SliderRow.qml — label, live value readout and a draggable pill slider.
// `value` is only displayed; the page writes the new value in onMoved, so there is one source of truth.
import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../../services"

Item {
    id: root

    property string label: ""
    property string description: ""
    property real from: 0
    property real to: 100
    property real stepSize: 1
    property real value: 0
    property string unit: ""
    property bool placeholder: false
    property bool showDivider: true
    signal moved(real value)

    readonly property real _ratio: root.to > root.from
        ? Math.max(0, Math.min(1, (root.value - root.from) / (root.to - root.from)))
        : 0

    Layout.fillWidth: true
    implicitHeight: root.description !== "" ? 86 : 72
    enabled: !root.placeholder
    opacity: root.enabled ? 1.0 : 0.4

    Behavior on opacity {
        NumberAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
    }

    function _setFromX(mouseX) {
        const usable = trackArea.width - handle.width
        if (usable <= 0) return
        const r = Math.max(0, Math.min(1, (mouseX - handle.width / 2) / usable))
        let v = root.from + r * (root.to - root.from)
        if (root.stepSize > 0) {
            v = root.from + Math.round((v - root.from) / root.stepSize) * root.stepSize
        }
        v = Math.max(root.from, Math.min(root.to, v))
        if (v !== root.value) root.moved(v)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: Dimens.paddingMedium
        anchors.rightMargin: Dimens.paddingMedium
        anchors.topMargin: Dimens.paddingSmall
        anchors.bottomMargin: Dimens.paddingSmall
        spacing: Dimens.spacingSmall

        RowLayout {
            Layout.fillWidth: true
            spacing: Dimens.spacingSmall

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    text: root.label
                    color: Colors.fg
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeBase
                    elide: Text.ElideRight
                }

                Text {
                    visible: root.description !== ""
                    Layout.fillWidth: true
                    text: root.description
                    color: Colors.subtext
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeXs
                    elide: Text.ElideRight
                }
            }

            ComingSoonTag {
                visible: root.placeholder
            }

            Text {
                text: (Math.round(root.value * 100) / 100) + root.unit
                color: Colors.subtext
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeBase
            }
        }

        Item {
            id: trackArea
            Layout.fillWidth: true
            Layout.preferredHeight: 20

            Rectangle {
                id: track
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                height: 6
                radius: 3
                color: Colors.elevatedBg
                border.color: Colors.border
                border.width: 1
            }

            Rectangle {
                anchors.left: track.left
                anchors.verticalCenter: track.verticalCenter
                height: track.height
                radius: track.radius
                width: handle.x + handle.width / 2
                color: Colors.accent
            }

            Rectangle {
                id: handle
                width: 16
                height: 16
                radius: 8
                anchors.verticalCenter: parent.verticalCenter
                x: root._ratio * (trackArea.width - width)
                color: Colors.fg
                border.color: Colors.accent
                border.width: 2
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                preventStealing: true
                onPressed: (mouse) => root._setFromX(mouse.x)
                onPositionChanged: (mouse) => { if (pressed) root._setFromX(mouse.x) }
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
