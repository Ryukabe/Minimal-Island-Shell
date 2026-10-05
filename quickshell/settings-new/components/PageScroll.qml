// components/PageScroll.qml — scrolling page body. Children go into a ColumnLayout.
// The root is a plain Item (not the Flickable) so layouts can size it safely.
import QtQuick
import QtQuick.Layouts
import "../../styles"

Item {
    id: root

    default property alias content: column.data
    property real contentSpacing: Dimens.spacingMedium

    Flickable {
        id: flick
        anchors.fill: parent
        contentWidth: width
        contentHeight: column.implicitHeight + Dimens.paddingLarge
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: column
            width: flick.width
            spacing: root.contentSpacing
        }
    }
}
