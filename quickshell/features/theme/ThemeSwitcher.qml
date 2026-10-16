// features/theme/ThemeSwitcher.qml
import QtQuick
import QtQuick.Layouts
import "."
import "../../core/shell"
import "components"
import "../../core/styles"

FocusScope {
    id: switcherRoot

    implicitWidth: 680
    implicitHeight: 210
    focus: true

    property int selectedIndex: -1
    property string searchQuery: ""
    property bool searchActive: false

    readonly property var filteredThemes: {
        var list = ThemeService.themesList || [];
        if (!searchQuery.trim()) return list;
        return list.filter(function(item) {
            return item.name.toLowerCase().includes(searchQuery.toLowerCase());
        });
    }

    function updateInitialSelection() {
        if (filteredThemes.length === 0) {
            selectedIndex = -1;
            return;
        }
        var activeIndex = -1;
        for (var i = 0; i < filteredThemes.length; i++) {
            if (filteredThemes[i].name === ThemeService.currentTheme) {
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

    onFilteredThemesChanged: updateInitialSelection()

    Component.onCompleted: {
        switcherRoot.forceActiveFocus();
        updateInitialSelection();
    }

    Keys.onPressed: event => {
        var count = filteredThemes.length;

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
            // [feature: apply selected theme]
            if (selectedIndex >= 0 && filteredThemes[selectedIndex]) {
                ThemeService.applyTheme(filteredThemes[selectedIndex].name);

                // Fix: Close the switcher when applying via keyboard
                if (typeof ShellState !== "undefined") {
                    ShellState.showPage("clock");
                }
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

        // [layout: header row containing title, active indicator, and search controls]
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: "Themes"
                color: Colors.fg
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeLg
                font.bold: true
            }

            Rectangle {
                implicitWidth: activeThemeText.implicitWidth + 14
                implicitHeight: 20
                radius: ShellState.islandCornerRadius
                color: Qt.rgba(1, 1, 1, 0.08)

                Text {
                    id: activeThemeText
                    anchors.centerIn: parent
                    text: "Active: " + (ThemeService.currentTheme || "Default")
                    color: Colors.accent
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeSm - 1
                    font.bold: true
                }
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                id: searchPill

                readonly property int collapsedW: 30
                readonly property int expandedW: 220
                readonly property bool useSpring: ShellState.motionSpringEnabled && !ShellState.motionReduced

                // Mirrored widths, one Behavior each, same pattern as the cards
                property real widthSpring: switcherRoot.searchActive ? expandedW : collapsedW
                property real widthEase: switcherRoot.searchActive ? expandedW : collapsedW

                Behavior on widthSpring {
                    enabled: searchPill.useSpring
                    SpringAnimation {
                        spring: Motion.glideSpring
                        damping: Motion.glideDamping
                        mass: Motion.glideMass
                        epsilon: Motion.epsilon
                    }
                }
                Behavior on widthEase {
                    enabled: !searchPill.useSpring
                    NumberAnimation {
                        duration: ShellState.motionDuration(Motion.glideMs)
                        easing.type: Easing.OutCubic
                    }
                }

                Layout.preferredWidth: useSpring ? widthSpring : widthEase
                Layout.preferredHeight: 30
                radius: ShellState.islandCornerRadius
                clip: true
                color: switcherRoot.searchActive ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(1, 1, 1, 0.08)
                border.width: searchInput.activeFocus ? 1 : 0
                border.color: Colors.accent

                Behavior on color { ColorAnimation { duration: ShellState.motionDuration(Motion.fadeMs) } }

                // Field lives on the left, fades in as the pill grows
                TextInput {
                    id: searchInput
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.right: iconBox.left
                    anchors.verticalCenter: parent.verticalCenter
                    verticalAlignment: Text.AlignVCenter
                    color: Colors.fg
                    font.pixelSize: Dimens.fontSizeSm
                    clip: true
                    enabled: switcherRoot.searchActive
                    opacity: switcherRoot.searchActive ? 1 : 0
                    Behavior on opacity {
                        NumberAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
                    }

                    onTextChanged: {
                        if (switcherRoot.searchActive) switcherRoot.searchQuery = text;
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

                // Icon pinned to the right end
                Item {
                    id: iconBox
                    width: 30
                    height: 30
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "search"
                        font.family: Fonts.icon
                        font.pixelSize: Dimens.fontSizeLg
                        font.variableAxes: Fonts.iconAxes
                        font.features: { "liga": 1 }
                        color: switcherRoot.searchActive ? Colors.accent : Colors.fg
                        Behavior on color { ColorAnimation { duration: ShellState.motionDuration(Motion.fadeMs) } }
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
        }

        // [layout: center-locked horizontal list view for theme cards]
        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: ListView.Horizontal
            spacing: 14
            clip: true

            flickableDirection: Flickable.HorizontalFlick
            boundsBehavior: Flickable.StopAtBounds

            // Tied to the Movement slider and Reduce Motion. This is a plain
            // duration, not a true spring; ListView's built-in highlight-follow
            // doesn't support swapping in a SpringAnimation.
            highlightMoveDuration: ShellState.motionDuration(Motion.glideMs)

            highlightRangeMode: ListView.StrictlyEnforceRange
            preferredHighlightBegin: width / 2 - 72
            preferredHighlightEnd: width / 2 + 72

            model: switcherRoot.filteredThemes

            WheelHandler {
                orientation: Qt.Horizontal
                property: "contentX"
                rotationScale: 15
            }

            delegate: ThemeCard {
                required property var modelData
                required property int index

                themeName: modelData.name
                isApplied: ThemeService.currentTheme === modelData.name
                isSelected: switcherRoot.selectedIndex === index

                implicitWidth: 145
                implicitHeight: 125

                onClicked: {
                    switcherRoot.selectedIndex = index;
                    listView.currentIndex = index;
                    ThemeService.applyTheme(modelData.name);

                    // Fix: Close the switcher when applying via mouse click
                    if (typeof ShellState !== "undefined") {
                        ShellState.showPage("clock");
                    }
                }
            }
        }
    }
}