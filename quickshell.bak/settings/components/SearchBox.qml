// components/SearchBox.qml — sidebar search. The index is built from core/SettingsRegistry.qml,
// so a new menu or view is searchable the moment it is added there; nothing to list by hand.
// It matches title, subtitle, tags and the parent menu name. While there is a query the host hides
// the section list and this component grows to fill the sidebar and shows the results itself.
// `extraEntries` carries the individual options (toggles, sliders, rows) found by
// SearchIndexService, so searching "bounce" lands on Appearance > Motion.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../core"
import "../../styles"
import "../../services"

ColumnLayout {
    id: root

    // [{ menuId, viewId, title, description, path, icon }] — individual options, from SearchIndexService.
    property var extraEntries: []

    property string searchText: searchInput.text
    property alias activeFocusInput: searchInput.activeFocus

    readonly property bool searching: searchInput.text.trim().length > 0
    readonly property bool hasResults: filteredResults.length > 0

    // viewId is "" when the result is a top-level menu.
    signal resultSelected(string menuId, string viewId)

    function clear() { searchInput.text = "" }
    function forceActiveFocus() { searchInput.forceActiveFocus() }
    function _select(entry) {
        root.resultSelected(entry.menuId, entry.viewId)
        root.clear()
    }

    // Reads exactly as the island's radius, no nesting.
    readonly property real _boxRadius: ShellState.islandCornerRadius

    Layout.fillWidth: true
    Layout.fillHeight: root.searching
    spacing: Dimens.spacingSmall

    // Lower-cased text plus a copy without punctuation, so "wifi" finds "Wi-Fi".
    function _hay(text) {
        const t = String(text).toLowerCase()
        return t + " " + t.replace(/[^a-z0-9 ]/g, "")
    }

    // ── Index: every menu and every view in the registry ──────────
    readonly property var _index: {
        let out = []
        const clusters = SettingsRegistry.clusters
        for (let c = 0; c < clusters.length; c++) {
            const menus = clusters[c].menus
            for (let m = 0; m < menus.length; m++) {
                const menu = menus[m]
                out.push({
                    menuId: menu.id, viewId: "", title: menu.title, subtitle: menu.subtitle,
                    icon: menu.icon, parentTitle: "", placeholder: !!menu.placeholder,
                    haystack: root._hay(menu.title + " " + menu.subtitle + " " + (menu.tags || ""))
                })
                const views = menu.views || []
                for (let v = 0; v < views.length; v++) {
                    const view = views[v]
                    out.push({
                        menuId: menu.id, viewId: view.id, title: view.title, subtitle: view.subtitle,
                        icon: view.icon, parentTitle: menu.title, placeholder: !!view.placeholder,
                        haystack: root._hay(view.title + " " + view.subtitle + " " + (view.tags || "") + " " + menu.title)
                    })
                }
            }
        }
        // Individual options found on the pages. The path ("Appearance › Motion") is their second line.
        const extra = root.extraEntries
        for (let i = 0; i < extra.length; i++) {
            const e = extra[i]
            out.push({
                menuId: e.menuId, viewId: e.viewId, title: e.title, subtitle: e.path,
                icon: e.icon, parentTitle: "", placeholder: false,
                haystack: root._hay(e.title + " " + e.description + " " + e.path)
            })
        }
        return out
    }

    // Every word of the query must appear somewhere; title matches rank first.
    readonly property var filteredResults: {
        const words = searchInput.text.toLowerCase().trim().split(/\s+/).filter(w => w.length > 0)
        if (words.length === 0) return []
        let scored = []
        for (let i = 0; i < root._index.length; i++) {
            const e = root._index[i]
            if (!words.every(w => e.haystack.includes(w))) continue
            const title = e.title.toLowerCase()
            let score = 0
            if (title === words.join(" ")) score += 100
            if (title.startsWith(words[0])) score += 40
            if (words.every(w => title.includes(w))) score += 20
            if (e.viewId !== "") score += 1   // a specific view beats its parent menu on a tie
            scored.push({ e: e, score: score, order: i })
        }
        scored.sort((a, b) => b.score - a.score || a.order - b.order)
        return scored.map(s => s.e)
    }

    // A few real names from the registry for the typing placeholder.
    readonly property var _phrases: {
        let titles = root._index.map(e => e.title)
        let out = ["Search settings..."]
        const step = Math.max(1, Math.floor(titles.length / 5))
        for (let i = 0; i < titles.length && out.length < 6; i += step) out.push("Search '" + titles[i] + "'...")
        return out
    }

    // ── Input box ──────────────────────────────────────────────
    Rectangle {
        id: inputBox
        Layout.fillWidth: true
        Layout.preferredHeight: 34

        color: searchInput.activeFocus ? Colors.elevatedBg : Colors.subBgMica
        radius: root._boxRadius
        border.color: searchInput.activeFocus ? Colors.accent : Colors.border
        border.width: 1

        Behavior on color { ColorAnimation { duration: ShellState.motionDuration(Motion.hoverMs) } }
        Behavior on border.color { ColorAnimation { duration: ShellState.motionDuration(Motion.hoverMs) } }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Dimens.paddingSmall
            anchors.rightMargin: Dimens.paddingSmall
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

                onTextChanged: resultsList.currentIndex = 0

                Keys.onPressed: (event) => {
                    if (root.searching && root.hasResults) {
                        if (event.key === Qt.Key_Down) {
                            resultsList.currentIndex = Math.min(resultsList.currentIndex + 1, root.filteredResults.length - 1)
                            resultsList.positionViewAtIndex(resultsList.currentIndex, ListView.Contain)
                            event.accepted = true
                            return
                        } else if (event.key === Qt.Key_Up) {
                            resultsList.currentIndex = Math.max(resultsList.currentIndex - 1, 0)
                            resultsList.positionViewAtIndex(resultsList.currentIndex, ListView.Contain)
                            event.accepted = true
                            return
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (resultsList.currentIndex >= 0 && resultsList.currentIndex < root.filteredResults.length) {
                                root._select(root.filteredResults[resultsList.currentIndex])
                            }
                            event.accepted = true
                            return
                        }
                    }

                    if (event.key === Qt.Key_Escape) {
                        if (text.length > 0) text = ""
                        else searchInput.focus = false
                        event.accepted = true
                    }
                }

                Text {
                    id: placeholderText
                    color: Colors.subtext
                    font: searchInput.font
                    visible: searchInput.text.length === 0
                    anchors.verticalCenter: parent.verticalCenter

                    property int phraseIdx: 0
                    property int charIdx: 0
                    property bool deleting: false

                    text: ""

                    Timer {
                        id: typewriterTimer
                        running: searchInput.text.length === 0 && !searchInput.activeFocus
                        repeat: true
                        interval: 100
                        onTriggered: {
                            const target = root._phrases[placeholderText.phraseIdx % root._phrases.length]

                            if (!placeholderText.deleting) {
                                placeholderText.charIdx++
                                placeholderText.text = target.substring(0, placeholderText.charIdx)
                                if (placeholderText.charIdx >= target.length) {
                                    placeholderText.deleting = true
                                    interval = 1800
                                } else {
                                    interval = 80
                                }
                            } else {
                                placeholderText.charIdx--
                                placeholderText.text = target.substring(0, Math.max(0, placeholderText.charIdx))
                                if (placeholderText.charIdx <= 0) {
                                    placeholderText.deleting = false
                                    placeholderText.phraseIdx = (placeholderText.phraseIdx + 1) % root._phrases.length
                                    interval = 400
                                } else {
                                    interval = 40
                                }
                            }
                        }
                    }
                }
            }

            // Clear button
            Rectangle {
                implicitWidth: 20
                implicitHeight: 20
                radius: 10
                color: clearMouse.containsMouse ? Colors.red : "transparent"
                visible: searchInput.text.length > 0

                Behavior on color { ColorAnimation { duration: ShellState.motionDuration(Motion.hoverMs) } }

                SymbolIcon {
                    anchors.centerIn: parent
                    name: "close"
                    size: Dimens.fontSizeSm
                    color: clearMouse.containsMouse ? "#ffffff" : Colors.subtext
                }

                MouseArea {
                    id: clearMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.clear()
                        searchInput.forceActiveFocus()
                    }
                }
            }
        }
    }

    // ── Results (live in the sidebar, under the box) ───────────
    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: root.searching

        ListView {
            id: resultsList
            anchors.fill: parent
            clip: true
            spacing: 3
            visible: root.hasResults
            model: root.filteredResults

            delegate: Item {
                id: resultRow
                required property var modelData
                required property int index

                width: resultsList.width
                height: 48

                readonly property bool isHighlighted: ListView.isCurrentItem

                Rectangle {
                    anchors.fill: parent
                    radius: Dimens.settingsContainerRadius
                    color: Colors.accent
                    opacity: resultRow.isHighlighted ? 0.18 : 0.0
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Dimens.paddingMedium
                    anchors.rightMargin: Dimens.paddingSmall
                    spacing: Dimens.spacingMedium

                    SymbolIcon {
                        Layout.preferredWidth: 24
                        name: resultRow.modelData.icon
                        size: Dimens.fontSize18
                        color: resultRow.isHighlighted ? Colors.accent : Colors.fg
                        animated: true
                        activated: resultRow.isHighlighted
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        Text {
                            Layout.fillWidth: true
                            text: resultRow.modelData.title
                            color: resultRow.isHighlighted ? Colors.accent : Colors.fg
                            font.family: Fonts.text
                            font.pixelSize: Dimens.fontSizeBase
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            text: resultRow.modelData.parentTitle !== ""
                                ? resultRow.modelData.parentTitle + "  ›  " + resultRow.modelData.subtitle
                                : resultRow.modelData.subtitle
                            color: Colors.subtext
                            font.family: Fonts.text
                            font.pixelSize: Dimens.fontSizeXs
                            elide: Text.ElideRight
                        }
                    }

                    ComingSoonTag {
                        visible: resultRow.modelData.placeholder
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: resultsList.currentIndex = resultRow.index
                    onClicked: root._select(resultRow.modelData)
                }
            }
        }

        RowLayout {
            anchors.top: parent.top
            anchors.topMargin: Dimens.paddingLarge
            anchors.horizontalCenter: parent.horizontalCenter
            visible: !root.hasResults
            spacing: Dimens.spacingSmall

            SymbolIcon {
                name: "search_off"
                size: Dimens.fontSizeMd
                color: Colors.subtext
            }

            Text {
                text: "No settings found"
                color: Colors.subtext
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeBase
            }
        }
    }
}
