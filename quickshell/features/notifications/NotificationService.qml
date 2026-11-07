pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import "../../core/shell"

Singleton {
    id: root

    readonly property alias trackedNotifications: server.trackedNotifications
    readonly property int count: server.trackedNotifications.values.length
    property var latestNotification: null
    // When the popup for latestNotification appeared (Detailed and Interactive popups show the time).
    property var latestReceivedAt: null

    // App names seen this session. The Alerts page lists these together with the muted ones,
    // so a muted app stays listed (and can be un-muted) even before it speaks again.
    property var seenApps: []
    readonly property var appNames: {
        var all = root.seenApps.concat(ShellState.notificationMutedApps)
        var out = []
        for (var i = 0; i < all.length; i++) {
            if (all[i] && out.indexOf(all[i]) < 0) out.push(all[i])
        }
        out.sort()
        return out
    }

    function isMuted(app) {
        return ShellState.notificationMutedApps.indexOf(app) >= 0
    }

    function setMuted(app, muted) {
        var next = ShellState.notificationMutedApps.filter(a => a !== app)
        if (muted) next.push(app)
        ShellState.notificationMutedApps = next
    }

    function _noteApp(app) {
        if (!app || root.seenApps.indexOf(app) >= 0) return
        root.seenApps = root.seenApps.concat([app])
    }

    // Dismisses every notification in the center. Used by the center's "Clear all" and by Settings.
    function clearAll() {
        const items = [...server.trackedNotifications.values]
        for (let i = 0; i < items.length; i++) items[i].dismiss()
    }

    // ---- Snooze ----
    // Hides the popup now and shows this notification again after `minutes`, if it is still in the
    // center and Focus is off by then. The reminder stays up until you click it.
    function snooze(notification, minutes) {
        if (!notification) return
        ShellState.dismissFlash()
        snoozeTimerComp.createObject(root, { notification: notification, interval: minutes * 60000 }).start()
    }

    Component {
        id: snoozeTimerComp

        Timer {
            property var notification: null
            repeat: false
            onTriggered: {
                const stillThere = notification && server.trackedNotifications.values.indexOf(notification) >= 0
                if (stillThere && !ShellState.focusModeEnabled) {
                    root.latestNotification = notification
                    root.latestReceivedAt = new Date()
                    root.playSound(false)
                    ShellState.flashPageFor("notification", 0)
                }
                destroy()
            }
        }
    }

    // ---- Sound ----
    // Off: silent. Default: the system's "new message" sound. Custom: the file chosen in Settings.
    // wav / ogg / flac go through pw-play (starts at once); anything else (mp3, m4a, ...) through ffplay.
    // A custom mode with no file chosen yet falls back to the default sound.
    property real _lastSoundMs: 0

    function _soundCommand() {
        const mode = ShellState.notificationSoundMode
        if (mode === "Off") return []

        let file = (ShellState.notificationSoundFile || "").trim()
        if (mode === "Custom" && file !== "") {
            file = file.replace(/^file:\/\//, "").replace(/^~(?=\/|$)/, Quickshell.env("HOME"))
            const ext = file.split(".").pop().toLowerCase()
            if (["wav", "ogg", "oga", "flac"].indexOf(ext) >= 0) return ["pw-play", file]
            return ["ffplay", "-nodisp", "-autoexit", "-loglevel", "quiet", file]
        }
        return ["canberra-gtk-play", "-i", "message-new-instant"]
    }

    // `test` skips the short cool-down that stops a chatty app from machine-gunning the sound.
    function playSound(test) {
        const cmd = root._soundCommand()
        if (cmd.length === 0) return
        const now = Date.now()
        if (test !== true && now - root._lastSoundMs < 400) return
        root._lastSoundMs = now
        Quickshell.execDetached(cmd)
    }

    // Keeps the notification center to the history limit by dismissing the oldest ones.
    // Runs when a new notification arrives, never when the slider moves.
    function _trimHistory() {
        var list = server.trackedNotifications.values
        var excess = list.length - ShellState.notificationHistoryLimit
        for (var i = 0; i < excess; i++) list[i].dismiss()
    }

    // How long the toast stays up, in ms. 0 means "until clicked".
    // Quickshell's expireTimeout is in SECONDS (<= 0 means the app didn't ask for one).
    function _toastDuration(notification, critical) {
        if (critical && ShellState.notificationCriticalSticky) return 0
        if (!ShellState.notificationAutoHide) return 0
        if (ShellState.notificationRespectAppTimeout && notification.expireTimeout > 0)
            return Math.round(notification.expireTimeout * 1000)
        return ShellState.notificationTimeoutMs
    }

    NotificationServer {
        id: server
        keepOnReload: false
        bodySupported: true
        imageSupported: true
        actionsSupported: true

        onNotification: (notification) => {
            notification.tracked = true
            root.latestNotification = notification
            root.latestReceivedAt = new Date()
            root._noteApp(notification.appName)
            root._trimHistory()

            var critical = notification.urgency === NotificationUrgency.Critical

            // Muted apps: no popup and no sound, still listed in the notification center.
            if (root.isMuted(notification.appName)) {
                console.log("[NotificationService] muted app — suppressed popup for:", notification.appName)
                return
            }

            // Skip island toast popups when Focus Mode is active (critical ones can bypass it)
            if (ShellState.focusModeEnabled && !(critical && ShellState.notificationCriticalBypassFocus)) {
                console.log("[NotificationService] Focus mode active — suppressed popup for:", notification.appName)
                return
            }

            root.playSound(false)
            ShellState.flashPageFor("notification", root._toastDuration(notification, critical))
        }
    }
}