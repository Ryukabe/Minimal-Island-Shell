// features/account/AccountService.qml — system accounts for the Accounts settings page.
// Reads real users with getent and changes them through pkexec, so the shell's polkit agent
// shows the password prompt. Passwords only travel over stdin, never as command arguments.
// Every value reaches the root shell as a separate argv entry, so nothing is interpolated.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    readonly property string currentUser: Quickshell.env("USER")

    // [{ name, uid, fullName, home, shell, groups }]
    property var users: []
    // "wheel", "sudo" or "" — whichever exists on this system.
    property string adminGroup: ""

    property bool busy: false
    property string busyOp: ""
    property string statusText: ""
    property bool statusOk: true

    // op is one of: name, password, add, remove
    signal finished(string op, bool ok)

    property string _stdin: ""
    property string _okMessage: ""
    property int _exitCode: 0

    // ---- Lookups ----
    function findUser(name) {
        const list = root.users
        for (let i = 0; i < list.length; i++) {
            if (list[i].name === name) return list[i]
        }
        return null
    }

    function isAdmin(name) {
        const u = root.findUser(name)
        return !!u && root.adminGroup !== "" && u.groups.indexOf(root.adminGroup) >= 0
    }

    function report(message, ok) {
        root.statusText = message
        root.statusOk = ok
    }

    function refresh() {
        if (!listProc.running) listProc.running = true
    }

    // ---- Validation ----
    function validUsername(name) {
        return /^[a-z_][a-z0-9_-]{0,31}$/.test(name)
    }

    // The name field of /etc/passwd is colon separated and line based.
    function _cleanText(s) {
        return s.indexOf(":") < 0 && s.indexOf("\n") < 0 && s.indexOf("\r") < 0
    }

    function _goodPassword(pw) {
        if (pw === "") { root.report("Type a password first", false); return false }
        if (pw.indexOf("\n") >= 0 || pw.indexOf("\r") >= 0) {
            root.report("The password can't contain a line break", false)
            return false
        }
        return true
    }

    // ---- Actions ----
    function setFullName(user, fullName) {
        const name = fullName.trim()
        if (!root.findUser(user)) { root.report("That account no longer exists", false); return false }
        if (!root._cleanText(name)) {
            root.report("The name can't contain a colon or a line break", false)
            return false
        }
        // usermod -c replaces the whole GECOS field, which is just the full name on a normal setup.
        return root._run("name", ["pkexec", "usermod", "-c", name, user], "", "Display name saved")
    }

    function setPassword(user, password) {
        if (!root.findUser(user)) { root.report("That account no longer exists", false); return false }
        if (!root._goodPassword(password)) return false
        // The password is read from stdin by the root shell, then piped to chpasswd.
        const script = "IFS= read -r pw; printf '%s:%s\\n' \"$1\" \"$pw\" | chpasswd"
        return root._run("password", ["pkexec", "sh", "-c", script, "sh", user],
                         password + "\n", "Password changed for " + user)
    }

    function addUser(username, fullName, password, admin) {
        const user = username.trim()
        const full = fullName.trim()
        if (!root.validUsername(user)) {
            root.report("Login name: lowercase letters, digits, - and _ only, starting with a letter", false)
            return false
        }
        if (root.findUser(user)) { root.report("That login name is already in use", false); return false }
        if (!root._cleanText(full)) {
            root.report("The name can't contain a colon or a line break", false)
            return false
        }
        if (!root._goodPassword(password)) return false

        // New accounts get the same login shell as the current user.
        const me = root.findUser(root.currentUser)
        const shell = me ? me.shell : ""
        const group = (admin && root.adminGroup !== "") ? root.adminGroup : ""

        const script = [
            "user=$1; full=$2; shell=$3; group=$4",
            "getent passwd \"$user\" >/dev/null && exit 10",
            "IFS= read -r pw",
            "if [ -n \"$group\" ]; then",
            "  useradd -m -s \"$shell\" -c \"$full\" -G \"$group\" \"$user\" || exit 11",
            "else",
            "  useradd -m -s \"$shell\" -c \"$full\" \"$user\" || exit 11",
            "fi",
            // If the password step fails, undo the half-made account.
            "printf '%s:%s\\n' \"$user\" \"$pw\" | chpasswd || { userdel -r \"$user\"; exit 12; }"
        ].join("\n")

        return root._run("add", ["pkexec", "sh", "-c", script, "sh", user, full, shell, group],
                         password + "\n", "Account " + user + " created")
    }

    function removeUser(user) {
        if (user === root.currentUser) {
            root.report("You can't remove the account you're signed in to", false)
            return false
        }
        if (!root.findUser(user)) { root.report("That account no longer exists", false); return false }
        // No -r: the home folder is kept on disk.
        return root._run("remove", ["pkexec", "userdel", user], "",
                         user + " removed. Their home folder was kept")
    }

    // ---- Runner ----
    function _run(op, command, input, okMessage) {
        if (root.busy) return false
        root.busy = true
        root.busyOp = op
        root.statusText = ""
        root._okMessage = okMessage
        root._stdin = input
        runner.command = command
        runner.running = true
        return true
    }

    function _errorFor(op, code) {
        const detail = errOut.text.trim() !== "" ? ": " + errOut.text.trim() : ""
        if (code === 126 || code === 127)
            return "Not authorised. The password prompt was closed, the password was wrong, or no polkit agent is running."
        if (op === "add" && code === 10) return "That login name is already in use"
        if (op === "add" && code === 11) return "Could not create the account" + detail
        if (op === "add" && code === 12) return "Could not set the password, so the new account was removed" + detail
        if (op === "remove") return "Could not remove the account. It may be signed in right now" + detail
        return "Failed (exit code " + code + ")" + detail
    }

    function _finish() {
        const ok = root._exitCode === 0
        const op = root.busyOp
        root._stdin = ""
        root.busy = false
        root.report(ok ? root._okMessage : root._errorFor(op, root._exitCode), ok)
        if (ok) root.refresh()
        root.finished(op, ok)
    }

    Process {
        id: runner
        stdinEnabled: true
        stderr: StdioCollector { id: errOut }
        // Write the password once the process is up, then forget it.
        onStarted: {
            if (root._stdin !== "") {
                runner.write(root._stdin)
                root._stdin = ""
            }
        }
        onExited: (exitCode, exitStatus) => {
            root._exitCode = exitCode
            finishTimer.restart()
        }
    }

    // Lets stderr finish arriving before the result is read.
    Timer {
        id: finishTimer
        interval: 100
        onTriggered: root._finish()
    }

    // ---- Reading the system ----
    // Real users: UID_MIN from login.defs (1000 if missing) up to 59999.
    readonly property string _listScript: [
        "min=$(awk '/^UID_MIN/ {print $2}' /etc/login.defs 2>/dev/null); min=${min:-1000}",
        "getent passwd | while IFS=: read -r name _ uid _ gecos home shell; do",
        "  if [ \"$uid\" -ge \"$min\" ] && [ \"$uid\" -lt 60000 ]; then",
        "    printf '%s\\t%s\\t%s\\t%s\\t%s\\t%s\\n' \"$name\" \"$uid\" \"$gecos\" \"$home\" \"$shell\" \"$(id -nG \"$name\" | tr ' ' ',')\"",
        "  fi",
        "done"
    ].join("\n")

    function _parseUsers(text) {
        const out = []
        const lines = text.split("\n")
        for (let i = 0; i < lines.length; i++) {
            if (lines[i] === "") continue
            const f = lines[i].split("\t")
            if (f.length < 6) continue
            out.push({
                name: f[0],
                uid: parseInt(f[1]),
                fullName: f[2].split(",")[0],
                home: f[3],
                shell: f[4],
                groups: f[5].split(",")
            })
        }
        root.users = out
    }

    Process {
        id: adminProc
        command: ["sh", "-c",
            "for g in wheel sudo; do if getent group \"$g\" >/dev/null; then echo \"$g\"; break; fi; done"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.adminGroup = text.trim()
                listProc.running = true
            }
        }
    }

    Process {
        id: listProc
        command: ["sh", "-c", root._listScript]
        stdout: StdioCollector {
            onStreamFinished: root._parseUsers(text)
        }
    }

    Component.onCompleted: adminProc.running = true
}