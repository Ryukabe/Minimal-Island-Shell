// components/PageTitle.qml — title card at the top of every page.
// On a menu's landing list it shows an icon badge; inside a view the badge is replaced by a back arrow.
// The badge icon plays its own motion whenever the page changes; the back arrow nudges on hover.
import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../../services"

Rectangle {
    id: root

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property bool canGoBack: false
    signal backClicked()

    Layout.fillWidth: true
    implicitHeight: 70
    radius: Dimens.settingsContainerRadius
    color: Colors.subBgMica
    border.color: Colors.border
    border.width: 1

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Dimens.paddingMedium
        anchors.rightMargin: Dimens.paddingMedium
        spacing: Dimens.spacingMedium

        Rectangle {
            visible: root.canGoBack
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            radius: 20
            color: backMouse.containsMouse ? Colors.elevatedBg : "transparent"

            Behavior on color {
                ColorAnimation { duration: ShellState.motionDuration(Motion.hoverMs) }
            }

            SymbolIcon {
                anchors.centerIn: parent
                name: "arrow_back"
                size: Dimens.fontSizeXxl
                color: Colors.fg
                animated: true
                hovered: backMouse.containsMouse
            }

            MouseArea {
                id: backMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.backClicked()
            }
        }

        Rectangle {
            visible: !root.canGoBack
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            radius: 20
            color: Colors.elevatedBg

            SymbolIcon {
                anchors.centerIn: parent
                name: root.icon
                size: Dimens.fontSizeXxl
                color: Colors.accent
                animated: true
                playOnLoad: true
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: root.title
                color: Colors.fg
                font.family: Fonts.display
                font.pixelSize: Dimens.fontSizeLg
                font.weight: Font.Bold
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: root.subtitle
                color: Colors.fgMuted
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeXs
                elide: Text.ElideRight
            }
        }
    }
}
