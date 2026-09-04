import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"
import "../services"
import "../components/settings"

Item {
    id: root

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
                    icon: "speed"
                    title: "Motion"
                    subtitle: "How fast the shell animates, or whether it animates at all."
                }

                SettingsToggleRow {
                    label: "Reduce motion"
                    checked: ShellState.motionReduced
                    onToggled: (val) => ShellState.motionReduced = val
                }

                SettingsSliderRow {
                    label: "Movement (size / position)"
                    from: 100; to: 800; stepSize: 10
                    value: ShellState.motionMovementMs
                    unit: " ms"
                    enabled: !ShellState.motionReduced
                    opacity: ShellState.motionReduced ? 0.4 : 1.0
                    onMoved: (val) => ShellState.motionMovementMs = val
                }

                SettingsSliderRow {
                    label: "Fades & colour"
                    from: 50; to: 500; stepSize: 10
                    value: ShellState.motionFadeMs
                    unit: " ms"
                    enabled: !ShellState.motionReduced
                    opacity: ShellState.motionReduced ? 0.4 : 1.0
                    onMoved: (val) => ShellState.motionFadeMs = val
                }

                SettingsSliderRow {
                    label: "Hover response"
                    from: 50; to: 400; stepSize: 10
                    value: ShellState.motionHoverMs
                    unit: " ms"
                    enabled: !ShellState.motionReduced
                    opacity: ShellState.motionReduced ? 0.4 : 1.0
                    onMoved: (val) => ShellState.motionHoverMs = val
                }

                SettingsSliderRow {
                    label: "Bounce"
                    from: 0; to: 100; stepSize: 1
                    value: ShellState.motionBouncePercent
                    unit: " %"
                    enabled: !ShellState.motionReduced
                    opacity: ShellState.motionReduced ? 0.4 : 1.0
                    onMoved: (val) => ShellState.motionBouncePercent = val
                }
            }
        }
    }
}