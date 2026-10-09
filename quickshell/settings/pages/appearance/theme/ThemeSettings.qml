// pages/appearance/theme/ThemeSettings.qml — Appearance > Theme.
// Theme picker, light/dark and theme tracking, and the manual palette colours (the old
// separate Colors page lives here now).
import QtQuick
import QtQuick.Layouts
import "../../../components"
import "../../../../services"
import "../../../../styles"
import "../../../../components/theme"

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
        ToggleRow {
            label: "Light mode"
            description: "Switch the whole shell between dark and light"
            checked: Colors.lightModeEnabled
            onToggled: (val) => {
                if (val !== Colors.lightModeEnabled) Colors.toggleLightMode()
            }
        }

        ToggleRow {
            label: "Colors follow theme"
            description: "Use the selected theme's colours instead of the manual palette below"
            checked: Colors.colorsFollowTheme
            onToggled: (val) => Colors.colorsFollowTheme = val
            showDivider: false
        }
    }

    SectionLabel { text: "Custom colors: dark" }

    GroupCard {
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

    SectionLabel { text: "Custom colors: light" }

    GroupCard {
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
