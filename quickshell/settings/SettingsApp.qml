import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../styles"
import "../services"

Scope {
    id: root

    IpcHandler {
        target: "settings"

        function open() {
            ShellState.openSettings()
        }

        function close() {
            ShellState.closeSettings()
        }

        function toggle() {
            ShellState.toggleSettings()
        }

        function onMessageReceived(message: string) {
            let cmd = message.trim().toLowerCase()

            if (cmd === "open" || cmd === "show") open()
            else if (cmd === "close" || cmd === "hide") close()
            else if (cmd === "toggle") toggle()
            else if (cmd.startsWith("section ")) {
                let targetSection = cmd.substring(8).trim()
                ShellState.openSettings()

                for (let i = 0; i < allSections.count; i++) {
                    let name = allSections.get(i).sectionName.toLowerCase()
                    if (name.includes(targetSection)) {
                        sectionList.currentIndex = i
                        break
                    }
                }
            }
        }
    }

    FloatingWindow {
        id: window

        title: "Settings"
        visible: ShellState.settingsOpen
        color: Colors.mainBg

        implicitWidth: 600
        implicitHeight: 800

        onVisibleChanged: if (visible) focusDelay.start()

        Timer {
            id: focusDelay
            interval: 50
            onTriggered: contentRoot.forceActiveFocus()
        }

        Item {
            id: contentRoot
            anchors.fill: parent
            focus: true

            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Escape) {
                    ShellState.closeSettings()
                    event.accepted = true
                }
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Toolbar strip — separated from the body by a tone shift
                // (subBg vs. mainBg below), no border/divider line at all.
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 54
                    color: Colors.subBg

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton
                        onPressed: window.startSystemMove()
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Dimens.paddingLarge
                        anchors.rightMargin: Dimens.paddingLarge
                        spacing: Dimens.spacingMedium

                        RowLayout {
                            spacing: Dimens.spacingSmall
                            Text {
                                text: "settings"
                                color: Colors.accent
                                font.family: Fonts.icon
                                font.variableAxes: Fonts.iconAxes
                                font.pixelSize: Dimens.fontSizeXl
                            }
                            Text {
                                text: "Settings"
                                color: Colors.fg
                                font.family: Fonts.display
                                font.pixelSize: Dimens.fontSizeLg
                                font.weight: Font.Bold
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // Search box — elevatedBg instead of a border to read
                        // as a raised input sitting on top of the toolbar.
                        Rectangle {
                            Layout.preferredWidth: 280
                            Layout.preferredHeight: 34
                            color: searchInput.activeFocus ? Colors.elevatedBg : Colors.mainBg
                            radius: Dimens.radiusMedium

                            Behavior on color { ColorAnimation { duration: 150 } }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: Dimens.paddingSmall
                                anchors.rightMargin: Dimens.paddingSmall
                                spacing: Dimens.spacingSmall

                                Text {
                                    text: "search"
                                    color: Colors.subtext
                                    font.family: Fonts.icon
                                    font.variableAxes: Fonts.iconAxes
                                    font.pixelSize: Dimens.fontSizeMd
                                }

                                TextInput {
                                    id: searchInput
                                    Layout.fillWidth: true
                                    verticalAlignment: TextInput.AlignVCenter
                                    color: Colors.fg
                                    font.family: Fonts.text
                                    font.pixelSize: Dimens.fontSizeBase
                                    selectByMouse: true

                                    Text {
                                        text: "Search 12 sections..."
                                        color: Colors.subtext
                                        font: searchInput.font
                                        visible: searchInput.text.length === 0
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: Dimens.paddingLarge
                    spacing: Dimens.spacingLarge

                    ListView {
                        id: sectionList
                        Layout.preferredWidth: 220
                        Layout.fillHeight: true
                        clip: true
                        spacing: Dimens.spacingSmall

                        model: ListModel {
                            id: allSections
                            ListElement { sectionName: "Bar & Island"; icon: "dock_to_bottom"; tag: "island bar layout geometry" }
                            ListElement { sectionName: "Clock & Date"; icon: "schedule"; tag: "time calendar date" }
                            ListElement { sectionName: "Media"; icon: "graphic_eq"; tag: "player mpris volume audio" }
                            ListElement { sectionName: "Appearance"; icon: "palette"; tag: "theme fonts color palette" }
                            ListElement { sectionName: "Motion"; icon: "speed"; tag: "animations physics springs" }
                            ListElement { sectionName: "Launcher"; icon: "rocket_launch"; tag: "app search calc clipboard" }
                            ListElement { sectionName: "Notifications"; icon: "notifications"; tag: "mako toasts daemon" }
                            ListElement { sectionName: "Control Center"; icon: "widgets"; tag: "quick settings tiles" }
                            ListElement { sectionName: "Lock Screen"; icon: "lock"; tag: "pam password macos" }
                            ListElement { sectionName: "Display"; icon: "desktop_windows"; tag: "resolution scale hyprland vrr" }
                            ListElement { sectionName: "Mouse"; icon: "mouse"; tag: "cursor sensitivity acceleration" }
                            ListElement { sectionName: "System"; icon: "settings"; tag: "hardware power info" }
                        }

                        delegate: Item {
                            id: delegateItem
                            width: sectionList.width
                            height: matchesSearch ? 38 : 0
                            visible: matchesSearch

                            property bool isSelected: sectionList.currentIndex === index
                            property bool matchesSearch: {
                                let query = searchInput.text.toLowerCase().trim()
                                if (query === "") return true
                                return model.sectionName.toLowerCase().includes(query) || model.tag.toLowerCase().includes(query)
                            }

                            Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 2
                                color: isSelected ? Colors.accent : (itemMouse.containsMouse ? Colors.elevatedBg : "transparent")
                                opacity: isSelected ? 0.2 : 1.0
                                radius: Dimens.radiusMedium

                                Behavior on color { ColorAnimation { duration: 120 } }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: Dimens.paddingMedium
                                spacing: Dimens.spacingMedium

                                Text {
                                    text: model.icon
                                    color: isSelected ? Colors.accent : Colors.fg
                                    font.family: Fonts.icon
                                    font.variableAxes: Fonts.iconAxes
                                    font.pixelSize: Dimens.fontSize15
                                }

                                Text {
                                    text: model.sectionName
                                    color: isSelected ? Colors.accent : Colors.fg
                                    font.family: Fonts.text
                                    font.pixelSize: Dimens.fontSizeBase
                                    font.weight: isSelected ? Font.Bold : Font.Normal
                                }
                            }

                            MouseArea {
                                id: itemMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: sectionList.currentIndex = index
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: Colors.subBg
                        radius: Dimens.radiusLarge

                        StackLayout {
                            anchors.fill: parent
                            anchors.margins: Dimens.paddingLarge
                            currentIndex: sectionList.currentIndex

                            Bar {}
                            Clock {}
                            Media {}
                            Appearance {}
                            Motion {}
                            Launcher {}
                            Notifications {}
                            ControlCenter {}
                            LockScreen {}
                            Display {}
                            Mouse {}
                            System {}
                        }
                    }
                }
            }

            // Resize handles — edges + corners, native OS resize.
            Item {
                anchors.fill: parent
                z: 100

                MouseArea {
                    width: 5
                    anchors { left: parent.left; top: parent.top; bottom: parent.bottom; topMargin: 10; bottomMargin: 10 }
                    cursorShape: Qt.SizeHorCursor
                    onPressed: window.startSystemResize(Edges.Left)
                }
                MouseArea {
                    width: 5
                    anchors { right: parent.right; top: parent.top; bottom: parent.bottom; topMargin: 10; bottomMargin: 10 }
                    cursorShape: Qt.SizeHorCursor
                    onPressed: window.startSystemResize(Edges.Right)
                }
                MouseArea {
                    height: 5
                    anchors { top: parent.top; left: parent.left; right: parent.right; leftMargin: 10; rightMargin: 10 }
                    cursorShape: Qt.SizeVerCursor
                    onPressed: window.startSystemResize(Edges.Top)
                }
                MouseArea {
                    height: 5
                    anchors { bottom: parent.bottom; left: parent.left; right: parent.right; leftMargin: 10; rightMargin: 10 }
                    cursorShape: Qt.SizeVerCursor
                    onPressed: window.startSystemResize(Edges.Bottom)
                }
                MouseArea {
                    width: 10; height: 10
                    anchors { left: parent.left; top: parent.top }
                    cursorShape: Qt.SizeFDiagCursor
                    onPressed: window.startSystemResize(Edges.Left | Edges.Top)
                }
                MouseArea {
                    width: 10; height: 10
                    anchors { right: parent.right; top: parent.top }
                    cursorShape: Qt.SizeBDiagCursor
                    onPressed: window.startSystemResize(Edges.Right | Edges.Top)
                }
                MouseArea {
                    width: 10; height: 10
                    anchors { left: parent.left; bottom: parent.bottom }
                    cursorShape: Qt.SizeBDiagCursor
                    onPressed: window.startSystemResize(Edges.Left | Edges.Bottom)
                }
                MouseArea {
                    width: 10; height: 10
                    anchors { right: parent.right; bottom: parent.bottom }
                    cursorShape: Qt.SizeFDiagCursor
                    onPressed: window.startSystemResize(Edges.Right | Edges.Bottom)
                }
            }
        }
    }
}