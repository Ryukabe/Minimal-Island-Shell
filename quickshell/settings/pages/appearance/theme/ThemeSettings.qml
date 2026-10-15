// pages/appearance/theme/ThemeSettings.qml — Appearance > Theme.
// Theme picker, light/dark mode (with Auto schedule), palette source, and the manual
// palette colours (the old separate Colors page lives here now).
import QtQuick
import QtQuick.Layouts
import "../../../components"
import "../../../../services"
import "../../../../core/styles"
import "../../../../components/theme"
import "../../../../core/state"

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

    readonly property bool autoOn: Colors.themeMode === "Auto"
    readonly property bool autoCustom: root.autoOn && Colors.autoSource === "Custom"

    SectionLabel { text: "Theme" }

    CardCarousel {
        id: themeCarousel
        model: ThemeService.themesList
        cardDelegate: Component {
            ThemeCard {
                required property var modelData
                required property int index

                themeName: modelData.name
                isApplied: ThemeService.currentTheme === modelData.name
                isSelected: themeCarousel.currentIndex === index
                onClicked: {
                    themeCarousel.currentIndex = index
                    ThemeService.applyTheme(modelData.name)
                }
            }
        }
    }

    SectionLabel { text: "Mode" }

    GroupCard {
        SegmentRow {
            label: "Theme Mode"
            description: "Choose dark, light, or auto based on time of day"
            options: ["Dark", "Light", "Auto"]
            selectedValue: Colors.themeMode
            onOptionSelected: (name) => Colors.themeMode = name
        }

        Reveal {
            shown: root.autoOn

            SegmentRow {
                label: "Auto Schedule"
                description: ShellState.locationLabel === ""
                    ? "No location set, using custom times until you pick one in Language & Region"
                    : "Location: light while the sun is up in " + ShellState.locationLabel
                options: ["Location", "Custom"]
                selectedValue: Colors.autoSource
                onOptionSelected: (name) => Colors.autoSource = name
            }
        }

        Reveal {
            shown: root.autoCustom || (root.autoOn && ShellState.locationLabel === "")

            TimeRow {
                label: "Light starts"
                description: "Switch to light mode at this time"
                minutes: Colors.autoLightStartMin
                onCommitted: (m) => Colors.autoLightStartMin = m
            }
        }

        Reveal {
            shown: root.autoCustom || (root.autoOn && ShellState.locationLabel === "")

            TimeRow {
                label: "Dark starts"
                description: "Switch back to dark mode at this time"
                minutes: Colors.autoLightEndMin
                onCommitted: (m) => Colors.autoLightEndMin = m
            }
        }

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