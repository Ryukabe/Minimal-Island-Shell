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

    MouseArea {
        id: dropdownBackdrop
        parent: root.Window.contentItem
        anchors.fill: parent
        visible: root.activeDropdown !== ""
        z: 190
        onClicked: root.activeDropdown = ""
    }

    ScrollView {
        id: scrollView
        anchors.fill: parent
        clip: true
        contentWidth: availableWidth
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        Item {
            width: scrollView.availableWidth
            implicitHeight: contentCol.implicitHeight + Dimens.paddingLarge

            ColumnLayout {
                id: contentCol
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - Dimens.paddingMedium * 2
                spacing: 12

                SettingsHeader {
                    icon: "palette"
                    title: "Appearance"
                    subtitle: "Theme, wallpaper, fonts, opacities, and surface depth."
                }

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

                SettingsSectionLabel { label: "Typography" }

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

                SettingsSectionLabel { label: "Opacity" }

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

                SettingsSectionLabel { label: "Shape & Depth" }

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

                SettingsSectionLabel { label: "Display" }

                SettingsToggleRow {
                    label: "Light Mode"
                    checked: Colors.lightModeEnabled
                    showDivider: false
                    onToggled: (val) => {
                        if (val !== Colors.lightModeEnabled) Colors.toggleLightMode()
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
        }
    }
}