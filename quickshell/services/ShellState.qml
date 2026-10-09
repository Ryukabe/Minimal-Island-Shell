// services/ShellState.qml
pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    // ================= DEFAULTS (single source of truth) =================
    // Every key here is a persisted setting. Each property below starts from this table,
    // and SettingsStore reads it for resets and for deciding which keys to save.
    readonly property var defaults: ({
        // bar & island
        islandTopMargin: 5,
        islandCornerRadius: 12,
        islandBorderWidth: 0,
        islandClickOutsideDismiss: true,
        islandNotchMode: false,
        islandNotchFlare: 14,
        islandHoverScale: 1.02,
        radiusUniversal: true,
        customRadiusCard: 12,
        customRadiusControl: 6,
        customRadiusChip: 3,
        islandCompactHeight: 36,
        islandCompactWidth: 160,
        islandExpandedHeight: 135,
        islandMinExpandedWidth: 619,
        // island visibility & scroll gestures
        islandAlwaysVisible: true,
        islandRevealOnHover: true,
        islandRevealZone: 6,
        islandHideDelayMs: 600,
        islandScrollVolume: true,
        islandScrollBrightness: true,
        // module sizing
        launcherWidth: 420,
        launcherMaxRows: 7,
        clipboardWidth: 420,
        clipboardMaxRows: 6,
        controlCenterWidth: 580,
        controlCenterHeight: 400,
        notificationCenterWidth: 360,
        notificationCenterMaxHeight: 480,
        powerMenuWidth: 320,
        powerMenuHeight: 76,
        statusPanelWidth: 520,
        statusPanelHeight: 172,
        timerWidth: 320,
        timerHeight: 180,
        // motion
        motionReduced: false,
        motionMovementMs: 480,
        motionFadeMs: 220,
        motionHoverMs: 250,
        motionBouncePercent: 20,
        motionExpressiveBouncePercent: 45,
        motionSpringEnabled: false,
        motionIconsEnabled: true,
        motionIconSpeedPercent: 100,
        motionIconBouncePercent: 50,
        // clock
        clockUse24Hour: false,
        clockShowSeconds: false,
        clockLeadingZero: true,
        clockLowercaseAmPm: false,
        clockDateStyle: 0,
        clockShowVisualizer: true,
        clockShowTimerIcon: true,
        clockShowRecordingIndicator: true,
        timerToastShowRecordingIndicator: true,
        // notifications & focus
        notificationPreviewsEnabled: true,
        focusModeEnabled: false,
        activeFocusMode: "Do Not Disturb",
        notificationAutoHide: true,
        notificationTimeoutMs: 5000,
        notificationRespectAppTimeout: true,
        notificationCriticalBypassFocus: true,
        notificationCriticalSticky: true,
        notificationHistoryLimit: 50,
        notificationMutedApps: [],
        notificationToastMaxWidth: 260,
        notificationOverFullscreen: false,
        notificationGroupExpanded: false,
        notificationGroupPreviewCount: 3,
        // event toasts
        eventToastMs: 2500,
        eventToastDnd: true,
        eventToastCharging: true,
        eventToastAudioOutput: true,
        eventToastAudioInput: true,
        // typography
        fontSizeBase: 15,
        fontBody: "SF Pro Text",
        fontDisplay: "SF Pro Display",
        iconStyle: "Rounded",
        iconWeight: 400,
        iconFilled: false,
        // sound & media
        volumeStep: 5,
        volumeMax: 100,
        lyricsBackend: "Auto",
        defaultPlayer: "Spotify",
        // language & region
        weatherUnit: "°C",
        systemTempUnit: "°C",
        // apps (arrays of desktop-entry ids)
        favouriteApps: [],
        hiddenApps: [],
        // about
        updateAutoCheck: true,
    })

    // ================= NAVIGATION / TRANSIENT STATE (not persisted) =================
    property string activePage: "clock"
    property string previousPage: "clock"
    property bool ignoreHover: false
    property bool settingsOpen: false

    // ================= FOCUS & NOTIFICATIONS =================
    property bool focusModeEnabled: root.defaults.focusModeEnabled
    property string activeFocusMode: root.defaults.activeFocusMode
    property bool notificationPreviewsEnabled: root.defaults.notificationPreviewsEnabled
    property bool notificationAutoHide: root.defaults.notificationAutoHide
    property real notificationTimeoutMs: root.defaults.notificationTimeoutMs
    property bool notificationRespectAppTimeout: root.defaults.notificationRespectAppTimeout
    property bool notificationCriticalBypassFocus: root.defaults.notificationCriticalBypassFocus
    property bool notificationCriticalSticky: root.defaults.notificationCriticalSticky
    property int notificationHistoryLimit: root.defaults.notificationHistoryLimit
    // Always reassign (never push) so change signals fire.
    property var notificationMutedApps: root.defaults.notificationMutedApps
    property real notificationToastMaxWidth: root.defaults.notificationToastMaxWidth
    property bool notificationOverFullscreen: root.defaults.notificationOverFullscreen
    // Notification center grouping: groups start fully open, or show this many before collapsing.
    property bool notificationGroupExpanded: root.defaults.notificationGroupExpanded
    property int notificationGroupPreviewCount: root.defaults.notificationGroupPreviewCount

    // ================= EVENT TOASTS =================
    property real eventToastMs: root.defaults.eventToastMs
    property bool eventToastDnd: root.defaults.eventToastDnd
    property bool eventToastCharging: root.defaults.eventToastCharging
    property bool eventToastAudioOutput: root.defaults.eventToastAudioOutput
    property bool eventToastAudioInput: root.defaults.eventToastAudioInput

    // ================= TYPOGRAPHY =================
    // Fonts.qml and Dimens.qml read these; the Typography page writes them.
    property real fontSizeBase: root.defaults.fontSizeBase            // 15 = 1.0 scale for Dimens.fontSize*
    property string fontBody: root.defaults.fontBody
    property string fontDisplay: root.defaults.fontDisplay
    property string iconStyle: root.defaults.iconStyle                // "Rounded" | "Outlined" | "Sharp"
    property int iconWeight: root.defaults.iconWeight
    property bool iconFilled: root.defaults.iconFilled

    // ================= BAR & ISLAND PROPERTIES =================
    property real islandTopMargin: root.defaults.islandTopMargin
    property real islandCornerRadius: root.defaults.islandCornerRadius
    property real islandBorderWidth: root.defaults.islandBorderWidth
    property bool islandClickOutsideDismiss: root.defaults.islandClickOutsideDismiss
    property bool islandNotchMode: root.defaults.islandNotchMode
    property real islandNotchFlare: root.defaults.islandNotchFlare
    property real islandHoverScale: root.defaults.islandHoverScale

    property real islandCompactHeight: root.defaults.islandCompactHeight
    property real islandCompactWidth: root.defaults.islandCompactWidth
    property real islandExpandedHeight: root.defaults.islandExpandedHeight
    property real islandMinExpandedWidth: root.defaults.islandMinExpandedWidth

    // Visibility: off = the island slides away while idle (clock / timer toast showing).
    property bool islandAlwaysVisible: root.defaults.islandAlwaysVisible
    property bool islandRevealOnHover: root.defaults.islandRevealOnHover
    property real islandRevealZone: root.defaults.islandRevealZone
    property real islandHideDelayMs: root.defaults.islandHideDelayMs
    property bool islandScrollVolume: root.defaults.islandScrollVolume
    property bool islandScrollBrightness: root.defaults.islandScrollBrightness

    // Radius system: universal on = everything follows islandCornerRadius; off = per-kind radii.
    property bool radiusUniversal: root.defaults.radiusUniversal
    property real customRadiusCard: root.defaults.customRadiusCard
    property real customRadiusControl: root.defaults.customRadiusControl
    property real customRadiusChip: root.defaults.customRadiusChip

    // ================= MODULE SIZING PROPERTIES =================
    property real launcherWidth: root.defaults.launcherWidth
    property int launcherMaxRows: root.defaults.launcherMaxRows

    property real clipboardWidth: root.defaults.clipboardWidth
    property int clipboardMaxRows: root.defaults.clipboardMaxRows

    property real controlCenterWidth: root.defaults.controlCenterWidth
    property real controlCenterHeight: root.defaults.controlCenterHeight

    property real notificationCenterWidth: root.defaults.notificationCenterWidth
    property real notificationCenterMaxHeight: root.defaults.notificationCenterMaxHeight

    property real powerMenuWidth: root.defaults.powerMenuWidth
    property real powerMenuHeight: root.defaults.powerMenuHeight

    property real statusPanelWidth: root.defaults.statusPanelWidth
    property real statusPanelHeight: root.defaults.statusPanelHeight

    property real timerWidth: root.defaults.timerWidth
    property real timerHeight: root.defaults.timerHeight

    // ================= UPDATES =================
    property bool updateAutoCheck: root.defaults.updateAutoCheck

    // ================= CLOCK =================
    // Single source of truth for the bar clock AND the Clock settings preview.
    // The two format strings below are derived — never persisted, never set by hand.
    property bool clockUse24Hour: root.defaults.clockUse24Hour
    property bool clockShowSeconds: root.defaults.clockShowSeconds
    property bool clockLeadingZero: root.defaults.clockLeadingZero
    property bool clockLowercaseAmPm: root.defaults.clockLowercaseAmPm
    property int clockDateStyle: root.defaults.clockDateStyle            // 0 = off, 1 = "ddd d", 2 = "ddd d MMM"
    property bool clockShowVisualizer: root.defaults.clockShowVisualizer
    property bool clockShowTimerIcon: root.defaults.clockShowTimerIcon
    property bool clockShowRecordingIndicator: root.defaults.clockShowRecordingIndicator
    property bool timerToastShowRecordingIndicator: root.defaults.timerToastShowRecordingIndicator

    // 12-hour mode always includes an AM/PM token, which is what makes h/hh
    // render as 1-12 instead of 0-23.
    readonly property string clockTimeFormat: {
        const hour = clockUse24Hour
            ? (clockLeadingZero ? "HH" : "H")
            : (clockLeadingZero ? "hh" : "h")
        const seconds = clockShowSeconds ? ":ss" : ""
        const ampm = clockUse24Hour ? "" : (clockLowercaseAmPm ? " ap" : " AP")
        return hour + ":mm" + seconds + ampm
    }

    readonly property string clockDateFormat: clockDateStyle === 2 ? "ddd d MMM" : "ddd d"

    // ================= MOTION & ANIMATIONS =================
    property bool motionReduced: root.defaults.motionReduced
    property real motionMovementMs: root.defaults.motionMovementMs
    property real motionFadeMs: root.defaults.motionFadeMs
    property real motionHoverMs: root.defaults.motionHoverMs
    property real motionBouncePercent: root.defaults.motionBouncePercent
    // Bounce amount for the Expressive tier only (Motion.qml). Independent of
    // motionBouncePercent so frequent motion stays subtle while rare,
    // playful moments can bounce more.
    property real motionExpressiveBouncePercent: root.defaults.motionExpressiveBouncePercent
    property bool motionSpringEnabled: root.defaults.motionSpringEnabled

    // Settings icon animations (SymbolIcon reads these three).
    property bool motionIconsEnabled: root.defaults.motionIconsEnabled
    property real motionIconSpeedPercent: root.defaults.motionIconSpeedPercent
    property real motionIconBouncePercent: root.defaults.motionIconBouncePercent

    // ================= SOUND & MEDIA =================
    // Stored here so they persist. VolumeService / the media module still have to read them.
    property int volumeStep: root.defaults.volumeStep
    property int volumeMax: root.defaults.volumeMax
    property string lyricsBackend: root.defaults.lyricsBackend            // "Auto" | "LRCLIB" | "Local files"
    property string defaultPlayer: root.defaults.defaultPlayer            // "Spotify" | "Firefox" | "mpv" | "Any"

    // ================= LANGUAGE & REGION =================
    property string weatherUnit: root.defaults.weatherUnit                // "°C" | "°F"
    property string systemTempUnit: root.defaults.systemTempUnit          // "°C" | "°F"

    // ================= APPS =================
    // Arrays of desktop-entry ids. Always reassign (never push) so change signals fire.
    property var favouriteApps: root.defaults.favouriteApps
    property var hiddenApps: root.defaults.hiddenApps

    // Keeps Hyprland's own window-manager animations (workspace switches,
    // window open/close, etc.) in sync with the shell's Reduce Motion
    // toggle. This only flips Hyprland's global animations:enabled switch
    // — it never touches which preset is selected in
    // HyprlandAnimationsService, so turning Reduce Motion back off
    // restores whatever preset was already active instead of resetting it.
    onMotionReducedChanged: HyprlandAnimationsService.setEnabled(!motionReduced)

    function motionDuration(ms) {
        return root.motionReduced ? 0 : ms
    }

    function motionOvershoot() {
        return root.motionReduced ? 1.0 : (1.0 + root.motionBouncePercent / 100)
    }

    // Generalized spring-stiffness mapping: shorter user-set duration (ms)
    // -> higher stiffness (snappier convergence). minK/maxK are the actual
    // SpringAnimation.spring range a tier should produce (e.g. 250-550 for
    // the snap tier, 150-400 for the slower glide tier).
    function springStiffnessFor(ms, minMs, maxMs, minK, maxK) {
        var t = Math.max(minMs, Math.min(maxMs, ms))
        var normalized = 1 - (t - minMs) / (maxMs - minMs)
        return minK + normalized * (maxK - minK)
    }

    // Generalized damping mapping: more bounce % -> lower damping (more
    // oscillation before settling). minD/maxD are the actual
    // SpringAnimation.damping range a tier should produce. bouncePercent is
    // optional: omit it to use the shared Bounce slider (motionBouncePercent),
    // pass a value to drive a tier from its own slider.
    function springDampingFor(minD, maxD, bouncePercent) {
        var raw = (bouncePercent === undefined) ? root.motionBouncePercent : bouncePercent
        var b = Math.max(0, Math.min(100, raw))
        return maxD - (b / 100) * (maxD - minD)
    }

    // ================= TIMERS & HELPERS =================
    property Timer hoverResetTimer: Timer {
        interval: 300
        repeat: false
        onTriggered: root.ignoreHover = false
    }

    // Pages that pop up briefly over whatever the user was doing. They never count as the
    // "previous page" to return to.
    function _isFlashPage(page) {
        return page === "notification" || page === "eventtoast"
    }

    function _returnFromFlash() {
        if (root.previousPage === "control" || root.previousPage === "clock" || root.previousPage === "timertoast") {
            root.activePage = root.previousPage
        } else {
            root.activePage = (TimerService.running || TimerService.secondsRemaining > 0) ? "timertoast" : "clock"
        }
    }

    property Timer flashTimer: Timer {
        interval: 1500
        onTriggered: root._returnFromFlash()
    }

    function showPage(page) {
        flashTimer.stop()
        if (!root._isFlashPage(page)) root.previousPage = page
        if (page === "clock" || page === "timertoast") {
            root.ignoreHover = true
            hoverResetTimer.restart()
        }
        root.activePage = page
    }

    function flashPage(page) {
        if (!root._isFlashPage(root.activePage) && root.activePage !== page) root.previousPage = root.activePage
        root.activePage = page
        flashTimer.interval = 1500
        flashTimer.restart()
    }

    // durationMs <= 0 means "stay until dismissFlash() or another showPage()".
    function flashPageFor(page, durationMs) {
        if (!root._isFlashPage(root.activePage) && root.activePage !== page) root.previousPage = root.activePage
        root.activePage = page
        if (durationMs > 0) {
            flashTimer.interval = durationMs
            flashTimer.restart()
        } else {
            flashTimer.stop()
        }
    }

    function dismissFlash() {
        flashTimer.stop()
        root._returnFromFlash()
    }

    function togglePage(page) {
        if (root.activePage === page) {
            showPage((TimerService.running || TimerService.secondsRemaining > 0) ? "timertoast" : "clock")
        } else {
            showPage(page)
        }
    }

    function openSettings() { root.settingsOpen = true }
    function closeSettings() { root.settingsOpen = false }
    function toggleSettings() { root.settingsOpen = !root.settingsOpen }

    // Hook for per-mode backend behavior (deferred: personal/work/calm
    // presets each changing wallpaper/theme/animations/border style — see
    // project notes). The previous mako-based Do Not Disturb implementation
    // has been removed from here: mako is gone from this project —
    // NotificationService.qml owns notifications directly and already
    // gates toast popups on focusModeEnabled itself, so calling makoctl
    // was commanding a daemon that isn't running. Nothing needs to happen
    // here for "Do Not Disturb" anymore; wire real per-mode backends here
    // as they get built.
    function _applyBackendForMode(mode, enabled) {
        // intentionally empty for now
    }

    function toggleFocusMode() {
        focusModeEnabled = !focusModeEnabled
        _applyBackendForMode(activeFocusMode, focusModeEnabled)
    }

    function setFocusMode(name) {
        if (root.focusModeEnabled && root.activeFocusMode === name) {
            toggleFocusMode()
            return
        }
        if (root.focusModeEnabled) _applyBackendForMode(root.activeFocusMode, false)
        root.activeFocusMode = name
        root.focusModeEnabled = true
        _applyBackendForMode(name, true)
    }

    function toggleClipboard() { togglePage("clipboard") }

    Component.onCompleted: {
        // Sync Hyprland's animation switch to whatever motionReduced was
        // restored to at startup (e.g. if it was left true from a
        // previous session), rather than waiting for the next toggle.
        HyprlandAnimationsService.setEnabled(!motionReduced)
    }
}