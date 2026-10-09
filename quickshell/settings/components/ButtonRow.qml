// components/ButtonRow.qml — label (+ optional description) with a button on the right.
import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../../services"

Item {
    id: root

    property string label: ""
    property string description: ""
    property string buttonText: ""
    property bool primary: false
    property bool busy: false
    property bool placeholder: false
    property bool showDivider: true
    signal clicked()

    Layout.fillWidth: true
    implicitHeight: root.description !== "" ? 62 : 54
    enabled: !root.placeholder
    opacity: root.enabled ? 1.0 : 0.4

    Behavior on opacity {
        NumberAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Dimens.paddingMedium
        anchors.rightMargin: Dimens.paddingMedium
        spacing: Dimens.spacingMedium

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

        ActionButton {
            Layout.alignment: Qt.AlignVCenter
            text: root.buttonText
            primary: root.primary
            busy: root.busy
            onClicked: root.clicked()
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