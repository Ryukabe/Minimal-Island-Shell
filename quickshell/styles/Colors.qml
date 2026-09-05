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

    // Guards against feedback loops and pre-load overwrites, same pattern
    // used in SettingsStore.qml.
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
            "iconStyle": Fonts.iconStyle,
            "iconWeight": Fonts.iconWeight
        };
        saveProcess.command = ["sh", "-c", "mkdir -p ~/.config/quickshell && echo '" + JSON.stringify(data) + "' > " + root.configPath];
        saveProcess.running = true;
    }

    onMicaAlphaChanged: saveAppearanceConfig()
    onMicaBetaChanged: saveAppearanceConfig()
    onLightModeEnabledChanged: saveAppearanceConfig()

    Connections {
        target: Fonts
        function onIconStyleChanged() { root.saveAppearanceConfig() }
        function onIconWeightChanged() { root.saveAppearanceConfig() }
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

    readonly property color mainBg: root.lightModeEnabled ? "#fffcf0" : "#131413"
    readonly property color subBg: root.lightModeEnabled ? "#f5f2e7" : "#1e1e1e"
    readonly property color elevatedBg: root.lightModeEnabled ? Qt.darker(subBg, 1.08) : Qt.lighter(subBg, 1.35)

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

    readonly property color mainBgMica: Qt.rgba(mainBg.r, mainBg.g, mainBg.b, micaAlpha)
    readonly property color subBgMica: Qt.rgba(subBg.r, subBg.g, subBg.b, micaBeta)

    function toHex(c) {
        if (!c || c.r === undefined) return "#000000";
        function h(v) { var s = Math.round(v * 255).toString(16); return s.length < 2 ? "0" + s : s; }
        return "#" + h(c.r) + h(c.g) + h(c.b);
    }
}