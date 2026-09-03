import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"
import "../components/settings"

Item {
    id: root

    property bool reduceMotion: false
    property real movementMs: 400
    property real fadeMs: 200
    property real hoverMs: 150
    property real bouncePercent: 40

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        SettingsHeader {
            icon: "speed"
            title: "Motion"
            subtitle: "How fast the shell animates, or whether it animates at all."
        }

        SettingsToggleRow {
            label: "Reduce motion"
            checked: root.reduceMotion
            onToggled: (val) => root.reduceMotion = val
        }

        SettingsSliderRow {
            label: "Movement (size / position)"
            from: 100; to: 800; stepSize: 10
            value: root.movementMs
            unit: " ms"
            enabled: !root.reduceMotion
            opacity: root.reduceMotion ? 0.4 : 1.0
            onMoved: (val) => root.movementMs = val
        }

        SettingsSliderRow {
            label: "Fades & colour"
            from: 50; to: 500; stepSize: 10
            value: root.fadeMs
            unit: " ms"
            enabled: !root.reduceMotion
            opacity: root.reduceMotion ? 0.4 : 1.0
            onMoved: (val) => root.fadeMs = val
        }

        SettingsSliderRow {
            label: "Hover response"
            from: 50; to: 400; stepSize: 10
            value: root.hoverMs
            unit: " ms"
            enabled: !root.reduceMotion
            opacity: root.reduceMotion ? 0.4 : 1.0
            onMoved: (val) => root.hoverMs = val
        }

        SettingsSliderRow {
            label: "Bounce"
            from: 0; to: 100; stepSize: 1
            value: root.bouncePercent
            unit: " %"
            enabled: !root.reduceMotion
            opacity: root.reduceMotion ? 0.4 : 1.0
            onMoved: (val) => root.bouncePercent = val
        }

        Item { Layout.fillHeight: true }
    }
}