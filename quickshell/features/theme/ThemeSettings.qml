// features/theme/ThemeSettings.qml — Appearance > Colors. Where the palette comes from, and the
// manual palette colours (the old separate Colors page lives here now).
// The theme picker and light/dark mode (with the Auto schedule) are on the Appearance page.
pragma ComponentBehavior: Bound

import QtQuick
import "../settings/components"
import "../../core/styles"


PageScroll {
    id: root

    readonly property var colorKeys: [
        { key: "background", label: "Background" },
        { key: "surface", label: "Surface" },
        { key: "foreground", label: "Foreground" },
        { key: "fgMuted", label: "Muted text" },
        { key: "border", label: "Border" },
        { key: "accent", label: "Accent" },
        { key: "red", label: "Red" },
        { key: "green", label: "Green" },
        { key: "yellow", label: "Yellow" },
        { key: "blue", label: "Blue" },
        { key: "purple", label: "Purple" },
        { key: "cyan", label: "Cyan" }
    ]

    SectionLabel { text: "Palette" }

    GroupCard {
        SegmentRow {
            label: "Palette Source"
            description: "Where to derive the color palette from"
            options: ["Prebuilt", "Dynamic", "Custom"]
            selectedValue: Colors.paletteSource
            onOptionSelected: (name) => Colors.paletteSource = name
            showDivider: false
        }
    }

    SectionLabel {
        text: "Custom colors: dark"
        visible: Colors.paletteSource === "Custom"
    }

    GroupCard {
        visible: Colors.paletteSource === "Custom"

        Repeater {
            model: root.colorKeys

            delegate: ColorRow {
                required property var modelData
                required property int index

                label: modelData.label
                value: Colors.hardcodedPalette.dark[modelData.key]
                showDivider: index !== root.colorKeys.length - 1
                onCommitted: (hex) => Colors.setHardcodedColor("dark", modelData.key, hex)
            }
        }
    }

    SectionLabel {
        text: "Custom colors: light"
        visible: Colors.paletteSource === "Custom"
    }

    GroupCard {
        visible: Colors.paletteSource === "Custom"

        Repeater {
            model: root.colorKeys

            delegate: ColorRow {
                required property var modelData
                required property int index

                label: modelData.label
                value: Colors.hardcodedPalette.light[modelData.key]
                showDivider: index !== root.colorKeys.length - 1
                onCommitted: (hex) => Colors.setHardcodedColor("light", modelData.key, hex)
            }
        }
    }
}
