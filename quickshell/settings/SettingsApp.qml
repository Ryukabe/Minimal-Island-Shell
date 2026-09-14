// SettingsApp.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "./services"
import "./common"
import "bar"
import "clock"
import "media"
import "appearance"
import "motion" as MotionPage
import "launcher"
import "controlcenter"
import "lockscreen"
import "system"
import "about"
import "keybinds"
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
        implicitWidth: 1080
        implicitHeight: 720

        onVisibleChanged: {
            if (visible) {
                focusDelay.start()
                gearSpinAnim.restart()
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

            RowLayout {
                anchors.fill: parent
                spacing: 0

                // Sidebar
                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 260
                    color: Colors.mainBgMica

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Dimens.paddingMedium
                        spacing: Dimens.spacingMedium

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Dimens.spacingSmall

                            Rectangle {
                                width: 40
                                height: 40
                                radius: 20
                                color: gearMouse.containsMouse ? Colors.elevatedBg : "transparent"

                                Behavior on color { ColorAnimation { duration: 120 } }

                                Text {
                                    id: settingsGearIcon
                                    anchors.centerIn: parent
                                    text: "settings"
                                    color: Colors.accent
                                    font.family: Fonts.icon
                                    font.pixelSize: Dimens.fontSizeLg
                                    transformOrigin: Item.Center
                                    scale: gearMouse.pressed ? 0.9 : (gearMouse.containsMouse ? 1.1 : 1.0)

                                    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

                                    RotationAnimation {
                                        id: gearSpinAnim
                                        target: settingsGearIcon
                                        from: 0
                                        to: 360
                                        duration: 500
                                        easing.type: Easing.OutBack
                                    }
                                }

                                MouseArea {
                                    id: gearMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: gearSpinAnim.restart()
                                }
                            }

                            ColumnLayout {
                                spacing: 0
                                Layout.fillWidth: true

                                Text {
                                    text: "Settings"
                                    color: Colors.fg
                                    font.family: Fonts.display
                                    font.pixelSize: Dimens.fontSizeLg
                                    font.weight: Font.Bold
                                }

                                Text {
                                    text: "Minimal Island Shell"
                                    color: Colors.subtext
                                    font.family: Fonts.text
                                    font.pixelSize: Dimens.fontSizeXs
                                }
                            }
                        }

                        SearchBox {
                            id: searchBox
                            Layout.fillWidth: true
                            onOptionSelected: (idx) => {
                                sectionList.currentIndex = idx
                                contentRoot.forceActiveFocus()
                            }
                        }

                        Item { height: 2 }

                        ListView {
                            id: sectionList
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            spacing: 3

                            model: ListModel {
                                id: allSections
                                ListElement { sectionName: "Bar & Island"; icon: "dock_to_bottom"; tag: "top margin corner radius border notch mode height" }
                                ListElement { sectionName: "Clock & Date"; icon: "schedule"; tag: "24-hour clock seconds format" }
                                ListElement { sectionName: "Media"; icon: "graphic_eq"; tag: "mpris volume audio output" }
                                ListElement { sectionName: "Appearance"; icon: "palette"; tag: "theme fonts color dark mode accent" }
                                ListElement { sectionName: "Motion"; icon: "speed"; tag: "animations physics springs" }
                                ListElement { sectionName: "Launcher"; icon: "rocket_launch"; tag: "app search calc clipboard" }
                                ListElement { sectionName: "Control Center"; icon: "widgets"; tag: "quick settings tiles network wifi" }
                                ListElement { sectionName: "Lock Screen"; icon: "lock"; tag: "pam password security" }
                                ListElement { sectionName: "Keybinds"; icon: "keyboard"; tag: "hyprland shortcuts binds hotkeys rebind" }
                                ListElement { sectionName: "System"; icon: "tune"; tag: "display resolution scale notifications toast dnd peace mode mouse touchpad cursor scrolling natural" }
                                ListElement { sectionName: "About"; icon: "info"; tag: "hardware power info sleep battery updates" }
                            }

                            delegate: Item {
                                width: sectionList.width
                                height: matchesSearch ? 40 : 0
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
                                    height: 36
                                    anchors.verticalCenter: parent.verticalCenter

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: Dimens.radiusMedium
                                        color: isSelected 
                                               ? Colors.accent
                                               : (itemMouse.containsMouse ? Colors.elevatedBg : "transparent")
                                        opacity: isSelected ? 0.18 : 1.0

                                        Behavior on color { ColorAnimation { duration: 120 } }
                                    }

                                    Rectangle {
                                        width: 3
                                        height: 16
                                        radius: 1.5
                                        anchors.left: parent.left
                                        anchors.leftMargin: 3
                                        anchors.verticalCenter: parent.verticalCenter
                                        color: Colors.accent
                                        visible: isSelected
                                    }

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: Dimens.paddingMedium
                                        anchors.rightMargin: Dimens.paddingSmall
                                        spacing: Dimens.spacingMedium

                                        Text {
                                            id: menuIcon
                                            text: model.icon
                                            color: isSelected ? Colors.accent : Colors.fg
                                            font.family: Fonts.icon
                                            font.pixelSize: Dimens.fontSize15
                                            transformOrigin: Item.Center
                                            scale: isSelected ? 1.2 : (itemMouse.containsMouse ? 1.1 : 1.0)
                                            rotation: itemMouse.pressed ? -15 : 0

                                            Behavior on scale {
                                                NumberAnimation { duration: 180; easing.type: Easing.OutBack }
                                            }
                                            Behavior on rotation {
                                                NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                                            }
                                            Behavior on color {
                                                ColorAnimation { duration: 120 }
                                            }
                                        }

                                        Text {
                                            text: model.sectionName
                                            color: isSelected ? Colors.accent : Colors.fg
                                            font.family: Fonts.text
                                            font.pixelSize: Dimens.fontSizeBase
                                            font.weight: isSelected ? Font.DemiBold : Font.Normal
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
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
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    width: 1
                    color: Colors.border
                    opacity: 0.3
                }

                // Content View area
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"

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

                        // Header Banner
                        SettingsHeader {
                            icon: allSections.get(sectionList.currentIndex).icon
                            title: allSections.get(sectionList.currentIndex).sectionName
                            subtitle: "Configure settings and options for " + allSections.get(sectionList.currentIndex).sectionName
                        }

                        // Stacked Subviews (Each view has its own SettingsScrollView)
                        StackLayout {
                            id: pageStack
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            currentIndex: sectionList.currentIndex

                            Bar {}
                            Clock {}
                            Media {}
                            Appearance {}
                            MotionPage.Motion {}
                            Launcher {}
                            ControlCenter {}
                            LockScreen {}
                            Keybinds {}
                            System {}
                            About {}
                        }
                    }
                }
            }
        }
    }
}