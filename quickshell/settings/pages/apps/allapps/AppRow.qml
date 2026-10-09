// pages/apps/allapps/AppRow.qml — one installed app: icon, name, short description, and two toggles
// (favourite star, hide eye). Only the All apps page uses it, so it lives here.
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../components"
import "../../../../styles"
import "../../../../services"

Item {
    id: root

    property string name: ""
    property string comment: ""
    property string iconName: ""
    property bool favourite: false
    property bool hidden: false
    property bool showDivider: true
    signal favouriteToggled()
    signal hiddenToggled()

    Layout.fillWidth: true
    implicitHeight: 56

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Dimens.paddingMedium
        anchors.rightMargin: Dimens.paddingMedium
        spacing: Dimens.spacingMedium

        // Hidden apps are dimmed so the list still reads at a glance.
        Image {
            Layout.preferredWidth: 28
            Layout.preferredHeight: 28
            source: Quickshell.iconPath(root.iconName, "application-x-executable")
            sourceSize: Qt.size(56, 56)
            fillMode: Image.PreserveAspectFit
            smooth: true
            opacity: root.hidden ? 0.4 : 1.0
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            opacity: root.hidden ? 0.5 : 1.0

            Text {
                Layout.fillWidth: true
                text: root.name
                color: Colors.fg
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeBase
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                visible: root.comment !== ""
                text: root.comment
                color: Colors.subtext
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeXs
                elide: Text.ElideRight
            }
        }

        Repeater {
            model: [
                { icon: "star", tip: "favourite" },
                { icon: "visibility_off", tip: "hidden" }
            ]

            delegate: Rectangle {
                id: toggle
                required property var modelData

                readonly property bool on: modelData.tip === "favourite" ? root.favourite : root.hidden

                Layout.preferredWidth: 34
                Layout.preferredHeight: 34
                radius: 17
                color: toggleMouse.containsMouse ? Colors.elevatedBg : "transparent"

                Behavior on color {
                    ColorAnimation { duration: ShellState.motionDuration(Motion.hoverMs) }
                }

                // A faint accent disc behind an active toggle.
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: Colors.accent
                    opacity: toggle.on ? 0.18 : 0.0

                    Behavior on opacity {
                        NumberAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
                    }
                }

                SymbolIcon {
                    anchors.centerIn: parent
                    name: toggle.modelData.icon
                    size: Dimens.fontSize18
                    color: toggle.on ? Colors.accent : Colors.fgMuted
                    animated: true
                    hovered: toggleMouse.containsMouse
                }

                MouseArea {
                    id: toggleMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: toggle.modelData.tip === "favourite" ? root.favouriteToggled() : root.hiddenToggled()
                }
            }
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
}
