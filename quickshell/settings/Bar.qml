import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"
import "../services"
import "../components/settings"

Item {
    id: root

    property bool notchMode: true
    property real notchFlare: 14
    property real barHeight: 34
    property real collapsedWidth: 150
    property real expandedHeight: 135
    property real minExpandedWidth: 619

    ScrollView {
        id: scrollView
        anchors.fill: parent
        anchors.rightMargin: 6
        clip: true
        contentWidth: availableWidth
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        Item {
            width: scrollView.availableWidth
            implicitHeight: contentCol.implicitHeight + Dimens.paddingLarge

            ColumnLayout {
                id: contentCol
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.min(parent.width - Dimens.paddingMedium * 2, 640)
                spacing: 0

                SettingsHeader {
                    icon: "dock_to_bottom"
                    title: "Bar & Island"
                    subtitle: "Shape and size of the island, the notch, and the Game Mode bar."
                }

                SettingsSectionLabel { label: "Behavior" }

                SettingsSliderRow {
                    label: "Top margin"
                    from: 0; to: 40; stepSize: 1
                    value: ShellState.islandTopMargin
                    unit: " px"
                    onMoved: (val) => ShellState.islandTopMargin = val
                }

                SettingsSliderRow {
                    label: "Corner radius"
                    from: 0; to: 30; stepSize: 1
                    value: ShellState.islandCornerRadius
                    unit: " px"
                    onMoved: (val) => ShellState.islandCornerRadius = val
                }

                SettingsSliderRow {
                    label: "Border width"
                    from: 0; to: 4; stepSize: 1
                    value: ShellState.islandBorderWidth
                    unit: " px"
                    onMoved: (val) => ShellState.islandBorderWidth = val
                }

                SettingsToggleRow {
                    label: "Click outside to dismiss"
                    checked: ShellState.islandClickOutsideDismiss
                    onToggled: (val) => ShellState.islandClickOutsideDismiss = val
                }

                SettingsSectionLabel { label: "Notch" }

                SettingsToggleRow {
                    label: "Notch mode"
                    checked: root.notchMode
                    onToggled: (val) => root.notchMode = val
                }

                SettingsSliderRow {
                    label: "Notch flare"
                    from: 0; to: 40; stepSize: 1
                    value: root.notchFlare
                    unit: " px"
                    onMoved: (val) => root.notchFlare = val
                }

                SettingsSliderRow {
                    label: "Bar height"
                    from: 24; to: 60; stepSize: 1
                    value: root.barHeight
                    unit: " px"
                    onMoved: (val) => root.barHeight = val
                }

                SettingsSliderRow {
                    label: "Collapsed width"
                    from: 80; to: 300; stepSize: 1
                    value: root.collapsedWidth
                    unit: " px"
                    onMoved: (val) => root.collapsedWidth = val
                }

                SettingsSliderRow {
                    label: "Expanded height"
                    from: 60; to: 400; stepSize: 1
                    value: root.expandedHeight
                    unit: " px"
                    onMoved: (val) => root.expandedHeight = val
                }

                SettingsSliderRow {
                    label: "Minimum expanded width"
                    from: 300; to: 900; stepSize: 1
                    value: root.minExpandedWidth
                    unit: " px"
                    onMoved: (val) => root.minExpandedWidth = val
                }
            }
        }
    }
}