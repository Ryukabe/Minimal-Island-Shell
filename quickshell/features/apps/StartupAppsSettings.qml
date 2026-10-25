// features/apps/StartupAppsSettings.qml — Apps > Startup apps.
// Commands that run when Hyprland starts (AutostartService). Apps picked from the list are saved
// as "gtk-launch <desktop id>"; anything else can be typed as a command.
import QtQuick
import QtQuick.Layouts
import "../settings/components"
import "../settings/core"
import "."
import "../../core/styles"

PageScroll {
    id: root

    // What the picker saves: "gtk-launch org.mozilla.firefox". gtk-launch starts an app by its
    // desktop id, so Exec field codes (%u, %F, ...) are handled for us.
    readonly property string launchPrefix: "gtk-launch "

    // Desktop id behind a saved command, or "" when it is a custom command.
    function _idOf(command) {
        return command.startsWith(root.launchPrefix) ? command.substring(root.launchPrefix.length).trim() : ""
    }

    // Row title: the app's name for picked apps, the raw command for everything else.
    function _labelFor(command) {
        const app = InstalledApps.byId(root._idOf(command))
        return app ? app.name : command
    }

    // Installed apps that are not on the list yet, in the picker's { value, label } shape.
    // Ids with unusual characters are left out (use the command field for those).
    readonly property var pickerItems: {
        const taken = AutostartService.apps.map(a => root._idOf(a.command))
        return InstalledApps.apps
            .filter(a => /^[A-Za-z0-9._+@-]+$/.test(a.id) && !taken.includes(a.id))
            .map(a => ({ value: a.id, label: a.name }))
    }

    function _openPicker() {
        SettingsPicker.open({
            title: "Add a startup app",
            searchHint: "Search installed apps...",
            items: root.pickerItems,
            selectedValue: "",
            initialQuery: "",
            onPick: function (id) { AutostartService.addApp(root.launchPrefix + id) }
        })
    }

    // Re-read the file so a hand edit is never overwritten by a stale copy.
    Component.onCompleted: AutostartService.refresh()

    SectionLabel { text: "Add" }

    GroupCard {
        ButtonRow {
            label: "Add an app"
            description: "Pick from your installed apps"
            buttonText: "Choose app"
            onClicked: root._openPicker()
        }

        TextRow {
            label: "Add a command"
            description: "For anything not in the list. Press Enter to add"
            placeholderText: "e.g. sh -c 'sleep 3 && spotify'"
            fieldWidth: 240
            monospace: true
            clearOnCommit: true
            showDivider: AutostartService.lastError !== ""
            onCommitted: (v) => AutostartService.addApp(v)
        }

        InfoRow {
            visible: AutostartService.lastError !== ""
            label: AutostartService.lastError
            showDivider: false
        }
    }

    SectionLabel { text: "Runs at login" }

    GroupCard {
        InfoRow {
            visible: startupRepeater.count === 0
            label: "No startup apps yet"
            showDivider: false
        }

        Repeater {
            id: startupRepeater
            model: AutostartService.apps

            delegate: ButtonRow {
                required property var modelData
                required property int index

                label: root._labelFor(modelData.command)
                buttonText: "Remove"
                showDivider: index < startupRepeater.count - 1
                onClicked: AutostartService.removeApp(modelData.command)
            }
        }
    }
}
