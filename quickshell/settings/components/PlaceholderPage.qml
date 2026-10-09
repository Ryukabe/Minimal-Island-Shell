// components/PlaceholderPage.qml — shown for any menu or view that has no real page yet.
import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../core"

PageScroll {
    id: root

    GroupCard {
        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: Dimens.paddingLarge
            Layout.bottomMargin: Dimens.paddingLarge
            spacing: Dimens.spacingSmall

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                radius: 24
                color: Colors.elevatedBg

                SymbolIcon {
                    anchors.centerIn: parent
                    name: "construction"
                    size: Dimens.fontSizeXxl
                    color: Colors.accent
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Coming soon"
                color: Colors.fg
                font.family: Fonts.display
                font.pixelSize: Dimens.fontSizeLg
                font.weight: Font.Bold
            }

            Text {
                Layout.fillWidth: true
                Layout.leftMargin: Dimens.paddingLarge
                Layout.rightMargin: Dimens.paddingLarge
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                text: SettingsNav.title + " has no options yet. They will appear here once this page is built."
                color: Colors.subtext
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeSm
            }
        }
    }
}
