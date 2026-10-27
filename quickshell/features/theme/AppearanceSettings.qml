// features/theme/AppearanceSettings.qml — the Appearance menu itself: the settings you reach for
// most. Theme picker and light/dark mode (with the Auto schedule) sit here. Wallpaper, Colors,
// Typography, Motion, Opacity, Corners and Templates open from the list at the bottom.
pragma ComponentBehavior: Bound

import QtQuick
import "../settings/components"
import "."
import "../../core/shell"
import "../../core/styles"
import "components"

PageScroll {
    id: root

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
            showDivider: root.autoOn
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
                showDivider: root.autoCustom || ShellState.locationLabel === ""
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
                showDivider: false
            }
        }
    }

    SectionLabel { text: "More appearance settings" }

    ViewList {}
}
