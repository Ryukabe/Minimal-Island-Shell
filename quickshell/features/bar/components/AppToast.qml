// features/bar/components/AppToast.qml — island page shown by AppLaunchToastService
import QtQuick
import QtQuick.Layouts
import "../../../core/styles"
import ".."
import "../../theme"
import "../../../core/shell"

Item {
    id: root

    readonly property real iconSize: ShellState.islandCompactHeight - Dimens.paddingSmall * 2
    readonly property string iconSource: AppLaunchToastService.iconName !== ""
        ? IconThemeService.resolve(AppLaunchToastService.iconName) : ""

    implicitWidth: Math.max(ShellState.islandCompactWidth + 5, contentRow.implicitWidth + Dimens.paddingLarge * 2)
    implicitHeight: ShellState.islandCompactHeight

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: Dimens.spacingMedium

        Item {
            Layout.preferredWidth: root.iconSize
            Layout.preferredHeight: root.iconSize
            Layout.alignment: Qt.AlignVCenter

            Image {
                id: appIcon
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                // Theme-folder SVGs render at this size, so ask for 2x to stay crisp.
                sourceSize.width: width * 2
                sourceSize.height: height * 2
                source: root.iconSource
                visible: status === Image.Ready
            }

            // First letter when the app has no usable icon.
            Rectangle {
                anchors.fill: parent
                radius: Math.min(ShellState.islandCornerRadius, width / 2)
                color: Colors.subBgMica
                visible: appIcon.status !== Image.Ready

                Text {
                    anchors.centerIn: parent
                    text: AppLaunchToastService.appName ? AppLaunchToastService.appName.charAt(0).toUpperCase() : "?"
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeBase
                    font.weight: Font.Bold
                    color: Colors.fg
                }
            }
        }

        Text {
            text: AppLaunchToastService.appName
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeBase
            font.bold: true
            color: Colors.fg
            elide: Text.ElideRight
            Layout.maximumWidth: ShellState.notificationToastMaxWidth
            Layout.alignment: Qt.AlignVCenter
        }
    }
}