// pages/about/UpdateService.qml — update checks and updates for the About page.
//   System: counts repo updates (checkupdates) and AUR updates (paru/yay). "Update Now" opens your default
//           terminal and runs pacman first, then the AUR helper for the AUR packages.
//   Shell:  the configs are symlinks into a git clone (found through the shell folder), so updating is
//           `git pull --ff-only`. Afterwards the dotfiles installer module links any new config folders.
//   Jobs run detached from Quickshell and report through a small status file, so restarting or hot-reloading
//   the shell mid-update does not lose them (git pull changes QML files, which can reload the shell).
import QtQuick
import Quickshell
import Quickshell.Io
import "../../core"
import "../../../services"

Item {
    id: root
    visible: false

    // ---- configuration
    property string branch: "main"
    property var aurHelpers: ["paru", "yay"]        // the first one that is installed is used
    property int autoCheckStartDelayMs: 60000       // first automatic check after the shell starts
    property int autoCheckIntervalMs: 21600000      // then every 6 hours
    readonly property string repoUrl: SettingsRegistry.projectRepo

    // How each terminal is told to run a command. Anything not listed uses "-e".
    readonly property var _terminalExecArgs: ({
        "kitty": [], "foot": [], "alacritty": ["-e"], "ghostty": ["-e"],
        "wezterm": ["start", "--"], "gnome-terminal": ["--"],
        "konsole": ["-e"], "xterm": ["-e"], "xfce4-terminal": ["-x"]
    })

    readonly property string _runDir: Quickshell.env("XDG_RUNTIME_DIR") || "/tmp"

    // ---- system packages
    property bool systemChecked: false
    property bool systemChecking: false
    property bool systemUpdating: false
    property int systemUpdateCount: 0
    property int systemRepoCount: 0
    property int systemAurCount: 0
    property string systemAurHelper: ""
    property var systemLastChecked: null
    property var systemLastUpdated: null
    property bool systemJustUpdated: false
    property string systemError: ""
    readonly property string systemDetail: root.systemUpdateCount === 0 ? ""
        : root.systemRepoCount + " from repos"
          + (root.systemAurHelper !== "" ? ", " + root.systemAurCount + " from AUR (" + root.systemAurHelper + ")" : "")

    // ---- shell (hermit-dots)
    property bool shellChecked: false
    property bool shellChecking: false
    property bool shellUpdating: false
    property bool shellUpdateAvailable: false
    property int shellCommitsBehind: 0
    property int shellCommitsAhead: 0               // local commits that are not on GitHub
    property int shellLocalChanges: 0               // uncommitted changes to tracked files
    property bool shellNeedsInstaller: false        // the update touches install/
    property bool shellInstallerChanged: false      // remembered from the last update run
    property var shellLastChecked: null
    property var shellLastUpdated: null
    property bool shellJustUpdated: false
    property string shellError: ""
    // Behind and ahead at once cannot fast-forward.
    readonly property bool shellBlocked: root.shellCommitsAhead > 0 && root.shellCommitsBehind > 0

    property var _launchedAt: ({})

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

    // ================= detached jobs =================
    // A job writes "running <pid>" to its status file, then "done <exit code> <message>" when finished.
    // Polling that file tells us when it ends, even if Quickshell was restarted meanwhile.
    function _statusFile(kind) { return root._runDir + "/hermit-update-" + kind + ".status" }
    function _logFile(kind) { return root._runDir + "/hermit-update-" + kind + ".log" }

    // Deletes the old status file and then starts the job, in one detached process (no race).
    function _spawn(file, argv) {
        Quickshell.execDetached(["sh", "-c", "rm -f \"$1\"; shift; exec \"$@\"", "sh", file].concat(argv))
    }

    // Wrapper for jobs that run inside a terminal: you see the output and can type a password.
    function _wrap(body) {
        return [
            "status=\"$1\"; shift",
            "echo \"running $$\" > \"$status\"",
            "(",
            body,
            ")",
            "rc=$?",
            "echo \"done $rc\" > \"$status\"",
            "echo",
            "if [ $rc -eq 0 ]; then echo 'Finished.'; else echo \"Failed (exit code $rc).\"; fi",
            "echo 'Press Enter to close.'; read -r _"
        ].join("\n")
    }

    // Wrapper for jobs with no terminal: output goes to a log, and the end of it becomes the error message.
    function _wrapQuiet(body) {
        return [
            "status=\"$1\"; log=\"$2\"; shift 2",
            "echo \"running $$\" > \"$status\"",
            "(",
            body,
            ") > \"$log\" 2>&1",
            "rc=$?",
            "msg=$(tr '\\n' ' ' < \"$log\" | tail -c 200)",
            "echo \"done $rc $msg\" > \"$status\""
        ].join("\n")
    }

    function _terminalArgv() {
        const id = ShellState.defaultTerminal
        if (!id) return null
        let bin = id.toLowerCase()
        const list = DesktopEntries.applications.values
        for (let i = 0; i < list.length; i++) {
            if (list[i].id === id) {
                const cmd = list[i].command
                if (cmd && cmd.length > 0) bin = cmd[0]
                break
            }
        }
        const extra = root._terminalExecArgs[bin.split("/").pop()]
        return [bin].concat(extra !== undefined ? extra : ["-e"])
    }

    function _launch(kind, body, args) {
        const term = root._terminalArgv()
        if (!term) {
            root[kind + "Error"] = "Pick a terminal in Apps > Default apps first"
            return false
        }
        const file = root._statusFile(kind)
        root._launchedAt[kind] = Date.now()
        root._spawn(file, term.concat(["sh", "-c", root._wrap(body), "sh", file], args))
        return true
    }

    function _launchQuiet(kind, body, args) {
        const file = root._statusFile(kind)
        root._launchedAt[kind] = Date.now()
        root._spawn(file, ["sh", "-c", root._wrapQuiet(body), "sh", file, root._logFile(kind)].concat(args))
    }

    function _onJobState(kind, state, arg, msg) {
        if (state === "") return
        if (state === "running") {
            root[kind + "Updating"] = true
            return
        }
        // "done", or "closed" (the job's process vanished, for example the terminal was closed)
        root[kind + "Updating"] = false
        Quickshell.execDetached(["rm", "-f", root._statusFile(kind)])
        if (state === "done" && arg !== "0") {
            root[kind + "Error"] = msg !== "" ? msg : "Update failed (exit code " + arg + ")"
            return
        }
        if (state === "done") {
            root[kind + "JustUpdated"] = true
            root[kind + "LastUpdated"] = new Date()
        }
        if (kind === "system") root.checkSystemUpdates()
        else root.checkShellUpdate()
    }

    // A job that never wrote its status file means it did not start (for example the terminal did not open).
    function _expireMissing(seen) {
        const kinds = ["system", "shell"]
        for (let i = 0; i < kinds.length; i++) {
            const k = kinds[i]
            if (root[k + "Updating"] && !seen[k] && Date.now() - (root._launchedAt[k] || 0) > 20000) {
                root[k + "Updating"] = false
                root[k + "Error"] = k === "system"
                    ? "The terminal did not open. Check your default terminal."
                    : "The update did not start"
            }
        }
    }

    readonly property string _pollScript: [
        "for k in system shell; do",
        "  f=\"$1/hermit-update-$k.status\"",
        "  [ -f \"$f\" ] || continue",
        "  read -r state arg rest < \"$f\"",
        "  if [ \"$state\" = running ] && ! kill -0 \"$arg\" 2>/dev/null; then state=closed; fi",
        "  echo \"$k=$state $arg $rest\"",
        "done"
    ].join("\n")

    Process {
        id: pollProc
        command: ["sh", "-c", root._pollScript, "sh", root._runDir]
        stdout: StdioCollector {
            onStreamFinished: {
                const seen = {}
                const lines = text.split("\n")
                for (let i = 0; i < lines.length; i++) {
                    const eq = lines[i].indexOf("=")
                    if (eq < 1) continue
                    const kind = lines[i].substring(0, eq)
                    const parts = lines[i].substring(eq + 1).trim().split(" ")
                    seen[kind] = true
                    root._onJobState(kind, parts[0], parts[1] || "", parts.slice(2).join(" "))
                }
                root._expireMissing(seen)
            }
        }
    }

    Timer {
        interval: 2000
        repeat: true
        running: root.systemUpdating || root.shellUpdating
        onTriggered: if (!pollProc.running) pollProc.running = true
    }

    // On start, pick up a job that was already running or finished while the shell was down or reloading.
    Component.onCompleted: pollProc.running = true

    // ================= system packages =================
    readonly property string _sysCheckScript: [
        "helper=''",
        "for h in \"$@\"; do command -v \"$h\" >/dev/null 2>&1 && { helper=$h; break; }; done",
        "echo \"helper=$helper\"",
        "if ! command -v checkupdates >/dev/null 2>&1; then echo 'error=checkupdates is not installed (pacman-contrib)'; exit 0; fi",
        "out=$(checkupdates 2>/dev/null); rc=$?",
        "if [ $rc -eq 0 ]; then echo \"repo=$(echo \"$out\" | wc -l)\"",
        "elif [ $rc -eq 2 ]; then echo 'repo=0'",
        "else echo 'error=Could not check for updates'; exit 0; fi",
        "if [ -n \"$helper\" ]; then echo \"aur=$(\"$helper\" -Qua 2>/dev/null | wc -l)\"; fi"
    ].join("\n")

    // Runs inside the terminal. $1 = AUR helper (may be empty).
    readonly property string _sysBody: [
        "sudo pacman -Syu || exit 1",
        "[ -z \"$1\" ] && exit 0",
        "\"$1\" -Sua"
    ].join("\n")

    function checkSystemUpdates() {
        if (root.systemChecking || root.systemUpdating) return
        root.systemChecking = true
        root.systemError = ""
        sysCheck.command = ["sh", "-c", root._sysCheckScript, "sh"].concat(root.aurHelpers)
        sysCheck.running = true
    }

    function runSystemUpdate() {
        if (root.systemUpdating || root.systemChecking) return
        root.systemJustUpdated = false
        root.systemError = ""
        if (root._launch("system", root._sysBody, [root.systemAurHelper]))
            root.systemUpdating = true
    }

    Process {
        id: sysCheck
        stdout: StdioCollector {
            onStreamFinished: {
                root.systemChecking = false
                let repo = -1, aur = 0, helper = ""
                const lines = text.split("\n")
                for (let i = 0; i < lines.length; i++) {
                    const l = lines[i]
                    if (l.indexOf("error=") === 0) {
                        root.systemError = l.substring(6).trim()
                        return
                    }
                    if (l.indexOf("helper=") === 0) helper = l.substring(7).trim()
                    else if (l.indexOf("repo=") === 0) repo = parseInt(l.substring(5))
                    else if (l.indexOf("aur=") === 0) aur = parseInt(l.substring(4))
                }
                if (isNaN(repo) || repo < 0) {
                    root.systemError = "Couldn't check for updates"
                    return
                }
                root.systemAurHelper = helper
                root.systemRepoCount = repo
                root.systemAurCount = isNaN(aur) ? 0 : aur
                root.systemUpdateCount = root.systemRepoCount + root.systemAurCount
                root.systemChecked = true
                root.systemLastChecked = new Date()
            }
        }
    }

    // ================= shell (hermit-dots) =================
    // $1 = shell folder (the symlink is followed to the clone), $2 = repo url, $3 = branch
    readonly property string _shellCheckScript: [
        "export GIT_TERMINAL_PROMPT=0",
        "d=$(readlink -f \"$1\" 2>/dev/null)",
        "top=$(git -C \"$d\" rev-parse --show-toplevel 2>/dev/null) || { echo 'error=Not a git checkout. Clone Hermit-dots and run the installer from the clone.'; exit 0; }",
        "cd \"$top\" || { echo 'error=Shell folder not found'; exit 0; }",
        "git fetch --quiet \"$2\" \"$3\" 2>/dev/null || { echo 'error=Could not reach GitHub'; exit 0; }",
        "echo \"behind=$(git rev-list --count HEAD..FETCH_HEAD 2>/dev/null)\"",
        "echo \"ahead=$(git rev-list --count FETCH_HEAD..HEAD 2>/dev/null)\"",
        "echo \"dirty=$(git status --porcelain --untracked-files=no 2>/dev/null | wc -l)\"",
        "echo \"installer=$(git diff --name-only HEAD FETCH_HEAD -- install 2>/dev/null | wc -l)\""
    ].join("\n")

    // Same arguments. Fast-forward only, then link any new config folders (no sudo needed).
    readonly property string _shellUpdateBody: [
        "export GIT_TERMINAL_PROMPT=0",
        "d=$(readlink -f \"$1\" 2>/dev/null)",
        "top=$(git -C \"$d\" rev-parse --show-toplevel 2>/dev/null) || { echo 'Not a git checkout'; exit 1; }",
        "cd \"$top\" || exit 1",
        "git pull --ff-only \"$2\" \"$3\" || exit 1",
        "HERMIT_YES=true bash \"$top/install/modules/70-dotfiles.sh\" || exit 1"
    ].join("\n")

    function checkShellUpdate() {
        if (root.shellChecking || root.shellUpdating) return
        root.shellChecking = true
        root.shellError = ""
        shellCheck.command = ["sh", "-c", root._shellCheckScript, "sh",
                              Quickshell.shellDir, root.repoUrl, root.branch]
        shellCheck.running = true
    }

    function runShellUpdate() {
        if (root.shellUpdating || root.shellChecking || root.shellBlocked) return
        root.shellJustUpdated = false
        root.shellError = ""
        root.shellInstallerChanged = root.shellNeedsInstaller
        root._launchQuiet("shell", root._shellUpdateBody,
                          [Quickshell.shellDir, root.repoUrl, root.branch])
        root.shellUpdating = true
    }

    Process {
        id: shellCheck
        stdout: StdioCollector {
            onStreamFinished: {
                root.shellChecking = false
                const lines = text.split("\n")
                let behind = -1, ahead = 0, dirty = 0, installer = 0
                for (let i = 0; i < lines.length; i++) {
                    const l = lines[i]
                    if (l.indexOf("error=") === 0) {
                        root.shellError = l.substring(6).trim()
                        return
                    }
                    if (l.indexOf("behind=") === 0) behind = parseInt(l.substring(7))
                    else if (l.indexOf("ahead=") === 0) ahead = parseInt(l.substring(6))
                    else if (l.indexOf("dirty=") === 0) dirty = parseInt(l.substring(6))
                    else if (l.indexOf("installer=") === 0) installer = parseInt(l.substring(10))
                }
                if (isNaN(behind) || behind < 0) {
                    root.shellError = "Couldn't check for updates"
                    return
                }
                root.shellCommitsBehind = behind
                root.shellCommitsAhead = isNaN(ahead) ? 0 : ahead
                root.shellLocalChanges = isNaN(dirty) ? 0 : dirty
                root.shellNeedsInstaller = installer > 0
                root.shellUpdateAvailable = behind > 0
                root.shellChecked = true
                root.shellLastChecked = new Date()
            }
        }
    }
}