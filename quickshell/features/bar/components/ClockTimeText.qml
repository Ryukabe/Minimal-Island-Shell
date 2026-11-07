// features/bar/components/ClockTimeText.qml — the time on the island: plain text, or one flip-clock card per digit.
import QtQuick
import "../../../core/shell"
import "../../../core/styles"

Item {
    id: root

    property string text: ""
    property bool plain: false      // true: the usual text, no cards
    property bool animate: true
    property bool cards: true
    property int durationMs: 420

    implicitWidth: root.plain ? plainText.implicitWidth : digits.implicitWidth
    implicitHeight: root.plain ? plainText.implicitHeight : digits.implicitHeight

    Text {
        id: plainText
        visible: root.plain
        text: root.text
        color: Colors.fg
        font {
            family: Fonts.display
            pixelSize: Dimens.fontSizeBase
            weight: 700
        }
    }

    Row {
        id: digits
        visible: !root.plain
        spacing: root.cards ? 2 : 0

        Repeater {
            model: root.text.length

            delegate: FlipDigit {
                required property int index

                value: root.text.charAt(index)
                animate: root.animate
                cards: root.cards
                durationMs: root.durationMs
            }
        }
    }
}