import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"
import "../components/settings"

Item {
    id: root

    property string theme: "rose-pine"
    property real fontSize: 15
    property real spacingUnit: 4
    property real smallRadius: 10

    readonly property var iconStyles: ["Rounded", "Outlined", "Sharp"]

    function cycleIconStyle() {
        var i = iconStyles.indexOf(Fonts.iconStyle)
        Fonts.iconStyle = iconStyles[(i + 1) % iconStyles.length]
    }

    ScrollView {
        id: scrollView
        anchors.fill: parent
        anchors.rightMargin: 6
        clip: true
        contentWidth: availableWidth
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        Item {
            width: scrollView.availableWidth
            implicitHeight: contentCol.implicitHeight + Dimens.paddingLarge

            ColumnLayout {
                id: contentCol
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.min(parent.width - Dimens.paddingMedium * 2, 640)
                spacing: 0

                SettingsHeader {
                    icon: "palette"
                    title: "Appearance"
                    subtitle: "Theme, wallpaper, fonts, corners, and surface depth."
                }

                SettingsSectionLabel { label: "Type" }

                SettingsRow {
                    label: "Theme"
                    value: root.theme
                    showChevron: true
                    onClicked: {} // TODO: wire to ThemeSwitcher module
                }

                SettingsRow {
                    label: "Wallpaper"
                    value: "Choose..."
                    showChevron: true
                    onClicked: {} // TODO: wire to WallpaperSwitcher module
                }

                SettingsSliderRow {
                    label: "Font size"
                    from: 10; to: 24; stepSize: 1
                    value: root.fontSize
                    unit: " px"
                    onMoved: (val) => root.fontSize = val
                }

                SettingsRow {
                    label: "Body font"
                    value: Fonts.text
                    showChevron: true
                    onClicked: {} // TODO: font picker
                }

                SettingsRow {
                    label: "Display font"
                    value: Fonts.display
                    showChevron: true
                    onClicked: {} // TODO: font picker
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
                    onToggled: (val) => {
                        if (val !== Colors.lightModeEnabled) Colors.toggleLightMode()
                    }
                }

                SettingsRow {
                    label: "Icon Style"
                    value: Fonts.iconStyle
                    showChevron: true
                    onClicked: root.cycleIconStyle()
                }

                SettingsSliderRow {
                    label: "Icon Weight"
                    from: 100; to: 700; stepSize: 50
                    value: Fonts.iconWeight
                    onMoved: (val) => Fonts.iconWeight = val
                }

                SettingsSliderRow {
                    label: "Surface Opacity"
                    from: 0.3; to: 1.0; stepSize: 0.05
                    decimals: 2
                    value: Colors.micaBeta
                    onMoved: (val) => Colors.micaBeta = val
                }
            }
        }
    }
}