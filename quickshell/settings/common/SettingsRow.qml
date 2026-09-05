import QtQuick
import QtQuick.Layouts
import "../../styles"

Item {
    id: root
    property string label: ""
    property string value: ""
    property bool showChevron: false
    property bool showDivider: true
    signal clicked()

    Layout.fillWidth: true
    implicitHeight: 44

    MouseArea {
        anchors.fill: parent
        enabled: root.showChevron
        cursorShape: root.showChevron ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }

    RowLayout {
        anchors.fill: parent
        spacing: Dimens.spacingSmall

        Text {
            text: root.label
            color: Colors.fg
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeBase
            Layout.fillWidth: true
        }

        Text {
            text: root.value
            color: Colors.subtext
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeBase
        }

        Text {
            visible: root.showChevron
            text: "chevron_right"
            color: Colors.subtext
            font.family: Fonts.icon
            font.variableAxes: Fonts.iconAxes
            font.pixelSize: Dimens.fontSizeMd
        }
    }

    Rectangle {
        visible: root.showDivider
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: Colors.border
        opacity: 0.35
    }
}