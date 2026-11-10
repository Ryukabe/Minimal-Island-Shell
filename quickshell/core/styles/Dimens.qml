// core/styles/Dimens.qml — spacing, font sizes and corner radii.
//
// padding* is inside a box, spacing* is between things. The short forms (Sm, Md, Lg) are old duplicates
// of Small, Medium and Large and are kept only until the rename pass at the end of Settings V3.
// Spacing follows Appearance > Spacing; font sizes follow Typography > Font size; radii follow Surfaces.
pragma Singleton
import QtQuick
import "../shell"

QtObject {

    // ================= SPACING =================
    // 1.0 is the default. Only padding and spacing follow it, not the radii.
    readonly property real densityScale: ShellState.uiDensity === "Compact" ? 0.85
        : (ShellState.uiDensity === "Roomy" ? 1.2 : 1.0)
    function scaledSpace(px) {
        return Math.max(1, Math.round(px * densityScale))
    }

    readonly property int paddingSmall: scaledSpace(6)
    readonly property int paddingMedium: scaledSpace(12)
    readonly property int paddingLarge: scaledSpace(18)

    readonly property int spacingSmall: scaledSpace(6)
    readonly property int spacingMedium: scaledSpace(12)
    readonly property int spacingLarge: scaledSpace(18)

    // Old names: duplicates of the tokens above
    readonly property int paddingSm: paddingSmall
    readonly property int paddingMd: paddingMedium
    readonly property int paddingLg: paddingLarge
    readonly property int spacingSm: spacingSmall
    readonly property int spacingMd: spacingMedium
    readonly property int spacingLg: spacingLarge

    // ================= FONT SIZES =================
    // 15 px (the slider's baseline) = 1.0. Every fontSize* token is its design value multiplied by this
    // scale, so the Typography "Font size" slider moves all text together.
    readonly property real fontScale: ShellState.fontSizeBase / 15
    function scaledFont(px) {
        return Math.max(1, Math.round(px * fontScale))
    }

    // The main steps
    readonly property int fontSizeXSm: scaledFont(10)
    readonly property int fontSizeSm: scaledFont(12)
    readonly property int fontSizeMd: scaledFont(14)
    readonly property int fontSizeLg: scaledFont(16)
    readonly property int fontSizeXl: scaledFont(20)
    readonly property int fontSizeXxl: scaledFont(22)
    readonly property int fontSizeXxxl: scaledFont(24)
    readonly property int fontSizeHuge: scaledFont(28)
    readonly property int fontSizeMassive: scaledFont(32)
    readonly property int fontSizeDisplay: scaledFont(64)

    // Odd steps in between (used 1 to 4 times each, except the first two)
    readonly property int fontSizeXs: scaledFont(9)       // smaller than XSm despite the name; used a lot
    readonly property int fontSizeBase: scaledFont(13)    // body size; not the slider's fontSizeBase in ShellState
    readonly property int fontSize11: scaledFont(11)
    readonly property int fontSize15: scaledFont(15)
    readonly property int fontSize18: scaledFont(18)
    readonly property int fontSize36: scaledFont(36)

    // ================= CORNER RADIUS SYSTEM =================
    // Island: ShellState.islandCornerRadius, the master value and the island's own radius.
    // Universal on  -> card follows the island, control = card - radiusStep, chip = control / 2.
    // Universal off -> card, control and chip each use their own ShellState value.
    // Pills (switch tracks, slider tracks) always use radiusFull.
    // radiusStep is fixed, so the corners do not change with the spacing setting.
    readonly property int radiusStep: 6
    readonly property int radiusFull: 9999

    readonly property real radiusIsland: ShellState.islandCornerRadius
    readonly property real radiusCard: ShellState.radiusUniversal
        ? radiusIsland : ShellState.customRadiusCard
    readonly property real radiusControl: ShellState.radiusUniversal
        ? Math.max(0, radiusCard - radiusStep) : ShellState.customRadiusControl
    readonly property real radiusChip: ShellState.radiusUniversal
        ? Math.round(radiusControl / 2) : ShellState.customRadiusChip

    // Settings UI uses these two names; they are the card and control radii.
    readonly property real settingsContainerRadius: radiusCard
    readonly property real settingsControlRadius: radiusControl

    // Old names, kept so files that still use them work. Each follows the system above.
    readonly property real radiusSmall: radiusChip
    readonly property real radiusMedium: radiusControl
    readonly property real radiusLarge: radiusCard

    // Old helper for module files that still compute their own nested radius from the island radius.
    function nestedRadius(outerRadius, gap) {
        return Math.max(0, outerRadius - gap)
    }
}