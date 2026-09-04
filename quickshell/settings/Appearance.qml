import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../services"
import "../components/theme"
import "../components/settings"
import "../styles"

Item {
    id: root

    property real fontSize: 15
    property real spacingUnit: 4
    property real smallRadius: 10

    // Tracks currently open floating dropdown ("bodyFont", "displayFont", or "")
    property string activeDropdown: ""

    readonly property var bodyFontOptions: ["Inter", "Roboto", "JetBrains Mono", "Sans-Serif"]
    readonly property var displayFontOptions: ["Cabinet Grotesk", "Inter Display", "Outfit", "SF Pro Display"]
    readonly property var iconStyles: ["Rounded", "Outlined", "Sharp"]

    // Backdrop overlay to dismiss active dropdown when clicking anywhere outside
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
                spacing: 12

                SettingsHeader {
                    icon: "palette"
                    title: "Appearance"
                    subtitle: "Theme, wallpaper, fonts, opacities, and surface depth."
                }

                SettingsSectionLabel { label: "Theme" }

                // --- Live Theme Carousel ---
                Item {
                    Layout.fillWidth: true
                    implicitHeight: 140

                    ListView {
                        id: themeList
                        anchors.fill: parent
                        orientation: ListView.Horizontal
                        spacing: 12
                        clip: true
                        model: ThemeService.themesList

                        WheelHandler {
                            orientation: Qt.Horizontal
                            property: "contentX"
                            rotationScale: 15
                        }

                        delegate: ThemeCard {
                            required property var modelData
                            required property int index

                            themeName: modelData.name
                            isApplied: ThemeService.currentTheme === modelData.name
                            isSelected: themeList.currentIndex === index

                            onClicked: {
                                themeList.currentIndex = index
                                ThemeService.applyTheme(modelData.name)
                            }
                        }
                    }
                }

                SettingsSectionLabel { label: "Wallpaper" }

                // --- Live Wallpaper Carousel ---
                Item {
                    Layout.fillWidth: true
                    implicitHeight: 140

                    ListView {
                        id: wallpaperList
                        anchors.fill: parent
                        orientation: ListView.Horizontal
                        spacing: 12
                        clip: true
                        model: WallpaperService.wallpapersList

                        WheelHandler {
                            orientation: Qt.Horizontal
                            property: "contentX"
                            rotationScale: 15
                        }

                        delegate: WallpaperCard {
                            required property var modelData
                            required property int index

                            wallpaperPath: modelData.path
                            wallpaperName: modelData.name
                            isApplied: WallpaperService.currentWallpaper === modelData.path
                            isSelected: wallpaperList.currentIndex === index

                            onClicked: {
                                wallpaperList.currentIndex = index
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

                // --- Body Font Dropdown ---
                Item {
                    Layout.fillWidth: true
                    implicitHeight: bodyFontRow.implicitHeight
                    z: root.activeDropdown === "bodyFont" ? 200 : 1

                    SettingsRow {
                        id: bodyFontRow
                        anchors.fill: parent
                        label: "Body font"
                        value: Fonts.text
                        showChevron: true
                        onClicked: root.activeDropdown = (root.activeDropdown === "bodyFont" ? "" : "bodyFont")
                    }

                    Rectangle {
                        visible: root.activeDropdown === "bodyFont"
                        width: 240
                        anchors.top: parent.bottom
                        anchors.topMargin: 4
                        anchors.right: parent.right
                        color: Colors.elevatedBg
                        radius: Dimens.radiusMedium
                        border.color: Qt.rgba(1, 1, 1, 0.12)
                        border.width: 1
                        z: 210
                        height: Math.min(bodyFontList.contentHeight + 8, 180)

                        MouseArea {
                            anchors.fill: parent
                            onWheel: (wheel) => {
                                bodyFontList.contentY = Math.max(0, Math.min(bodyFontList.contentY - wheel.angleDelta.y, bodyFontList.contentHeight - bodyFontList.height))
                                wheel.accepted = true
                            }
                        }

                        ListView {
                            id: bodyFontList
                            anchors.fill: parent
                            anchors.margins: 4
                            clip: true
                            model: root.bodyFontOptions

                            delegate: Item {
                                width: bodyFontList.width
                                height: 36

                                property bool isSelected: modelData === Fonts.text
                                property bool isHighlighted: bfMouse.containsMouse || isSelected

                                Rectangle {
                                    anchors.fill: parent
                                    color: isHighlighted ? Colors.accent : "transparent"
                                    opacity: isHighlighted ? (isSelected ? 0.3 : 0.15) : 0
                                    radius: Dimens.radiusSmall
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10

                                    Text {
                                        text: modelData
                                        color: Colors.fg
                                        font.family: modelData
                                        font.pixelSize: Dimens.fontSizeBase
                                    }

                                    Item { Layout.fillWidth: true }

                                    Text {
                                        visible: isSelected
                                        text: "check"
                                        color: Colors.accent
                                        font.family: Fonts.icon
                                        font.pixelSize: Dimens.fontSizeMd
                                    }
                                }

                                MouseArea {
                                    id: bfMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        Fonts.text = modelData
                                        root.activeDropdown = ""
                                    }
                                }
                            }
                        }
                    }
                }

                // --- Display Font Dropdown ---
                Item {
                    Layout.fillWidth: true
                    implicitHeight: displayFontRow.implicitHeight
                    z: root.activeDropdown === "displayFont" ? 200 : 1

                    SettingsRow {
                        id: displayFontRow
                        anchors.fill: parent
                        label: "Display font"
                        value: Fonts.display
                        showChevron: true
                        onClicked: root.activeDropdown = (root.activeDropdown === "displayFont" ? "" : "displayFont")
                    }

                    Rectangle {
                        visible: root.activeDropdown === "displayFont"
                        width: 240
                        anchors.top: parent.bottom
                        anchors.topMargin: 4
                        anchors.right: parent.right
                        color: Colors.elevatedBg
                        radius: Dimens.radiusMedium
                        border.color: Qt.rgba(1, 1, 1, 0.12)
                        border.width: 1
                        z: 210
                        height: Math.min(displayFontList.contentHeight + 8, 180)

                        MouseArea {
                            anchors.fill: parent
                            onWheel: (wheel) => {
                                displayFontList.contentY = Math.max(0, Math.min(displayFontList.contentY - wheel.angleDelta.y, displayFontList.contentHeight - displayFontList.height))
                                wheel.accepted = true
                            }
                        }

                        ListView {
                            id: displayFontList
                            anchors.fill: parent
                            anchors.margins: 4
                            clip: true
                            model: root.displayFontOptions

                            delegate: Item {
                                width: displayFontList.width
                                height: 36

                                property bool isSelected: modelData === Fonts.display
                                property bool isHighlighted: dfMouse.containsMouse || isSelected

                                Rectangle {
                                    anchors.fill: parent
                                    color: isHighlighted ? Colors.accent : "transparent"
                                    opacity: isHighlighted ? (isSelected ? 0.3 : 0.15) : 0
                                    radius: Dimens.radiusSmall
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10

                                    Text {
                                        text: modelData
                                        color: Colors.fg
                                        font.family: modelData
                                        font.pixelSize: Dimens.fontSizeBase
                                    }

                                    Item { Layout.fillWidth: true }

                                    Text {
                                        visible: isSelected
                                        text: "check"
                                        color: Colors.accent
                                        font.family: Fonts.icon
                                        font.pixelSize: Dimens.fontSizeMd
                                    }
                                }

                                MouseArea {
                                    id: dfMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        Fonts.display = modelData
                                        root.activeDropdown = ""
                                    }
                                }
                            }
                        }
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
                    onToggled: (val) => {
                        if (val !== Colors.lightModeEnabled) Colors.toggleLightMode()
                    }
                }

                // --- Icon Style Switcher ---
                RowLayout {
                    Layout.fillWidth: true
                    implicitHeight: 36

                    Text {
                        text: "Icon Style"
                        color: Colors.fg
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeBase
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        implicitWidth: segmentedRow.implicitWidth + 8
                        implicitHeight: 32
                        color: Qt.rgba(1, 1, 1, 0.04)
                        radius: Dimens.radiusMedium
                        border.color: Qt.rgba(1, 1, 1, 0.12)

                        RowLayout {
                            id: segmentedRow
                            anchors.centerIn: parent
                            spacing: 2

                            Repeater {
                                model: root.iconStyles

                                delegate: Rectangle {
                                    required property string modelData
                                    property bool isSelected: Fonts.iconStyle === modelData

                                    implicitWidth: 72
                                    implicitHeight: 26
                                    radius: Dimens.radiusSmall
                                    color: isSelected ? Colors.accent : (segMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent")

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData
                                        color: isSelected ? Colors.fg : Colors.subtext
                                        font.family: Fonts.text
                                        font.pixelSize: Dimens.fontSizeSmall
                                        font.weight: isSelected ? Font.Medium : Font.Normal
                                    }

                                    MouseArea {
                                        id: segMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: Fonts.iconStyle = modelData
                                    }
                                }
                            }
                        }
                    }
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