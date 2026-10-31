// features/clipboard/Clipboard.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import "."
import "../../core/shell"
import "../../core/styles"

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
                focusTimer.restart()
            }
        }
    }

    Component.onCompleted: {
        focusTimer.restart()
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
                    text: "content_paste"
                    font.family: Fonts.icon
                    font.pixelSize: Dimens.fontSizeMd
                    font.variableAxes: Fonts.iconAxes
                    color: Colors.fgMuted
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
                            if (list.length > 0) root.deleteItem(list[root.selectedIndex])
                            event.accepted = true
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (list.length > 0) root.pasteItem(list[root.selectedIndex])
                            event.accepted = true
                        }
                    }
                }

                // Clear History Button (keeps pinned items)
                Rectangle {
                    width: 24
                    height: 24
                    radius: ShellState.islandCornerRadius
                    color: "transparent"
                    visible: ClipboardService.history.length > 0

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

            delegate: Rectangle {
                id: itemDelegate
                required property var modelData
                required property int index

                readonly property bool active: index === root.selectedIndex

                width: clipList.width
                height: rowContent.implicitHeight + 2 * root.rowPadding
                radius: ShellState.islandCornerRadius
                color: active ? Colors.subBgMica : "transparent"

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
                                    onClicked: root.deleteItem(itemDelegate.modelData)
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
            visible: ClipboardService.filteredHistory.length === 0
        }
    }
}