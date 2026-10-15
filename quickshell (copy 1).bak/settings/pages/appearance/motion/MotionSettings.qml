// pages/appearance/motion/MotionSettings.qml — Appearance > Motion.
// Every control binds straight to ShellState (the single source of truth); SettingsStore persists it.
import QtQuick
import QtQuick.Layouts
import "../../../components"
import "../../../../services"
import "../../../../styles"
import "../../../../components/theme"

PageScroll {
    id: root

    GroupCard {
        ToggleRow {
            label: "Reduce motion"
            description: "Turns off shell animations and Hyprland's own animations"
            checked: ShellState.motionReduced
            onToggled: (val) => ShellState.motionReduced = val
            showDivider: false
        }
    }

    SectionLabel { text: "Icons" }

    GroupCard {
        ToggleRow {
            label: "Animated icons"
            description: "Settings icons play their own motion on hover and when a page opens"
            checked: ShellState.motionIconsEnabled
            enabled: !ShellState.motionReduced
            onToggled: (val) => ShellState.motionIconsEnabled = val
        }

        SliderRow {
            label: "Icon speed"
            description: "How fast icon animations play. 100 % is the default"
            from: 50; to: 200; stepSize: 5
            value: ShellState.motionIconSpeedPercent
            unit: " %"
            enabled: !ShellState.motionReduced && ShellState.motionIconsEnabled
            onMoved: (val) => ShellState.motionIconSpeedPercent = val
        }

        SliderRow {
            label: "Icon bounce"
            description: "How far icons overshoot before they settle. 0 % is none"
            from: 0; to: 100; stepSize: 5
            value: ShellState.motionIconBouncePercent
            unit: " %"
            enabled: !ShellState.motionReduced && ShellState.motionIconsEnabled
            onMoved: (val) => ShellState.motionIconBouncePercent = val
            showDivider: false
        }
    }

    SectionLabel { text: "Timing" }

    GroupCard {
        SliderRow {
            label: "Movement"
            description: "Panel resizes, page swaps and card selection"
            from: 100; to: 800; stepSize: 10
            value: ShellState.motionMovementMs
            unit: " ms"
            enabled: !ShellState.motionReduced
            onMoved: (val) => ShellState.motionMovementMs = val
        }

        SliderRow {
            label: "Fades & colour"
            description: "Opacity and colour changes"
            from: 50; to: 500; stepSize: 10
            value: ShellState.motionFadeMs
            unit: " ms"
            enabled: !ShellState.motionReduced
            onMoved: (val) => ShellState.motionFadeMs = val
        }

        SliderRow {
            label: "Hover response"
            description: "Pointer-over feedback and small toggles"
            from: 50; to: 400; stepSize: 10
            value: ShellState.motionHoverMs
            unit: " ms"
            enabled: !ShellState.motionReduced
            onMoved: (val) => ShellState.motionHoverMs = val
            showDivider: false
        }
    }

    SectionLabel { text: "Bounce" }

    GroupCard {
        ToggleRow {
            label: "Spring physics"
            description: "Experimental. Lets movement overshoot and settle"
            checked: ShellState.motionSpringEnabled
            onToggled: (val) => ShellState.motionSpringEnabled = val
        }

        SliderRow {
            label: "Bounce amount"
            description: "Everyday movement: island resizes, hover and selection. Needs spring physics"
            from: 0; to: 100; stepSize: 1
            value: ShellState.motionBouncePercent
            unit: " %"
            enabled: !ShellState.motionReduced && ShellState.motionSpringEnabled
            onMoved: (val) => ShellState.motionBouncePercent = val
        }

        SliderRow {
            label: "Playful bounce"
            description: "Page pop-ins and other rare, playful moments. Needs spring physics"
            from: 0; to: 100; stepSize: 1
            value: ShellState.motionExpressiveBouncePercent
            unit: " %"
            enabled: !ShellState.motionReduced && ShellState.motionSpringEnabled
            onMoved: (val) => ShellState.motionExpressiveBouncePercent = val
            showDivider: false
        }
    }

    SectionLabel { text: "Hyprland animations" }

    Flickable {
        id: animFlick

        property int selectedIndex: -1

        Layout.fillWidth: true
        implicitHeight: animRow.height
        contentWidth: animRow.width
        contentHeight: animRow.height
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.HorizontalFlick

        Row {
            id: animRow
            spacing: Dimens.spacingMedium

            Repeater {
                model: HyprlandAnimationsService.animationsList

                delegate: AnimationCard {
                    required property var modelData
                    required property int index

                    presetName: modelData.name
                    isApplied: HyprlandAnimationsService.currentAnimation === modelData.name
                    isSelected: animFlick.selectedIndex === index
                    onClicked: {
                        animFlick.selectedIndex = index
                        HyprlandAnimationsService.applyAnimation(modelData.name)
                    }
                }
            }
        }
    }
}