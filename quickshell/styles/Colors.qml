// styles/Colors.qml
pragma Singleton
import QtQuick
import Quickshell.Io
import "../services"

Item {
    id: root

    property var palette: ({})
    property bool loaded: false
    property bool lightModeEnabled: false

    // Default fallbacks — still used by pick() for foreground/accent/semantic
    // colors. Background entries here are now inert since mainBg/subBg no
    // longer route through pick() at all.
    readonly property var _safetyPalette: ({
        isLight: false,
        background: "#040e0d",
        foreground: "#f5e2c5",
        fgMuted: "#c4b09a",
        surface: "#0f211f",
        border: "#152a26",
        accent: "#3dd1b0",
        red: "#ff6048",
        green: "#7ad9a8",
        yellow: "#f5cd5b",
        blue: "#5fc8d4",
        purple: "#e89aa8",
        cyan: "#3dd1b0"
    })

    FileView {
        id: themeFile
        path: ThemeService.currentThemeJsonPath
        watchChanges: true

        onLoaded: {
            try {
                root.palette = JSON.parse(text());
                root.loaded = true;
            } catch (e) {
                console.log("[Colors] failed to parse quickshell.json:", e);
                root.palette = ({});
                root.loaded = false;
            }
        }
        onLoadFailed: error => {
            console.log("[Colors] failed to load theme file:", error);
            root.palette = ({});
            root.loaded = false;
        }
        onFileChanged: reload()
    }

    readonly property bool themeHasBothVariants: root.loaded
        && root.palette.dark !== undefined
        && root.palette.light !== undefined

    readonly property var activePalette: {
        if (!root.loaded) return ({});
        if (root.themeHasBothVariants) {
            return root.lightModeEnabled ? root.palette.light : root.palette.dark;
        }
        return root.palette;
    }

    function pick(key) {
        var val = root.activePalette[key];
        if (val === undefined) {
            return root._safetyPalette[key] !== undefined ? root._safetyPalette[key] : "#000000";
        }
        return val;
    }

    function toggleLightMode() {
        if (root.themeHasBothVariants) {
            root.lightModeEnabled = !root.lightModeEnabled;
        }
    }

    readonly property bool darkMode: !pick("isLight")

        // ─────────────────────────────────────────────────────────────
    // mainBg / subBg / elevatedBg — fixed, hardcoded pair plus one derived
    // tone. NOT theme-driven. elevatedBg is computed from subBg (not a
    // third hardcoded hex) so it can't drift out of sync with it — it's
    // for anything that needs to read as "raised" above a card (search
    // boxes, hover states, nested inputs) WITHOUT a border line, since
    // borders are being phased out in favor of elevation.
    // ─────────────────────────────────────────────────────────────
    readonly property color mainBg: root.lightModeEnabled ? "#fffcf0" : "#131413"
    readonly property color subBg: root.lightModeEnabled ? "#f5f2e7" : "#1e1e1e"
    readonly property color elevatedBg: root.lightModeEnabled ? Qt.darker(subBg, 1.06) : Qt.lighter(subBg, 1.35)

    // Foreground / accent / semantic colors — still theme-driven, unchanged.
    readonly property color fg: pick("foreground")
    readonly property color fgMuted: pick("fgMuted")
    readonly property color subtext: pick("fgMuted")
    readonly property color border: pick("border")
    readonly property color accent: pick("accent")

    readonly property color red: pick("red")
    readonly property color green: pick("green")
    readonly property color yellow: pick("yellow")
    readonly property color blue: pick("blue")
    readonly property color purple: pick("purple")
    readonly property color cyan: pick("cyan")

    readonly property color black: darkMode ? subBg : border
    readonly property color white: darkMode ? "#ffffff" : subBg

    readonly property color brightBlack: darkMode ? fgMuted : border
    readonly property color brightRed: red
    readonly property color brightGreen: green
    readonly property color brightYellow: yellow
    readonly property color brightBlue: blue
    readonly property color brightPurple: purple
    readonly property color brightCyan: cyan
    readonly property color brightWhite: white

    // Mica Effect — no longer readonly, since Appearance settings now drive
    // these live via sliders. Same default values as before.
    property real micaAlpha: 1.0
    property real micaBeta: 0.80

    // Translucent variants of the two fixed backgrounds above.
    readonly property color mainBgMica: Qt.rgba(mainBg.r, mainBg.g, mainBg.b, micaAlpha)
    readonly property color subBgMica: Qt.rgba(subBg.r, subBg.g, subBg.b, micaBeta)

    // Shared by adapters/* — kept public since color→hex is generic.
    function toHex(c) {
        function h(v) { var s = Math.round(v * 255).toString(16); return s.length < 2 ? "0" + s : s; }
        return "#" + h(c.r) + h(c.g) + h(c.b);
    }
}