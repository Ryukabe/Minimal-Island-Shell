pragma Singleton
import QtQuick
import ".."
import "../../shell"

Item {
    // NOTE: the policy dir and binary/process names below are unverified for Helium.
    // Check with: which helium-browser helium ; ls /etc/helium ; chrome://policy inside Helium.
    ChromiumPolicy {
        label: "helium"
        active: ShellState.templatesEnabled && ShellState.templateHelium
        policyDir: "/etc/helium/policies/managed"
        binaries: ["helium-browser", "helium"]
        procNames: ["helium", "helium-browser"]
    }
}
