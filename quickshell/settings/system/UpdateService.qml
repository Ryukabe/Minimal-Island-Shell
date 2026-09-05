// settings/services/UpdateService.qml — real system updates (pacman/yay) and
// real shell self-update (git fetch/pull against this repo). No checks run
// automatically; everything is user-triggered via the Check/Update buttons.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    readonly property string repoPath: Quickshell.shellDir

    // --- System package updates (pacman + AUR via yay) ---
    property bool systemChecking: false
    property bool systemChecked: false
    property int systemUpdateCount: 0
    property bool systemJustUpdated: false

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
            }
        }
    }

    Process {
        id: systemUpdateProc
        command: ["kitty", "-e", "yay", "-Syu"]
        onExited: (exitCode, exitStatus) => {
            root.systemJustUpdated = (exitCode === 0)
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

    function checkShellUpdate() {
        root.shellChecking = true
        root.shellChecked = false
        root.shellJustUpdated = false
        shellFetchProc.running = true
    }

    function runShellUpdate() {
        root.shellUpdating = true
        shellPullProc.running = true
    }

    Process {
        id: shellFetchProc
        command: ["git", "-C", root.repoPath, "fetch", "--quiet"]
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                shellCountProc.running = true
            } else {
                root.shellChecking = false
                root.shellChecked = true
                root.shellUpdateAvailable = false
            }
        }
    }

    Process {
        id: shellCountProc
        command: ["git", "-C", root.repoPath, "rev-list", "--count", "HEAD..@{u}"]
        stdout: StdioCollector {
            onStreamFinished: {
                let n = parseInt(text.trim())
                root.shellCommitsBehind = isNaN(n) ? 0 : n
                root.shellUpdateAvailable = root.shellCommitsBehind > 0
                root.shellChecking = false
                root.shellChecked = true
            }
        }
    }

    Process {
        id: shellPullProc
        command: ["git", "-C", root.repoPath, "pull"]
        onExited: (exitCode, exitStatus) => {
            root.shellUpdating = false
            if (exitCode === 0) {
                root.shellUpdateAvailable = false
                root.shellCommitsBehind = 0
                root.shellJustUpdated = true
            }
        }
    }
}