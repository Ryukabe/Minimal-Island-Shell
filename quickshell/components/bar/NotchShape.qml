import QtQuick
import QtQuick.Shapes
import "../../styles"

Shape {
    id: root
    property real notchWidth: 160
    property real notchHeight: 36
    property real bottomRadius: 12
    property real flare: 14
    property color fillColor: Colors.mainBgMica

    width: notchWidth + flare * 2
    height: notchHeight

    ShapePath {
        fillColor: root.fillColor
        strokeWidth: -1

        startX: 0
        startY: 0

        // Top-left flare — smooth outward curve from the screen edge into
        // the notch's left vertical side, instead of a sharp 90° corner.
        PathQuad { x: root.flare; y: root.flare; controlX: root.flare; controlY: 0 }

        // Left vertical edge down to the bottom-left rounded corner.
        PathLine { x: root.flare; y: root.notchHeight - root.bottomRadius }
        PathArc {
            x: root.flare + root.bottomRadius; y: root.notchHeight
            radiusX: root.bottomRadius; radiusY: root.bottomRadius
            direction: PathArc.Clockwise
        }

        // Bottom edge.
        PathLine { x: root.flare + root.notchWidth - root.bottomRadius; y: root.notchHeight }
        PathArc {
            x: root.flare + root.notchWidth; y: root.notchHeight - root.bottomRadius
            radiusX: root.bottomRadius; radiusY: root.bottomRadius
            direction: PathArc.Clockwise
        }

        // Right vertical edge up, then the mirrored top-right flare.
        PathLine { x: root.flare + root.notchWidth; y: root.flare }
        PathQuad { x: root.flare * 2 + root.notchWidth; y: 0; controlX: root.flare + root.notchWidth; controlY: 0 }

        // Close along the flat top edge (flush with the screen edge).
        PathLine { x: 0; y: 0 }
    }
}