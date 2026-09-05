// settings/components/SettingsUpdateCard.qml — status card with Check + action
// buttons, used for both system updates and shell self-update.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../styles"

Rectangle {
    id: root

    property string icon: "update"
    property string title: ""
    property string statusText: "Not checked yet"
    property string actionText: "Update"
    property string noteText: ""
    property bool actionEnabled: false
    property bool checking: false
    property bool busy: false

    signal checkRequested()
    signal actionRequested()

    Layout.fillWidth: true
    implicitHeight: contentCol.implicitHeight + Dimens.paddingMedium * 2
    radius: Dimens.radiusMedium
    color: Colors.subBgMica
    border.color: Qt.rgba(1, 1, 1, 0.08)
    border.width: 1

    ColumnLayout {
        id: contentCol
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Dimens.paddingMedium
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            spacing: Dimens.spacingMedium

            Text {
                text: root.icon
                color: Colors.accent
                font.family: Fonts.icon
                font.variableAxes: Fonts.iconAxes
                font.pixelSize: Dimens.fontSizeXl
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: root.title
                    color: Colors.fg
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeBase
                    font.weight: Font.Medium
                }

                Text {
                    text: root.checking ? "Checking..." : root.statusText
                    color: Colors.subtext
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeSm
                }
            }

            Button {
                text: "Check"
                enabled: !root.checking && !root.busy
                onClicked: root.checkRequested()
            }

            Button {
                text: root.busy ? "Working..." : root.actionText
                enabled: root.actionEnabled && !root.busy && !root.checking
                onClicked: root.actionRequested()
            }
        }

        Text {
            visible: root.noteText.length > 0
            text: root.noteText
            color: Colors.accent
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeSm
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }
    }
}