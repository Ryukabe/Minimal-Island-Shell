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

    ColumnLayout {
        anchors.fill: parent
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

        Item { Layout.fillHeight: true }
    }
}