// components/CatalogChip.qml — one item in an "Add ..." catalogue.
// Tap it to add the item, or press and drag it into the layout (the page's CatalogDrag does the rest).
import QtQuick
import "../../../core/shell"
import "../../../core/styles"

Rectangle {
    id: root

    // What it adds (the layout service's type id) and what it says.
    property string typeId: ""
    property string label: ""
    // The page's CatalogDrag.
    property var controller: null

    signal activated()

    implicitWidth: chipLabel.implicitWidth + Dimens.paddingLarge
    implicitHeight: 34
    radius: Dimens.radiusChip
    color: (hover.hovered || dragger.active) ? Colors.accent : Colors.elevatedBg
    // The chip stays put (dimmed) while its ghost travels with the pointer.
    opacity: dragger.active ? 0.5 : 1.0

    Behavior on color {
        ColorAnimation { duration: ShellState.motionDuration(Motion.hoverMs) }
    }

    Text {
        id: chipLabel
        anchors.centerIn: parent
        text: root.label
        color: (hover.hovered || dragger.active) ? Colors.mainBgMica : Colors.fg
        font.family: Fonts.text
        font.pixelSize: Dimens.fontSizeSm
    }

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: root.activated()
    }

    DragHandler {
        id: dragger
        target: null

        onActiveChanged: {
            if (!root.controller) return
            if (active) root.controller.begin(root.typeId, root.label, centroid.scenePosition)
            else root.controller.end(centroid.scenePosition)
        }

        onCentroidChanged: {
            if (active && root.controller) root.controller.move(centroid.scenePosition)
        }
    }
}
