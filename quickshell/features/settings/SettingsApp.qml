// SettingsApp.qml — settings window: sidebar of menus on the left, a page host on the right.
// What exists, and where it lives, is defined in core/SettingsRegistry.qml.
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "core"
import "components"
import "pages/about"
import "../hyprland"
import "../theme"
import "../../core/shell"
import "../../core/styles"

Scope {
    id: root

    // Reading SettingsStore here creates it at shell start, so saved settings are applied
    // even before any page that uses the store is opened (pages load lazily).
    readonly property bool storeLoaded: SettingsStore._loaded

    // ── Shell-wide services ────────────────────────────────────
    // They live here (not in the About page) so update checks keep running while Settings is
    // closed. A page receives one by declaring a property with the same name
    // (see the injection in pageLoader.onLoaded below).
    SystemInfoService { id: systemInfo }
    UpdateService { id: updateService }

    // Finds every individual option on every page for the search box (no hand-kept list).
    SearchIndexService {
        id: searchIndex
        baseDir: decodeURIComponent(String(Qt.resolvedUrl(".")).replace(/^file:\/\//, "").replace(/\/$/, ""))
    }

    // ── IPC ────────────────────────────────────────────────────
    // Argument and return types must be spelled out or Quickshell does not register the function.
    IpcHandler {
        target: "settings"

        function open(): void { ShellState.openSettings() }
        function close(): void { ShellState.closeSettings() }
        function toggle(): void { ShellState.toggleSettings() }

        // qs ipc call settings section appearance   |   ... section appearance/motion
        function section(name: string): void {
            ShellState.openSettings()
            SettingsNav.openByName(name)
        }
    }

    // ── Window ─────────────────────────────────────────────────
    FloatingWindow {
        id: window
        title: "Settings"
        visible: ShellState.settingsOpen
        color: Colors.mainBgMica
        implicitWidth: 1080
        implicitHeight: 720

        onVisibleChanged: {
            if (visible) {
                focusDelay.start()
                gearIcon.play()
                searchIndex.rebuild()
                IconThemeService.refreshThemes()
                LayoutSettingsService.refresh()
            }
        }

        Timer {
            id: focusDelay
            interval: 50
            onTriggered: contentRoot.forceActiveFocus()
        }

        Item {
            id: contentRoot
            anchors.fill: parent
            focus: true

            // ── Search: jump to a picked option ────────────────
            // Title of the option picked in search; scrolled to and flashed once its page is up.
            property string pendingOption: ""

            // ── Remembering the scroll position ────────────────
            // The scroller of the page now showing, and the key ("menu/view") its position is saved under.
            // Going back to a page restores where it was; the page itself is rebuilt from scratch.
            property var activeFlick: null
            property string activeFlickKey: ""

            // Retries a few times because the page loads a moment after the navigation.
            Timer {
                id: jumpTimer
                interval: 120
                property int attempts: 0
                onTriggered: {
                    if (contentRoot.jumpToOption(contentRoot.pendingOption)) {
                        contentRoot.pendingOption = ""
                        return
                    }
                    attempts++
                    if (attempts < 8) restart()
                    else contentRoot.pendingOption = ""
                }
            }

            // Saves the position as the page scrolls.
            Connections {
                target: contentRoot.activeFlick
                ignoreUnknownSignals: true

                function onContentYChanged() {
                    if (contentRoot.activeFlickKey !== "" && contentRoot.activeFlick)
                        SettingsNav.scrollMemory[contentRoot.activeFlickKey] = contentRoot.activeFlick.contentY
                }
            }

            // Puts the saved position back once the page is tall enough to reach it (its content
            // lays out over a few frames).
            Timer {
                id: restoreTimer
                interval: 40
                property var flick: null
                property real target: 0
                property int attempts: 0
                onTriggered: {
                    if (!flick) return
                    const maxY = Math.max(0, flick.contentHeight - flick.height)
                    attempts++
                    if (maxY >= target - 1 || attempts >= 10) {
                        flick.contentY = Math.min(target, maxY)
                        return
                    }
                    restart()
                }
            }

            // Clears the "returning" flag a moment after the page has loaded, so the page itself
            // (which reads it while it is being built) still sees it.
            Timer {
                id: returnTimer
                interval: 400
                onTriggered: SettingsNav.returning = false
            }

            NumberAnimation {
                id: scrollAnim
                property: "contentY"
                duration: ShellState.motionDuration(Motion.fadeMs)
                easing.type: Easing.OutCubic
            }

            // Highlight laid over the found row; blinks twice, then removes itself.
            Component {
                id: flashComp

                Rectangle {
                    id: flash
                    anchors.fill: parent
                    z: 50
                    radius: Dimens.settingsContainerRadius
                    color: Colors.accent
                    opacity: 0

                    SequentialAnimation {
                        running: true
                        NumberAnimation { target: flash; property: "opacity"; to: 0.35; duration: 180 }
                        NumberAnimation { target: flash; property: "opacity"; to: 0.0; duration: 450 }
                        NumberAnimation { target: flash; property: "opacity"; to: 0.35; duration: 180 }
                        NumberAnimation { target: flash; property: "opacity"; to: 0.0; duration: 600 }
                        ScriptAction { script: flash.destroy() }
                    }
                }
            }

            // First visible item whose label/title (pass 0) or text (pass 1, section headings) matches.
            function _findOption(node, target, pass) {
                if (!node || node.visible === false) return null
                if (node.height > 0) {
                    if (pass === 0) {
                        if (node.label !== undefined && String(node.label).trim() === target) return node
                        if (typeof node.title === "string" && node.title.trim() === target) return node
                    } else if (typeof node.text === "string" && node.text.trim() === target) {
                        return node
                    }
                }
                const kids = node.children
                if (!kids) return null
                for (let i = 0; i < kids.length; i++) {
                    const r = contentRoot._findOption(kids[i], target, pass)
                    if (r) return r
                }
                return null
            }

            // Scrolls the page to the option and flashes it. Returns false until the row exists.
            function jumpToOption(target) {
                const page = pageLoader.item
                if (!page || target === "") return false
                const want = String(target).trim()
                const row = contentRoot._findOption(page, want, 0) || contentRoot._findOption(page, want, 1)
                if (!row) return false

                let fl = row.parent
                while (fl && !(fl.contentY !== undefined && fl.contentHeight !== undefined)) fl = fl.parent
                if (fl) {
                    const y = row.mapToItem(fl.contentItem, 0, 0).y
                    const maxY = Math.max(0, fl.contentHeight - fl.height)
                    scrollAnim.stop()
                    scrollAnim.target = fl
                    scrollAnim.to = Math.max(0, Math.min(y - fl.height / 3, maxY))
                    scrollAnim.start()
                }
                flashComp.createObject(row)
                return true
            }

            // The scroller of a page: the one a PageScroll exposes, else the first Flickable inside it.
            function findFlickable(node) {
                if (!node) return null
                if ("flickable" in node && node.flickable) return node.flickable
                if (node.contentY !== undefined && node.contentHeight !== undefined) return node
                const kids = node.children
                if (!kids) return null
                for (let i = 0; i < kids.length; i++) {
                    const r = contentRoot.findFlickable(kids[i])
                    if (r) return r
                }
                return null
            }

            // Hands a shared service to the page if the page declares a property with that name.
            function inject(page, name, value) {
                if (name in page) page[name] = value
            }

            // ── Input ──────────────────────────────────────────
            // Click anywhere outside the search box to give focus back (closes the suggestions).
            TapHandler {
                onTapped: (eventPoint) => {
                    const p = searchBox.mapFromItem(contentRoot, eventPoint.position)
                    if (!searchBox.contains(p)) contentRoot.forceActiveFocus()
                }
            }

            // Ctrl+F focuses search. Escape steps back out of a view first, then closes the window.
            Keys.onPressed: (event) => {
                if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_F) {
                    searchBox.forceActiveFocus()
                    event.accepted = true
                    return
                }
                if (event.key === Qt.Key_Escape) {
                    if (SettingsNav.canGoBack) SettingsNav.back()
                    else ShellState.closeSettings()
                    event.accepted = true
                }
            }

            RowLayout {
                anchors.fill: parent
                spacing: 0

                // ============ SIDEBAR ============
                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 260
                    color: "transparent"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Dimens.paddingMedium
                        spacing: Dimens.spacingMedium

                        // Header: gear + app title
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Dimens.spacingSmall

                            Rectangle {
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                radius: 20
                                color: gearMouse.containsMouse ? Colors.elevatedBg : "transparent"

                                Behavior on color {
                                    ColorAnimation { duration: ShellState.motionDuration(Motion.hoverMs) }
                                }

                                // The gear turns when Settings opens, on hover and on click.
                                SymbolIcon {
                                    id: gearIcon
                                    anchors.centerIn: parent
                                    name: "settings"
                                    size: Dimens.fontSizeLg
                                    color: Colors.accent
                                    animated: true
                                    hovered: gearMouse.containsMouse
                                }

                                MouseArea {
                                    id: gearMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: gearIcon.play()
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0

                                Text {
                                    text: SettingsRegistry.appTitle
                                    color: Colors.fg
                                    font.family: Fonts.display
                                    font.pixelSize: Dimens.fontSizeLg
                                    font.weight: Font.Bold
                                }

                                Text {
                                    text: SettingsRegistry.appSubtitle
                                    color: Colors.subtext
                                    font.family: Fonts.text
                                    font.pixelSize: Dimens.fontSizeXs
                                }
                            }
                        }

                        // Search: while there is a query (or the box is focused and empty) it fills
                        // the sidebar with results and the section list below is hidden.
                        SearchBox {
                            id: searchBox
                            extraEntries: searchIndex.entries

                            onResultSelected: (menuId, viewId, optionTitle) => {
                                if (viewId !== "") SettingsNav.openView(menuId, viewId)
                                else SettingsNav.openMenu(menuId)
                                contentRoot.pendingOption = optionTitle
                                jumpTimer.attempts = 0
                                if (optionTitle !== "") jumpTimer.restart()
                            }
                            onDismissed: contentRoot.forceActiveFocus()
                        }

                        // Section list
                        Flickable {
                            id: sidebarFlick
                            visible: !searchBox.searching && !searchBox.suggesting
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            contentWidth: width
                            contentHeight: sidebarColumn.implicitHeight
                            clip: true
                            boundsBehavior: Flickable.StopAtBounds

                            ColumnLayout {
                                id: sidebarColumn
                                width: sidebarFlick.width
                                spacing: Dimens.spacingLarge

                                Repeater {
                                    model: SettingsRegistry.clusters

                                    delegate: ColumnLayout {
                                        id: cluster
                                        required property var modelData

                                        Layout.fillWidth: true
                                        spacing: 3

                                        Repeater {
                                            model: cluster.modelData.menus

                                            delegate: SidebarItem {
                                                required property var modelData

                                                icon: modelData.icon
                                                title: modelData.title
                                                subtitle: modelData.subtitle
                                                selected: SettingsNav.menuId === modelData.id
                                                onClicked: SettingsNav.openMenu(modelData.id)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ============ PAGE AREA ============
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"

                    // Drag the window by its top edge.
                    MouseArea {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 24
                        z: 10
                        acceptedButtons: Qt.LeftButton
                        onPressed: window.startSystemMove()
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Dimens.paddingLarge
                        spacing: Dimens.spacingMedium

                        PageTitle {
                            icon: SettingsNav.icon
                            title: SettingsNav.title
                            subtitle: SettingsNav.subtitle
                            canGoBack: SettingsNav.canGoBack
                            onBackClicked: SettingsNav.back()
                        }

                        Loader {
                            id: pageLoader
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            source: SettingsNav.pageSource !== "" ? Qt.resolvedUrl(SettingsNav.pageSource) : ""

                            // Loader does not reliably size its item inside a layout, so bind it.
                            onLoaded: {
                                const page = pageLoader.item as Item
                                if (!page) return
                                page.width = Qt.binding(() => pageLoader.width)
                                page.height = Qt.binding(() => pageLoader.height)

                                // Pages that declare these properties receive the shared services.
                                contentRoot.inject(page, "updateService", updateService)
                                contentRoot.inject(page, "systemInfo", systemInfo)

                                // Track this page's scroller; coming back to a page restores its position
                                // (but a jump from search scrolls to its option instead).
                                const fl = contentRoot.findFlickable(page)
                                const key = SettingsNav.menuId + "/" + SettingsNav.viewId
                                contentRoot.activeFlickKey = key
                                contentRoot.activeFlick = fl
                                const saved = SettingsNav.scrollMemory[key]
                                if (fl && SettingsNav.returning && contentRoot.pendingOption === ""
                                        && saved !== undefined && saved > 0) {
                                    restoreTimer.flick = fl
                                    restoreTimer.target = saved
                                    restoreTimer.attempts = 0
                                    restoreTimer.restart()
                                }
                                returnTimer.restart()

                                loadFade.restart()
                            }

                            NumberAnimation {
                                id: loadFade
                                target: pageLoader
                                property: "opacity"
                                from: 0
                                to: 1
                                duration: ShellState.motionDuration(Motion.fadeMs)
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }
            }

            PickerSheet {
                anchors.fill: parent
                z: 100
            }
        }
    }
}
