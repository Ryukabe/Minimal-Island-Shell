// components/TimeRow.qml — label with a time of day you step with − / +.
import QtQuick
import QtQuick.Layouts
import "../../../core/styles"
import "../../../core/state"

Item {
    id: root

    property string label: ""
    property string description: ""
    property int minutes: 0            // minutes after midnight
    property int stepMinutes: 15
    property bool showDivider: true
    signal committed(int minutes)

    Layout.fillWidth: true
    implicitHeight: description !== "" ? 64 : 54

    function _format(total) {
        var h = Math.floor(total / 60) % 24
        var m = total % 60
        var mm = (m < 10 ? "0" : "") + m
        if (ShellState.clockUse24Hour) return (h < 10 ? "0" : "") + h + ":" + mm
        var h12 = h % 12 === 0 ? 12 : h % 12
        return h12 + ":" + mm + (h < 12 ? " AM" : " PM")
    }

    function _step(dir) {
        root.committed((root.minutes + dir * root.stepMinutes + 1440) % 1440)
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
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }

            Text {
                visible: root.description !== ""
                Layout.fillWidth: true
                text: root.description
                color: Colors.fgMuted
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeSm
                elide: Text.ElideRight
            }
        }

        Rectangle {
            implicitHeight: 34
            implicitWidth: pill.implicitWidth + 6
            radius: height / 2
            color: Colors.elevatedBg

            Row {
                id: pill
                anchors.centerIn: parent
                spacing: 0

                Rectangle {
                    width: 28; height: 28; radius: 14
                    color: minusArea.containsMouse ? Colors.border : "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: "−"
                        color: Colors.fg
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeBase
                    }
                    MouseArea {
                        id: minusArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root._step(-1)
                    }
                }

                Text {
                    width: 78
                    height: 28
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: root._format(root.minutes)
                    color: Colors.fg
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeSm
                    font.weight: Font.DemiBold
                }

                Rectangle {
                    width: 28; height: 28; radius: 14
                    color: plusArea.containsMouse ? Colors.border : "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: "+"
                        color: Colors.fg
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeBase
                    }
                    MouseArea {
                        id: plusArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root._step(1)
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