// pages/appearance/typography/TypographySettings.qml — Appearance > Typography.
// Values live on ShellState (persisted by SettingsStore). Fonts.qml and Dimens.qml read them,
// so write to ShellState here and never to those directly.
import QtQuick
import QtQuick.Layouts
import "../../../components"
import "../../../../services"
import "../../../../styles"

PageScroll {
    id: root

    readonly property var bodyFontOptions: ["SF Pro Text", "Inter", "Roboto", "JetBrains Mono", "Sans-Serif"]
    readonly property var displayFontOptions: ["Cabinet Grotesk", "Inter Display", "Outfit", "SF Pro Display"]
    readonly property var iconStyles: ["Rounded", "Outlined", "Sharp"]

    SectionLabel { text: "Fonts" }

    GroupCard {
        SliderRow {
            label: "Font size"
            description: "Base size everything else scales from"
            from: 12; to: 18; stepSize: 1
            value: ShellState.fontSizeBase
            unit: " px"
            onMoved: (val) => ShellState.fontSizeBase = val
        }

        DropdownRow {
            label: "Body font"
            options: root.bodyFontOptions
            selectedValue: ShellState.fontBody
            onOptionSelected: (value) => ShellState.fontBody = value
        }

        DropdownRow {
            label: "Display font"
            options: root.displayFontOptions
            selectedValue: ShellState.fontDisplay
            onOptionSelected: (value) => ShellState.fontDisplay = value
            showDivider: false
        }
    }

    SectionLabel { text: "Icons" }

    GroupCard {
        SegmentRow {
            label: "Icon style"
            options: root.iconStyles
            selectedValue: ShellState.iconStyle
            onOptionSelected: (name) => ShellState.iconStyle = name
        }

        SliderRow {
            label: "Icon weight"
            description: "Thin to bold strokes for Material Symbols"
            from: 100; to: 700; stepSize: 50
            value: ShellState.iconWeight
            onMoved: (val) => ShellState.iconWeight = val
        }

        ToggleRow {
            label: "Filled icons"
            description: "Solid icons instead of outlines"
            checked: ShellState.iconFilled
            onToggled: (val) => ShellState.iconFilled = val
            showDivider: false
        }
    }
}
