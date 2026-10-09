// components/bar/EventToast.qml — island page shown by EventToastService
import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../../services"

Item {
    id: root

    implicitWidth: Math.max(ShellState.islandCompactWidth + 5, contentRow.implicitWidth + Dimens.paddingLarge * 2)
    implicitHeight: ShellState.islandCompactHeight

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: Dimens.spacingMedium

        Text {
            text: EventToastService.icon
            font.family: Fonts.icon
            font.pixelSize: Dimens.fontSizeMd
            font.variableAxes: Fonts.iconAxes
            color: Colors.accent
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: EventToastService.title
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeBase
            font.bold: true
            color: Colors.fg
            elide: Text.ElideRight
            Layout.maximumWidth: ShellState.notificationToastMaxWidth
            Layout.alignment: Qt.AlignVCenter
        }
    }
}