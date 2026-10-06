// components/SidebarItem.qml — one menu entry in the sidebar: icon, title, one-line subtitle.
import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../../services"

Item {
    id: root

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property bool selected: false
    signal clicked()

    Layout.fillWidth: true
    implicitHeight: 48

    Rectangle {
        anchors.fill: parent
        radius: Dimens.settingsContainerRadius
        color: (itemMouse.containsMouse && !root.selected) ? Colors.elevatedBg : "transparent"

        Behavior on color {
            ColorAnimation { duration: ShellState.motionDuration(Motion.hoverMs) }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: Dimens.settingsContainerRadius
        color: Colors.accent
        opacity: root.selected ? 0.18 : 0.0

        Behavior on opacity {
            NumberAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
        }
    }

    Rectangle {
        visible: root.selected
        width: 3
        height: 18
        radius: 1.5
        anchors.left: parent.left
        anchors.leftMargin: 3
        anchors.verticalCenter: parent.verticalCenter
        color: Colors.accent
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Dimens.paddingMedium
        anchors.rightMargin: Dimens.paddingSmall
        spacing: Dimens.spacingMedium

        SymbolIcon {
            Layout.preferredWidth: 24
            name: root.icon
            size: Dimens.fontSize18
            color: root.selected ? Colors.accent : Colors.fg

            // Plays this icon's own motion on hover and when the item becomes selected.
            animated: true
            hovered: itemMouse.containsMouse
            activated: root.selected

            Behavior on color {
                ColorAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                Layout.fillWidth: true
                text: root.title
                color: root.selected ? Colors.accent : Colors.fg
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeBase
                font.weight: root.selected ? Font.DemiBold : Font.Normal
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
    }

    MouseArea {
        id: itemMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
