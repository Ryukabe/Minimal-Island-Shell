// features/launcher/AliasesPinnedSettings.qml — Launcher > Aliases & pinned.
// An alias is a short word that puts one app first. Pinned apps are listed first while nothing is typed.
import QtQuick
import QtQuick.Layouts
import "../settings/components"
import "../settings/core"
import "../apps"
import "."
import "../../core/styles"

PageScroll {
    id: root

    property string error: ""

    readonly property var aliasKeys: Object.keys(LauncherData.aliases).sort()

    // Installed apps as picker items, one per name, minus the names in `excluded` (lowercase).
    function _appItems(excluded) {
        const seen = {}
        const out = []
        for (const a of InstalledApps.apps) {
            const key = a.name.toLowerCase()
            if (seen[key] || excluded.indexOf(key) >= 0) continue
            seen[key] = true
            out.push({ value: a.name, label: a.name })
        }
        out.sort((x, y) => x.label.localeCompare(y.label))
        return out
    }

    function _startAlias(raw) {
        const k = (raw || "").trim().toLowerCase()
        if (!/^[a-z0-9._-]{1,16}$/.test(k)) {
            root.error = "An alias is 1 to 16 letters, digits, dots, dashes or underscores, with no spaces"
            return
        }
        root.error = ""
        SettingsPicker.open({
            title: "Alias: " + k,
            searchHint: "Search installed apps...",
            items: root._appItems([]),
            selectedValue: LauncherData.aliases[k] || "",
            initialQuery: "",
            onPick: function (name) { LauncherData.setAlias(k, name) }
        })
    }

    function _startPin() {
        SettingsPicker.open({
            title: "Pin an app",
            searchHint: "Search installed apps...",
            items: root._appItems(LauncherData.pinned.map(p => p.toLowerCase())),
            selectedValue: "",
            initialQuery: "",
            onPick: function (name) { LauncherData.addPinned(name) }
        })
    }

    SectionLabel { text: "Add an alias" }

    GroupCard {
        TextRow {
            label: "New alias"
            description: "Type a short word and press Enter, then pick the app. Typing exactly that word puts the app first"
            placeholderText: "e.g. ff"
            fieldWidth: 160
            monospace: true
            clearOnCommit: true
            showDivider: root.error !== ""
            onCommitted: (v) => root._startAlias(v)
        }

        InfoRow {
            visible: root.error !== ""
            label: root.error
            showDivider: false
        }
    }

    SectionLabel { text: "Aliases" }

    GroupCard {
        InfoRow {
            visible: root.aliasKeys.length === 0
            label: "No aliases yet"
            showDivider: false
        }

        Repeater {
            id: aliasRepeater
            model: root.aliasKeys

            delegate: ButtonRow {
                required property string modelData
                required property int index

                label: modelData
                description: LauncherData.aliases[modelData]
                buttonText: "Remove"
                showDivider: index < aliasRepeater.count - 1
                onClicked: LauncherData.removeAlias(modelData)
            }
        }
    }

    SectionLabel { text: "Pinned apps" }

    GroupCard {
        ButtonRow {
            label: "Pin an app"
            description: "Pinned apps are listed first while the search box is empty, in the order you pin them"
            buttonText: "Choose app"
            onClicked: root._startPin()
            showDivider: LauncherData.pinned.length > 0
        }

        Repeater {
            id: pinnedRepeater
            model: LauncherData.pinned

            delegate: ButtonRow {
                required property string modelData
                required property int index

                label: modelData
                buttonText: "Unpin"
                showDivider: index < pinnedRepeater.count - 1
                onClicked: LauncherData.removePinned(modelData)
            }
        }
    }
}