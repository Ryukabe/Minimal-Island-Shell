// settings/components/SettingsSegmentedRow.qml — label + capsule segmented control with a sliding highlight.
// Currently used for Icon Style, Main Modifier Key, and Power Profile; reusable for any future exclusive-choice row.
// Pass `icons` (array parallel to `options`, same length, glyph string per option) to get
// icon+label on the selected segment and icon-only on the rest, matching the morphing-pill
// reference. Leave `icons` empty (default) and every segment just stays label-only, which is
// what both current call sites (Main Modifier Key, Power Profile) get with zero changes needed.
import QtQuick
import QtQuick.Layouts
import "../../styles"

RowLayout {
    id: root

    property string label: ""
    property var options: []
    property var icons: []
    property string selectedValue: ""

    signal optionSelected(string value)

    Layout.fillWidth: true
    implicitHeight: 36

    // Real rendered geometry of each segment, filled in live by the delegates
    // themselves (via onXChanged/onWidthChanged) so the highlight slides to the
    // segment's *actual* position/width rather than an estimated one.
    property var _segmentGeometry: []

    function _updateGeometry(index, x, width) {
        var geo = root._segmentGeometry.slice()
        geo[index] = { x: x, width: width }
        root._segmentGeometry = geo
        root._syncHighlight()
    }

    function _syncHighlight() {
        var idx = root.options.indexOf(root.selectedValue)
        if (idx < 0 || idx >= root._segmentGeometry.length) return
        var geo = root._segmentGeometry[idx]
        if (!geo) return
        highlightPill.x = segmentRow.x + geo.x
        highlightPill.width = geo.width
    }

    onSelectedValueChanged: root._syncHighlight()

    Text {
        text: root.label
        color: Colors.fg
        font.family: Fonts.text
        font.pixelSize: Dimens.fontSizeBase
        Layout.fillWidth: true
    }

    Rectangle {
        id: track
        implicitWidth: segmentRow.implicitWidth + 8
        implicitHeight: 32
        color: Qt.rgba(1, 1, 1, 0.04)
        radius: Dimens.radiusFull
        border.color: "transparent"

        Behavior on implicitWidth {
            NumberAnimation { duration: Motion.selectMs; easing.type: Easing.OutCubic }
        }

        // The single moving "selected" pill - segments themselves stay
        // transparent and just sit wherever this lands.
        Rectangle {
            id: highlightPill
            y: 3
            height: parent.height - 6
            radius: Dimens.radiusFull
            color: Colors.accent

            Behavior on x {
                NumberAnimation { duration: Motion.selectMs; easing.type: Easing.OutCubic }
            }
            Behavior on width {
                NumberAnimation { duration: Motion.selectMs; easing.type: Easing.OutCubic }
            }
        }

        Row {
            id: segmentRow
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 4
            spacing: 2

            Repeater {
                id: repeater
                model: root.options

                delegate: Rectangle {
                    id: seg
                    required property string modelData
                    required property int index

                    property bool isSelected: root.selectedValue === modelData
                    property string iconGlyph: (root.icons.length > index) ? root.icons[index] : ""

                    height: 26
                    width: contentRow.implicitWidth + 20
                    color: "transparent"

                    Behavior on width {
                        NumberAnimation { duration: Motion.selectMs; easing.type: Easing.OutCubic }
                    }

                    onXChanged: root._updateGeometry(index, x, width)
                    onWidthChanged: root._updateGeometry(index, x, width)
                    Component.onCompleted: root._updateGeometry(index, x, width)

                    Row {
                        id: contentRow
                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            text: seg.iconGlyph
                            visible: seg.iconGlyph !== ""
                            font.family: Fonts.icon
                            font.pixelSize: Dimens.fontSizeSm
                            color: seg.isSelected ? Colors.black : Colors.subtext
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: seg.modelData
                            visible: seg.isSelected || seg.iconGlyph === ""
                            color: seg.isSelected ? Colors.black : Colors.subtext
                            font.family: Fonts.text
                            font.pixelSize: Dimens.fontSizeSm
                            font.weight: seg.isSelected ? Font.Medium : Font.Normal
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: segMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.optionSelected(seg.modelData)
                    }
                }
            }
        }
    }
}