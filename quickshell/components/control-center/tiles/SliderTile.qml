import QtQuick
import "../../../styles"
import "../../../services"

Rectangle {
    id: root

    property string iconGlyph: ""
    property real value: 0
    property string label: Math.round(value) + "%"
    property bool iconClickable: false

    signal valueRequested(int percent)
    signal iconClicked()
    signal subviewRequested()

    radius: ShellState.islandCornerRadius
    color: Colors.subBgMica
    border.width: 1
    border.color: Colors.border

    readonly property bool vertical: height > width

    // Square area at the start of the slider where the icon sits.
    // Used ONLY for icon placement, never for the fill length.
    readonly property real iconCell: Math.min(width, height)

    readonly property bool showChevron: !vertical
        && width >= iconCell + percentLabel.implicitWidth + chevron.implicitWidth + Dimens.paddingLarge * 2
    readonly property bool showLabel: vertical
        || width >= iconCell + percentLabel.implicitWidth + Dimens.paddingMedium * 2

    // Animate only value changes, never tile resizes.
    readonly property real _target: Math.max(0, Math.min(1, root.value / 100))
    property real _fraction: _target
    Behavior on _fraction {
        NumberAnimation {
            duration: ShellState.motionDuration(Motion.fadeMs)
            easing.type: Easing.OutCubic
        }
    }

    // Foreground items turn dark when the fill is under them, light when they sit on the empty track.
    readonly property bool iconCovered: (vertical ? fill.height : fill.width)
        >= iconCell / 2 + (vertical ? icon.height : icon.width) / 2
    readonly property bool labelCovered: vertical
        ? fill.height >= root.height - (Dimens.paddingMedium + percentLabel.height / 2)
        : fill.width >= percentLabel.x + percentLabel.width / 2
    readonly property bool chevronCovered: fill.width >= chevron.x + chevron.width / 2

    Rectangle {
        id: fill
        color: Colors.accent
        radius: Math.min(root.radius, Math.min(width, height) / 2)
        width: root.vertical ? root.width : root.width * root._fraction
        height: root.vertical ? root.height * root._fraction : root.height
        x: 0
        y: root.height - height
    }

    // Declared before the icon/chevron so their click areas sit above it.
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        function setFromPosition(mouse) {
            var f = root.vertical ? 1 - mouse.y / root.height : mouse.x / root.width
            root.valueRequested(Math.max(0, Math.min(100, Math.round(f * 100))))
        }
        onPressed: (mouse) => setFromPosition(mouse)
        onPositionChanged: (mouse) => { if (pressed) setFromPosition(mouse) }
    }

    Text {
        id: icon
        text: root.iconGlyph
        font.family: Fonts.icon
        font.pixelSize: Dimens.fontSizeMd
        font.variableAxes: Fonts.iconAxes
        font.features: { "liga": 1, "dlig": 1 }
        color: root.iconCovered ? Colors.subBgMica : Colors.fg
        Behavior on color { ColorAnimation { duration: ShellState.motionDuration(Motion.fadeMs) } }

        x: (root.iconCell - width) / 2
        y: (root.vertical ? root.height - root.iconCell : 0) + (root.iconCell - height) / 2

        MouseArea {
            anchors.fill: parent
            anchors.margins: -Dimens.spacingSmall
            enabled: root.iconClickable
            cursorShape: Qt.PointingHandCursor
            onClicked: root.iconClicked()
        }
    }

    Text {
        id: percentLabel
        visible: root.showLabel
        text: root.label
        font.family: Fonts.text
        font.pixelSize: Dimens.fontSizeSm
        font.weight: Font.DemiBold
        color: root.labelCovered ? Colors.subBgMica : Colors.fg
        Behavior on color { ColorAnimation { duration: ShellState.motionDuration(Motion.fadeMs) } }

        anchors.top: root.vertical ? parent.top : undefined
        anchors.topMargin: Dimens.paddingMedium
        anchors.horizontalCenter: root.vertical ? parent.horizontalCenter : undefined
        anchors.verticalCenter: root.vertical ? undefined : parent.verticalCenter
        anchors.right: root.vertical ? undefined : (root.showChevron ? chevron.left : parent.right)
        anchors.rightMargin: root.showChevron ? Dimens.spacingSmall : Dimens.paddingMedium
    }

    Text {
        id: chevron
        visible: root.showChevron
        text: "chevron_right"
        font.family: Fonts.icon
        font.pixelSize: Dimens.fontSizeMd
        font.variableAxes: Fonts.iconAxes
        color: root.chevronCovered ? Colors.subBgMica : Colors.fgMuted
        opacity: chevronMouse.containsMouse ? 1.0 : 0.7
        anchors.right: parent.right
        anchors.rightMargin: Dimens.paddingMedium
        anchors.verticalCenter: parent.verticalCenter

        MouseArea {
            id: chevronMouse
            anchors.fill: parent
            anchors.margins: -Dimens.spacingSmall
            enabled: root.showChevron
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.subviewRequested()
        }
    }
}