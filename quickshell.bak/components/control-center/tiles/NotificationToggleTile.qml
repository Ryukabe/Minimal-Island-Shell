// components/control-center/tiles/NotificationToggleTile.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../../styles"
import "../../../services"

Rectangle {
    id: tile

    radius: ShellState.islandCornerRadius
    color: Colors.subBgMica
    border.width: 1
    border.color: Colors.border
    clip: true

    readonly property int notifCount: NotificationService.trackedNotifications.values.length

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Dimens.paddingMd
        spacing: Dimens.spacingSm

        Text {
            text: "Notifications"
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeSm
            font.bold: true
            color: Colors.fg
        }

        Text {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: tile.notifCount === 0
            text: "No notifications"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeXSm
            color: Colors.fgMuted
        }

        ListView {
            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: tile.notifCount > 0
            clip: true
            spacing: Dimens.spacingSm
            model: NotificationService.trackedNotifications
            ScrollBar.vertical: ScrollBar {}

            delegate: Rectangle {
                id: row
                required property var modelData

                width: list.width
                height: rowContent.implicitHeight + Dimens.paddingSm * 2
                radius: Dimens.nestedRadius(ShellState.islandCornerRadius, Dimens.paddingSmall)
                color: Colors.mainBgMica

                RowLayout {
                    id: rowContent
                    anchors.fill: parent
                    anchors.margins: Dimens.paddingSm
                    spacing: Dimens.spacingSm

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            Layout.fillWidth: true
                            text: row.modelData.appName + ": " + row.modelData.summary
                            font.family: Fonts.text
                            font.pixelSize: Dimens.fontSizeXSm
                            font.bold: true
                            color: Colors.fg
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: row.modelData.body !== ""
                            text: row.modelData.body
                            font.family: Fonts.text
                            font.pixelSize: Dimens.fontSizeXs
                            color: Colors.fgMuted
                            elide: Text.ElideRight
                            maximumLineCount: 2
                            wrapMode: Text.Wrap
                        }
                    }

                    Text {
                        text: "close"
                        font.family: Fonts.icon
                        font.pixelSize: Dimens.fontSizeMd
                        font.variableAxes: Fonts.iconAxes
                        color: closeMouse.containsMouse ? Colors.accent : Colors.fgMuted

                        MouseArea {
                            id: closeMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: row.modelData.dismiss()
                        }
                    }
                }
            }
        }
    }
}