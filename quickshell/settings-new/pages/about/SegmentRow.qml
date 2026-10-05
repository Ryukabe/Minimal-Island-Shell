// pages/about/SegmentRow.qml — label with a pill of mutually exclusive options (e.g. power profile).
import QtQuick
import QtQuick.Layouts
import "../../../styles"
import "../../../services"

Item {
    id: root

    property string label: ""
    property var options: []
    property string selectedValue: ""
    property bool showDivider: true
    signal optionSelected(string name)

    Layout.fillWidth: true
    implicitHeight: 54

    RowLayout {
        anchors.fill: parent
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
            implicitWidth: segments.implicitWidth + 6
            radius: height / 2
            color: Colors.elevatedBg

            Row {
                id: segments
                anchors.centerIn: parent
                spacing: 0

                Repeater {
                    model: root.options

                    delegate: Rectangle {
                        id: segment
                        required property var modelData

                        readonly property bool active: root.selectedValue === segment.modelData

                        height: 28
                        width: segmentLabel.implicitWidth + Dimens.paddingLarge * 2
                        radius: height / 2
                        color: segment.active ? Colors.accent : "transparent"

                        Behavior on color {
                            ColorAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
                        }

                        Text {
                            id: segmentLabel
                            anchors.centerIn: parent
                            text: segment.modelData
                            color: segment.active ? Colors.mainBgMica : Colors.fg
                            font.family: Fonts.text
                            font.pixelSize: Dimens.fontSizeSm
                            font.weight: segment.active ? Font.DemiBold : Font.Normal
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.optionSelected(segment.modelData)
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
