// styles/Colors.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../services"

Item {
    id: root

    property var palette: ({})
    property bool loaded: false
    property bool lightModeEnabled: false

    property real micaAlpha: 1.0
    property real micaBeta: 0.80

    property bool reduceTransparency: false

    // Island drop-shadow — persisted the same way as micaAlpha/micaBeta.
    // shadowBlur = edge softness (0-1). shadowScale = how far the halo
    // reaches outward before blurring — this is the "left/right spread"
    // knob; blur alone doesn't push it wider, it just softens the edge.
    property bool islandShadowEnabled: true
    property color shadowColor: "#000000"
    property real shadowOpacity: 0.55
    property real shadowBlur: 0.75
    property real shadowScale: 1.25
    property real shadowVerticalOffset: 6

    // When true (default), every pick()-based color tracks the active
    // theme as usual. When false, pick() reads from hardcodedPalette
    // instead — still split by light/dark, so toggling Light Mode while
    // frozen still swaps to a sane hardcoded pair rather than one fixed
    // set for both modes.
    property bool colorsFollowTheme: true

    property var hardcodedPalette: ({
        dark: {
            background: "#131413",
            surface: "#1e1e1e",
            foreground: "#f5e2c5",
            fgMuted: "#c4b09a",
            border: "#152a26",
            accent: "#3dd1b0",
            red: "#ff6048",
            green: "#7ad9a8",
            yellow: "#f5cd5b",
            blue: "#5fc8d4",
            purple: "#e89aa8",
            cyan: "#3dd1b0"
        },
        light: {
            background: "#fffcf0",
            surface: "#f5f2e7",
            foreground: "#1a1a1a",
            fgMuted: "#5a5a5a",
            border: "#dddddd",
            accent: "#2a9d8f",
            red: "#d1453d",
            green: "#4a9d6f",
            yellow: "#b8932e",
            blue: "#3a8fa0",
            purple: "#b06a7a",
            cyan: "#2a9d8f"
        }
    })

    property bool _configLoaded: false
    property bool _applyingConfig: false

    readonly property string configPath: Quickshell.env("HOME") + "/.config/quickshell/appearance.json"

    // --- Safety Palette ---
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

    // --- Configuration Persistence ---
    FileView {
        id: appearanceConfigFile
        path: root.configPath
        watchChanges: true
        onLoaded: {
            root._applyingConfig = true
            try {
                var data = JSON.parse(text());
                if (data.micaAlpha !== undefined) root.micaAlpha = data.micaAlpha;
                if (data.micaBeta !== undefined) root.micaBeta = data.micaBeta;
                if (data.lightModeEnabled !== undefined) root.lightModeEnabled = data.lightModeEnabled;
                if (data.reduceTransparency !== undefined) root.reduceTransparency = data.reduceTransparency;
                if (data.colorsFollowTheme !== undefined) root.colorsFollowTheme = data.colorsFollowTheme;
                if (data.hardcodedPalette !== undefined) root.hardcodedPalette = data.hardcodedPalette;
                if (data.islandShadowEnabled !== undefined) root.islandShadowEnabled = data.islandShadowEnabled;
                if (data.shadowColor !== undefined) root.shadowColor = data.shadowColor;
                if (data.shadowOpacity !== undefined) root.shadowOpacity = data.shadowOpacity;
                if (data.shadowBlur !== undefined) root.shadowBlur = data.shadowBlur;
                if (data.shadowScale !== undefined) root.shadowScale = data.shadowScale;
                if (data.shadowVerticalOffset !== undefined) root.shadowVerticalOffset = data.shadowVerticalOffset;
                if (data.iconStyle !== undefined) Fonts.iconStyle = data.iconStyle;
                if (data.iconWeight !== undefined) Fonts.iconWeight = data.iconWeight;
            } catch (e) {
                console.log("[Colors] Config parse error:", e);
            }
            root._applyingConfig = false
            root._configLoaded = true
        }
        onLoadFailed: error => {
            root._configLoaded = true
        }
    }

    Process {
        id: saveProcess
    }

    function saveAppearanceConfig() {
        if (!root._configLoaded || root._applyingConfig) return;
        var data = {
            "micaAlpha": root.micaAlpha,
            "micaBeta": root.micaBeta,
            "lightModeEnabled": root.lightModeEnabled,
            "reduceTransparency": root.reduceTransparency,
            "colorsFollowTheme": root.colorsFollowTheme,
            "hardcodedPalette": root.hardcodedPalette,
            "islandShadowEnabled": root.islandShadowEnabled,
            "shadowColor": root.toHex(root.shadowColor),
            "shadowOpacity": root.shadowOpacity,
            "shadowBlur": root.shadowBlur,
            "shadowScale": root.shadowScale,
            "shadowVerticalOffset": root.shadowVerticalOffset,
            "iconStyle": Fonts.iconStyle,
            "iconWeight": Fonts.iconWeight
        };
        saveProcess.command = ["sh", "-c", "mkdir -p ~/.config/quickshell && echo '" + JSON.stringify(data) + "' > " + root.configPath];
        saveProcess.running = true;
    }

    onMicaAlphaChanged: saveAppearanceConfig()
    onMicaBetaChanged: saveAppearanceConfig()
    onLightModeEnabledChanged: saveAppearanceConfig()
    onReduceTransparencyChanged: saveAppearanceConfig()
    onColorsFollowThemeChanged: saveAppearanceConfig()
    onHardcodedPaletteChanged: saveAppearanceConfig()
    onIslandShadowEnabledChanged: saveAppearanceConfig()
    onShadowColorChanged: saveAppearanceConfig()
    onShadowOpacityChanged: saveAppearanceConfig()
    onShadowBlurChanged: saveAppearanceConfig()
    onShadowScaleChanged: saveAppearanceConfig()
    onShadowVerticalOffsetChanged: saveAppearanceConfig()

    Connections {
        target: Fonts
        function onIconStyleChanged() { root.saveAppearanceConfig() }
        function onIconWeightChanged() { root.saveAppearanceConfig() }
    }

    // Call this to edit one hardcoded color. `mode` is "dark" or "light",
    // `key` matches the quickshell.json keys (background, surface,
    // foreground, fgMuted, border, accent, red, green, yellow, blue,
    // purple, cyan). Reassigns the whole object since QML doesn't emit
    // change notifications for in-place mutation of nested `var` props.
    function setHardcodedColor(mode, key, hexValue) {
        var next = JSON.parse(JSON.stringify(root.hardcodedPalette));
        if (!next[mode]) next[mode] = {};
        next[mode][key] = hexValue;
        root.hardcodedPalette = next;
    }

    // --- Theme Loader ---
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

    // Single gate for every color below. When colorsFollowTheme is off,
    // reads from hardcodedPalette[mode] first; falls through to the
    // theme/safety palette only if that key is missing there too.
    function pick(key) {
        if (!root.colorsFollowTheme) {
            var mode = root.lightModeEnabled ? "light" : "dark";
            var hc = root.hardcodedPalette[mode];
            if (hc && hc[key] !== undefined) return hc[key];
        }
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

    readonly property color elevatedBg: root.lightModeEnabled ? Qt.darker(bgsur, 1.08) : Qt.lighter(bgsur, 1.35)

    // All of these already route through pick(), so the colorsFollowTheme
    // toggle applies to every one of them automatically — no per-property
    // changes needed below this line.
    readonly property color bg: pick("background")
    readonly property color bgsur: pick("surface")
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

    readonly property color black: darkMode ? subBgMica : border
    readonly property color white: darkMode ? subBgMica : border

    readonly property real _effectiveMicaAlpha: root.reduceTransparency ? 1.0 : root.micaAlpha
    readonly property real _effectiveMicaBeta: root.reduceTransparency ? 1.0 : root.micaBeta

    readonly property color mainBgMica: Qt.rgba(bg.r, bg.g, bg.b, root._effectiveMicaAlpha)
    readonly property color subBgMica: Qt.rgba(bgsur.r, bgsur.g, bgsur.b, root._effectiveMicaBeta)

    function toHex(c) {
        if (!c || c.r === undefined) return "#000000";
        function h(v) { var s = Math.round(v * 255).toString(16); return s.length < 2 ? "0" + s : s; }
        return "#" + h(c.r) + h(c.g) + h(c.b);
    }
}