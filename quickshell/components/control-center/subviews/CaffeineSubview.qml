import QtQuick
import QtQuick.Layouts
import "../../../styles"
import "../../../services"

Item {
    id: root
    implicitWidth: 340
    implicitHeight: 280

    signal backRequested()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        // ---- Header with Back Button ----
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Text {
                text: "arrow_back"
                font.family: Fonts.icon
                font.pixelSize: Dimens.fontSizeLg
                color: Colors.fg
                Layout.alignment: Qt.AlignVCenter

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -8
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.backRequested()
                }
            }

            Text {
                text: "Caffeine Settings"
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSize15
                font.bold: true
                color: Colors.fg
                Layout.alignment: Qt.AlignVCenter
            }
        }

        // ---- Status Card ----
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 64
            radius: Dimens.radiusMediumLarge
            color: Colors.subBgMica
            border.width: 1
            border.color: Colors.border

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12

                Text {
                    text: "coffee"
                    font.family: Fonts.icon
                    font.pixelSize: Dimens.fontSizeXl
                    color: CaffeineService.enabled ? Colors.accent : Colors.fgMuted
                    Layout.alignment: Qt.AlignVCenter
                }

                Column {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 2

                    Text {
                        text: CaffeineService.enabled ? "Inhibit Active" : "Inhibit Disabled"
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeSm
                        font.bold: true
                        color: Colors.fg
                    }

                    Text {
                        text: CaffeineService.enabled ? "System sleeping & lid lock prevented" : "Normal power saving active"
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeXs
                        color: Colors.fgMuted
                    }
                }

                // Main Switch Toggle
                Rectangle {
                    width: 44
                    height: 24
                    radius: 12
                    color: CaffeineService.enabled ? Colors.accent : Colors.bgSurface
                    border.width: 1
                    border.color: Colors.border

                    Behavior on color { ColorAnimation { duration: 150 } }

                    Rectangle {
                        width: 18
                        height: 18
                        radius: 9
                        color: Colors.fg
                        anchors.verticalCenter: parent.verticalCenter
                        x: CaffeineService.enabled ? parent.width - width - 3 : 3

                        Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: CaffeineService.toggle()
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}