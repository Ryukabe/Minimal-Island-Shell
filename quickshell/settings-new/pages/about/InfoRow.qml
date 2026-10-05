// pages/about/InfoRow.qml — read-only "label ........ value" row. Give it a `link` to make it clickable.
import QtQuick
import QtQuick.Layouts
import "../../components"
import "../../../styles"
import "../../../services"

Item {
    id: root

    property string label: ""
    property string value: ""
    property string link: ""
    property bool showDivider: true

    Layout.fillWidth: true
    implicitHeight: 44

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: 2
        anchors.bottomMargin: 2
        radius: Dimens.settingsControlRadius
        color: (root.link !== "" && rowMouse.containsMouse) ? Colors.elevatedBg : "transparent"

        Behavior on color {
            ColorAnimation { duration: ShellState.motionDuration(Motion.hoverMs) }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Dimens.paddingMedium
        anchors.rightMargin: Dimens.paddingMedium
        spacing: Dimens.spacingMedium

        Text {
            text: root.label
            color: Colors.fg
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeBase
        }

        Text {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
            text: root.value
            color: Colors.subtext
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeBase
            elide: Text.ElideRight
        }

        SymbolIcon {
            visible: root.link !== ""
            name: "open_in_new"
            size: Dimens.fontSizeLg
            color: Colors.fgMuted
        }
    }

    Rectangle {
        visible: root.showDivider
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Dimens.paddingMedium
        anchors.rightMargin: Dimens.paddingMedium
        height: 1
        color: Colors.border
        opacity: 0.35
    }

    MouseArea {
        id: rowMouse
        anchors.fill: parent
        enabled: root.link !== ""
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Qt.openUrlExternally(root.link)
    }
}
