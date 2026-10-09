pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import "../services"

Singleton {
    id: root

    readonly property alias trackedNotifications: server.trackedNotifications
    property var latestNotification: null

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
            root._noteApp(notification.appName)
            root._trimHistory()

            var critical = notification.urgency === NotificationUrgency.Critical

            // Muted apps: no popup, still listed in the notification center.
            if (root.isMuted(notification.appName)) {
                console.log("[NotificationService] muted app — suppressed popup for:", notification.appName)
                return
            }

            // Skip island toast popups when Focus Mode is active (critical ones can bypass it)
            if (ShellState.focusModeEnabled && !(critical && ShellState.notificationCriticalBypassFocus)) {
                console.log("[NotificationService] Focus mode active — suppressed popup for:", notification.appName)
                return
            }

            ShellState.flashPageFor("notification", root._toastDuration(notification, critical))
        }
    }
}