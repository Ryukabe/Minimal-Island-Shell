// settings/common/SettingsUpdateCard.qml — status card with Check + action
// buttons, used for both system updates and shell self-update.
import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../common"

Rectangle {
    id: root

    property string icon: "update"
    property string title: ""
    property string statusText: "Not checked yet"
    property string actionText: "Update"
    property string noteText: ""
    property string lastCheckedText: ""
    property string lastUpdatedText: ""
    property bool actionEnabled: false
    property bool checking: false
    property bool busy: false

    signal checkRequested()
    signal actionRequested()

    Layout.fillWidth: true
    implicitHeight: contentCol.implicitHeight + Dimens.paddingMedium * 2
    radius: Dimens.radiusMedium
    color: Colors.subBgMica
    // Borders removed per design feedback — the mica background alone
    // separates the card from the page without an outline.

    ColumnLayout {
        id: contentCol
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Dimens.paddingMedium
        spacing: 4

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

            // Guarantees the buttons sit flush right regardless of title/status
            // text length — do not remove in favor of fillWidth on the column above.
            Item { Layout.fillWidth: true }

            RowLayout {
                spacing: Dimens.spacingSmall

                SettingsButton {
                    text: "Recheck"
                    enabled: !root.checking && !root.busy
                    onClicked: root.checkRequested()
                }

                SettingsButton {
                    primary: true
                    text: root.actionText
                    busy: root.busy
                    enabled: root.actionEnabled && !root.busy && !root.checking
                    onClicked: root.actionRequested()
                }
            }
        }

        Text {
            visible: root.lastCheckedText.length > 0 || root.lastUpdatedText.length > 0
            text: [
                root.lastCheckedText.length > 0 ? "Last checked: " + root.lastCheckedText : "",
                root.lastUpdatedText.length > 0 ? "Last updated: " + root.lastUpdatedText : ""
            ].filter(s => s.length > 0).join("  •  ")
            color: Colors.subtext
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeXs
            Layout.fillWidth: true
            Layout.topMargin: 2
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