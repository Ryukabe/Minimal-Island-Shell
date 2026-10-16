// features/bar/PrivacyService.qml — is anything using the microphone or camera right now?
// Polls while Settings > Bar & Island > Clock > Mic and camera indicator is on.
// UNTESTED: written without any output from this machine (see notes in chat).
pragma Singleton
import QtQuick
import Quickshell.Io
import "../../core/styles"
import "../../core/shell"

QtObject {
    id: root

    readonly property bool enabled: ShellState.clockShowPrivacyIndicator

    property bool micActive: false
    property bool pwCamera: false     // an app reading a camera through PipeWire
    property bool v4lCamera: false    // a process holding /dev/video* open
    readonly property bool cameraActive: pwCamera || v4lCamera

    // Like iOS: camera wins when both are on.
    readonly property string kind: cameraActive ? "camera" : (micActive ? "mic" : "none")
    readonly property bool active: kind !== "none"

    // Keeps the last real color so the dot does not change color while it fades out.
    property color lastColor: Colors.yellow
    onKindChanged: {
        if (kind !== "none") lastColor = (kind === "camera") ? Colors.green : Colors.yellow
    }

    // Capture streams from these apps are ignored (volume meters, the shell itself).
    readonly property var ignoredApps: ["PulseAudio Volume Control", "pavucontrol", "quickshell", "Quickshell"]
    readonly property int pollMs: 2000

    onEnabledChanged: {
        if (!enabled) {
            micActive = false
            pwCamera = false
            v4lCamera = false
        }
    }

    function _isTrue(v) {
        return v === true || String(v) === "true"
    }

    function parsePipewire(text) {
        var objs
        try {
            objs = JSON.parse(text)
        } catch (e) {
            return
        }
        if (!Array.isArray(objs)) return

        var mic = false
        var cam = false
        for (var i = 0; i < objs.length; i++) {
            var o = objs[i]
            if (!o || o.type !== "PipeWire:Interface:Node") continue
            var info = o.info
            if (!info || !info.props || info.state !== "running") continue

            var props = info.props
            var app = props["application.name"] || props["node.name"] || ""
            if (root.ignoredApps.indexOf(app) >= 0) continue

            var cls = props["media.class"]
            if (cls === "Stream/Input/Audio") {
                // Capturing a speaker's monitor (screen recorders, visualizers) is not the mic.
                if (root._isTrue(props["stream.capture.sink"])) continue
                mic = true
            } else if (cls === "Stream/Input/Video") {
                cam = true
            }
        }
        micActive = mic
        pwCamera = cam
    }

    property Process pipewireProc: Process {
        command: ["pw-dump"]
        stdout: StdioCollector {
            onStreamFinished: root.parsePipewire(text)
        }
    }

    // fuser prints the PIDs of processes using the files. No output = nothing has it open,
    // or fuser / a camera is not there.
    property Process cameraProc: Process {
        command: ["sh", "-c", "fuser /dev/video* 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: root.v4lCamera = text.trim().length > 0
        }
    }

    property Timer poller: Timer {
        interval: root.pollMs
        repeat: true
        running: root.enabled
        triggeredOnStart: true
        onTriggered: {
            if (!root.pipewireProc.running) root.pipewireProc.running = true
            if (!root.cameraProc.running) root.cameraProc.running = true
        }
    }
}