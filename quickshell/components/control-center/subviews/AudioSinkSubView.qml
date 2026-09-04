// components/control-center/subviews/AudioSinkSubView.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../../styles"
import "../../../services"

Item {
    id: root
    implicitWidth: 580
    implicitHeight: 200

    signal backRequested()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Item {
            Layout.fillWidth: true
            implicitHeight: 32

            Text {
                text: "arrow_back"
                font.family: Fonts.icon
                font.pixelSize: Dimens.fontSizeLg
                color: Colors.fg
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -8
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.backRequested()
                }
            }

            Text {
                text: "Audio Output"
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSize15
                font.bold: true
                color: Colors.fg
                anchors.centerIn: parent
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Dimens.radiusLarge
            color: Colors.subBgMica
            border.width: 1
            border.color: Colors.border

            Text {
                anchors.centerIn: parent
                text: "Output device switching isn't wired up yet"
                font.pixelSize: Dimens.fontSizeSm
                color: Colors.fgMuted
            }
        }
    }
}