// styles/Dimens.qml
pragma Singleton
import QtQuick
import "../services"

QtObject {

    // Padding & Spacing
    readonly property int paddingSmall: 6
    readonly property int paddingMedium: 12
    readonly property int paddingLarge: 18
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

    // --- Font scale ---
    // 15 px (the slider's baseline) = 1.0. Every fontSize* token below is
    // its design value multiplied by this scale, so the Appearance
    // "Font size" slider moves all text together.
    readonly property real fontScale: ShellState.fontSizeBase / 15
    function scaledFont(px) {
        return Math.max(1, Math.round(px * fontScale))
    }

    // Font Sizes
    readonly property int fontSizeSm: scaledFont(12)
    readonly property int fontSizeMd: scaledFont(14)
    readonly property int fontSizeLg: scaledFont(16)

    // Component Sizes
    readonly property int barHeight: 40
    readonly property int islandHeight: 40

    // Additional font sizes
    readonly property int fontSizeXs: scaledFont(9)
    readonly property int fontSizeXSm: scaledFont(10)
    readonly property int fontSize11: scaledFont(11)
    readonly property int fontSizeBase: scaledFont(13)
    readonly property int fontSize15: scaledFont(15)
    readonly property int fontSize18: scaledFont(18)
    readonly property int fontSizeXl: scaledFont(20)
    readonly property int fontSizeXxl: scaledFont(22)
    readonly property int fontSizeXxxl: scaledFont(24)
    readonly property int fontSizeHuge: scaledFont(28)
    readonly property int fontSizeMassive: scaledFont(32)
    readonly property int fontSize36: scaledFont(36)
    readonly property int fontSizeDisplay: scaledFont(64)

    // ================= CORNER RADIUS SYSTEM =================
    // Island: ShellState.islandCornerRadius, the master value and the island's own radius.
    // Universal on  -> card follows the island, control = card - paddingSmall, chip = control / 2.
    // Universal off -> card, control and chip each use their own ShellState value.
    // Pills (switch tracks, slider tracks) always use radiusFull.
    readonly property int radiusFull: 9999

    readonly property real radiusIsland: ShellState.islandCornerRadius
    readonly property real radiusCard: ShellState.radiusUniversal
        ? radiusIsland : ShellState.customRadiusCard
    readonly property real radiusControl: ShellState.radiusUniversal
        ? Math.max(0, radiusCard - paddingSmall) : ShellState.customRadiusControl
    readonly property real radiusChip: ShellState.radiusUniversal
        ? Math.round(radiusControl / 2) : ShellState.customRadiusChip

    // Settings UI uses these two names; they are the card and control radii.
    readonly property real settingsContainerRadius: radiusCard
    readonly property real settingsControlRadius: radiusControl

    // --- Old names, kept so files I can't see keep working ---
    // They no longer hold fixed numbers; each one follows the system above.
    // Delete a name once nothing in the shell uses it any more.
    readonly property real radiusXSmall: radiusChip
    readonly property real radiusSmall: radiusChip
    readonly property real radiusTiny: radiusControl
    readonly property real radiusMedium: radiusControl
    readonly property real radiusLarge: radiusCard
    readonly property real radiusMediumLarge: radiusCard
    readonly property real radiusXLarge: radiusCard
    readonly property real radiusXXLarge: radiusCard
    readonly property real borderRadiusSmall: radiusSmall
    readonly property real borderRadiusMedium: radiusMedium
    readonly property real borderRadiusLarge: radiusLarge
    readonly property real islandRadius: radiusIsland

    // Old helper for module files that still compute their own nested radius from the island radius.
    // Those files ignore the component-wise values until they are moved to the tokens above.
    function nestedRadius(outerRadius, gap) {
        return Math.max(0, outerRadius - gap)
    }
}