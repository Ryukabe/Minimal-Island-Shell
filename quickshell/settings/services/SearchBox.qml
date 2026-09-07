import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../styles"

Rectangle {
    id: root

    property string searchText: searchInput.text
    property alias activeFocusInput: searchInput.activeFocus

    signal optionSelected(int sectionIndex)

    function clear() { searchInput.text = "" }
    function forceActiveFocus() { searchInput.forceActiveFocus() }
    function appendText(txt) {
        searchInput.forceActiveFocus()
        searchInput.text += txt
        searchInput.cursorPosition = searchInput.text.length
    }

    Layout.preferredWidth: 280
    Layout.preferredHeight: 34

    color: searchInput.activeFocus ? Colors.elevatedBg : Colors.subBgMica
    radius: Dimens.radiusMedium
    border.color: searchInput.activeFocus ? Colors.accent : Qt.rgba(1, 1, 1, 0.08)
    border.width: 1

    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    // Backdrop overlay to remove search focus when clicking outside
    MouseArea {
        id: searchBackdrop
        parent: root.Window.contentItem
        anchors.fill: parent
        visible: searchInput.activeFocus && searchInput.text.trim().length > 0
        z: 190
        onClicked: searchInput.focus = false
    }

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
            clip: true

            onTextChanged: resultsList.currentIndex = 0

            Keys.onPressed: (event) => {
                if (searchOverlay.visible && searchOverlay.hasResults) {
                    if (event.key === Qt.Key_Down) {
                        resultsList.currentIndex = Math.min(resultsList.currentIndex + 1, searchOverlay.filteredResults.length - 1)
                        event.accepted = true
                        return
                    } else if (event.key === Qt.Key_Up) {
                        resultsList.currentIndex = Math.max(resultsList.currentIndex - 1, 0)
                        event.accepted = true
                        return
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        if (resultsList.currentIndex >= 0 && resultsList.currentIndex < searchOverlay.filteredResults.length) {
                            let selected = searchOverlay.filteredResults[resultsList.currentIndex]
                            root.optionSelected(selected.sectionIndex)
                            root.clear()
                        }
                        event.accepted = true
                        return
                    }
                }

                if (event.key === Qt.Key_Escape) {
                    if (text.length > 0) {
                        text = ""
                    } else {
                        searchInput.focus = false
                    }
                    event.accepted = true
                }
            }

            Text {
                id: placeholderText
                color: Colors.subtext
                font: searchInput.font
                visible: searchInput.text.length === 0
                anchors.verticalCenter: parent.verticalCenter

                property var phrases: [
                    "Search settings...",
                    "Search 'Notch mode'...",
                    "Search 'Border width'...",
                    "Search 'Corner radius'...",
                    "Search 'Blur Strength'...",
                    "Search 'Movement (size / position)'..."
                ]
                property int phraseIdx: 0
                property int charIdx: 0
                property bool deleting: false

                text: ""

                Timer {
                    id: typewriterTimer
                    running: searchInput.text.length === 0 && !searchInput.activeFocus
                    repeat: true
                    interval: 100
                    onTriggered: {
                        let target = placeholderText.phrases[placeholderText.phraseIdx]

                        if (!placeholderText.deleting) {
                            placeholderText.charIdx++
                            placeholderText.text = target.substring(0, placeholderText.charIdx)
                            if (placeholderText.charIdx === target.length) {
                                placeholderText.deleting = true
                                interval = 1800
                            } else {
                                interval = 80
                            }
                        } else {
                            placeholderText.charIdx--
                            placeholderText.text = target.substring(0, placeholderText.charIdx)
                            if (placeholderText.charIdx === 0) {
                                placeholderText.deleting = false
                                placeholderText.phraseIdx = (placeholderText.phraseIdx + 1) % placeholderText.phrases.length
                                interval = 400
                            } else {
                                interval = 40
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: searchOverlay
        width: 320
        anchors.top: parent.bottom
        anchors.topMargin: 6
        anchors.right: parent.right
        color: Colors.elevatedBg
        radius: Dimens.radiusMedium
        border.color: Qt.rgba(1, 1, 1, 0.1)
        border.width: 1
        z: 200
        visible: searchInput.activeFocus && searchInput.text.trim().length > 0

        property var filteredResults: {
            let q = searchInput.text.toLowerCase().trim()
            if (q === "") return []
            let res = []
            for (let i = 0; i < globalTogglesModel.count; i++) {
                let item = globalTogglesModel.get(i)
                if (item.title.toLowerCase().includes(q)) {
                    res.push(item)
                }
            }
            return res
        }

        property bool hasResults: filteredResults.length > 0

        height: hasResults ? Math.min(resultsList.contentHeight + 8, 260) : 48

        MouseArea {
            anchors.fill: parent
            onWheel: (wheel) => {
                resultsList.contentY = Math.max(0, Math.min(resultsList.contentY - wheel.angleDelta.y, resultsList.contentHeight - resultsList.height))
                wheel.accepted = true
            }
        }

        ListModel {
            id: globalTogglesModel

            // -- Bar & Island (index 0) --
            ListElement { title: "Top margin"; sectionIndex: 0; sectionName: "Bar & Island" }
            ListElement { title: "Corner radius"; sectionIndex: 0; sectionName: "Bar & Island" }
            ListElement { title: "Border width"; sectionIndex: 0; sectionName: "Bar & Island" }
            ListElement { title: "Click outside to dismiss"; sectionIndex: 0; sectionName: "Bar & Island" }
            ListElement { title: "Notch mode"; sectionIndex: 0; sectionName: "Bar & Island" }
            ListElement { title: "Notch flare"; sectionIndex: 0; sectionName: "Bar & Island" }
            ListElement { title: "Bar height"; sectionIndex: 0; sectionName: "Bar & Island" }
            ListElement { title: "Collapsed width"; sectionIndex: 0; sectionName: "Bar & Island" }
            ListElement { title: "Expanded height floor"; sectionIndex: 0; sectionName: "Bar & Island" }
            ListElement { title: "Minimum expanded width"; sectionIndex: 0; sectionName: "Bar & Island" }
            ListElement { title: "Launcher width"; sectionIndex: 0; sectionName: "Bar & Island" }
            ListElement { title: "Clipboard width"; sectionIndex: 0; sectionName: "Bar & Island" }
            ListElement { title: "Control center width"; sectionIndex: 0; sectionName: "Bar & Island" }
            ListElement { title: "Control center height"; sectionIndex: 0; sectionName: "Bar & Island" }
            ListElement { title: "Notification center width"; sectionIndex: 0; sectionName: "Bar & Island" }
            ListElement { title: "Power menu width"; sectionIndex: 0; sectionName: "Bar & Island" }
            ListElement { title: "Power menu height"; sectionIndex: 0; sectionName: "Bar & Island" }
            ListElement { title: "Status panel width"; sectionIndex: 0; sectionName: "Bar & Island" }
            ListElement { title: "Status panel height"; sectionIndex: 0; sectionName: "Bar & Island" }
            ListElement { title: "Timer width"; sectionIndex: 0; sectionName: "Bar & Island" }
            ListElement { title: "Timer height"; sectionIndex: 0; sectionName: "Bar & Island" }

            // -- Clock & Date (index 1) — unconfirmed, left as previously entered --
            ListElement { title: "24-Hour Clock"; sectionIndex: 1; sectionName: "Clock & Date" }
            ListElement { title: "Show Seconds"; sectionIndex: 1; sectionName: "Clock & Date" }

            // -- Appearance (index 3) --
            ListElement { title: "Auto-switch wallpaper with theme"; sectionIndex: 3; sectionName: "Appearance" }
            ListElement { title: "Font size"; sectionIndex: 3; sectionName: "Appearance" }
            ListElement { title: "Body font"; sectionIndex: 3; sectionName: "Appearance" }
            ListElement { title: "Display font"; sectionIndex: 3; sectionName: "Appearance" }
            ListElement { title: "Main opacity"; sectionIndex: 3; sectionName: "Appearance" }
            ListElement { title: "Secondary opacity"; sectionIndex: 3; sectionName: "Appearance" }
            ListElement { title: "Spacing unit"; sectionIndex: 3; sectionName: "Appearance" }
            ListElement { title: "Small radius"; sectionIndex: 3; sectionName: "Appearance" }
            ListElement { title: "Light Mode"; sectionIndex: 3; sectionName: "Appearance" }
            ListElement { title: "Icon Style"; sectionIndex: 3; sectionName: "Appearance" }
            ListElement { title: "Icon Weight"; sectionIndex: 3; sectionName: "Appearance" }

            // -- Motion (index 4) --
            ListElement { title: "Reduce motion"; sectionIndex: 4; sectionName: "Motion" }
            ListElement { title: "Movement (size / position)"; sectionIndex: 4; sectionName: "Motion" }
            ListElement { title: "Fades & colour"; sectionIndex: 4; sectionName: "Motion" }
            ListElement { title: "Hover response"; sectionIndex: 4; sectionName: "Motion" }
            ListElement { title: "Bounce"; sectionIndex: 4; sectionName: "Motion" }
            ListElement { title: "Spring physics for bounce"; sectionIndex: 4; sectionName: "Motion" }

            // -- Lock Screen (index 7) --
            ListElement { title: "24-Hour Clock"; sectionIndex: 7; sectionName: "Lock Screen" }
            ListElement { title: "Show Date"; sectionIndex: 7; sectionName: "Lock Screen" }
            ListElement { title: "Show Username"; sectionIndex: 7; sectionName: "Lock Screen" }
            ListElement { title: "Placeholder Text"; sectionIndex: 7; sectionName: "Lock Screen" }
            ListElement { title: "Use Accent Color for Errors"; sectionIndex: 7; sectionName: "Lock Screen" }
            ListElement { title: "Frosted Glass Background Blur"; sectionIndex: 7; sectionName: "Lock Screen" }
            ListElement { title: "Blur Strength"; sectionIndex: 7; sectionName: "Lock Screen" }
            ListElement { title: "Wallpaper Dim Intensity"; sectionIndex: 7; sectionName: "Lock Screen" }
            ListElement { title: "Show HYPRLAND Action"; sectionIndex: 7; sectionName: "Lock Screen" }
            ListElement { title: "Show REBOOT Action"; sectionIndex: 7; sectionName: "Lock Screen" }
            ListElement { title: "Show POWER Action"; sectionIndex: 7; sectionName: "Lock Screen" }

            // -- System (index 9) --
            ListElement { title: "Display Scale Factor"; sectionIndex: 9; sectionName: "System" }
            ListElement { title: "Peace Mode (Do Not Disturb)"; sectionIndex: 9; sectionName: "System" }
            ListElement { title: "Natural Scrolling"; sectionIndex: 9; sectionName: "System" }

            // -- About (index 10) --
            ListElement { title: "Device Name"; sectionIndex: 10; sectionName: "About" }
            ListElement { title: "Operating System"; sectionIndex: 10; sectionName: "About" }
            ListElement { title: "Kernel"; sectionIndex: 10; sectionName: "About" }
            ListElement { title: "Uptime"; sectionIndex: 10; sectionName: "About" }
            ListElement { title: "Memory"; sectionIndex: 10; sectionName: "About" }
            ListElement { title: "Storage"; sectionIndex: 10; sectionName: "About" }
            ListElement { title: "Active Power Profile"; sectionIndex: 10; sectionName: "About" }
            ListElement { title: "System Packages"; sectionIndex: 10; sectionName: "About" }
            ListElement { title: "Minimal-Island-Shell"; sectionIndex: 10; sectionName: "About" }
            ListElement { title: "Reload Shell State"; sectionIndex: 10; sectionName: "About" }
        }

        ListView {
            id: resultsList
            anchors.fill: parent
            anchors.margins: 4
            clip: true
            visible: searchOverlay.hasResults
            model: searchOverlay.filteredResults

            delegate: Item {
                width: resultsList.width
                height: 36

                property bool isHighlighted: resultsList.currentIndex === index || resultMouse.containsMouse

                Rectangle {
                    anchors.fill: parent
                    color: isHighlighted ? Colors.accent : "transparent"
                    opacity: isHighlighted ? 0.2 : 1.0
                    radius: Dimens.radiusSmall
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10

                    Text {
                        text: modelData.title
                        color: Colors.fg
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeBase
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: modelData.sectionName
                        color: Colors.subtext
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeSm
                    }
                }

                MouseArea {
                    id: resultMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: resultsList.currentIndex = index
                    onClicked: {
                        root.optionSelected(modelData.sectionIndex)
                        root.clear()
                    }
                }
            }
        }

        RowLayout {
            anchors.centerIn: parent
            visible: !searchOverlay.hasResults
            spacing: Dimens.spacingSmall

            Text {
                text: "search_off"
                color: Colors.subtext
                font.family: Fonts.icon
                font.variableAxes: Fonts.iconAxes
                font.pixelSize: Dimens.fontSizeMd
            }

            Text {
                text: "No settings found"
                color: Colors.subtext
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeBase
            }
        }
    }
}