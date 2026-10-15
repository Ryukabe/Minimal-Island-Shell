// components/CardCarousel.qml — horizontally scrolling row of cards (themes, wallpapers, presets).
// Give it a `model` and a `cardDelegate` Component; the delegate gets modelData and index.
// `currentIndex` is the card the user last clicked (-1 = none), for the selected outline.
import QtQuick
import QtQuick.Layouts
import "../../styles"

Flickable {
    id: root

    property var model: []
    property Component cardDelegate: null
    property int currentIndex: -1

    Layout.fillWidth: true
    implicitHeight: cardRow.height
    contentWidth: cardRow.width
    contentHeight: cardRow.height
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    flickableDirection: Flickable.HorizontalFlick

    Row {
        id: cardRow
        spacing: Dimens.spacingMedium

        Repeater {
            model: root.model
            delegate: root.cardDelegate
        }
    }
}
