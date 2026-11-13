// features/clipboard/Clipboard.qml — the clipboard history page. The island animates this page's size; inside it,
// everything uses the island's curves: OutBack for things that appear, OutCubic for small moves and fades.
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import "."
import "../../core/shell"
import "../../core/styles"
import "../launcher"

Item {
    id: root

    // rowHeight is the nominal height of a one-line row; it only sizes the panel cap now
    readonly property int rowHeight: 58
    readonly property int rowPadding: 10
    readonly property int thumbSize: 56
    readonly property int chromeHeight: 76
    readonly property int maxVisibleRows: ShellState.clipboardMaxRows
    readonly property int maxWidth: ShellState.clipboardWidth

    property var historyItems: ClipboardService.filteredHistory
    property int selectedIndex: 0
    property real now: Date.now()

    // True for a moment after the panel opens: rows then wait for the island's content delay and stagger in.
    property bool opening: true
    // True for a moment after typing in the search box: rows are rebuilt and only fade.
    property bool typing: false
    // Rows animate in only for those two. A pin, delete or new copy rebuilds the list without replaying it.
    readonly property bool entering: root.opening || root.typing

    implicitWidth: maxWidth
    implicitHeight: Math.min(
        chromeHeight + Math.max(clipList.contentHeight, rowHeight),
        chromeHeight + maxVisibleRows * rowHeight
    )

    function timeLabel(ms) {
        if (!ms) return ""
        var s = Math.floor((now - ms) / 1000)
        if (s < 60) return "Just now"
        var m = Math.floor(s / 60)
        if (m < 60) return m + "m ago"
        var h = Math.floor(m / 60)
        if (h < 24) return h + "h ago"
        var d = Math.floor(h / 24)
        if (d < 7) return d + "d ago"
        return Qt.formatDate(new Date(ms), "d MMM")
    }

    // Nothing while typing, the island's content delay plus a short stagger when the panel opens.
    function enterDelay(index) {
        return root.opening ? Motion.contentDelayMs + Math.min(index, 6) * 22 : 0
    }

    function selectId(id) {
        var list = ClipboardService.filteredHistory
        for (var i = 0; i < list.length; i++) {
            if (list[i].id === id) {
                selectedIndex = i
                clipList.positionViewAtIndex(i, ListView.Contain)
                return
            }
        }
    }

    function pinItem(item) {
        if (!item) return
        ClipboardService.togglePin(item)
        selectId(item.id)
    }

    function deleteItem(item) {
        if (!item) return
        ClipboardService.deleteItem(item)
        var n = ClipboardService.filteredHistory.length
        selectedIndex = Math.max(0, Math.min(selectedIndex, n - 1))
    }

    // Delete the selected row: it slides out first, then the item is deleted.
    function removeSelected() {
        var list = ClipboardService.filteredHistory
        if (list.length === 0) return
        var row = clipList.itemAtIndex(root.selectedIndex)
        if (row) row.startRemove()
        else root.deleteItem(list[root.selectedIndex])
    }

    function pasteItem(item) {
        if (!item) return
        ClipboardService.selectAndPaste(item.id)
        ShellState.showPage("clock")
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

    Timer {
        id: typingTimer
        interval: 400
        repeat: false
        onTriggered: root.typing = false
    }

    // keeps "5m ago" labels fresh while the panel is open
    Timer {
        interval: 30000
        repeat: true
        running: ShellState.activePage === "clipboard"
        onTriggered: root.now = Date.now()
    }

    Connections {
        target: ShellState
        function onActivePageChanged() {
            if (ShellState.activePage === "clipboard") {
                searchInput.text = ClipboardService.searchQuery
                root.selectedIndex = 0
                root.now = Date.now()
                root.opening = true
                openTimer.restart()
                focusTimer.restart()
            }
        }
    }

    Component.onCompleted: {
        focusTimer.restart()
        openTimer.restart()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        // Search Header
        Rectangle {
            Layout.fillWidth: true
            height: 40
            radius: ShellState.islandCornerRadius
            color: Colors.subBgMica

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8

                Text {
                    id: headerGlyph
                    text: searchInput.text.length > 0 ? "search" : "content_paste"
                    font.family: Fonts.icon
                    font.pixelSize: Dimens.fontSizeMd
                    font.variableAxes: Fonts.iconAxes
                    color: searchInput.text.length > 0 ? Colors.accent : Colors.fgMuted

                    property bool ready: false
                    Component.onCompleted: headerGlyph.ready = true

                    Behavior on color {
                        ColorAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
                    }

                    // The icon pops in when it changes, with the island's OutBack curve.
                    onTextChanged: if (headerGlyph.ready && !ShellState.motionReduced) glyphPop.restart()

                    ParallelAnimation {
                        id: glyphPop
                        NumberAnimation {
                            target: headerGlyph
                            property: "scale"
                            from: 0.6
                            to: 1.0
                            duration: ShellState.motionDuration(Motion.glideMs * 0.6)
                            easing.type: Easing.OutBack
                            easing.overshoot: ShellState.motionIslandOvershoot() * 1.5
                        }
                        NumberAnimation {
                            target: headerGlyph
                            property: "opacity"
                            from: 0.3
                            to: 1.0
                            duration: ShellState.motionDuration(Motion.fadeMs)
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                TextInput {
                    id: searchInput
                    Layout.fillWidth: true
                    color: Colors.fg
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeMd
                    focus: true

                    Text {
                        text: "Search clipboard history..."
                        color: Colors.fgMuted
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeMd
                        visible: parent.text.length === 0
                    }

                    onTextChanged: {
                        ClipboardService.searchQuery = text
                        root.selectedIndex = 0
                        root.typing = true
                        typingTimer.restart()
                    }

                    Keys.onPressed: (event) => {
                        var list = ClipboardService.filteredHistory
                        var ctrl = (event.modifiers & Qt.ControlModifier) !== 0
                        if (event.key === Qt.Key_Down) {
                            if (root.selectedIndex < list.length - 1) {
                                root.selectedIndex++
                                clipList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                            }
                            event.accepted = true
                        } else if (event.key === Qt.Key_Up) {
                            if (root.selectedIndex > 0) {
                                root.selectedIndex--
                                clipList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                            }
                            event.accepted = true
                        } else if (event.key === Qt.Key_Escape) {
                            ShellState.showPage("clock")
                            event.accepted = true
                        } else if (ctrl && event.key === Qt.Key_P) {
                            if (list.length > 0) root.pinItem(list[root.selectedIndex])
                            event.accepted = true
                        } else if (ctrl && event.key === Qt.Key_D) {
                            root.removeSelected()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (list.length > 0) root.pasteItem(list[root.selectedIndex])
                            event.accepted = true
                        }
                    }
                }

                // Clear History Button (keeps pinned items). It fades in and out.
                Rectangle {
                    width: 24
                    height: 24
                    radius: ShellState.islandCornerRadius
                    color: "transparent"
                    opacity: ClipboardService.history.length > 0 ? 1 : 0
                    visible: opacity > 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: ShellState.motionDuration(Motion.fadeMs)
                            easing.type: Easing.OutCubic
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "delete_sweep"
                        font.family: Fonts.icon
                        font.pixelSize: Dimens.fontSizeMd
                        font.variableAxes: Fonts.iconAxes
                        color: Colors.fgMuted
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ClipboardService.clearAll()
                    }
                }
            }
        }

        // Clipboard Item List
        ListView {
            id: clipList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: ClipboardService.filteredHistory
            currentIndex: root.selectedIndex
            spacing: 4
            // build every delegate up front (max ~100) so contentHeight, and so the panel height, is exact
            cacheBuffer: 4000

            // One highlight that glides to the selected row, drawn behind the rows. It keeps its last place
            // while the list is rebuilt, so a pin or a new copy does not make it slide in from the top.
            highlightFollowsCurrentItem: false
            highlight: Rectangle {
                id: hl
                property real lastY: 0
                property real lastH: 0
                readonly property real wantY: clipList.currentItem ? clipList.currentItem.y : hl.lastY
                readonly property real wantH: clipList.currentItem ? clipList.currentItem.height : hl.lastH
                onWantYChanged: hl.lastY = hl.wantY
                onWantHChanged: hl.lastH = hl.wantH

                visible: clipList.count > 0
                radius: ShellState.islandCornerRadius
                color: Colors.subBgMica
                width: clipList.width
                y: hl.wantY
                height: hl.wantH

                Behavior on y {
                    NumberAnimation {
                        duration: ShellState.motionDuration(Motion.hoverMs)
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on height {
                    NumberAnimation {
                        duration: ShellState.motionDuration(Motion.hoverMs)
                        easing.type: Easing.OutCubic
                    }
                }
            }

            delegate: Rectangle {
                id: itemDelegate
                required property var modelData
                required property int index

                readonly property bool active: index === root.selectedIndex

                width: clipList.width
                height: rowContent.implicitHeight + 2 * root.rowPadding
                radius: ShellState.islandCornerRadius
                color: "transparent"

                // Entrance: fade and rise a little, only while the panel opens or you type.
                readonly property bool fadeEnabled: LauncherState.animateResults && !ShellState.motionReduced
                property real enter: (itemDelegate.fadeEnabled && root.entering) ? 0 : 1
                // Delete: slide out to the right and fade, then the item is deleted.
                property real leave: 0
                opacity: itemDelegate.enter * (1 - itemDelegate.leave)
                transform: Translate {
                    x: itemDelegate.leave * 24
                    y: (1 - itemDelegate.enter) * 5
                }

                SequentialAnimation {
                    id: enterAnim
                    PauseAnimation { duration: ShellState.motionDuration(root.enterDelay(itemDelegate.index)) }
                    NumberAnimation {
                        target: itemDelegate
                        property: "enter"
                        to: 1
                        duration: ShellState.motionDuration(Motion.fadeMs)
                        easing.type: Easing.OutCubic
                    }
                }
                Component.onCompleted: if (itemDelegate.enter < 1) enterAnim.start()

                SequentialAnimation {
                    id: removeAnim
                    NumberAnimation {
                        target: itemDelegate
                        property: "leave"
                        to: 1
                        duration: ShellState.motionDuration(Motion.fadeMs)
                        easing.type: Easing.OutCubic
                    }
                    ScriptAction { script: root.deleteItem(itemDelegate.modelData) }
                }

                function startRemove() {
                    if (itemDelegate.fadeEnabled) removeAnim.start()
                    else root.deleteItem(itemDelegate.modelData)
                }

                // declared first so the action buttons below sit on top of it
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: root.selectedIndex = itemDelegate.index
                    onClicked: root.pasteItem(itemDelegate.modelData)
                }

                RowLayout {
                    id: rowContent
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: root.rowPadding
                    spacing: 10

                    // square thumbnail (image entries only)
                    Rectangle {
                        Layout.preferredWidth: root.thumbSize
                        Layout.preferredHeight: root.thumbSize
                        Layout.alignment: Qt.AlignTop
                        visible: itemDelegate.modelData.isImage
                        radius: Dimens.radiusSmall
                        color: Colors.elevatedBg
                        clip: true

                        Text {
                            anchors.centerIn: parent
                            visible: thumb.status !== Image.Ready
                            text: "image"
                            font.family: Fonts.icon
                            font.pixelSize: Dimens.fontSizeLg
                            font.variableAxes: Fonts.iconAxes
                            color: Colors.fgMuted
                        }

                        Image {
                            id: thumb
                            anchors.fill: parent
                            source: itemDelegate.modelData.thumb
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: false
                            clip: true
                            sourceSize.width: root.thumbSize * 2
                            sourceSize.height: root.thumbSize * 2

                            // The thumbnail fades in when it has loaded.
                            opacity: thumb.status === Image.Ready ? 1 : 0
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: ShellState.motionDuration(Motion.fadeMs)
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        spacing: 4

                        // text preview, wraps up to 3 lines
                        Text {
                            Layout.fillWidth: true
                            visible: !itemDelegate.modelData.isImage
                            text: itemDelegate.modelData.text
                            color: Colors.fg
                            font.family: Fonts.text
                            font.pixelSize: Dimens.fontSizeMd
                            wrapMode: Text.Wrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                        }

                        // image details, to the right of the thumbnail
                        Text {
                            Layout.fillWidth: true
                            visible: itemDelegate.modelData.isImage
                            text: "Image"
                            color: Colors.fg
                            font.family: Fonts.text
                            font.pixelSize: Dimens.fontSizeMd
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: itemDelegate.modelData.isImage
                            text: itemDelegate.modelData.imageInfo
                            color: Colors.fgMuted
                            font.family: Fonts.text
                            font.pixelSize: Dimens.fontSizeSm
                            elide: Text.ElideRight
                        }

                        // meta row: clipboard icon, time, actions
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Text {
                                text: "content_paste"
                                font.family: Fonts.icon
                                font.pixelSize: Dimens.fontSizeSm
                                font.variableAxes: Fonts.iconAxes
                                color: Colors.fgMuted
                            }

                            Text {
                                Layout.fillWidth: true
                                text: root.timeLabel(itemDelegate.modelData.time)
                                color: Colors.fgMuted
                                font.family: Fonts.text
                                font.pixelSize: Dimens.fontSizeSm
                                elide: Text.ElideRight
                            }

                            // Pin button
                            Item {
                                Layout.preferredWidth: 24
                                Layout.preferredHeight: 24
                                opacity: (itemDelegate.active || itemDelegate.modelData.pinned) ? 1 : 0
                                enabled: opacity > 0

                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: ShellState.motionDuration(Motion.fadeMs * 0.6)
                                        easing.type: Easing.OutCubic
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: "push_pin"
                                    font.family: Fonts.icon
                                    font.pixelSize: Dimens.fontSizeMd
                                    font.variableAxes: itemDelegate.modelData.pinned ? Fonts.iconAxesFilled : Fonts.iconAxes
                                    color: itemDelegate.modelData.pinned ? Colors.accent : Colors.fgMuted
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.pinItem(itemDelegate.modelData)
                                }
                            }

                            // Delete button
                            Item {
                                Layout.preferredWidth: 24
                                Layout.preferredHeight: 24
                                opacity: itemDelegate.active ? 1 : 0
                                enabled: opacity > 0

                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: ShellState.motionDuration(Motion.fadeMs * 0.6)
                                        easing.type: Easing.OutCubic
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: "delete"
                                    font.family: Fonts.icon
                                    font.pixelSize: Dimens.fontSizeMd
                                    font.variableAxes: Fonts.iconAxes
                                    color: Colors.red
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: itemDelegate.startRemove()
                                }
                            }
                        }
                    }
                }
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Clipboard empty"
            color: Colors.fgMuted
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeMd
            opacity: ClipboardService.filteredHistory.length === 0 ? 1 : 0
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation {
                    duration: ShellState.motionDuration(Motion.fadeMs)
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
}