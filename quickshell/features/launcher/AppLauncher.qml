\// features/launcher/AppLauncher.qml — the launcher page. The island animates this page's size; inside it,
// everything uses the island's curves: OutBack for things that appear, OutCubic for small moves and fades.
pragma ComponentBehavior: Bound

import "../clipboard"
import "."
import "../theme"
import "../../core/shell"
import "../../core/styles"
import QtQuick
import QtQuick.Controls
import Quickshell

Item {
    id: root

    readonly property int rowHeight: 54
    readonly property int maxVisibleRows: ShellState.launcherMaxRows
    readonly property int maxWidth: Math.round(ShellState.launcherWidth)
    readonly property int minWidth: Math.round(maxWidth * 0.72)
    readonly property int chromeHeight: 76

    // Grid sizing
    readonly property int appCellHeight: 88
    readonly property int emojiCellSize: 48
    readonly property int sideMargins: 24   // 12px on each side of the list/grid

    // AppLauncher fills the island directly (no settings-window layer in
    // between), so its containers derive straight off the master with
    // their own real margin (12px, matching Dimens.paddingMedium below).
    readonly property real _outerRadius: ShellState.islandCornerRadius

    property string query: ""
    // App rows are DesktopEntry objects; everything else is a plain row object
    // with a `kind` (see features/launcher/LauncherSearch.qml).
    property var results: LauncherSearch.search(query)
    property int selectedIndex: 0

    // True for a moment after the panel opens: results then wait for the island's content delay and
    // stagger in. While typing it is false, so results only fade.
    property bool opening: true

    // ---- mode / layout ----
    readonly property string mode: LauncherSearch.parse(query).mode
    readonly property bool isEmoji: mode === "emoji"

    // Emoji is always a grid (unless it only has an info row, e.g. "No emoji found").
    // Apps use the grid only when the layout setting is Grid AND every row is a
    // plain app (no calculator / unit / system rows mixed in).
    readonly property bool useGrid: {
        if (mode === "emoji") return results.every(r => r.kind === "copy")
        if (mode !== "apps" || LauncherState.viewMode !== "Grid") return false
        return results.every(r => r.kind === undefined)
    }

    readonly property int gridWidth: maxWidth - sideMargins
    readonly property int gridColumns: isEmoji
        ? Math.max(1, Math.floor(gridWidth / emojiCellSize))
        : LauncherState.gridColumns
    readonly property int gridCellHeight: isEmoji ? emojiCellSize : appCellHeight
    readonly property int gridRows: Math.ceil(results.length / gridColumns)
    readonly property int gridVisibleRows: Math.max(2, Math.floor(maxVisibleRows * rowHeight / gridCellHeight))

    // Search-bar icon follows the active plugin
    readonly property string searchGlyph: {
        switch (mode) {
        case "cmd":      return "terminal"
        case "web":      return "travel_explore"
        case "files":    return "folder_open"
        case "note":     return "edit_note"
        case "snippets": return "text_snippet"
        case "emoji":    return "mood"
        default:
            var first = results.length > 0 ? results[0] : null
            if (first && first.kind === "copy" && first.id === "calc") return "calculate"
            if (first && first.kind === "copy" && first.id === "unit") return "straighten"
            return "search"
        }
    }
    readonly property bool pluginActive: searchGlyph !== "search"

    implicitWidth: (LauncherState.shrinkForFewResults && !useGrid && results.length <= 1) ? minWidth : maxWidth
    implicitHeight: useGrid
        ? chromeHeight + Math.min(Math.max(gridRows, 1), gridVisibleRows) * gridCellHeight
        : Math.min(
            chromeHeight + Math.max(results.length, 1) * rowHeight,
            chromeHeight + maxVisibleRows * rowHeight
        )

    // ---- hover name pill (emoji grid) ----
    property string tipLabel: ""
    property string tipLastLabel: ""   // kept while the pill fades out
    property real tipX: 0
    property real tipY: 0
    property real tipCellHeight: 0

    function showTip(item, label) {
        var p = item.mapToItem(root, item.width / 2, 0)
        tipX = p.x
        tipY = p.y
        tipCellHeight = item.height
        tipLabel = label
        tipLastLabel = label
    }

    function hideTip() {
        tipLabel = ""
    }

    // Delay before a result starts to appear: nothing while typing, the island's content delay plus a short
    // stagger when the panel opens.
    function enterDelay(index, stepMs, cap) {
        return root.opening ? Motion.contentDelayMs + Math.min(index, cap) * stepMs : 0
    }

    function scrollToSelected() {
        if (useGrid) appGrid.positionViewAtIndex(selectedIndex, GridView.Contain)
        else appList.positionViewAtIndex(selectedIndex, ListView.Contain)
    }

    function move(delta) {
        selectedIndex = Math.max(0, Math.min(selectedIndex + delta, results.length - 1))
        scrollToSelected()
    }

    function activate(item) {
        if (LauncherSearch.activate(item)) ShellState.showPage("clock")
    }

    onQueryChanged: {
        selectedIndex = 0
        hideTip()
        LauncherSearch.prepare(query)
        if (LauncherState.clipboardHistory && query.startsWith(":")) {
            ClipboardService.searchQuery = query.substring(1)
            ShellState.showPage("clipboard")
        }
    }

    Timer {
        id: focusTimer
        interval: 50
        repeat: false
        onTriggered: searchInput.forceActiveFocus()
    }

    Timer {
        id: openTimer
        interval: 700
        repeat: false
        onTriggered: root.opening = false
    }

    onVisibleChanged: {
        if (visible && ShellState.activePage === "launcher") {
            focusTimer.restart()
        }
    }

    Component.onCompleted: {
        focusTimer.restart()
        openTimer.restart()
    }

    Rectangle {
        id: searchBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 12
        height: 44
        radius: root._outerRadius
        color: Colors.subBgMica

        MouseArea {
            anchors.fill: parent
            onClicked: searchInput.forceActiveFocus()
        }

        Row {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: Dimens.spacingLg

            Text {
                id: glyph
                anchors.verticalCenter: parent.verticalCenter
                text: root.searchGlyph
                font.family: Fonts.icon
                font.pixelSize: Dimens.fontSizeLg
                font.variableAxes: Fonts.iconAxes
                font.features: { "liga": 1, "dlig": 1 }
                color: root.pluginActive ? Colors.accent : Colors.fgMuted

                property bool ready: false
                Component.onCompleted: glyph.ready = true

                Behavior on color {
                    ColorAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
                }

                // A new mode pops its icon in, with the island's OutBack curve.
                onTextChanged: if (glyph.ready && !ShellState.motionReduced) glyphPop.restart()

                ParallelAnimation {
                    id: glyphPop
                    NumberAnimation {
                        target: glyph
                        property: "scale"
                        from: 0.6
                        to: 1.0
                        duration: ShellState.motionDuration(Motion.glideMs * 0.6)
                        easing.type: Easing.OutBack
                        easing.overshoot: ShellState.motionIslandOvershoot() * 1.5
                    }
                    NumberAnimation {
                        target: glyph
                        property: "opacity"
                        from: 0.3
                        to: 1.0
                        duration: ShellState.motionDuration(Motion.fadeMs)
                        easing.type: Easing.OutCubic
                    }
                }
            }

            Item {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 24
                height: searchInput.height

                Text {
                    text: "Search..."
                    color: Colors.fgMuted
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeMd
                    anchors.verticalCenter: parent.verticalCenter
                    visible: searchInput.text.length === 0
                }

                TextInput {
                    id: searchInput
                    width: parent.width
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeLg
                    color: Colors.fg
                    clip: true
                    focus: true
                    onTextChanged: root.query = text

                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Down) {
                            root.move(root.useGrid ? root.gridColumns : 1)
                            event.accepted = true
                        } else if (event.key === Qt.Key_Up) {
                            root.move(root.useGrid ? -root.gridColumns : -1)
                            event.accepted = true
                        } else if (root.useGrid && event.key === Qt.Key_Right) {
                            root.move(1)
                            event.accepted = true
                        } else if (root.useGrid && event.key === Qt.Key_Left) {
                            root.move(-1)
                            event.accepted = true
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            root.activate(root.results[root.selectedIndex])
                            event.accepted = true
                        }
                    }
                }
            }
        }
    }

    // ---------------- List layout ----------------
    ListView {
        id: appList
        visible: !root.useGrid
        anchors.top: searchBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: 8
        anchors.margins: 12
        clip: true
        spacing: 2
        model: root.useGrid ? [] : root.results
        currentIndex: root.selectedIndex

        // One highlight that glides to the selected row. It is drawn behind the rows.
        highlightFollowsCurrentItem: false
        highlight: Rectangle {
            visible: appList.currentItem !== null
            radius: root._outerRadius
            color: Colors.subBgMica
            height: appList.currentItem ? appList.currentItem.height : 0
            width: appList.width
            y: appList.currentItem ? appList.currentItem.y : 0

            Behavior on y {
                NumberAnimation {
                    duration: ShellState.motionDuration(Motion.hoverMs)
                    easing.type: Easing.OutCubic
                }
            }
        }

        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        WheelHandler {
            onWheel: (event) => {
                appList.contentY = Math.max(
                    0,
                    Math.min(appList.contentY - event.angleDelta.y, Math.max(0, appList.contentHeight - appList.height))
                )
            }
        }

        delegate: Rectangle {
            id: delegateRoot
            required property int index
            required property var modelData

            // Non-app rows (calculator, web search, files, ...) carry a `kind`.
            readonly property bool isAction: modelData.kind !== undefined
            readonly property bool selected: delegateRoot.index === root.selectedIndex

            width: appList.width
            height: root.rowHeight - appList.spacing
            radius: root._outerRadius
            color: "transparent"

            // Entrance: fade and rise a little. Runs on every filter change (the rows are rebuilt).
            readonly property bool fadeEnabled: LauncherState.animateResults && !ShellState.motionReduced
            property real enter: delegateRoot.fadeEnabled ? 0 : 1
            opacity: delegateRoot.enter
            transform: Translate { y: (1 - delegateRoot.enter) * 5 }

            SequentialAnimation {
                id: enterAnim
                PauseAnimation { duration: ShellState.motionDuration(root.enterDelay(delegateRoot.index, 22, 6)) }
                NumberAnimation {
                    target: delegateRoot
                    property: "enter"
                    to: 1
                    duration: ShellState.motionDuration(Motion.fadeMs)
                    easing.type: Easing.OutCubic
                }
            }
            Component.onCompleted: if (delegateRoot.fadeEnabled) enterAnim.start()

            Row {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: Dimens.spacingMd

                Item {
                    width: 32
                    height: 32
                    anchors.verticalCenter: parent.verticalCenter
                    visible: LauncherState.showIcons

                    Image {
                        id: appIcon
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectFit
                        // Theme-folder SVGs render at this size, so ask for 2x to stay crisp.
                        sourceSize.width: width * 2
                        sourceSize.height: height * 2
                        source: delegateRoot.isAction ? "" : IconThemeService.resolve(delegateRoot.modelData.icon)
                        visible: status === Image.Ready
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: ShellState.islandCornerRadius
                        color: delegateRoot.selected ? Colors.mainBgMica : Colors.subBgMica
                        visible: appIcon.status !== Image.Ready

                        Behavior on color {
                            ColorAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
                        }

                        // first letter for apps without an icon
                        Text {
                            anchors.centerIn: parent
                            visible: !delegateRoot.isAction
                            text: delegateRoot.modelData.name ? delegateRoot.modelData.name.charAt(0).toUpperCase() : "?"
                            font.family: Fonts.text
                            font.pixelSize: Dimens.fontSizeMd
                            font.weight: Font.Bold
                            color: Colors.fg
                        }

                        // glyph for calculator / web / files / system / ... rows
                        Text {
                            anchors.centerIn: parent
                            visible: delegateRoot.isAction
                            text: delegateRoot.modelData.glyph || "bolt"
                            font.family: Fonts.icon
                            font.pixelSize: Dimens.fontSizeLg
                            font.variableAxes: Fonts.iconAxes
                            font.features: { "liga": 1, "dlig": 1 }
                            color: Colors.accent
                        }
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 1
                    width: parent.width - (LauncherState.showIcons ? 44 : 0)

                    Text {
                        text: delegateRoot.modelData.name
                        color: delegateRoot.modelData.kind === "info" ? Colors.fgMuted : Colors.fg
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeMd
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                        width: parent.width
                    }

                    Text {
                        text: delegateRoot.modelData.comment || ""
                        color: Colors.fgMuted
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeSm
                        visible: text.length > 0
                        elide: Text.ElideRight
                        width: parent.width
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: root.selectedIndex = delegateRoot.index
                onClicked: root.activate(delegateRoot.modelData)
            }
        }
    }

    // ---------------- Grid layout (apps + emoji) ----------------
    GridView {
        id: appGrid
        visible: root.useGrid
        anchors.top: searchBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: 8
        anchors.margins: 12
        clip: true
        cellWidth: Math.floor(width / root.gridColumns)
        cellHeight: root.gridCellHeight
        model: root.useGrid ? root.results : []
        currentIndex: root.selectedIndex

        // One highlight that glides to the selected cell. It is drawn behind the cells.
        highlightFollowsCurrentItem: false
        highlight: Rectangle {
            visible: appGrid.currentItem !== null
            radius: root._outerRadius
            color: Colors.subBgMica
            width: appGrid.cellWidth - 4
            height: appGrid.cellHeight - 4
            x: appGrid.currentItem ? appGrid.currentItem.x + 2 : 0
            y: appGrid.currentItem ? appGrid.currentItem.y + 2 : 0

            Behavior on x {
                NumberAnimation {
                    duration: ShellState.motionDuration(Motion.hoverMs)
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on y {
                NumberAnimation {
                    duration: ShellState.motionDuration(Motion.hoverMs)
                    easing.type: Easing.OutCubic
                }
            }
        }

        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        onContentYChanged: root.hideTip()

        WheelHandler {
            onWheel: (event) => {
                appGrid.contentY = Math.max(
                    0,
                    Math.min(appGrid.contentY - event.angleDelta.y, Math.max(0, appGrid.contentHeight - appGrid.height))
                )
            }
        }

        delegate: Item {
            id: cell
            required property int index
            required property var modelData

            readonly property bool selected: cell.index === root.selectedIndex
            readonly property bool emoji: root.isEmoji

            width: appGrid.cellWidth
            height: appGrid.cellHeight

            // A selected cell grows a little, with a plain ease.
            scale: cell.selected ? 1.04 : 1.0
            Behavior on scale {
                NumberAnimation {
                    duration: ShellState.motionDuration(Motion.hoverMs)
                    easing.type: Easing.OutCubic
                }
            }

            // Entrance: fade and rise a little.
            readonly property bool fadeEnabled: LauncherState.animateResults && !ShellState.motionReduced
            property real enter: cell.fadeEnabled ? 0 : 1
            opacity: cell.enter
            transform: Translate { y: (1 - cell.enter) * 5 }

            SequentialAnimation {
                id: cellEnterAnim
                PauseAnimation { duration: ShellState.motionDuration(root.enterDelay(cell.index, 16, 8)) }
                NumberAnimation {
                    target: cell
                    property: "enter"
                    to: 1
                    duration: ShellState.motionDuration(Motion.fadeMs)
                    easing.type: Easing.OutCubic
                }
            }
            Component.onCompleted: if (cell.fadeEnabled) cellEnterAnim.start()

            // ---- emoji cell ----
            Text {
                anchors.centerIn: parent
                visible: cell.emoji
                text: cell.emoji ? cell.modelData.value : ""
                font.pixelSize: Dimens.fontSizeXl
                color: Colors.fg
            }

            // ---- app cell ----
            Column {
                anchors.centerIn: parent
                visible: !cell.emoji
                spacing: Dimens.spacingSm
                width: parent.width - 12

                Item {
                    width: 40
                    height: 40
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: LauncherState.showIcons

                    Image {
                        id: gridIcon
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectFit
                        sourceSize.width: width * 2
                        sourceSize.height: height * 2
                        source: cell.emoji ? "" : IconThemeService.resolve(cell.modelData.icon)
                        visible: status === Image.Ready
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: root._outerRadius
                        color: cell.selected ? Colors.mainBgMica : Colors.subBgMica
                        visible: gridIcon.status !== Image.Ready

                        Behavior on color {
                            ColorAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: (!cell.emoji && cell.modelData.name) ? cell.modelData.name.charAt(0).toUpperCase() : "?"
                            font.family: Fonts.text
                            font.pixelSize: Dimens.fontSizeLg
                            font.weight: Font.Bold
                            color: Colors.fg
                        }
                    }
                }

                Text {
                    width: parent.width
                    text: cell.emoji ? "" : (cell.modelData.name || "")
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    color: Colors.fg
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeSm
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    root.selectedIndex = cell.index
                    if (cell.emoji) {
                        // "😀  grinning face" -> "grinning face"
                        root.showTip(cell, cell.modelData.name.replace(cell.modelData.value, "").trim())
                    }
                }
                onExited: root.hideTip()
                onClicked: root.activate(cell.modelData)
            }
        }
    }

    // Hover name for emoji (shown only while the mouse is over a cell). It fades in and out.
    Rectangle {
        id: hoverTip
        z: 10
        opacity: root.tipLabel.length > 0 ? 1 : 0
        visible: opacity > 0
        width: tipText.implicitWidth + 16
        height: tipText.implicitHeight + 8
        radius: Dimens.radiusSmall
        color: Colors.mainBgMica
        border.width: 1
        border.color: Colors.border

        x: Math.max(4, Math.min(root.tipX - width / 2, root.width - width - 4))
        y: (root.tipY - height - 2 >= 0) ? (root.tipY - height - 2) : (root.tipY + root.tipCellHeight + 2)

        Behavior on opacity {
            NumberAnimation {
                duration: ShellState.motionDuration(Motion.fadeMs * 0.6)
                easing.type: Easing.OutCubic
            }
        }

        Text {
            id: tipText
            anchors.centerIn: parent
            text: root.tipLastLabel
            color: Colors.fg
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeSm
        }
    }

    Text {
        anchors.top: searchBar.bottom
        anchors.topMargin: 24
        anchors.horizontalCenter: parent.horizontalCenter
        text: "No apps found"
        color: Colors.fgMuted
        font.family: Fonts.text
        font.pixelSize: Dimens.fontSizeMd
        opacity: root.results.length === 0 ? 1 : 0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: ShellState.motionDuration(Motion.fadeMs)
                easing.type: Easing.OutCubic
            }
        }
    }

    Connections {
        target: ShellState
        function onActivePageChanged() {
            if (ShellState.activePage === "launcher") {
                searchInput.text = ""
                root.selectedIndex = 0
                root.opening = true
                openTimer.restart()
                LauncherSearch.prepare("")
                focusTimer.restart()
            }
        }
    }
}