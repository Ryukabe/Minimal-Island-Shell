// components/LandingRow.qml — one row in a landing list: icon, title, subtitle, chevron.
// The row icon plays its own motion on hover, and the chevron nudges right.
import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../../services"

Item {
    id: root

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property bool placeholder: false
    property bool showDivider: true
    signal clicked()

    Layout.fillWidth: true
    implicitHeight: 60

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: 2
        anchors.bottomMargin: 2
        radius: Dimens.settingsControlRadius
        color: rowMouse.containsMouse ? Colors.elevatedBg : "transparent"

        Behavior on color {
            ColorAnimation { duration: ShellState.motionDuration(Motion.hoverMs) }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Dimens.paddingMedium
        anchors.rightMargin: Dimens.paddingMedium
        spacing: Dimens.spacingMedium

        Rectangle {
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            radius: 18
            color: Colors.elevatedBg

            SymbolIcon {
                anchors.centerIn: parent
                name: root.icon
                size: Dimens.fontSize18
                color: Colors.accent
                animated: true
                hovered: rowMouse.containsMouse
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: root.title
                color: Colors.fg
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeBase
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: root.subtitle
                color: Colors.subtext
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeXs
                elide: Text.ElideRight
            }
        }

        ComingSoonTag {
            visible: root.placeholder
        }

        SymbolIcon {
            name: "chevron_right"
            size: Dimens.fontSizeXxl
            color: Colors.fgMuted
            animated: true
            hovered: rowMouse.containsMouse
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
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
