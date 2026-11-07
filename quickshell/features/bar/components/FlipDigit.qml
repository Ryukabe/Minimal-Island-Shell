// features/bar/components/FlipDigit.qml — one character of the flip clock.
// A digit that changes flips like a split-flap card: the top half of the old digit folds down, then the
// bottom half of the new digit opens. A character that is not a digit (":" or the AM/PM letters) is just drawn.
import QtQuick
import "../../../core/shell"
import "../../../core/styles"

Item {
    id: root

    property string value: ""
    property bool animate: true
    property bool cards: true
    property int durationMs: 420
    property color textColor: Colors.fg
    property string fontFamily: Fonts.display
    property real pixelSize: Dimens.fontSizeBase
    property int fontWeight: 700

    readonly property bool isDigit: /^[0-9]$/.test(root.value)

    // What the layers show: the new digit, and the old one while a flip is running.
    // Set in code (not bound to `value`) so the old value is still there when `value` changes.
    property string _new: ""
    property string _old: ""
    property bool _flipping: false
    property real _fold: 0      // 0..1: the old top half folding away
    property real _unfold: 0    // 0..1: the new bottom half opening

    // Every digit takes the width of "0", so cards never change size.
    Text {
        id: probe
        visible: false
        text: root.isDigit ? "0" : root.value
        font.family: root.fontFamily
        font.pixelSize: root.pixelSize
        font.weight: root.fontWeight
    }

    readonly property real cardWidth: Math.ceil(probe.implicitWidth) + (root.cards && root.isDigit ? 8 : 0)
    readonly property real cardHeight: Math.ceil(probe.implicitHeight) + (root.cards ? 4 : 0)

    implicitWidth: root.cardWidth
    implicitHeight: root.cardHeight

    Component.onCompleted: {
        root._new = root.value
        root._old = root.value
    }

    onValueChanged: {
        anim.stop()
        const shown = root._new
        if (!root.animate || !root.isDigit || root.durationMs <= 0 || shown === "" || shown === root.value) {
            root._old = root.value
            root._new = root.value
            root._flipping = false
            root._fold = 0
            root._unfold = 0
            return
        }
        root._old = shown
        root._new = root.value
        root._fold = 0
        root._unfold = 0
        root._flipping = true
        anim.restart()
    }

    SequentialAnimation {
        id: anim

        NumberAnimation {
            target: root; property: "_fold"
            from: 0; to: 1
            duration: root.durationMs * 0.45
            easing.type: Easing.InQuad
        }
        NumberAnimation {
            target: root; property: "_unfold"
            from: 0; to: 1
            duration: root.durationMs * 0.55
            easing.type: Easing.OutBack
            easing.overshoot: 0.9
        }
        ScriptAction {
            script: {
                root._old = root._new
                root._flipping = false
            }
        }
    }

    // Card background.
    Rectangle {
        anchors.fill: parent
        visible: root.cards && root.isDigit
        radius: 4
        color: Colors.elevatedBg
    }

    // New digit, top half: uncovered while the old top half folds away.
    FlipHalf {
        glyph: root._new
        cardWidth: root.cardWidth; cardHeight: root.cardHeight
        textColor: root.textColor; fontFamily: root.fontFamily
        pixelSize: root.pixelSize; fontWeight: root.fontWeight
    }

    // Old digit, bottom half: stays until the new bottom half opens over it.
    FlipHalf {
        lowerHalf: true
        glyph: root._old
        cardWidth: root.cardWidth; cardHeight: root.cardHeight
        textColor: root.textColor; fontFamily: root.fontFamily
        pixelSize: root.pixelSize; fontWeight: root.fontWeight
    }

    // Old digit, top half folding down (first part of the flip).
    FlipHalf {
        visible: root._flipping && root._fold < 1
        glyph: root._old
        shade: root._fold
        cardWidth: root.cardWidth; cardHeight: root.cardHeight
        textColor: root.textColor; fontFamily: root.fontFamily
        pixelSize: root.pixelSize; fontWeight: root.fontWeight
        transform: Scale { origin.y: root.cardHeight / 2; yScale: 1 - root._fold }
    }

    // New digit, bottom half opening (second part of the flip).
    FlipHalf {
        visible: root._flipping && root._fold >= 1
        lowerHalf: true
        glyph: root._new
        shade: 1 - root._unfold
        cardWidth: root.cardWidth; cardHeight: root.cardHeight
        textColor: root.textColor; fontFamily: root.fontFamily
        pixelSize: root.pixelSize; fontWeight: root.fontWeight
        transform: Scale { origin.y: 0; yScale: root._unfold }
    }

    // The centre line of the card.
    Rectangle {
        visible: root.cards && root.isDigit
        anchors.left: parent.left
        anchors.right: parent.right
        y: root.cardHeight / 2 - 0.5
        height: 1
        color: Qt.rgba(0, 0, 0, 0.4)
    }
}