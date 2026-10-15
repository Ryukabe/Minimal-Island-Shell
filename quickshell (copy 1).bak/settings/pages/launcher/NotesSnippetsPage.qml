// pages/launcher/NotesSnippetsPage.qml — Launcher > Notes & snippets.
import QtQuick
import QtQuick.Layouts
import "../../components"
import "../../../services"
import "../../../styles"

PageScroll {
    id: root

    SectionLabel { text: "Quick notes" }

    GroupCard {
        SegmentRow {
            label: "Storage"
            options: ["One file", "Per day", "Per capture"]
            selectedValue: LauncherData.notesMode === "running" ? "One file"
                         : LauncherData.notesMode === "daily" ? "Per day" : "Per capture"
            onOptionSelected: (name) => LauncherData.setNotesMode(
                name === "One file" ? "running" : name === "Per day" ? "daily" : "capture")
        }

        Reveal {
            shown: LauncherData.notesMode === "running"

            TextRow {
                label: "Notes file"
                value: LauncherData.notesFile
                fieldWidth: 280
                monospace: true
                onCommitted: (v) => LauncherData.setNotesFile(v)
            }
        }

        Reveal {
            shown: LauncherData.notesMode !== "running"

            TextRow {
                label: "Notes folder"
                value: LauncherData.notesFolder
                fieldWidth: 280
                monospace: true
                onCommitted: (v) => LauncherData.setNotesFolder(v)
            }
        }

        ButtonRow {
            label: "Notes location"
            buttonText: "Open"
            onClicked: LauncherData.openNotesFolder()
            showDivider: false
        }
    }

    SectionLabel { text: "Snippets" }

    GroupCard {
        TextRow {
            label: "Snippets folder"
            description: "One subfolder per category"
            value: LauncherData.snippetsFolder
            fieldWidth: 280
            monospace: true
            onCommitted: (v) => LauncherData.setSnippetsFolder(v)
        }

        ButtonRow {
            label: "Snippets location"
            buttonText: "Open"
            onClicked: LauncherData.openSnippetsFolder()
            showDivider: false
        }
    }

    SectionLabel { text: "Aliases, pinned apps and search engines" }

    GroupCard {
        ButtonRow {
            label: "launcher-data.json"
            description: "Edited by hand"
            buttonText: "Open file"
            onClicked: LauncherData.openFile()
            showDivider: false
        }
    }
}