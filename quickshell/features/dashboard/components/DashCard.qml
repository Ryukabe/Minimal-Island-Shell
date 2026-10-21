// Shared card body for every Dashboard component. Children go inside the content area.
import QtQuick
import "../../../core/styles"

Rectangle {
    id: card

    default property alias content: body.data

    radius: Dimens.radiusCard
    color: Colors.subBgMica
    clip: true

    Item {
        id: body
        anchors.fill: parent
    }

    // Border sits above everything so blurred backgrounds cannot cover it.
    Rectangle {
        anchors.fill: parent
        radius: card.radius
        color: "transparent"
        border.width: 1
        border.color: Colors.border
        z: 10
    }
}