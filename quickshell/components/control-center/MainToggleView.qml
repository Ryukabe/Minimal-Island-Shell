pragma ComponentBehavior: Bound

import QtQuick
import "../../styles"
import "../../services"
import "../common"

Item {
    id: root
    implicitWidth: 580
    implicitHeight: Math.min(contentColumn.implicitHeight + 32, 640)

    signal openWifi()
    signal openBluetooth()
    signal openFocus()
    signal openPowerProfile()
    signal openCaffeine()
    
    Column {
        id: contentColumn
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 16
        spacing: 16

        // ---- Header ----
        Item {
            id: headerRow
            width: parent.width
            height: 28

            Text {
                text: "Control Center"
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSize15
                font.bold: true
                color: Colors.fg
                anchors.centerIn: parent
            }
        }

        // ---- Paged toggle grid ----
        TogglePager {
            id: togglePager
            width: parent.width
            onOpenWifi: root.openWifi()
            onOpenBluetooth: root.openBluetooth()
            onOpenFocus: root.openFocus()
            onOpenPowerProfile: root.openPowerProfile()
            onOpenCaffeine: root.openCaffeine()
        }

        // ---- Volume slider ----
        Rectangle {
            id: volumeSlider
            width: parent.width
            height: 48
            radius: height / 2
            color: Colors.bgSurfaceMica
            border.width: 1
            border.color: Colors.border

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                radius: parent.radius
                width: Math.max(height, parent.width * (VolumeService.muted ? 0 : VolumeService.percent / 100))
                color: Colors.accent
                Behavior on width { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
            }

            Text {
                text: VolumeService.muted ? "volume_off" : "volume_up"
                font.family: Fonts.icon
                font.pixelSize: Dimens.fontSizeMd
                font.variableAxes: Fonts.iconAxes
                font.features: { "liga": 1, "dlig": 1 }
                color: Colors.fg
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -8
                    cursorShape: Qt.PointingHandCursor
                    onClicked: VolumeService.toggleMute()
                }
            }

            Text {
                text: VolumeService.muted ? "Muted" : VolumeService.percent + "%"
                font.pixelSize: Dimens.fontSizeSm
                font.weight: Font.DemiBold
                color: Colors.fg
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                function updatePct(x) {
                    var pct = Math.max(0, Math.min(100, Math.round((x / width) * 100)))
                    VolumeService.setPercent(pct)
                }
                onPressed: (mouse) => updatePct(mouse.x)
                onPositionChanged: (mouse) => { if (pressed) updatePct(mouse.x) }
            }
        }

        // ---- Brightness slider ----
        Rectangle {
            id: brightnessSlider
            width: parent.width
            height: 48
            radius: height / 2
            color: Colors.bgSurfaceMica
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

            Text {
                text: "light_mode"
                font.family: Fonts.icon
                font.pixelSize: Dimens.fontSizeMd
                font.variableAxes: Fonts.iconAxes
                font.features: { "liga": 1, "dlig": 1 }
                color: Colors.fg
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: BrightnessService.percent + "%"
                font.pixelSize: Dimens.fontSizeSm
                font.weight: Font.DemiBold
                color: Colors.fg
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                function updatePct(x) {
                    var pct = Math.max(0, Math.min(100, Math.round((x / width) * 100)))
                    BrightnessService.setPercent(pct)
                }
                onPressed: (mouse) => updatePct(mouse.x)
                onPositionChanged: (mouse) => { if (pressed) updatePct(mouse.x) }
            }
        }
    }
}