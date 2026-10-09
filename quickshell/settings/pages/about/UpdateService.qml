// pages/about/UpdateService.qml — update checks for About: system packages (pacman) and the shell (git).
// Plain component (no qmldir). SettingsApp.qml creates one and hands it to About.qml.
//   System: `checkupdates` (package pacman-contrib) counts pending updates. "Update Now" opens
//           `terminal` running `sudo pacman -Syu`, so you see the prompts. Change `terminal` if needed.
//   Shell:  finds the git clone behind the shell folder (follows the symlink), fetches `branch` from the
//           project repo and counts commits behind/ahead. "Update Shell" only ever fast-forwards.
//           A copy install (not a git checkout) reports that it cannot self-update.
//   Auto:   while ShellState.updateAutoCheck is on, checks shortly after start and then periodically.
import QtQuick
import Quickshell
import Quickshell.Io
import "../../core"
import "../../../services"

Item {
    id: root
    visible: false

    // ---- configuration
    property string repoDir: ""                    // empty = the shell folder (symlink is followed)
    property string branch: "main"
    property string terminal: "kitty"
    property int autoCheckStartDelayMs: 60000      // first automatic check after the shell starts
    property int autoCheckIntervalMs: 21600000     // then every 6 hours
    readonly property string repoUrl: SettingsRegistry.projectRepo

    // ---- system packages
    property bool systemChecked: false
    property bool systemChecking: false
    property bool systemUpdating: false
    property int systemUpdateCount: 0
    property var systemLastChecked: null
    property var systemLastUpdated: null
    property bool systemJustUpdated: false
    property string systemError: ""

    // ---- shell (hermit-dots)
    property bool shellChecked: false
    property bool shellChecking: false
    property bool shellUpdating: false
    property bool shellUpdateAvailable: false
    property int shellCommitsBehind: 0
    property int shellCommitsAhead: 0              // local commits that are not on the remote
    property bool shellOutsideConfig: false        // an update touches files outside config/
    property string shellPreviousCommit: ""        // short hash before the last update
    property var shellLastChecked: null
    property var shellLastUpdated: null
    property bool shellJustUpdated: false
    property string shellError: ""

    // Pending-update count from before "Update Now", so the re-check can tell whether it worked.
    property int _countBeforeUpdate: -1

    function formatTime(d) {
        if (!d) return ""
        const now = new Date()
        const t = Qt.formatTime(d, ShellState.clockUse24Hour ? "HH:mm" : "h:mm AP")
        const sameDay = (a, b) => a.getFullYear() === b.getFullYear()
            && a.getMonth() === b.getMonth() && a.getDate() === b.getDate()
        if (sameDay(d, now)) return "Today, " + t
        const yesterday = new Date(now.getFullYear(), now.getMonth(), now.getDate() - 1)
        if (sameDay(d, yesterday)) return "Yesterday, " + t
        return Qt.formatDate(d, "d MMM") + ", " + t
    }

    function _dir() { return root.repoDir !== "" ? root.repoDir : Quickshell.shellDir }

    function checkAll() {
        root.checkSystemUpdates()
        root.checkShellUpdate()
    }

    // ================= automatic checks =================
    Timer {
        interval: root.autoCheckStartDelayMs
        running: true
        repeat: false
        onTriggered: if (ShellState.updateAutoCheck) root.checkAll()
    }

    Timer {
        interval: root.autoCheckIntervalMs
        running: ShellState.updateAutoCheck
        repeat: true
        onTriggered: root.checkAll()
    }

    Connections {
        target: ShellState
        function onUpdateAutoCheckChanged() {
            if (ShellState.updateAutoCheck) root.checkAll()
        }
    }

    // ================= system packages =================
    function checkSystemUpdates() {
        if (root.systemChecking || root.systemUpdating) return
        root.systemChecking = true
        root.systemError = ""
        sysCheck.running = true
    }

    function runSystemUpdate() {
        if (root.systemUpdating || root.systemChecking) return
        root.systemUpdating = true
        root.systemJustUpdated = false
        root._countBeforeUpdate = root.systemUpdateCount
        sysUpdate.command = [root.terminal, "-e", "sh", "-c",
            "sudo pacman -Syu; echo; echo 'Finished. Press Enter to close.'; read -r _"]
        sysUpdate.running = true
    }

    Process {
        id: sysCheck
        // checkupdates exits 0 = updates found, 2 = none, anything else = failed.
        command: ["sh", "-c",
            "if ! command -v checkupdates >/dev/null 2>&1; then echo -1; exit 0; fi; "
            + "out=$(checkupdates 2>/dev/null); rc=$?; "
            + "if [ $rc -eq 0 ]; then echo \"$out\" | wc -l; elif [ $rc -eq 2 ]; then echo 0; else echo -2; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.systemChecking = false
                const n = parseInt(text.trim())
                if (isNaN(n) || n < 0) {
                    root.systemError = n === -1 ? "checkupdates is not installed (pacman-contrib)"
                                                : "Couldn't check for updates"
                    root._countBeforeUpdate = -1
                    return
                }
                root.systemUpdateCount = n
                root.systemChecked = true
                root.systemLastChecked = new Date()
                if (root._countBeforeUpdate >= 0) {
                    if (n < root._countBeforeUpdate) {
                        root.systemLastUpdated = new Date()
                        root.systemJustUpdated = true
                    }
                    root._countBeforeUpdate = -1
                }
            }
        }
    }

    Process {
        id: sysUpdate
        onRunningChanged: {
            if (!running && root.systemUpdating) {
                root.systemUpdating = false
                root.checkSystemUpdates()
            }
        }
    }

    // ================= shell (git) =================
    // Shared prefix: resolve the clone behind the shell folder. $1 = folder, $2 = url, $3 = branch.
    readonly property string _findRepo: [
        "export GIT_TERMINAL_PROMPT=0",
        "d=$(readlink -f \"$1\" 2>/dev/null)",
        "top=$(git -C \"$d\" rev-parse --show-toplevel 2>/dev/null) || { echo \"error=Not a git checkout (copy installs can't self-update)\"; exit 0; }",
        "cd \"$top\" || { echo \"error=Shell folder not found\"; exit 0; }"
    ].join("\n")

    function checkShellUpdate() {
        if (root.shellChecking || root.shellUpdating) return
        root.shellChecking = true
        root.shellError = ""
        shellCheck.command = ["sh", "-c", root._findRepo + "\n" + [
            "git fetch --quiet \"$2\" \"$3\" 2>/dev/null || { echo \"error=Could not reach GitHub\"; exit 0; }",
            "echo \"behind=$(git rev-list --count HEAD..FETCH_HEAD 2>/dev/null)\"",
            "echo \"ahead=$(git rev-list --count FETCH_HEAD..HEAD 2>/dev/null)\"",
            "echo \"outside=$(git diff --name-only HEAD FETCH_HEAD 2>/dev/null | grep -vE '^config/|\\.md$|^LICENSE' | wc -l)\""
        ].join("\n"), "sh", root._dir(), root.repoUrl, root.branch]
        shellCheck.running = true
    }

    function runShellUpdate() {
        if (root.shellUpdating || root.shellChecking) return
        root.shellUpdating = true
        root.shellJustUpdated = false
        root.shellError = ""
        shellUpdate.command = ["sh", "-c", root._findRepo + "\n" + [
            "before=$(git rev-parse --short HEAD)",
            "if out=$(git pull --ff-only --quiet \"$2\" \"$3\" 2>&1); then",
            "  echo \"from=$before\"; echo ok=1",
            "else",
            "  echo \"error=$(printf '%s' \"$out\" | tr '\\n' ' ' | tail -c 200)\"",
            "fi"
        ].join("\n"), "sh", root._dir(), root.repoUrl, root.branch]
        shellUpdate.running = true
    }

    Process {
        id: shellCheck
        stdout: StdioCollector {
            onStreamFinished: {
                root.shellChecking = false
                const lines = text.split("\n")
                let behind = -1, ahead = 0, outside = 0
                for (let i = 0; i < lines.length; i++) {
                    const l = lines[i]
                    if (l.indexOf("error=") === 0) {
                        root.shellError = l.substring(6).trim()
                        return
                    }
                    if (l.indexOf("behind=") === 0) behind = parseInt(l.substring(7))
                    else if (l.indexOf("ahead=") === 0) ahead = parseInt(l.substring(6))
                    else if (l.indexOf("outside=") === 0) outside = parseInt(l.substring(8))
                }
                if (isNaN(behind) || behind < 0) {
                    root.shellError = "Couldn't check for updates"
                    return
                }
                root.shellCommitsBehind = behind
                root.shellCommitsAhead = isNaN(ahead) ? 0 : ahead
                root.shellOutsideConfig = outside > 0
                root.shellUpdateAvailable = behind > 0
                root.shellChecked = true
                root.shellLastChecked = new Date()
            }
        }
    }

    Process {
        id: shellUpdate
        stdout: StdioCollector {
            onStreamFinished: {
                root.shellUpdating = false
                const lines = text.split("\n")
                let from = ""
                for (let i = 0; i < lines.length; i++) {
                    const l = lines[i]
                    if (l.indexOf("error=") === 0) {
                        root.shellError = l.substring(6).trim()
                        return
                    }
                    if (l.indexOf("from=") === 0) from = l.substring(5).trim()
                    if (l.indexOf("ok=1") === 0) {
                        root.shellPreviousCommit = from
                        root.shellJustUpdated = true
                        root.shellUpdateAvailable = false
                        root.shellCommitsBehind = 0
                        root.shellLastUpdated = new Date()
                        return
                    }
                }
                root.shellError = "Update did not finish"
            }
        }
    }
}