// components/ToggleRow.qml — label (+ optional description) with an on/off switch.
// `placeholder: true` greys the row out, adds the "Coming soon" tag and ignores clicks.
import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../../services"

Item {
    id: root

    property string label: ""
    property string description: ""
    property bool checked: false
    property bool placeholder: false
    property bool showDivider: true
    signal toggled(bool checked)

    Layout.fillWidth: true
    implicitHeight: root.description !== "" ? 58 : 44
    enabled: !root.placeholder
    opacity: root.enabled ? 1.0 : 0.4

    Behavior on opacity {
        NumberAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled(!root.checked)
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Dimens.paddingMedium
        anchors.rightMargin: Dimens.paddingMedium
        spacing: Dimens.spacingSmall

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: root.label
                color: Colors.fg
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeBase
                elide: Text.ElideRight
            }

            Text {
                visible: root.description !== ""
                Layout.fillWidth: true
                text: root.description
                color: Colors.subtext
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeXs
                elide: Text.ElideRight
            }
        }

        ComingSoonTag {
            visible: root.placeholder
        }

        Rectangle {
            id: track
            implicitWidth: 40
            implicitHeight: 22
            radius: height / 2
            color: root.checked ? Colors.accent : Colors.elevatedBg
            border.color: root.checked ? Colors.accent : Colors.border
            border.width: 1

            Behavior on color {
                ColorAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
            }

            Rectangle {
                id: handle
                width: 16
                height: 16
                radius: 8
                x: root.checked ? track.width - width - 3 : 3
                anchors.verticalCenter: parent.verticalCenter
                color: Colors.fg

                Behavior on x {
                    NumberAnimation {
                        duration: ShellState.motionDuration(Motion.snapMs)
                        easing.type: Easing.OutCubic
                    }
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
