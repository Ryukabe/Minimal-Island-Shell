// components/DropdownRow.qml — label with a pill showing the current choice; click it and the
// options unfold inside the row (no popup window, so it behaves inside the settings layout).
// Long lists scroll: at most `maxVisibleOptions` rows are shown at once.
import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../../services"

Item {
    id: root

    property string label: ""
    property var options: []
    property string selectedValue: ""
    property bool showDivider: true
    property bool open: false
    property int maxVisibleOptions: 8
    signal optionSelected(string value)

    readonly property int _headerHeight: 54
    readonly property int _optionHeight: 34
    readonly property int _optionSpacing: 2

    Layout.fillWidth: true
    implicitHeight: root._headerHeight + (root.open ? optionFlick.height + Dimens.paddingSmall : 0)
    clip: true

    Behavior on implicitHeight {
        NumberAnimation { duration: ShellState.motionDuration(Motion.fadeMs); easing.type: Easing.OutCubic }
    }

    RowLayout {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: root._headerHeight
        anchors.leftMargin: Dimens.paddingMedium
        anchors.rightMargin: Dimens.paddingMedium
        spacing: Dimens.spacingMedium

        Text {
            Layout.fillWidth: true
            text: root.label
            color: Colors.fg
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeBase
            elide: Text.ElideRight
        }

        Rectangle {
            implicitHeight: 34
            implicitWidth: pillRow.implicitWidth + Dimens.paddingMedium * 2
            radius: height / 2
            color: pillMouse.containsMouse || root.open ? Colors.elevatedBg : Colors.subBgMica

            Behavior on color {
                ColorAnimation { duration: ShellState.motionDuration(Motion.hoverMs) }
            }

            RowLayout {
                id: pillRow
                anchors.centerIn: parent
                spacing: Dimens.spacingSmall

                Text {
                    text: root.selectedValue
                    color: Colors.fg
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeBase
                }

                SymbolIcon {
                    name: "expand_more"
                    size: Dimens.fontSizeLg
                    color: Colors.fgMuted
                    rotation: root.open ? 180 : 0

                    Behavior on rotation {
                        NumberAnimation { duration: ShellState.motionDuration(Motion.fadeMs); easing.type: Easing.OutCubic }
                    }
                }
            }

            MouseArea {
                id: pillMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.open = !root.open
            }
        }
    }

    Flickable {
        id: optionFlick
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header.bottom
        anchors.leftMargin: Dimens.paddingMedium
        anchors.rightMargin: Dimens.paddingMedium
        height: Math.min(optionList.implicitHeight,
                         root.maxVisibleOptions * (root._optionHeight + root._optionSpacing))
        contentWidth: width
        contentHeight: optionList.implicitHeight
        interactive: contentHeight > height
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        visible: root.open || root.implicitHeight > root._headerHeight

        Column {
            id: optionList
            width: optionFlick.width
            spacing: root._optionSpacing

            Repeater {
                model: root.options

                delegate: Rectangle {
                    id: optionRow
                    required property var modelData

                    readonly property bool active: root.selectedValue === optionRow.modelData

                    width: optionList.width
                    height: root._optionHeight
                    radius: Dimens.settingsControlRadius
                    color: optionRow.active ? Colors.accent : (optionMouse.containsMouse ? Colors.elevatedBg : "transparent")

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: Dimens.paddingMedium
                        anchors.rightMargin: Dimens.paddingMedium
                        text: optionRow.modelData
                        color: optionRow.active ? Colors.mainBgMica : Colors.fg
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeBase
                        font.weight: optionRow.active ? Font.DemiBold : Font.Normal
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        id: optionMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.open = false
                            root.optionSelected(optionRow.modelData)
                        }
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
