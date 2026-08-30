// modules/Clipboard.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import "../services"
import "../styles"

Item {
    id: root

    // EXPLICIT DIMENSIONS REQUIRED FOR DYNAMIC ISLAND MORPHING
    implicitWidth: 420
    implicitHeight: 320

    readonly property int rowHeight: 44
    readonly property int maxVisibleRows: 6
    property int selectedIndex: 0

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

    Rectangle {
        anchors.fill: parent
        color: Colors.bg
        radius: Dimens.radiusXLarge
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            // Search Header
            Rectangle {
                Layout.fillWidth: true
                height: 40
                radius: Dimens.borderRadiusLarge
                color: Colors.bgSurface

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8

                    Text {
                        text: "📋"
                        font.pixelSize: 14
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
}