// components/CatalogDrag.qml — the state of one drag from a catalogue chip into a layout.
// Put ONE on a page, give it the page's Flickable and the page item, and hand it to every CatalogChip.
// While a chip is dragged it holds the pointer position (in scene coordinates), draws a small ghost
// under the pointer, and scrolls the page when the pointer nears its top or bottom edge.
// The page reads `active`, `type`, `scenePos` (and `tick`, which also changes while the page scrolls)
// to show where the item would land, and reacts to `dropped` to actually add it.
import QtQuick
import "../../../core/styles"

Item {
    id: root

    // Set by the page.
    property Flickable flickable: null
    property Item viewport: null

    // Drag state.
    property string type: ""
    property string label: ""
    property point scenePos: Qt.point(0, 0)
    // Bumps when the page scrolls under a still pointer, so bindings that map scenePos recompute.
    property int tick: 0
    readonly property bool active: root.type !== ""

    // Emitted once, after the chip is let go. The pointer may be anywhere: the page decides if it is over the layout.
    signal dropped(string type, point scenePos)

    // Takes no room in the page's column.
    visible: false

    function begin(itemType, text, pos) {
        root.label = text
        root.scenePos = pos
        root.type = itemType
    }

    function move(pos) {
        root.scenePos = pos
    }

    function end(pos) {
        const droppedType = root.type
        root.type = ""
        if (droppedType === "") return
        // Deferred: adding to the layout removes the chip that started the drag, which may still be running its handler.
        Qt.callLater(function () { root.dropped(droppedType, pos) })
    }

    // Edge scrolling while a chip is held near the top or bottom of the visible page.
    Timer {
        interval: 16
        repeat: true
        running: root.active && root.flickable !== null && root.viewport !== null
        onTriggered: {
            const p = root.viewport.mapFromItem(null, root.scenePos.x, root.scenePos.y)
            const edge = 56
            let dy = 0
            if (p.y < edge) dy = -Math.ceil((edge - p.y) / 4)
            else if (p.y > root.viewport.height - edge) dy = Math.ceil((p.y - (root.viewport.height - edge)) / 4)
            if (dy === 0) return

            const f = root.flickable
            const maxY = Math.max(0, f.contentHeight - f.height)
            const next = Math.max(0, Math.min(maxY, f.contentY + dy))
            if (next !== f.contentY) {
                f.contentY = next
                root.tick++
            }
        }
    }

    // The ghost follows the pointer. It lives on the window's own content item so no card or scroller clips it.
    Rectangle {
        parent: Window.contentItem
        visible: root.active
        z: 10000
        width: ghostText.implicitWidth + Dimens.paddingLarge
        height: 34
        radius: Dimens.radiusChip
        color: Colors.accent
        opacity: 0.92
        x: root.scenePos.x - width / 2
        y: root.scenePos.y - height - 8

        Text {
            id: ghostText
            anchors.centerIn: parent
            text: root.label
            color: Colors.mainBgMica
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeSm
        }
    }
}
