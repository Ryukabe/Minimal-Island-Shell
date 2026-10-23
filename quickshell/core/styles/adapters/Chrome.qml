pragma Singleton
import QtQuick
import ".."
import "../../shell"

Item {
    ChromiumPolicy {
        label: "chrome"
        active: ShellState.templatesEnabled && ShellState.templateChrome
        policyDir: "/etc/opt/chrome/policies/managed"
        binaries: ["google-chrome-stable", "google-chrome", "chrome"]
        procNames: ["chrome"]
    }
}
