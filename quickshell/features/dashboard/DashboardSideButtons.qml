import QtQuick

Item {
    id: root

    property real gap: 12

    signal powerRequested()
    signal controlCenterRequested()
    signal launcherRequested()
    signal settingsRequested()

    // Left side
    Column {
        spacing: 10
anchors.left: parent.left
anchors.leftMargin: root.gap
        anchors.verticalCenter: parent.verticalCenter

        FloatingRoundButton { icon: "power_settings_new"; onClicked: root.powerRequested() }
        FloatingRoundButton { icon: "apps"; onClicked: root.launcherRequested() }
    }

    // Right side
    Column {
        spacing: 10
anchors.right: parent.right
anchors.rightMargin: root.gap
        anchors.verticalCenter: parent.verticalCenter

        FloatingRoundButton { icon: "tune"; onClicked: root.controlCenterRequested() }
        FloatingRoundButton { icon: "settings"; onClicked: root.settingsRequested() }
    }
}