// styles/Dimens.qml
pragma Singleton
import QtQuick

QtObject {
    // Border Radii
    readonly property int radiusSmall: 4
    readonly property int radiusMedium: 8
    readonly property int radiusLarge: 12
    readonly property int radiusFull: 9999
    readonly property int borderRadiusSmall: radiusSmall
    readonly property int borderRadiusMedium: radiusMedium
    readonly property int borderRadiusLarge: radiusLarge

    // Padding & Spacing
    readonly property int paddingSmall: 8
    readonly property int paddingMedium: 14
    readonly property int paddingLarge: 20
    readonly property int paddingSm: paddingSmall
    readonly property int paddingMd: paddingMedium
    readonly property int paddingLg: paddingLarge

    readonly property int spacingSmall: 6
    readonly property int spacingMedium: 12
    readonly property int spacingLarge: 18
    readonly property int spacingSm: spacingSmall
    readonly property int spacingMd: spacingMedium
    readonly property int spacingLg: spacingLarge

    readonly property int marginSmall: 6
    readonly property int marginMedium: 12
    readonly property int marginLg: marginMedium

    // Font Sizes
    readonly property int fontSizeSm: 12
    readonly property int fontSizeMd: 14
    readonly property int fontSizeLg: 16

    // Component Sizes
    readonly property int barHeight: 40
    readonly property int islandHeight: 40
    readonly property int radiusXSmall: 2
    readonly property int radiusTiny: 6
    readonly property int radiusMediumLarge: 14
    readonly property int radiusXLarge: 18
    readonly property int radiusXXLarge: 20

    // Additional font sizes
    readonly property int fontSizeXs: 9
    readonly property int fontSizeXSm: 10
    readonly property int fontSizeBase: 13
    readonly property int fontSize15: 15
    readonly property int fontSizeXl: 20
    readonly property int fontSizeXxl: 22
    readonly property int fontSizeXxxl: 24
    readonly property int fontSizeHuge: 28
    readonly property int fontSizeMassive: 32
    readonly property int fontSizeDisplay: 64

    // Island radius    
    readonly property int islandRadius: 10
}