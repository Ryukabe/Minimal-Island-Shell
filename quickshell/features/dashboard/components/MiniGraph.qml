import QtQuick
import "../../../core/styles"

Canvas {
    id: root

    property var values: []
    property color lineColor: Colors.accent
    // 0 = scale to the largest value seen
    property real maxValue: 100

    onValuesChanged: requestPaint()
    onLineColorChanged: requestPaint()
    onMaxValueChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    onPaint: {
        var ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)
        var n = root.values.length
        if (n < 2 || width <= 0 || height <= 0) return

        var top = root.maxValue
        if (top <= 0) {
            top = 1
            for (var i = 0; i < n; i++) top = Math.max(top, root.values[i])
        }
        var pad = 2
        function px(idx) { return idx / (n - 1) * width }
        function py(val) { return height - pad - Math.max(0, Math.min(1, val / top)) * (height - pad * 2) }

        ctx.beginPath()
        ctx.moveTo(px(0), py(root.values[0]))
        for (var j = 1; j < n; j++) ctx.lineTo(px(j), py(root.values[j]))
        ctx.lineWidth = 1.5
        ctx.lineJoin = "round"
        ctx.strokeStyle = root.lineColor
        ctx.stroke()

        ctx.lineTo(width, height)
        ctx.lineTo(0, height)
        ctx.closePath()
        ctx.fillStyle = Qt.rgba(root.lineColor.r, root.lineColor.g, root.lineColor.b, 0.15)
        ctx.fill()
    }
}