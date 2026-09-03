import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"
import "../components/settings"

Item {
    id: root

    property bool notchMode: true
    property real notchFlare: 14
    property real barHeight: 34
    property real collapsedWidth: 150
    property real expandedHeight: 135
    property real minExpandedWidth: 619

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        SettingsHeader {
            icon: "dock_to_bottom"
            title: "Bar & Island"
            subtitle: "Shape and size of the island, the notch, and the Game Mode bar."
        }

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

        Item { Layout.fillHeight: true }
    }
}