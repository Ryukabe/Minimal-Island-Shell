// components/SearchBox.qml — sidebar search. The index is built from core/SettingsRegistry.qml
// (menus and views) plus `extraEntries` (individual options found by SearchIndexService).
// Matching: every word must match (substring, or a small typo for words of 4+ letters).
// Title and word-start matches rank first; matched letters are shown in bold.
// Focused with an empty box it lists recent picks (or the main menus). Picking an option reports
// its title so the host can scroll to the row and flash it.

pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../core"
import "../../../core/styles"
import "../../../core/shell"

ColumnLayout {
    id: root

    // [{ menuId, viewId, title, description, path, icon }] — individual options, from SearchIndexService.
    property var extraEntries: []

    // Last picked results, newest first (kept until the shell reloads).
    property var recents: []

    property string searchText: searchInput.text
    property alias activeFocusInput: searchInput.activeFocus

    readonly property bool searching: searchInput.text.trim().length > 0
    readonly property bool suggesting: searchInput.activeFocus && !root.searching && root._suggestions.length > 0
    readonly property bool hasResults: root.displayResults.length > 0

    // viewId is "" for a top-level menu; optionTitle is "" unless the pick was an individual option.
    signal resultSelected(string menuId, string viewId, string optionTitle)
    // Search is finished (picked something or pressed Escape): the host should take focus back.
    signal dismissed()

    function clear() { searchInput.text = "" }
    function forceActiveFocus() {
        searchInput.forceActiveFocus()
        searchInput.selectAll()
    }

    function _remember(entry) {
        const key = e => e.menuId + "|" + e.viewId + "|" + e.title
        const rest = root.recents.filter(r => key(r) !== key(entry))
        root.recents = [entry].concat(rest).slice(0, 5)
    }

    function _select(entry) {
        root._remember(entry)
        root.clear()
        root.resultSelected(entry.menuId, entry.viewId, entry.isOption ? entry.title : "")
        root.dismissed()
    }

    // Reads exactly as the island's radius, no nesting.
    readonly property real _boxRadius: ShellState.islandCornerRadius

    Layout.fillWidth: true
    Layout.fillHeight: root.searching || root.suggesting
    spacing: Dimens.spacingSmall

    onSuggestingChanged: resultsList.currentIndex = 0

    // ── Text helpers ───────────────────────────────────────────
    // Lower-cased text plus a copy without punctuation, so "wifi" finds "Wi-Fi".
    function _hay(text) {
        const t = String(text).toLowerCase()
        return t + " " + t.replace(/[^a-z0-9 ]/g, "")
    }

    // Adds the fields search needs: haystack, word list for typo matching, title words.
    function _entry(e, hayText) {
        const hay = root._hay(hayText)
        const toks = {}
        hay.split(/[^a-z0-9]+/).forEach(t => { if (t.length >= 3) toks[t] = true })
        e.haystack = hay
        e.tokens = Object.keys(toks)
        e.titleWords = String(e.title).toLowerCase().split(/[^a-z0-9]+/).filter(t => t.length > 0)
        return e
    }

    // Edit distance, giving up early once it is above `limit`.
    function _dist(a, b, limit) {
        if (Math.abs(a.length - b.length) > limit) return limit + 1
        let prev = []
        for (let j = 0; j <= b.length; j++) prev.push(j)
        for (let i = 1; i <= a.length; i++) {
            let cur = [i]
            let rowMin = i
            for (let j = 1; j <= b.length; j++) {
                const cost = a[i - 1] === b[j - 1] ? 0 : 1
                const v = Math.min(prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + cost)
                cur.push(v)
                if (v < rowMin) rowMin = v
            }
            if (rowMin > limit) return limit + 1
            prev = cur
        }
        return prev[b.length]
    }

    // 0 = no match, 0.5 = typo match, 1 = found somewhere, 3 = starts a word in the title.
    function _wordScore(e, w) {
        if (e.haystack.includes(w)) {
            for (let i = 0; i < e.titleWords.length; i++) {
                if (e.titleWords[i].startsWith(w)) return 3
            }
            return 1
        }
        const limit = w.length >= 7 ? 2 : (w.length >= 4 ? 1 : 0)
        if (limit === 0) return 0
        for (let i = 0; i < e.tokens.length; i++) {
            const t = e.tokens[i]
            if (root._dist(w, t, limit) <= limit || root._dist(w, t.substring(0, w.length), limit) <= limit) return 0.5
        }
        return 0
    }

    function _escape(s) {
        return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
    }

    // Title as StyledText with the typed words in bold.
    function _highlight(text, words) {
        const s = String(text)
        const lower = s.toLowerCase()
        const mark = []
        for (let i = 0; i < s.length; i++) mark.push(false)
        for (let w = 0; w < words.length; w++) {
            const idx = lower.indexOf(words[w])
            if (idx < 0) continue
            for (let k = idx; k < idx + words[w].length && k < s.length; k++) mark[k] = true
        }
        let out = ""
        let open = false
        for (let i = 0; i < s.length; i++) {
            if (mark[i] && !open) { out += "<b>"; open = true }
            if (!mark[i] && open) { out += "</b>"; open = false }
            out += root._escape(s[i])
        }
        if (open) out += "</b>"
        return out
    }

    // ── Index: every menu, every view, every option ─────────────
    readonly property var _index: {
        let out = []
        const clusters = SettingsRegistry.clusters
        for (let c = 0; c < clusters.length; c++) {
            const menus = clusters[c].menus
            for (let m = 0; m < menus.length; m++) {
                const menu = menus[m]
                out.push(root._entry({
                    menuId: menu.id, viewId: "", title: menu.title, subtitle: menu.subtitle,
                    description: "", icon: menu.icon, parentTitle: "", isOption: false,
                    placeholder: !!menu.placeholder
                }, menu.title + " " + menu.subtitle + " " + (menu.tags || "")))
                const views = menu.views || []
                for (let v = 0; v < views.length; v++) {
                    const view = views[v]
                    out.push(root._entry({
                        menuId: menu.id, viewId: view.id, title: view.title, subtitle: view.subtitle,
                        description: "", icon: view.icon, parentTitle: menu.title, isOption: false,
                        placeholder: !!view.placeholder
                    }, view.title + " " + view.subtitle + " " + (view.tags || "") + " " + menu.title))
                }
            }
        }
        const extra = root.extraEntries
        for (let i = 0; i < extra.length; i++) {
            const e = extra[i]
            out.push(root._entry({
                menuId: e.menuId, viewId: e.viewId, title: e.title, subtitle: e.path,
                description: e.description || "", icon: e.icon, parentTitle: "", isOption: true,
                placeholder: false
            }, e.title + " " + e.description + " " + e.path))
        }
        return out
    }

    readonly property var _words: searchInput.text.toLowerCase().trim().split(/\s+/).filter(w => w.length > 0)

    // Every word must match; word-start and title matches rank first, pages beat options on a tie.
    readonly property var filteredResults: {
        const words = root._words
        if (words.length === 0) return []
        let scored = []
        for (let i = 0; i < root._index.length; i++) {
            const e = root._index[i]
            let score = 0
            let ok = true
            for (let w = 0; w < words.length; w++) {
                const ws = root._wordScore(e, words[w])
                if (ws === 0) { ok = false; break }
                score += ws * 5
            }
            if (!ok) continue
            const title = e.title.toLowerCase()
            if (title === words.join(" ")) score += 100
            if (title.startsWith(words[0])) score += 40
            if (words.every(w => title.includes(w))) score += 20
            if (!e.isOption) score += 3
            if (e.viewId !== "") score += 1
            scored.push({ e: e, score: score, order: i })
        }
        scored.sort((a, b) => b.score - a.score || a.order - b.order)
        return scored.map(s => s.e)
    }

    // Shown when the box is focused and empty: recent picks, or the main menus.
    readonly property var _suggestions: {
        if (root.recents.length > 0) return root.recents
        return root._index.filter(e => !e.isOption && e.viewId === "").slice(0, 6)
    }

    readonly property var displayResults: root.searching ? root.filteredResults : (root.suggesting ? root._suggestions : [])

    // Page names only for the typing placeholder.
    readonly property var _phrases: {
        let titles = root._index.filter(e => !e.isOption).map(e => e.title)
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
                    if ((root.searching || root.suggesting) && root.hasResults) {
                        if (event.key === Qt.Key_Down) {
                            resultsList.currentIndex = Math.min(resultsList.currentIndex + 1, root.displayResults.length - 1)
                            resultsList.positionViewAtIndex(resultsList.currentIndex, ListView.Contain)
                            event.accepted = true
                            return
                        } else if (event.key === Qt.Key_Up) {
                            resultsList.currentIndex = Math.max(resultsList.currentIndex - 1, 0)
                            resultsList.positionViewAtIndex(resultsList.currentIndex, ListView.Contain)
                            event.accepted = true
                            return
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (resultsList.currentIndex >= 0 && resultsList.currentIndex < root.displayResults.length) {
                                root._select(root.displayResults[resultsList.currentIndex])
                            }
                            event.accepted = true
                            return
                        }
                    }

                    if (event.key === Qt.Key_Escape) {
                        if (text.length > 0) {
                            text = ""
                        } else {
                            searchInput.focus = false
                            root.dismissed()
                        }
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
        visible: root.searching || root.suggesting

        ColumnLayout {
            anchors.fill: parent
            spacing: Dimens.spacingSmall
            visible: root.hasResults

            // Heading for the empty-box list.
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Dimens.paddingMedium
                Layout.rightMargin: Dimens.paddingSmall
                visible: root.suggesting

                Text {
                    Layout.fillWidth: true
                    text: root.recents.length > 0 ? "Recent" : "Suggestions"
                    color: Colors.subtext
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeXs
                }

                Text {
                    visible: root.recents.length > 0
                    text: "Clear"
                    color: clearRecentMouse.containsMouse ? Colors.accent : Colors.subtext
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeXs

                    MouseArea {
                        id: clearRecentMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.recents = []
                    }
                }
            }

            ListView {
                id: resultsList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 3
                model: root.displayResults

                delegate: Item {
                    id: resultRow
                    required property var modelData
                    required property int index

                    width: resultsList.width
                    height: resultRow.modelData.description !== "" ? 62 : 48

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
                                text: root._highlight(resultRow.modelData.title, root._words)
                                textFormat: Text.StyledText
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

                            Text {
                                Layout.fillWidth: true
                                visible: resultRow.modelData.description !== ""
                                text: resultRow.modelData.description
                                color: Colors.fgMuted
                                font.family: Fonts.text
                                font.pixelSize: Dimens.fontSizeXs
                                elide: Text.ElideRight
                            }
                        }

                        ComingSoonTag {
                            visible: resultRow.modelData.placeholder
                        }

                        // "Page" or "Option" tag
                        Rectangle {
                            implicitWidth: kindText.implicitWidth + 12
                            implicitHeight: 16
                            radius: 8
                            color: "transparent"
                            border.color: Colors.border
                            border.width: 1

                            Text {
                                id: kindText
                                anchors.centerIn: parent
                                text: resultRow.modelData.isOption ? "Option" : "Page"
                                color: Colors.subtext
                                font.family: Fonts.text
                                font.pixelSize: Dimens.fontSizeXs
                            }
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
        }

        RowLayout {
            anchors.top: parent.top
            anchors.topMargin: Dimens.paddingLarge
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.searching && !root.hasResults
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