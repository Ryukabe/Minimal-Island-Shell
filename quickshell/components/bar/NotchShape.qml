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

    antialiasing: true
    preferredRendererType: Shape.CurveRenderer

    ShapePath {
        fillColor: root.fillColor
        strokeWidth: -1

        startX: 0
        startY: 0

        // Top-left flare.
        PathQuad { x: root.flare; y: root.flare; controlX: root.flare; controlY: 0 }

        // Left vertical edge down to the bottom-left corner.
        PathLine { x: root.flare; y: root.notchHeight - root.bottomRadius }

        // Bottom-left rounded corner — control point at the sharp corner
        // itself guarantees a tangent, correctly-curved fillet (no arc
        // direction/large-arc ambiguity like PathArc has).
        PathQuad {
            x: root.flare + root.bottomRadius; y: root.notchHeight
            controlX: root.flare; controlY: root.notchHeight
        }

        // Bottom edge.
        PathLine { x: root.flare + root.notchWidth - root.bottomRadius; y: root.notchHeight }

        // Bottom-right rounded corner, mirrored the same way.
        PathQuad {
            x: root.flare + root.notchWidth; y: root.notchHeight - root.bottomRadius
            controlX: root.flare + root.notchWidth; controlY: root.notchHeight
        }

        // Right vertical edge up, then the mirrored top-right flare.
        PathLine { x: root.flare + root.notchWidth; y: root.flare }
        PathQuad { x: root.flare * 2 + root.notchWidth; y: 0; controlX: root.flare + root.notchWidth; controlY: 0 }

        // Close along the flat top edge.
        PathLine { x: 0; y: 0 }
    }
}