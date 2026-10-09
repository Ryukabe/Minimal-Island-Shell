// components/GroupCard.qml — rounded card that stacks rows. Not collapsible: views replace accordions.
import QtQuick
import QtQuick.Layouts
import "../../styles"

Rectangle {
    id: root

    default property alias content: column.data

    Layout.fillWidth: true
    implicitHeight: column.implicitHeight + Dimens.paddingSmall * 2
    radius: Dimens.settingsContainerRadius
    color: Colors.subBgMica
    border.color: Colors.border
    border.width: 1

    ColumnLayout {
        id: column
        anchors.fill: parent
        anchors.margins: Dimens.paddingSmall
        spacing: 0
    }
}
