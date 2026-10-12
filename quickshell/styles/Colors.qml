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

    // ================= THEME MODE =================
    // "Dark" | "Light" | "Auto". lightModeEnabled below is derived from this.
    property string themeMode: "Dark"

    // Auto schedule. "Location" = light while the sun is up at the location picked
    // in Language & Region. "Custom" = light between the two times below.
    property string autoSource: "Location"
    property int autoLightStartMin: 360     // minutes after midnight (06:00)
    property int autoLightEndMin: 1080      // 18:00

    property real _nowMs: Date.now()
    readonly property bool _hasLocation: LocationService.hasLocation

    // True when the sun is above the horizon at (latDeg, lonDeg) at time ms.
    // Plain solar-position maths, no timezone needed.
    function _sunIsUp(ms, latDeg, lonDeg) {
        var rad = Math.PI / 180;
        var n = ms / 86400000 - 10957.5;                       // days since J2000.0
        var L = (280.460 + 0.9856474 * n) % 360;
        var g = (357.528 + 0.9856003 * n) * rad;
        var lambda = (L + 1.915 * Math.sin(g) + 0.020 * Math.sin(2 * g)) * rad;
        var eps = (23.439 - 0.0000004 * n) * rad;
        var dec = Math.asin(Math.sin(eps) * Math.sin(lambda));
        var ra = Math.atan2(Math.cos(eps) * Math.sin(lambda), Math.cos(lambda));
        var gmst = (280.46061837 + 360.98564736629 * n) * rad;
        var ha = gmst + lonDeg * rad - ra;
        var lat = latDeg * rad;
        var sinAlt = Math.sin(lat) * Math.sin(dec) + Math.cos(lat) * Math.cos(dec) * Math.cos(ha);
        return Math.asin(sinAlt) > -0.833 * rad;               // standard sunrise/sunset horizon
    }

    readonly property bool _autoIsLight: {
        if (root.autoSource === "Location" && LocationService.hasLocation)
            return root._sunIsUp(root._nowMs, LocationService.latitude, LocationService.longitude);
        // Wall time at the picked location (system time if none is picked).
        var d = LocationService.localize(new Date(root._nowMs));
        var m = d.getHours() * 60 + d.getMinutes();
        if (root.autoLightStartMin <= root.autoLightEndMin)
            return m >= root.autoLightStartMin && m < root.autoLightEndMin;
        return m >= root.autoLightStartMin || m < root.autoLightEndMin;   // window crosses midnight
    }

    readonly property bool lightModeEnabled:
        themeMode === "Light" || (themeMode === "Auto" && _autoIsLight)

    Timer {
        interval: 60000
        repeat: true
        running: root.themeMode === "Auto"
        triggeredOnStart: true
        onTriggered: root._nowMs = Date.now()
    }

    // ================= TRANSPARENCY & SHADOW =================
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

    // ================= PALETTE SOURCE =================
    // "Prebuilt" | "Dynamic" | "Custom".
    // Custom reads hardcodedPalette (still split by light/dark, so Light mode
    // while on Custom swaps to a sane hardcoded pair). Prebuilt and Dynamic
    // read the active theme file.
    // TODO(dynamic): Dynamic currently behaves exactly like Prebuilt. When the
    // wallpaper palette generator exists, point the theme loader / activePalette
    // at its output whenever paletteSource === "Dynamic".
    property string paletteSource: "Prebuilt"
    readonly property bool colorsFollowTheme: paletteSource !== "Custom"

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

    readonly property string configPath: Quickshell.env("HOME") + "/.config/quickshell/state/appearance.json"

    // --- Safety Palette ---
    // Last-resort fallback when the theme file is missing/unparseable.
    // Values come from the Hermit palette.json (v2.0.0, dark).
    // border = #8C8C8C at 12% opacity, pre-blended over background (#101010) -> #1F1F1F.
    readonly property var _safetyPalette: ({
        isLight: false,
        background: "#101010",
        foreground: "#F6F1EA",
        fgMuted: "#8C8C8C",
        surface: "#1C1C1C",
        border: "#1F1F1F",
        accent: "#77B0A8",
        red: "#DF5B61",
        green: "#8CCF7E",
        yellow: "#E5C76B",
        blue: "#67B0E8",
        purple: "#C488EC",
        cyan: "#6CBFBF"
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
                // New keys win; old keys migrate existing saved configs.
                if (data.themeMode !== undefined) root.themeMode = data.themeMode;
                else if (data.lightModeEnabled !== undefined) root.themeMode = data.lightModeEnabled ? "Light" : "Dark";
                if (data.autoSource !== undefined) root.autoSource = data.autoSource;
                if (data.autoLightStartMin !== undefined) root.autoLightStartMin = data.autoLightStartMin;
                if (data.autoLightEndMin !== undefined) root.autoLightEndMin = data.autoLightEndMin;
                if (data.reduceTransparency !== undefined) root.reduceTransparency = data.reduceTransparency;
                if (data.paletteSource !== undefined) root.paletteSource = data.paletteSource;
                else if (data.colorsFollowTheme !== undefined) root.paletteSource = data.colorsFollowTheme ? "Prebuilt" : "Custom";
                if (data.hardcodedPalette !== undefined) root.hardcodedPalette = data.hardcodedPalette;
                if (data.islandShadowEnabled !== undefined) root.islandShadowEnabled = data.islandShadowEnabled;
                if (data.shadowColor !== undefined) root.shadowColor = data.shadowColor;
                if (data.shadowOpacity !== undefined) root.shadowOpacity = data.shadowOpacity;
                if (data.shadowBlur !== undefined) root.shadowBlur = data.shadowBlur;
                if (data.shadowScale !== undefined) root.shadowScale = data.shadowScale;
                if (data.shadowVerticalOffset !== undefined) root.shadowVerticalOffset = data.shadowVerticalOffset;
                // iconStyle / iconWeight are owned by ShellState now (Fonts only reads them), so they are
                // not loaded from this file any more.
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
            "themeMode": root.themeMode,
            "autoSource": root.autoSource,
            "autoLightStartMin": root.autoLightStartMin,
            "autoLightEndMin": root.autoLightEndMin,
            "reduceTransparency": root.reduceTransparency,
            "paletteSource": root.paletteSource,
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
    onThemeModeChanged: saveAppearanceConfig()
    onAutoSourceChanged: saveAppearanceConfig()
    onAutoLightStartMinChanged: saveAppearanceConfig()
    onAutoLightEndMinChanged: saveAppearanceConfig()
    onReduceTransparencyChanged: saveAppearanceConfig()
    onPaletteSourceChanged: saveAppearanceConfig()
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

    // Single gate for every color below. When paletteSource is "Custom",
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

    // Bright terminal colors (kitty color8-15). Prefers an explicit
    // "bright" block in the active theme's quickshell.json — e.g.
    // "bright": { "black": "#...", "red": "#...", ... "white": "#..." }
    // — and only falls back to a computed lighten of the matching base
    // color when paletteSource is Custom (hardcoded palette has no
    // bright entries) or the current theme hasn't defined its own set yet.
    function pickBright(key, baseColor) {
        if (root.colorsFollowTheme) {
            var brightSet = root.activePalette.bright;
            if (brightSet && brightSet[key] !== undefined) return brightSet[key];
        }
        return Qt.lighter(baseColor, 1.4);
    }

    // Switches between fixed Dark and Light. If called while in Auto, it
    // leaves Auto and pins the opposite of whatever is showing right now.
    function toggleLightMode() {
        if (root.themeHasBothVariants) {
            root.themeMode = root.lightModeEnabled ? "Dark" : "Light";
        }
    }

    readonly property bool darkMode: !pick("isLight")

    readonly property color elevatedBg: root.lightModeEnabled ? Qt.darker(bgsur, 1.18) : Qt.lighter(bgsur, 1.25)

    // All of these already route through pick(), so the palette source
    // applies to every one of them automatically — no per-property
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

    readonly property color brightBlack: pickBright("black", black)
    readonly property color brightRed: pickBright("red", red)
    readonly property color brightGreen: pickBright("green", green)
    readonly property color brightYellow: pickBright("yellow", yellow)
    readonly property color brightBlue: pickBright("blue", blue)
    readonly property color brightPurple: pickBright("purple", purple)
    readonly property color brightCyan: pickBright("cyan", cyan)
    readonly property color brightWhite: pickBright("white", white)

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