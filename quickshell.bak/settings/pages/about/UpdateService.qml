// pages/about/UpdateService.qml — real system updates (pacman/yay) and real shell self-update
// (git fetch/pull against github.com/Ryukabe/hermit-dots, branch main). Checks run on creation and on a
// timer; "Recheck" is on demand.
// Not a singleton (no qmldir): SettingsApp.qml creates one instance at shell start so the checks keep
// running while Settings is closed, and hands it to the About page.
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    // Local clone that holds the shell. The installer symlinks ~/.config/quickshell into ~/hermit-dots,
    // so git walks up from here and finds the clone's .git.
    readonly property string repoPath: Quickshell.shellDir
    // Upstream the shell updates from. Fetched by URL, so it works whatever remote the clone has set.
    readonly property string repoUrl: "https://github.com/Ryukabe/hermit-dots.git"
    readonly property string repoBranch: "main"

    function formatTime(date) {
        return date ? Qt.formatDateTime(date, "MMM d, hh:mm AP") : ""
    }

    // --- System package updates (pacman + AUR via yay) ---
    property bool systemChecking: false
    property bool systemChecked: false
    property int systemUpdateCount: 0
    property bool systemJustUpdated: false
    property var systemLastChecked: null
    property var systemLastUpdated: null

    function checkSystemUpdates() {
        root.systemChecking = true
        root.systemChecked = false
        root.systemJustUpdated = false
        systemCheckProc.running = true
    }

    function runSystemUpdate() {
        systemUpdateProc.running = true
    }

    Process {
        id: systemCheckProc
        command: ["yay", "-Qu"]
        stdout: StdioCollector {
            onStreamFinished: {
                let trimmed = text.trim()
                root.systemUpdateCount = trimmed.length > 0 ? trimmed.split("\n").length : 0
                root.systemChecking = false
                root.systemChecked = true
                root.systemLastChecked = new Date()
            }
        }
    }

    Process {
        id: systemUpdateProc
        command: ["kitty", "-e", "yay", "-Syu"]
        onExited: (exitCode, exitStatus) => {
            root.systemJustUpdated = (exitCode === 0)
            if (exitCode === 0) root.systemLastUpdated = new Date()
            root.systemChecked = false
            root.systemUpdateCount = 0
        }
    }

    // --- Shell repo self-update (git) ---
    property bool shellChecking: false
    property bool shellChecked: false
    property bool shellUpdateAvailable: false
    property int shellCommitsBehind: 0
    property bool shellUpdating: false
    property bool shellJustUpdated: false
    // Empty = fine. Set when a check or update fails; About.qml shows it under the card.
    property string shellError: ""
    property var shellLastChecked: null
    property var shellLastUpdated: null

    function checkShellUpdate() {
        root.shellChecking = true
        root.shellChecked = false
        root.shellJustUpdated = false
        root.shellError = ""
        shellFetchProc.running = true
    }

    function runShellUpdate() {
        root.shellUpdating = true
        root.shellError = ""
        shellPullProc.running = true
    }

    Process {
        id: shellFetchProc
        command: ["git", "-C", root.repoPath, "fetch", "--quiet", root.repoUrl, root.repoBranch]
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                shellCountProc.running = true
            } else {
                root.shellChecking = false
                root.shellChecked = true
                root.shellUpdateAvailable = false
                root.shellError = "Couldn't reach GitHub, or this isn't a git clone (installed with --copy?)."
                root.shellLastChecked = new Date()
            }
        }
    }

    Process {
        id: shellCountProc
        command: ["git", "-C", root.repoPath, "rev-list", "--count", "HEAD..FETCH_HEAD"]
        stdout: StdioCollector {
            onStreamFinished: {
                let n = parseInt(text.trim())
                root.shellCommitsBehind = isNaN(n) ? 0 : n
                root.shellUpdateAvailable = root.shellCommitsBehind > 0
                root.shellChecking = false
                root.shellChecked = true
                root.shellLastChecked = new Date()
            }
        }
    }

    Process {
        id: shellPullProc
        command: ["git", "-C", root.repoPath, "pull", "--ff-only", root.repoUrl, root.repoBranch]
        onExited: (exitCode, exitStatus) => {
            root.shellUpdating = false
            if (exitCode === 0) {
                root.shellUpdateAvailable = false
                root.shellCommitsBehind = 0
                root.shellJustUpdated = true
                root.shellLastUpdated = new Date()
            } else {
                root.shellError = "Update failed. Local changes may be in the way; run git pull in your hermit-dots folder to see why."
            }
        }
    }

    // Auto-check once on shell startup instead of waiting for a click.
    Component.onCompleted: {
        checkSystemUpdates()
        checkShellUpdate()
    }

    // Periodic re-check so status doesn't go stale if Settings stays open
    // or the shell runs for a long time between manual visits to this page.
    Timer {
        interval: 15 * 60 * 1000 // 15 minutes
        running: true
        repeat: true
        onTriggered: {
            if (!root.systemChecking) root.checkSystemUpdates()
            if (!root.shellChecking) root.checkShellUpdate()
        }
    }
}