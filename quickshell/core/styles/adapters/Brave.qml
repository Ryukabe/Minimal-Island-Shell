pragma Singleton
import QtQuick
import ".."
import "../../shell"

Item {
    ChromiumPolicy {
        label: "brave"
        active: ShellState.templatesEnabled && ShellState.templateBrave
        policyDir: "/etc/brave/policies/managed"
        binaries: ["brave", "brave-browser", "brave-browser-stable"]
        procNames: ["brave"]
    }
}
