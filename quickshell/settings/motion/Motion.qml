// settings/motion/Motion.qml
import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../components/theme"
import "../common"
import "../../styles"

Item {
    id: root

    SettingsScrollView {
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

        SettingsSectionLabel { label: "Hyprland Animations" }

        SettingsCarouselRow {
            id: hyprAnimCarousel
            Layout.topMargin: Dimens.spacingSmall
            model: HyprlandAnimationsService.animationsList
            cardDelegate: Component {
                AnimationCard {
                    required property var modelData
                    required property int index
                    presetName: modelData.name
                    isApplied: HyprlandAnimationsService.currentAnimation === modelData.name
                    isSelected: hyprAnimCarousel.currentIndex === index
                    onClicked: {
                        hyprAnimCarousel.currentIndex = index
                        HyprlandAnimationsService.applyAnimation(modelData.name)
                    }
                }
            }
        }
    }
}