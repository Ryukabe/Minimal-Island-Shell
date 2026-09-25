// settings/common/SettingsTriggerToggleRow.qml — a feature toggle with an
// editable single-character trigger mark shown underneath while it's on.
import QtQuick
import QtQuick.Layouts
import "../../styles"

ColumnLayout {
    id: root
    spacing: 2

    property string label: ""
    property string hint: ""          // sample word shown after the mark, e.g. "smile"
    property bool checked: false
    property string trigger: ""
    property bool showDivider: true

    signal toggled(bool checked)
    signal triggerCommitted(string value)

    Layout.fillWidth: true

    Item {
        Layout.fillWidth: true
        implicitHeight: 44

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Dimens.paddingMedium
            anchors.rightMargin: Dimens.paddingMedium
            spacing: Dimens.spacingSmall

            Text {
                text: root.label
                color: Colors.fg
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeBase
                Layout.fillWidth: true
            }

            Rectangle {
                id: toggleTrack
                implicitWidth: 40
                implicitHeight: 22
                radius: height / 2
                color: root.checked ? Colors.accent : Colors.elevatedBg
                border.color: root.checked ? Colors.accent : Colors.border
                border.width: 1

                Behavior on color { ColorAnimation { duration: 150 } }

                Rectangle {
                    width: 16
                    height: 16
                    radius: 8
                    x: root.checked ? toggleTrack.width - width - 3 : 3
                    anchors.verticalCenter: parent.verticalCenter
                    color: Colors.fg

                    Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.toggled(!root.checked)
                }
            }
        }
    }

    RowLayout {
        visible: root.checked
        Layout.fillWidth: true
        Layout.leftMargin: Dimens.paddingMedium
        Layout.rightMargin: Dimens.paddingMedium
        Layout.bottomMargin: Dimens.spacingSmall
        spacing: Dimens.spacingSmall

        Text {
            text: "Trigger mark"
            color: Colors.fgMuted
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeXs
        }

        Rectangle {
            implicitWidth: 40
            implicitHeight: 26
            radius: Dimens.settingsControlRadius
            color: triggerInput.activeFocus ? Colors.mainBgMica : Colors.elevatedBg
            border.color: triggerInput.activeFocus ? Colors.accent : Colors.border
            border.width: 1

            TextInput {
                id: triggerInput
                anchors.centerIn: parent
                width: 16
                text: root.trigger
                color: Colors.fg
                font.family: Fonts.mono
                font.pixelSize: Dimens.fontSizeSm
                horizontalAlignment: TextInput.AlignHCenter
                selectByMouse: true
                maximumLength: 1

                // The parent decides whether the new mark is valid. Either way,
                // re-sync the box to the real value once the decision is made.
                onEditingFinished: {
                    root.triggerCommitted(text)
                    text = root.trigger
                }
            }
        }

        Text {
            visible: root.hint !== ""
            text: "e.g. " + root.trigger + root.hint
            color: Colors.fgMuted
            font.family: Fonts.mono
            font.pixelSize: Dimens.fontSizeXs
            Layout.fillWidth: true
            elide: Text.ElideRight
        }
    }

    Rectangle {
        visible: root.showDivider
        Layout.fillWidth: true
        Layout.leftMargin: Dimens.paddingMedium
        Layout.rightMargin: Dimens.paddingMedium
        height: 1
        color: Colors.border
        opacity: 0.35
    }
}