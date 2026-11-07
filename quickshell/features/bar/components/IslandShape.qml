// features/bar/components/IslandShape.qml — the island's background shape, for every style.
// One path covers both styles: `progress` 0 is the floating island (rounded top corners), 1 is the
// notch (flat top edge with outward flares). Anything in between is a smooth morph, so changing
// style is an animation. A future Bar style adds another parameter to this path, not another shape.
import QtQuick
import QtQuick.Shapes
import "../../../core/shell"
import "../../../core/styles"

Shape {
    id: root

    property real bodyWidth: 160
    property real bodyHeight: 36
    property real topRadius: ShellState.islandCornerRadius
    property real bottomRadius: ShellState.islandCornerRadius
    property real flare: 14
    // 0 = island, 1 = notch. A little above 1 is fine (an overshoot).
    property real progress: 0
    property color fillColor: Colors.mainBgMica

    // The flare and the top corners at this point of the morph.
    readonly property real p: Math.max(0, root.progress)
    readonly property real f: root.p * root.flare
    readonly property real cornerStartX: (1 - root.p) * root.topRadius
    readonly property real cornerEndY: Math.min((1 - root.p) * root.topRadius + root.f,
                                                root.bodyHeight - root.bottomRadius)

    width: root.bodyWidth + root.f * 2
    height: root.bodyHeight

    antialiasing: true
    preferredRendererType: Shape.CurveRenderer

    ShapePath {
        fillColor: root.fillColor
        strokeWidth: -1

        startX: root.cornerStartX
        startY: 0

        // Top-left corner: rounded on the island, a flare on the notch.
        PathQuad { x: root.f; y: root.cornerEndY; controlX: root.f; controlY: 0 }

        // Left edge down to the bottom-left corner.
        PathLine { x: root.f; y: root.bodyHeight - root.bottomRadius }
        PathQuad {
            x: root.f + root.bottomRadius; y: root.bodyHeight
            controlX: root.f; controlY: root.bodyHeight
        }

        // Bottom edge and the bottom-right corner.
        PathLine { x: root.f + root.bodyWidth - root.bottomRadius; y: root.bodyHeight }
        PathQuad {
            x: root.f + root.bodyWidth; y: root.bodyHeight - root.bottomRadius
            controlX: root.f + root.bodyWidth; controlY: root.bodyHeight
        }

        // Right edge up to the top-right corner.
        PathLine { x: root.f + root.bodyWidth; y: root.cornerEndY }
        PathQuad {
            x: root.width - root.cornerStartX; y: 0
            controlX: root.f + root.bodyWidth; controlY: 0
        }

        // Close along the flat top edge.
        PathLine { x: root.cornerStartX; y: 0 }
    }
}