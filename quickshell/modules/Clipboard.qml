// modules/Clipboard.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import "../services"
import "../styles"

Item {
    id: root

    readonly property int rowHeight: 42
    readonly property int maxVisibleRows: 6
    readonly property int chromeHeight: 76
    readonly property int maxWidth: 420

    property var historyItems: ClipboardService.filteredHistory
    property int selectedIndex: 0

    implicitWidth: maxWidth
    implicitHeight: Math.min(
        chromeHeight + Math.max(historyItems.length, 1) * rowHeight,
        chromeHeight + maxVisibleRows * rowHeight
    )

    Timer {
        id: focusTimer
        interval: 50
        repeat: false
        onTriggered: searchInput.forceActiveFocus()
    }

    Connections {
        target: ShellState
        function onActivePageChanged() {
            if (ShellState.activePage === "clipboard") {
                searchInput.text = ClipboardService.searchQuery
                root.selectedIndex = 0
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
            radius: Dimens.borderRadiusLarge
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
                        if (event.key === Qt.Key_Down) {
                            if (root.selectedIndex < ClipboardService.filteredHistory.length - 1) {
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
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (ClipboardService.filteredHistory.length > 0) {
                                var item = ClipboardService.filteredHistory[root.selectedIndex]
                                ClipboardService.selectAndPaste(item.id)
                                ShellState.showPage("clock")
                            }
                            event.accepted = true
                        }
                    }
                }

                // Clear History Button
                Rectangle {
                    width: 24
                    height: 24
                    radius: Dimens.borderRadiusSmall
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
                        onClicked: {
                            ClipboardService.clearAll()
                        }
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

            delegate: Rectangle {
                id: itemDelegate
                required property var modelData
                required property int index

                width: clipList.width
                height: 38
                radius: Dimens.borderRadiusMedium
                color: index === root.selectedIndex ? Colors.bgSurface : "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8

                    Text {
                        text: modelData.id ? `#${modelData.id}` : ""
                        color: Colors.fgMuted
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeSm
                    }

                    Text {
                        Layout.fillWidth: true
                        text: modelData.text || ""
                        color: Colors.fg
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeMd
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: root.selectedIndex = index
                    onClicked: {
                        ClipboardService.selectAndPaste(modelData.id)
                        ShellState.showPage("clock")
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