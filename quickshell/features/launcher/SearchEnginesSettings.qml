// features/launcher/SearchEnginesSettings.qml — Launcher > Search engines.
// A keyword starts a web search: "yt lofi" searches YouTube. A "?" at the start uses the default engine.
import QtQuick
import QtQuick.Layouts
import "../settings/components"
import "."
import "../../core/styles"

PageScroll {
    id: root

    property string newKey: ""
    property string newName: ""
    property string newUrl: ""
    property string error: ""

    readonly property var engineKeys: Object.keys(LauncherData.engines)
    readonly property var engineItems: root.engineKeys.map(k => ({ value: k, label: LauncherData.engines[k].name }))

    function _add() {
        root.error = LauncherData.addEngine(root.newKey, root.newName, root.newUrl)
        if (root.error === "") {
            root.newKey = ""
            root.newName = ""
            root.newUrl = ""
        }
    }

    SectionLabel { text: "Default" }

    GroupCard {
        PickerRow {
            label: "Default engine"
            description: "Used when a search starts with ?"
            pickerTitle: "Default engine"
            searchHint: "Search engines..."
            hint: "Choose an engine"
            items: root.engineItems
            value: LauncherData.defaultEngine
            strict: true
            showDivider: false
            onCommitted: (v) => LauncherData.setDefaultEngine(v)
        }
    }

    SectionLabel { text: "Engines" }

    GroupCard {
        Repeater {
            id: engineRepeater
            model: root.engineKeys

            delegate: ButtonRow {
                required property string modelData
                required property int index

                label: LauncherData.engines[modelData].name
                description: modelData + "  ·  " + LauncherData.engines[modelData].url
                buttonText: "Remove"
                enabled: root.engineKeys.length > 1
                showDivider: true
                onClicked: LauncherData.removeEngine(modelData)
            }
        }

        ButtonRow {
            label: "Restore built-in engines"
            description: "Back to the seven that came with the launcher. Engines you added are removed"
            buttonText: "Restore"
            showDivider: false
            onClicked: LauncherData.resetEngines()
        }
    }

    SectionLabel { text: "Add an engine" }

    GroupCard {
        TextRow {
            label: "Keyword"
            description: "Letters only, up to 12. Press Enter"
            placeholderText: "e.g. npm"
            value: root.newKey
            fieldWidth: 160
            monospace: true
            onCommitted: (v) => root.newKey = v.trim()
        }

        TextRow {
            label: "Name"
            description: "Shown in the results. Press Enter"
            placeholderText: "e.g. npm"
            value: root.newName
            fieldWidth: 160
            onCommitted: (v) => root.newName = v.trim()
        }

        TextRow {
            label: "Address"
            description: "Use %s where the search words go. Press Enter"
            placeholderText: "https://www.npmjs.com/search?q=%s"
            value: root.newUrl
            fieldWidth: 280
            monospace: true
            onCommitted: (v) => root.newUrl = v.trim()
            showDivider: true
        }

        ButtonRow {
            label: "Add engine"
            description: root.error
            buttonText: "Add"
            showDivider: false
            onClicked: root._add()
        }
    }
}