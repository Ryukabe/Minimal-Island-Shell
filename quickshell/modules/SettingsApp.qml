// modules/SettingsApp.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../styles"
import "../services"

PanelWindow {
    id: root

    // Standalone floating top-level window as seen in Panacea Shell
    WlrLayershell.namespace: "quickshell:settings"
    WlrLayershell.layer: WlrLayer.Top
    
    color: "transparent"
    visible: ShellState.activePage === "settings"

    implicitWidth: 860
    implicitHeight: 600

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    // Center the floating settings window on screen
    Item {
        anchors.centerIn: parent
        width: root.implicitWidth
        height: root.implicitHeight

        Rectangle {
            anchors.fill: parent
            color: Colors.bg ?? "#1e1e2e"
            border.color: Colors.border ?? "#313244"
            border.width: 1
            radius: 16

            // Shadow simulation or clean border layout
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16

                // Header & Search
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Text {
                        text: "Settings"
                        color: Colors.fg ?? "#cdd6f4"
                        font.family: Fonts.display ?? "Sans"
                        font.pixelSize: 22
                        font.weight: Font.Bold
                    }

                    Item { Layout.fillWidth: true }

                    // Search input matching Panacea 12-section search bar
                    Rectangle {
                        Layout.preferredWidth: 260
                        Layout.preferredHeight: 36
                        color: Colors.surface ?? "#252538"
                        radius: 8
                        border.color: searchInput.activeFocus ? (Colors.accent ?? "#89b4fa") : "transparent"

                        TextInput {
                            id: searchInput
                            anchors.fill: parent
                            anchors.margins: 10
                            verticalAlignment: TextInput.AlignVCenter
                            color: Colors.fg ?? "#cdd6f4"
                            font.family: Fonts.sans ?? "Sans"
                            font.pixelSize: 13

                            // Placeholder text handling
                            Text {
                                text: "Search 12 sections..."
                                color: Colors.subtext ?? "#6c7086"
                                font: searchInput.font
                                visible: searchInput.text.length === 0
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    // Close Button
                    Button {
                        text: "✕"
                        onClicked: ShellState.showPage("clock")
                    }
                }

                // Main Content Area (Sidebar Categories + Active View Panel)
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 16

                    // Sidebar Section List (12 Sections)
                    ListView {
                        id: sectionList
                        Layout.preferredWidth: 200
                        Layout.fillHeight: true
                        clip: true
                        spacing: 4

                        model: ListModel {
                            id: settingsModel
                            ListElement { sectionName: "Bar & Island"; icon: "󱂬" }
                            ListElement { sectionName: "Media"; icon: "󝈩" }
                            ListElement { sectionName: "Clock & Date"; icon: "󱪫" }
                            ListElement { sectionName: "Appearance"; icon: "󰏘" }
                            ListElement { sectionName: "Motion"; icon: "󰓅" }
                            ListElement { sectionName: "Launcher"; icon: "󱗼" }
                            ListElement { sectionName: "Notifications"; icon: "󰂚" }
                            ListElement { sectionName: "Control Center"; icon: "󱃖" }
                            ListElement { sectionName: "Lock Screen"; icon: "󰌾" }
                            ListElement { sectionName: "Display"; icon: "󰍹" }
                            ListElement { sectionName: "Mouse"; icon: "󰍽" }
                            ListElement { sectionName: "System"; icon: "󰒓" }
                        }

                        delegate: Item {
                            width: sectionList.width
                            property bool isSelected: ListView.isCurrentItem

                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 2
                                color: isSelected ? (Colors.accent ?? "#89b4fa") : "transparent"
                                opacity: isSelected ? 0.15 : 1.0
                                radius: 8
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                spacing: 10

                                Text {
                                    text: model.icon
                                    color: isSelected ? (Colors.accent ?? "#89b4fa") : (Colors.fg ?? "#cdd6f4")
                                    font.family: Fonts.nerdFont ?? "monospace"
                                    font.pixelSize: 14
                                }

                                Text {
                                    text: model.sectionName
                                    color: isSelected ? (Colors.accent ?? "#89b4fa") : (Colors.fg ?? "#cdd6f4")
                                    font.family: Fonts.sans ?? "Sans"
                                    font.pixelSize: 13
                                    font.weight: isSelected ? Font.Bold : Font.Normal
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClikeed: sectionList.currentIndex = index
                            }
                        }
                    }

                    // Content View Panel
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: Colors.surface ?? "#252538"
                        radius: 12

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 12

                            Text {
                                text: sectionList.model.get(sectionList.currentIndex).sectionName
                                color: Colors.fg ?? "#cdd6f4"
                                font.family: Fonts.display ?? "Sans"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                            }

                            Text {
                                text: "Configuration options for " + sectionList.model.get(sectionList.currentIndex).sectionName + " live here. Changes write directly to your shell parameters."
                                color: Colors.subtext ?? "#a6adc8"
                                font.family: Fonts.sans ?? "Sans"
                                font.pixelSize: 13
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                            }

                            Item { Layout.fillHeight: true }
                        }
                    }
                }
            }
        }
    }
}