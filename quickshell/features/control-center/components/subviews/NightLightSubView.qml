pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../../../core/shell"
import "../../../../core/styles"
import "../../../display"

Item {
    id: root
    implicitWidth: 380
    implicitHeight: 260

    signal backRequested()

    readonly property real fraction: NightLightService.maxTemperature > NightLightService.minTemperature
        ? Math.max(0, Math.min(1, (NightLightService.temperature - NightLightService.minTemperature)
            / (NightLightService.maxTemperature - NightLightService.minTemperature)))
        : 0

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: Dimens.spacingLg

        RowLayout {
            Layout.fillWidth: true
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
                text: "Night Light"
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeLg
                font.bold: true
                color: Colors.fg
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                id: powerPill
                implicitWidth: powerLabel.implicitWidth + Dimens.paddingLarge
                implicitHeight: 30
                radius: Dimens.radiusChip
                color: NightLightService.enabled ? Colors.accent : Colors.elevatedBg

                Behavior on color { ColorAnimation { duration: ShellState.motionDuration(Motion.fadeMs) } }

                Text {
                    id: powerLabel
                    anchors.centerIn: parent
                    text: NightLightService.enabled ? "On" : "Off"
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeSm
                    color: NightLightService.enabled ? Colors.mainBgMica : Colors.fg
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: NightLightService.toggle()
                }
            }
        }

        Item { Layout.fillHeight: true }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: NightLightService.temperature + "K"
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
                width: Math.max(height, parent.width * root.fraction)
                color: Colors.accent
                Behavior on width {
                    NumberAnimation {
                        duration: ShellState.motionDuration(Motion.fadeMs)
                        easing.type: Easing.OutCubic
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                preventStealing: true

                function updateFromX(x) {
                    const f = Math.max(0, Math.min(1, x / track.width))
                    const k = NightLightService.minTemperature
                        + f * (NightLightService.maxTemperature - NightLightService.minTemperature)
                    NightLightService.setTemperature(k)
                }
                onPressed: (mouse) => updateFromX(mouse.x)
                onPositionChanged: (mouse) => { if (pressed) updateFromX(mouse.x) }
            }
        }

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "Warm"
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeXSm
                color: Colors.fgMuted
            }

            Item { Layout.fillWidth: true }

            Text {
                text: "Cold"
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeXSm
                color: Colors.fgMuted
            }
        }

        Item { Layout.fillHeight: true }
    }
}