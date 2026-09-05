import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "./services"
import "bar"
import "clock"
import "media"
import "appearance"
import "motion"
import "launcher"
import "notifications"
import "controlcenter"
import "lockscreen"
import "display"
import "mouse"
import "system"
import "../services"
import "../styles"

Scope {
    id: root

    IpcHandler {
        target: "settings"

        function open() { ShellState.openSettings() }
        function close() { ShellState.closeSettings() }
        function toggle() { ShellState.toggleSettings() }

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
        color: Colors.mainBgMica
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
                } else if (!searchBox.activeFocusInput && event.text.length > 0 
                           && !(event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier))) {
                    if (event.key !== Qt.Key_Tab && event.key !== Qt.Key_Return 
                        && event.key !== Qt.Key_Enter && event.key !== Qt.Key_Backspace) {
                        
                        searchBox.appendText(event.text)
                        event.accepted = true
                    }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 54
                    color: "transparent"
                    z: 10

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

                        SearchBox {
                            id: searchBox
                            onOptionSelected: (idx) => {
                                sectionList.currentIndex = idx
                                contentRoot.forceActiveFocus()
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
                        spacing: 0

                        model: ListModel {
                            id: allSections
                            ListElement { sectionName: "Bar & Island"; icon: "dock_to_bottom"; tag: "top margin corner radius border notch mode height" }
                            ListElement { sectionName: "Clock & Date"; icon: "schedule"; tag: "24-hour clock seconds format" }
                            ListElement { sectionName: "Media"; icon: "graphic_eq"; tag: "mpris volume audio output" }
                            ListElement { sectionName: "Appearance"; icon: "palette"; tag: "theme fonts color dark mode accent" }
                            ListElement { sectionName: "Motion"; icon: "speed"; tag: "animations physics springs" }
                            ListElement { sectionName: "Launcher"; icon: "rocket_launch"; tag: "app search calc clipboard" }
                            ListElement { sectionName: "Notifications"; icon: "notifications"; tag: "mako toasts position timeout" }
                            ListElement { sectionName: "Control Center"; icon: "widgets"; tag: "quick settings tiles network wifi" }
                            ListElement { sectionName: "Lock Screen"; icon: "lock"; tag: "pam password security" }
                            ListElement { sectionName: "Display"; icon: "desktop_windows"; tag: "resolution scale vrr monitor" }
                            ListElement { sectionName: "Mouse"; icon: "mouse"; tag: "cursor sensitivity scroll" }
                            ListElement { sectionName: "System"; icon: "settings"; tag: "hardware power info sleep battery" }
                        }

                        delegate: Item {
                            width: sectionList.width
                            height: matchesSearch ? 42 : 0
                            visible: height > 0
                            clip: true

                            property bool isSelected: sectionList.currentIndex === index
                            property bool matchesSearch: {
                                let query = searchBox.searchText.toLowerCase().trim()
                                if (query === "") return true
                                return model.sectionName.toLowerCase().includes(query) || model.tag.toLowerCase().includes(query)
                            }

                            Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                            Item {
                                width: parent.width
                                height: 38
                                anchors.top: parent.top

                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    color: isSelected ? Colors.accent : (itemMouse.containsMouse ? Colors.subBg : "transparent")
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
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: Colors.subBgMica
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
        }
    }
}