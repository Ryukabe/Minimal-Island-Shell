// pages/keybinds/KeybindsPage.qml — the Keybinds menu. Main modifier, a form to add a shortcut,
// and a conflict count sit here; each category of shortcuts opens from the list at the bottom.
// The form: press the keys (checked live for clashes and risky combos), pick what it should do
// from a list or type a command, optionally name it, then Add.
import QtQuick
import QtQuick.Layouts
import "../settings/components"
import "."
import "../../core/styles"

PageScroll {
    id: root

    property bool addOpen: false
    property string newCombo: ""
    property string newName: ""
    property string actionGroup: "Run"
    property string actionTitle: "Run a command"
    property string actionValue: ""

    readonly property var modifierOptions: ["SUPER", "CTRL", "ALT"]
    readonly property int conflictCount: {
        const counts = HyprlandKeybindsService.conflictCounts || {}
        return Object.keys(counts).filter(k => counts[k] > 1).length
    }

    // The action list for the chosen type, the entry picked from it, and what it would write.
    // `built` is null until the input (command, workspace, ...) is valid.
    readonly property var groupEntries: HyprlandKeybindsService.actionsForGroup(root.actionGroup)
    readonly property var groupTitles: root.groupEntries.map(e => e.title)
    readonly property var currentEntry: {
        for (let i = 0; i < root.groupEntries.length; i++) {
            if (root.groupEntries[i].title === root.actionTitle) return root.groupEntries[i]
        }
        return root.groupEntries.length > 0 ? root.groupEntries[0] : null
    }
    readonly property string currentInput: root.currentEntry ? root.currentEntry.input : "none"
    readonly property var built: root.currentEntry ? root.currentEntry.build(root.actionValue) : null

    // Live checks on the pressed combination.
    readonly property var comboConflict: root.newCombo.length > 0
        ? HyprlandKeybindsService.findConflict(root.newCombo) : null
    readonly property var comboRisk: root.newCombo.length > 0
        ? HyprlandKeybindsService.comboRisk(root.newCombo) : ({ level: "ok", text: "" })
    readonly property bool comboBlocked: root.comboConflict !== null || root.comboRisk.level === "block"
    readonly property bool comboWarn: !root.comboBlocked && root.comboRisk.level === "warn"
    readonly property string comboNote: root.comboConflict
        ? root.newCombo + " already runs " + root.comboConflict.label + ". Pick another combination."
        : root.comboRisk.text

    function cap(s) {
        return s.length > 0 ? s.charAt(0).toUpperCase() + s.slice(1) : s
    }

    function defaultValueFor(input) {
        switch (input) {
            case "direction": return "left"
            case "workspace": return "1"
            case "app": return "terminal"
            case "name": return "magic"
            default: return ""
        }
    }

    function selectGroup(group) {
        const entries = HyprlandKeybindsService.actionsForGroup(group)
        root.actionGroup = group
        root.actionTitle = entries.length > 0 ? entries[0].title : ""
        root.actionValue = entries.length > 0 ? root.defaultValueFor(entries[0].input) : ""
    }

    function selectAction(title) {
        const entry = root.groupEntries.find(e => e.title === title)
        root.actionTitle = title
        root.actionValue = entry ? root.defaultValueFor(entry.input) : ""
    }

    // Closing always disarms capture and wipes the staged combo, name and action.
    function closeAdd() {
        root.addOpen = false
        newBindCapture.deactivateAndClear()
        root.newCombo = ""
        root.newName = ""
        root.selectGroup("Run")
    }

    SectionLabel { text: "Main key" }

    GroupCard {
        SegmentRow {
            label: "Main modifier"
            options: root.modifierOptions
            selectedValue: HyprlandKeybindsService.mainMod
            onOptionSelected: (name) => HyprlandKeybindsService.setMainMod(name)
            showDivider: false
        }
    }

    SectionLabel { text: "New shortcut" }

    GroupCard {
        ButtonRow {
            label: "Add a shortcut"
            description: "Run a command or an action from a key combination"
            buttonText: root.addOpen ? "Close" : "New"
            primary: !root.addOpen
            showDivider: root.addOpen
            onClicked: root.addOpen ? root.closeAdd() : root.addOpen = true
        }

        Reveal {
            shown: root.addOpen

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 54
                Layout.leftMargin: Dimens.paddingMedium
                Layout.rightMargin: Dimens.paddingMedium
                spacing: Dimens.spacingMedium

                Text {
                    Layout.fillWidth: true
                    text: "Shortcut"
                    color: Colors.fg
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeBase
                }

                KeyCaptureField {
                    id: newBindCapture
                    Layout.preferredWidth: 220
                    onComboChanged: (combo) => root.newCombo = combo
                    onCancelled: newBindCapture.deactivateAndClear()
                }
            }

            // Clash or risk note for the pressed keys. Red = cannot add, yellow = allowed, be careful.
            Text {
                visible: root.comboNote.length > 0
                Layout.fillWidth: true
                Layout.leftMargin: Dimens.paddingMedium
                Layout.rightMargin: Dimens.paddingMedium
                Layout.bottomMargin: Dimens.paddingSmall
                wrapMode: Text.WordWrap
                text: root.comboNote
                color: root.comboBlocked ? Colors.red : Colors.yellow
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeXs
            }

            SegmentRow {
                label: "Does what"
                options: HyprlandKeybindsService.actionGroups
                selectedValue: root.actionGroup
                onOptionSelected: (name) => root.selectGroup(name)
            }

            DropdownRow {
                label: "Action"
                options: root.groupTitles
                selectedValue: root.actionTitle
                onOptionSelected: (value) => root.selectAction(value)
            }

            TextRow {
                visible: root.currentInput === "command"
                label: "Command"
                placeholderText: "e.g. spotify"
                value: root.actionValue
                fieldWidth: 280
                monospace: true
                onEdited: (t) => root.actionValue = t
                onCommitted: (v) => root.actionValue = v
            }

            SegmentRow {
                visible: root.currentInput === "direction"
                label: "Direction"
                options: ["Left", "Right", "Up", "Down"]
                selectedValue: root.cap(root.actionValue)
                onOptionSelected: (name) => root.actionValue = name.toLowerCase()
            }

            DropdownRow {
                visible: root.currentInput === "workspace"
                label: "Workspace"
                options: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
                selectedValue: root.actionValue
                onOptionSelected: (value) => root.actionValue = value
            }

            SegmentRow {
                visible: root.currentInput === "app"
                label: "App"
                options: ["Terminal", "Browser", "Files"]
                selectedValue: root.cap(root.actionValue)
                onOptionSelected: (name) => root.actionValue = name.toLowerCase()
            }

            TextRow {
                visible: root.currentInput === "name"
                label: "Scratchpad name"
                placeholderText: "magic"
                value: root.actionValue
                fieldWidth: 200
                monospace: true
                onEdited: (t) => root.actionValue = t
                onCommitted: (v) => root.actionValue = v
            }

            TextRow {
                label: "Name"
                description: "Optional. Shown in the list instead of the command"
                placeholderText: "e.g. Open Spotify"
                value: root.newName
                fieldWidth: 280
                onEdited: (t) => root.newName = t
                onCommitted: (v) => root.newName = v
            }

            ButtonRow {
                label: root.newCombo.length > 0 ? root.newCombo : "No shortcut set yet"
                description: root.newCombo.length === 0
                    ? "Click the shortcut field above and press the keys"
                    : (root.built ? root.built.action : "Fill in the action above")
                buttonText: root.comboWarn ? "Add anyway" : "Add"
                primary: true
                enabled: root.newCombo.trim().length > 0 && root.built !== null && !root.comboBlocked
                showDivider: false
                onClicked: {
                    HyprlandKeybindsService.addBind(root.newCombo.trim(), root.built.action,
                                                    root.built.flags, root.newName)
                    root.closeAdd()
                }
            }
        }
    }

    SectionLabel { text: "Health" }

    GroupCard {
        InfoRow {
            label: "Shortcut conflicts"
            value: root.conflictCount === 0 ? "None" : root.conflictCount + " found"
            showDivider: false
        }
    }

    SectionLabel { text: "Shortcuts" }

    ViewList {}
}
