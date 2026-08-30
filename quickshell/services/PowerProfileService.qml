pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // State is optimistic only — auto-cpufreq has no reliable readback
    // command, so this reflects "what we last told it to do," not
    // confirmed system state.
    property string activeProfile: "auto" // "auto" | "performance" | "powersave"

    property var profiles: [
        { id: "auto", name: "Automatic", desc: "Let auto-cpufreq decide", flag: "reset" },
        { id: "performance", name: "Performance", desc: "Maximum CPU performance", flag: "performance" },
        { id: "powersave", name: "Battery Saver", desc: "Prioritize battery life", flag: "powersave" }
    ]

    Process {
        id: setProc
    }

    function setProfile(profileId) {
        const profile = root.profiles.find(function(p) { return p.id === profileId })
        if (!profile) return

        setProc.command = ["pkexec", "auto-cpufreq", "--force=" + profile.flag]
        setProc.running = true
        root.activeProfile = profileId
    }
}