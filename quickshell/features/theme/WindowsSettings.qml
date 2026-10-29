// features/theme/WindowsSettings.qml — Appearance > Windows. How Hyprland draws windows: corner
// shape, gaps, border, opacity, dimming and shadow. The window corner radius itself is part of
// the radius system on Surfaces, and the shadow color is shared with the island's (Surfaces).
import QtQuick
import "../settings/components"
import "../../core/shell"
import "../../core/styles"

PageScroll {
    id: root

    function shapeName(power) {
        if (power < 2.5) return "Circle"
        if (power < 3.5) return "Smooth"
        return "Squircle"
    }

    function shapePower(name) {
        if (name === "Circle") return 2
        if (name === "Smooth") return 3
        return 4
    }

    SectionLabel { text: "Corners" }

    GroupCard {
        SegmentRow {
            label: "Corner shape"
            description: "Radius comes from Surfaces (now " + Math.round(ShellState.windowRounding)
                + " px). Circle matches the island's corners exactly"
            options: ["Circle", "Smooth", "Squircle"]
            selectedValue: root.shapeName(ShellState.windowRoundingPower)
            onOptionSelected: (name) => ShellState.windowRoundingPower = root.shapePower(name)
            showDivider: false
        }
    }

    SectionLabel { text: "Gaps" }

    GroupCard {
        SliderRow {
            label: "Inner gap"
            description: "Space between windows"
            from: 0; to: 40; stepSize: 1
            value: ShellState.windowGapsIn
            unit: " px"
            onMoved: (val) => ShellState.windowGapsIn = val
        }

        SliderRow {
            label: "Outer gap"
            description: "Space between windows and the screen edges. Added below the island's strip"
            from: 0; to: 60; stepSize: 1
            value: ShellState.windowGapsOut
            unit: " px"
            onMoved: (val) => ShellState.windowGapsOut = val
            showDivider: false
        }
    }

    SectionLabel { text: "Border" }

    GroupCard {
        SliderRow {
            label: "Border size"
            description: "Thickness of the window border. Border colors are not set here"
            from: 0; to: 10; stepSize: 1
            value: ShellState.windowBorderSize
            unit: " px"
            onMoved: (val) => ShellState.windowBorderSize = val
            showDivider: false
        }
    }

    SectionLabel { text: "Opacity" }

    GroupCard {
        SliderRow {
            label: "Active window"
            description: "The window you are using. Whole window, text included"
            from: 10; to: 100; stepSize: 1
            value: Math.round(ShellState.windowActiveOpacity * 100)
            unit: " %"
            onMoved: (val) => ShellState.windowActiveOpacity = val / 100
        }

        SliderRow {
            label: "Inactive windows"
            description: "Every window that does not have focus"
            from: 10; to: 100; stepSize: 1
            value: Math.round(ShellState.windowInactiveOpacity * 100)
            unit: " %"
            onMoved: (val) => ShellState.windowInactiveOpacity = val / 100
        }

        SliderRow {
            label: "Fullscreen windows"
            description: "Windows in fullscreen"
            from: 10; to: 100; stepSize: 1
            value: Math.round(ShellState.windowFullscreenOpacity * 100)
            unit: " %"
            onMoved: (val) => ShellState.windowFullscreenOpacity = val / 100
            showDivider: false
        }
    }

    SectionLabel { text: "Dimming" }

    GroupCard {
        ToggleRow {
            label: "Dim inactive windows"
            description: "Darken windows that do not have focus"
            checked: ShellState.windowDimInactive
            onToggled: (val) => ShellState.windowDimInactive = val
        }

        SliderRow {
            label: "Dim strength"
            description: "How dark inactive windows get"
            from: 0; to: 100; stepSize: 1
            value: Math.round(ShellState.windowDimStrength * 100)
            unit: " %"
            enabled: ShellState.windowDimInactive
            onMoved: (val) => ShellState.windowDimStrength = val / 100
            showDivider: false
        }
    }

    SectionLabel { text: "Shadow" }

    GroupCard {
        ToggleRow {
            label: "Window shadow"
            description: "Soft shadow around windows. The color is shared with the island's shadow on Surfaces"
            checked: ShellState.windowShadowEnabled
            onToggled: (val) => ShellState.windowShadowEnabled = val
        }

        SliderRow {
            label: "Shadow opacity"
            from: 0; to: 100; stepSize: 1
            value: Math.round(ShellState.windowShadowOpacity * 100)
            unit: " %"
            enabled: ShellState.windowShadowEnabled
            onMoved: (val) => ShellState.windowShadowOpacity = val / 100
        }

        SliderRow {
            label: "Shadow range"
            description: "How far the shadow reaches"
            from: 0; to: 60; stepSize: 1
            value: ShellState.windowShadowRange
            unit: " px"
            enabled: ShellState.windowShadowEnabled
            onMoved: (val) => ShellState.windowShadowRange = val
        }

        SliderRow {
            label: "Shadow sharpness"
            description: "Higher makes the shadow fade out faster"
            from: 1; to: 4; stepSize: 1
            value: ShellState.windowShadowPower
            unit: ""
            enabled: ShellState.windowShadowEnabled
            onMoved: (val) => ShellState.windowShadowPower = val
        }

        SliderRow {
            label: "Shadow scale"
            description: "100% is the normal size"
            from: 50; to: 200; stepSize: 5
            value: Math.round(ShellState.windowShadowScale * 100)
            unit: " %"
            enabled: ShellState.windowShadowEnabled
            onMoved: (val) => ShellState.windowShadowScale = val / 100
            showDivider: false
        }
    }
}