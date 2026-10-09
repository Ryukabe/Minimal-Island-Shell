pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../../styles"
import "../../../services"

Item {
    id: root
    implicitWidth: 380
    implicitHeight: 220

    signal backRequested()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: Dimens.spacingLg

        RowLayout {
            spacing: Dimens.spacingSm

            Text {
                text: "arrow_back"
                font.family: Fonts.icon
                font.pixelSize: Dimens.fontSizeLg
                font.variableAxes: Fonts.iconAxes
                color: backMouse.containsMouse ? Colors.accent : Colors.fg

                MouseArea {
                    id: backMouse
                    anchors.fill: parent
                    anchors.margins: -8
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.backRequested()
                }
            }

            Text {
                text: "Brightness"
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeLg
                font.bold: true
                color: Colors.fg
            }
        }

        Item { Layout.fillHeight: true }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: BrightnessService.percent + "%"
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeMassive
            font.bold: true
            color: Colors.fg
        }

        Rectangle {
            id: track
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            radius: Dimens.radiusFull
            color: Colors.mainBgMica
            border.width: 1
            border.color: Colors.border

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                radius: parent.radius
                width: Math.max(height, parent.width * (BrightnessService.percent / 100))
                color: Colors.accent
                Behavior on width { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                function updatePct(x) {
                    var pct = Math.max(0, Math.min(100, Math.round((x / track.width) * 100)))
                    BrightnessService.setPercent(pct)
                }
                onPressed: (mouse) => updatePct(mouse.x)
                onPositionChanged: (mouse) => { if (pressed) updatePct(mouse.x) }
            }
        }

        Item { Layout.fillHeight: true }
    }
}