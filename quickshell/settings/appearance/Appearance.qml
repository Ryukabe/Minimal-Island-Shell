// settings/appearance/Appearance.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../services"
import "../../components/theme"
import "../common"
import "../../styles"

Item {
    id: root

    property real fontSize: 15
    property real spacingUnit: 4
    property real smallRadius: 10

    property string activeDropdown: ""

    readonly property var bodyFontOptions: ["Inter", "Roboto", "JetBrains Mono", "Sans-Serif"]
    readonly property var displayFontOptions: ["Cabinet Grotesk", "Inter Display", "Outfit", "SF Pro Display"]
    readonly property var iconStyles: ["Rounded", "Outlined", "Sharp"]
    readonly property var colorKeys: [
        { key: "background", label: "Background" },
        { key: "surface", label: "Surface" },
        { key: "foreground", label: "Foreground" },
        { key: "fgMuted", label: "Muted Text" },
        { key: "border", label: "Border" },
        { key: "accent", label: "Accent" },
        { key: "red", label: "Red" },
        { key: "green", label: "Green" },
        { key: "yellow", label: "Yellow" },
        { key: "blue", label: "Blue" },
        { key: "purple", label: "Purple" },
        { key: "cyan", label: "Cyan" }
    ]

    MouseArea {
        id: dropdownBackdrop
        parent: root.Window.contentItem
        anchors.fill: parent
        visible: root.activeDropdown !== ""
        z: 190
        onClicked: root.activeDropdown = ""
    }

    SettingsScrollView {
        SettingsHeader {
            icon: "palette"
            title: "Appearance"
            subtitle: "Theme, wallpaper, fonts, opacities, and surface depth."
        }

        // Group 1: Theme & Wallpaper
        SettingsGroup {
            title: "Theme & Wallpaper"
            description: "Choose shell theme and background desktop wallpaper"
            icon: "palette"
            expanded: true

            SettingsSectionLabel { label: "Theme" }

            SettingsCarouselRow {
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

            SettingsSectionLabel { label: "Wallpaper" }

            SettingsCarouselRow {
                id: wallpaperCarousel
                model: WallpaperService.wallpapersList
                cardDelegate: Component {
                    WallpaperCard {
                        required property var modelData
                        required property int index
                        wallpaperPath: modelData.path
                        wallpaperName: modelData.name
                        isApplied: WallpaperService.currentWallpaper === modelData.path
                        isSelected: wallpaperCarousel.currentIndex === index
                        onClicked: {
                            wallpaperCarousel.currentIndex = index
                            WallpaperService.applyWallpaper(modelData.path)
                        }
                    }
                }
            }

            SettingsToggleRow {
                label: "Auto-switch wallpaper with theme"
                checked: WallpaperService.autoSwitchOnThemeChange
                showDivider: false
                onToggled: (val) => WallpaperService.setAutoSwitch(val)
            }
        }

        // Group 2: Typography & Style
        SettingsGroup {
            title: "Typography & Icon Style"
            description: "Font families, base scale, and Material Symbols styling"
            icon: "text_fields"
            expanded: true

            SettingsSliderRow {
                label: "Font size"
                from: 10; to: 24; stepSize: 1
                value: root.fontSize
                unit: " px"
                onMoved: (val) => root.fontSize = val
            }

            SettingsDropdownRow {
                label: "Body font"
                options: root.bodyFontOptions
                selectedValue: Fonts.text
                isOpen: root.activeDropdown === "bodyFont"
                onToggled: root.activeDropdown = (root.activeDropdown === "bodyFont" ? "" : "bodyFont")
                onOptionSelected: (value) => {
                    Fonts.text = value
                    root.activeDropdown = ""
                }
            }

            SettingsDropdownRow {
                label: "Display font"
                options: root.displayFontOptions
                selectedValue: Fonts.display
                isOpen: root.activeDropdown === "displayFont"
                onToggled: root.activeDropdown = (root.activeDropdown === "displayFont" ? "" : "displayFont")
                onOptionSelected: (value) => {
                    Fonts.display = value
                    root.activeDropdown = ""
                }
            }

            SettingsSegmentedRow {
                label: "Icon Style"
                options: root.iconStyles
                selectedValue: Fonts.iconStyle
                onOptionSelected: (value) => Fonts.iconStyle = value
            }

            SettingsSliderRow {
                label: "Icon Weight"
                from: 100; to: 700; stepSize: 50
                value: Fonts.iconWeight
                onMoved: (val) => Fonts.iconWeight = val
            }
        }

        // Group 3: Opacity, Radius & Depth
        SettingsGroup {
            title: "Opacity & Surface Depth"
            description: "Mica transparency, geometry radii, and drop shadows"
            icon: "layers"
            expanded: false

            SettingsSliderRow {
                label: "Main opacity"
                from: 0.0; to: 1.0; stepSize: 0.01
                decimals: 2
                value: Colors.micaAlpha
                onMoved: (val) => Colors.micaAlpha = val
            }

            SettingsSliderRow {
                label: "Secondary opacity"
                from: 0.0; to: 1.0; stepSize: 0.01
                decimals: 2
                value: Colors.micaBeta
                onMoved: (val) => Colors.micaBeta = val
            }

            SettingsSliderRow {
                label: "Spacing unit"
                from: 2; to: 16; stepSize: 1
                value: root.spacingUnit
                unit: " px"
                onMoved: (val) => root.spacingUnit = val
            }

            SettingsSliderRow {
                label: "Small radius"
                from: 0; to: 24; stepSize: 1
                value: root.smallRadius
                unit: " px"
                onMoved: (val) => root.smallRadius = val
            }

            SettingsToggleRow {
                label: "Enable shadow"
                checked: Colors.islandShadowEnabled
                showDivider: false
                onToggled: (val) => Colors.islandShadowEnabled = val
            }

            SettingsColorRow {
                Layout.fillWidth: true
                label: "Shadow color"
                value: Colors.shadowColor
                showDivider: true
                onCommitted: (hex) => Colors.shadowColor = hex
            }

            SettingsSliderRow {
                label: "Shadow softness"
                from: 0.0; to: 1.0; stepSize: 0.01
                decimals: 2
                value: Colors.shadowBlur
                enabled: Colors.islandShadowEnabled
                opacity: Colors.islandShadowEnabled ? 1.0 : 0.4
                onMoved: (val) => Colors.shadowBlur = val
            }

            SettingsSliderRow {
                label: "Shadow spread"
                from: 1.0; to: 2.0; stepSize: 0.05
                decimals: 2
                value: Colors.shadowScale
                enabled: Colors.islandShadowEnabled
                opacity: Colors.islandShadowEnabled ? 1.0 : 0.4
                onMoved: (val) => Colors.shadowScale = val
            }
        }

        // Group 4: Custom Color Overrides
        SettingsGroup {
            title: "Custom Colors & Theme Overrides"
            description: "Toggle theme tracking, light mode, and manual palette colors"
            icon: "color_lens"
            expanded: false

            SettingsToggleRow {
                label: "Light Mode"
                checked: Colors.lightModeEnabled
                showDivider: false
                onToggled: (val) => {
                    if (val !== Colors.lightModeEnabled) Colors.toggleLightMode()
                }
            }

            SettingsToggleRow {
                label: "Colors follow theme"
                checked: Colors.colorsFollowTheme
                showDivider: false
                onToggled: (val) => Colors.colorsFollowTheme = val
            }

            SettingsSectionLabel { label: "Custom Colors — Dark" }

            Repeater {
                model: root.colorKeys
                delegate: SettingsColorRow {
                    Layout.fillWidth: true
                    label: modelData.label
                    value: Colors.hardcodedPalette.dark[modelData.key]
                    showDivider: index !== root.colorKeys.length - 1
                    onCommitted: (hex) => Colors.setHardcodedColor("dark", modelData.key, hex)
                }
            }

            SettingsSectionLabel { label: "Custom Colors — Light" }

            Repeater {
                model: root.colorKeys
                delegate: SettingsColorRow {
                    Layout.fillWidth: true
                    label: modelData.label
                    value: Colors.hardcodedPalette.light[modelData.key]
                    showDivider: index !== root.colorKeys.length - 1
                    onCommitted: (hex) => Colors.setHardcodedColor("light", modelData.key, hex)
                }
            }
        }
    }
}