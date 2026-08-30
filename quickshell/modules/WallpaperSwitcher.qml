// modules/WallpaperSwitcher.qml
import QtQuick
import QtQuick.Layouts
import "../services"
import "../components/theme"
import "../styles"

FocusScope {
    id: switcherRoot

    implicitWidth: 680
    implicitHeight: 210
    focus: true

    property int selectedIndex: -1
    property string searchQuery: ""
    property bool searchActive: false

    readonly property var filteredWallpapers: {
        var list = WallpaperService.wallpapersList || [];
        if (!searchQuery.trim()) return list;
        return list.filter(function(item) {
            return item.name.toLowerCase().includes(searchQuery.toLowerCase());
        });
    }

    function updateInitialSelection() {
        if (filteredWallpapers.length === 0) {
            selectedIndex = -1;
            return;
        }
        var activeIndex = -1;
        for (var i = 0; i < filteredWallpapers.length; i++) {
            if (filteredWallpapers[i].path === WallpaperService.currentWallpaper) {
                activeIndex = i;
                break;
            }
        }
        selectedIndex = activeIndex !== -1 ? activeIndex : 0;
        listView.currentIndex = selectedIndex;
        if (selectedIndex !== -1) {
            listView.positionViewAtIndex(selectedIndex, ListView.Center);
        }
    }

    onFilteredWallpapersChanged: updateInitialSelection()

    Component.onCompleted: {
        switcherRoot.forceActiveFocus();
        updateInitialSelection();
    }

    Keys.onPressed: event => {
        var count = filteredWallpapers.length;

        // [feature: auto-open search and catch typed character on key press]
        if (!searchActive && event.text.length > 0 && event.text >= " " && event.key !== Qt.Key_Escape && event.key !== Qt.Key_Return && event.key !== Qt.Key_Enter) {
            searchActive = true;
            searchInput.text = event.text;
            searchQuery = event.text;
            searchInput.cursorPosition = searchInput.text.length;
            searchInput.forceActiveFocus();
            event.accepted = true;
            return;
        }

        if (count === 0) return;

        // [feature: directional navigation controls]
        if (event.key === Qt.Key_Right || event.key === Qt.Key_Down) {
            if (selectedIndex < count - 1) {
                selectedIndex += 1;
                listView.currentIndex = selectedIndex;
            }
            event.accepted = true;
        } else if (event.key === Qt.Key_Left || event.key === Qt.Key_Up) {
            if (selectedIndex > 0) {
                selectedIndex -= 1;
                listView.currentIndex = selectedIndex;
            }
            event.accepted = true;
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            // [feature: apply selected wallpaper]
            if (selectedIndex >= 0 && filteredWallpapers[selectedIndex]) {
                WallpaperService.applyWallpaper(filteredWallpapers[selectedIndex].path);
            }
            event.accepted = true;
        } else if (event.key === Qt.Key_Escape) {
            // [feature: escape key handling for search or page exit]
            if (searchActive) {
                searchActive = false;
                searchQuery = "";
                searchInput.text = "";
                switcherRoot.forceActiveFocus();
            } else if (typeof ShellState !== "undefined") {
                ShellState.showPage("clock");
            }
            event.accepted = true;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // [layout: header row containing title, item count badge, and search controls]
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: "Wallpapers"
                color: Colors.fg
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeLg
                font.bold: true
            }

            Rectangle {
                implicitWidth: countText.implicitWidth + 12
                implicitHeight: 20
                radius: 10
                color: Qt.rgba(1, 1, 1, 0.08)

                Text {
                    id: countText
                    anchors.centerIn: parent
                    text: filteredWallpapers.length
                    color: Colors.fgMuted
                    font.pixelSize: Dimens.fontSizeSm - 1
                    font.bold: true
                }
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                id: searchBar
                visible: switcherRoot.searchActive
                implicitWidth: switcherRoot.searchActive ? 180 : 0
                implicitHeight: 30
                radius: 15
                color: Qt.rgba(1, 1, 1, 0.08)
                border.width: searchInput.activeFocus ? 1 : 0
                border.color: Colors.accent

                Behavior on implicitWidth {
                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                }

                TextInput {
                    id: searchInput
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    verticalAlignment: Text.AlignVCenter
                    color: Colors.fg
                    font.pixelSize: Dimens.fontSizeSm
                    clip: true
                    onTextChanged: {
                        if (switcherRoot.searchActive) {
                            switcherRoot.searchQuery = text;
                        }
                    }

                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Escape) {
                            switcherRoot.searchActive = false;
                            switcherRoot.searchQuery = "";
                            searchInput.text = "";
                            switcherRoot.forceActiveFocus();
                            event.accepted = true;
                        }
                    }

                    Text {
                        text: "Search..."
                        color: Colors.fgMuted
                        font.pixelSize: Dimens.fontSizeSm
                        visible: !searchInput.text && !searchInput.inputMethodComposing
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            Rectangle {
                implicitWidth: 30
                implicitHeight: 30
                radius: 15
                color: switcherRoot.searchActive ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.08)

                Text {
                    anchors.centerIn: parent
                    text: "search"
                    font.family: Fonts.icon
                    font.pixelSize: 16
                    font.variableAxes: Fonts.iconAxes
                    font.features: { "liga": 1 }
                    color: switcherRoot.searchActive ? Colors.accent : Colors.fg
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        switcherRoot.searchActive = !switcherRoot.searchActive;
                        if (switcherRoot.searchActive) {
                            searchInput.forceActiveFocus();
                        } else {
                            switcherRoot.searchQuery = "";
                            searchInput.text = "";
                            switcherRoot.forceActiveFocus();
                        }
                    }
                }
            }
        }

        // [layout: center-locked horizontal list view for wallpaper cards]
        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: ListView.Horizontal
            spacing: 14
            clip: true

            flickableDirection: Flickable.HorizontalFlick
            boundsBehavior: Flickable.StopAtBounds
            highlightMoveDuration: 0
            
            highlightRangeMode: ListView.StrictlyEnforceRange
            preferredHighlightBegin: width / 2 - 72
            preferredHighlightEnd: width / 2 + 72

            model: switcherRoot.filteredWallpapers

            WheelHandler {
                orientation: Qt.Horizontal
                property: "contentX"
                rotationScale: 15
            }

            delegate: WallpaperCard {
                required property var modelData
                required property int index

                wallpaperPath: modelData.path
                wallpaperName: modelData.name
                isApplied: WallpaperService.currentWallpaper === modelData.path
                isSelected: switcherRoot.selectedIndex === index

                implicitWidth: 145
                implicitHeight: 125

                onClicked: {
                    switcherRoot.selectedIndex = index;
                    listView.currentIndex = index;
                    WallpaperService.applyWallpaper(modelData.path);
                }
            }
        }
    }
}