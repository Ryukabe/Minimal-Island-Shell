// pages/apps/allapps/AllAppsSettings.qml — Apps > All apps.
// Lists every installed app (from the .desktop entries) with a favourite star and a hide eye.
// Favourites and hidden live on ShellState (arrays of app ids) and are saved by SettingsStore.
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../components"
import "../../../../services"
import "../../../../styles"

PageScroll {
    id: root

    readonly property var favourites: ShellState.favouriteApps     // app ids
    readonly property var hidden: ShellState.hiddenApps            // app ids
    property string showFilter: "All"
    property string query: ""

    // Every app that is meant to appear in menus, A to Z.
    readonly property var allApps: {
        const out = []
        const list = DesktopEntries.applications.values
        for (let i = 0; i < list.length; i++) {
            const e = list[i]
            if (e.noDisplay) continue
            out.push({ id: e.id, name: e.name, comment: e.comment || e.genericName || "", icon: e.icon })
        }
        out.sort((a, b) => a.name.localeCompare(b.name))
        return out
    }

    readonly property var shownApps: {
        const q = root.query.toLowerCase().trim()
        return root.allApps.filter(a => {
            if (root.showFilter === "Favourites" && !root.favourites.includes(a.id)) return false
            if (root.showFilter === "Hidden" && !root.hidden.includes(a.id)) return false
            if (q === "") return true
            return a.name.toLowerCase().includes(q) || a.comment.toLowerCase().includes(q)
        })
    }

    function _toggle(list, id) {
        return list.includes(id) ? list.filter(x => x !== id) : list.concat([id])
    }

    // ---- Filter + search ----
    GroupCard {
        SegmentRow {
            label: "Show"
            options: ["All", "Favourites", "Hidden"]
            selectedValue: root.showFilter
            onOptionSelected: (name) => root.showFilter = name
            showDivider: false
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 40
        radius: Dimens.settingsControlRadius
        color: searchInput.activeFocus ? Colors.elevatedBg : Colors.subBgMica
        border.width: 1
        border.color: searchInput.activeFocus ? Colors.accent : Colors.border

        Behavior on color {
            ColorAnimation { duration: ShellState.motionDuration(Motion.hoverMs) }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Dimens.paddingMedium
            anchors.rightMargin: Dimens.paddingMedium
            spacing: Dimens.spacingSmall

            SymbolIcon {
                name: "search"
                size: Dimens.fontSizeMd
                color: searchInput.activeFocus ? Colors.accent : Colors.fgMuted
            }

            TextInput {
                id: searchInput
                Layout.fillWidth: true
                verticalAlignment: TextInput.AlignVCenter
                color: Colors.fg
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeBase
                selectByMouse: true
                clip: true
                onTextChanged: root.query = text

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: searchInput.text.length === 0
                    text: "Search installed apps"
                    color: Colors.subtext
                    font: searchInput.font
                }
            }
        }
    }

    SectionLabel { text: root.shownApps.length + (root.shownApps.length === 1 ? " app" : " apps") }

    // ---- The list ----
    GroupCard {
        visible: root.shownApps.length > 0

        Repeater {
            model: root.shownApps

            delegate: AppRow {
                required property var modelData
                required property int index

                name: modelData.name
                comment: modelData.comment
                iconName: modelData.icon
                favourite: root.favourites.includes(modelData.id)
                hidden: root.hidden.includes(modelData.id)
                showDivider: index !== root.shownApps.length - 1
                onFavouriteToggled: ShellState.favouriteApps = root._toggle(ShellState.favouriteApps, modelData.id)
                onHiddenToggled: ShellState.hiddenApps = root._toggle(ShellState.hiddenApps, modelData.id)
            }
        }
    }

    Text {
        Layout.fillWidth: true
        visible: root.shownApps.length === 0
        horizontalAlignment: Text.AlignHCenter
        text: root.showFilter === "All" ? "No apps found" : "Nothing in " + root.showFilter.toLowerCase() + " yet"
        color: Colors.subtext
        font.family: Fonts.text
        font.pixelSize: Dimens.fontSizeBase
    }
}