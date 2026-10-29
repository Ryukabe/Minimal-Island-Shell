// components/CatalogChip.qml — one item in an "Add ..." catalogue.
// Press and drag it into the layout (the page's CatalogDrag does the rest). Tap adds it too, unless the
// page turns that off with tapToAdd: false. An optional icon sits before the name.
import QtQuick
import "../../../core/shell"
import "../../../core/styles"

Rectangle {
    id: root

    // What it adds (the layout service's type id) and what it says.
    property string typeId: ""
    property string label: ""
    property string icon: ""
    // Off = drag only (the Bar page).
    property bool tapToAdd: true
    // The page's CatalogDrag.
    property var controller: null

    signal activated()

    readonly property bool lit: hover.hovered || dragger.active

    implicitWidth: content.implicitWidth + Dimens.paddingLarge
    implicitHeight: 34
    radius: Dimens.radiusChip
    color: root.lit ? Colors.accent : Colors.elevatedBg
    // The chip stays put (dimmed) while its ghost travels with the pointer.
    opacity: dragger.active ? 0.5 : 1.0

    Behavior on color {
        ColorAnimation { duration: ShellState.motionDuration(Motion.hoverMs) }
    }

    Row {
        id: content
        anchors.centerIn: parent
        spacing: 6

        SymbolIcon {
            visible: root.icon !== ""
            name: root.icon
            size: Dimens.fontSizeSm + 2
            color: root.lit ? Colors.mainBgMica : Colors.fg
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: chipLabel
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            color: root.lit ? Colors.mainBgMica : Colors.fg
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeSm
        }
    }

    HoverHandler {
        id: hover
        cursorShape: root.tapToAdd ? Qt.PointingHandCursor : Qt.OpenHandCursor
    }

    TapHandler {
        enabled: root.tapToAdd
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
