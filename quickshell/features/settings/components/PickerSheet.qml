// components/PickerSheet.qml — the select page: scrim, card with title + close, search, list.
// One instance lives in SettingsApp.qml; content comes from core/SettingsPicker.qml.
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../core"
import "../../../core/state"
import "../../../core/styles"

Item {
    id: root

    readonly property real cardWidth: 440
    readonly property real cardMaxHeight: 480
    readonly property real rowHeight: 40
    readonly property bool springOn: ShellState.motionSpringEnabled && !ShellState.motionReduced

    // Same radius rule as the rest of the shell: universal follows the island radius.
    readonly property real cardRadius: ShellState.radiusUniversal
        ? ShellState.islandCornerRadius
        : ShellState.customRadiusCard
    readonly property real controlRadius: ShellState.radiusUniversal
        ? ShellState.islandCornerRadius
        : ShellState.customRadiusControl

    property string query: ""
    property int highlighted: 0

    // Local mode filters here; remote mode shows whatever the page last set.
    readonly property var filtered: {
        if (SettingsPicker.remote) return SettingsPicker.items
        var q = root.query.trim().toLowerCase()
        var all = SettingsPicker.items
        if (q === "") return all
        return all.filter(it => it.label.toLowerCase().indexOf(q) >= 0)
    }

    onFilteredChanged: if (SettingsPicker.remote) root.highlighted = 0

    visible: opacity > 0
    enabled: SettingsPicker.opened
    opacity: SettingsPicker.opened ? 1 : 0
    Behavior on opacity {
        NumberAnimation {
            duration: ShellState.motionDuration(Motion.fadeMs)
            easing.type: Easing.OutCubic
        }
    }

    function begin() {
        searchInput.text = SettingsPicker.initialQuery
        if (SettingsPicker.remote) SettingsPicker.search(searchInput.text)

        var idx = 0
        var all = SettingsPicker.items
        for (var i = 0; i < all.length; i++) {
            if (all[i].value === SettingsPicker.selectedValue) { idx = i; break }
        }
        root.highlighted = idx

        popSpring.stop()
        popEase.stop()
        card.scale = 0.94
        if (root.springOn) popSpring.start()
        else popEase.start()

        focusTimer.restart()
        Qt.callLater(() => list.positionViewAtIndex(root.highlighted, ListView.Center))
    }

    function end() {
        if (root.parent) root.parent.forceActiveFocus()
    }

    Connections {
        target: SettingsPicker
        function onOpenedChanged() {
            if (SettingsPicker.opened) root.begin()
            else root.end()
        }
    }

    Timer {
        id: focusTimer
        interval: 50
        repeat: false
        onTriggered: searchInput.forceActiveFocus()
    }

    // Click outside the card to close.
    Rectangle {
        anchors.fill: parent
        color: Qt.alpha(Colors.black, 0.45)

        MouseArea {
            anchors.fill: parent
            onClicked: SettingsPicker.close()
            // Swallow wheel events so the page underneath doesn't scroll.
            onWheel: (wheel) => { wheel.accepted = true }
        }
    }

    SpringAnimation {
        id: popSpring
        target: card
        property: "scale"
        to: 1.0
        spring: Motion.expressiveSpring
        damping: Motion.expressiveDamping
        mass: Motion.expressiveMass
        epsilon: Motion.scaleEpsilon
    }

    NumberAnimation {
        id: popEase
        target: card
        property: "scale"
        to: 1.0
        duration: ShellState.motionDuration(Motion.expressiveMs)
        easing.type: Easing.OutCubic
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: Math.min(root.width - Dimens.paddingLarge * 2, root.cardWidth)
        height: Math.min(root.height - Dimens.paddingLarge * 2, root.cardMaxHeight)
        radius: root.cardRadius
        color: Colors.elevatedBg
        border.color: Colors.border
        border.width: 1

        // Swallow clicks and wheel events so they don't reach the scrim or the page.
        MouseArea {
            anchors.fill: parent
            onWheel: (wheel) => { wheel.accepted = true }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Dimens.paddingLarge
            spacing: Dimens.spacingMedium

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: SettingsPicker.title
                    color: Colors.fg
                    font.family: Fonts.display
                    font.pixelSize: Dimens.fontSizeMd
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                }

                Rectangle {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    radius: root.controlRadius
                    color: closeMouse.containsMouse ? Colors.subBgMica : "transparent"

                    Behavior on color {
                        ColorAnimation { duration: ShellState.motionDuration(Motion.hoverMs) }
                    }

                    SymbolIcon {
                        anchors.centerIn: parent
                        name: "close"
                        size: Dimens.fontSizeMd
                        color: Colors.fgMuted
                    }

                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: SettingsPicker.close()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                radius: root.controlRadius
                color: Colors.subBgMica
                border.width: 1
                border.color: searchInput.activeFocus ? Colors.accent : "transparent"

                Behavior on border.color {
                    ColorAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Dimens.paddingMedium
                    anchors.rightMargin: Dimens.paddingMedium
                    spacing: Dimens.spacingSmall

                    SymbolIcon {
                        name: "search"
                        size: Dimens.fontSizeMd
                        color: Colors.fgMuted
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: SettingsPicker.searchHint
                            color: Colors.fgMuted
                            font.family: Fonts.text
                            font.pixelSize: Dimens.fontSizeMd
                            visible: searchInput.text.length === 0
                        }

                        TextInput {
                            id: searchInput
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width
                            color: Colors.fg
                            font.family: Fonts.text
                            font.pixelSize: Dimens.fontSizeMd
                            clip: true

                            onTextChanged: {
                                root.query = text
                                root.highlighted = 0
                                if (SettingsPicker.remote) SettingsPicker.search(text)
                            }

                            Keys.onPressed: (event) => {
                                if (event.key === Qt.Key_Down) {
                                    root.highlighted = Math.min(root.highlighted + 1, root.filtered.length - 1)
                                    list.positionViewAtIndex(root.highlighted, ListView.Contain)
                                    event.accepted = true
                                } else if (event.key === Qt.Key_Up) {
                                    root.highlighted = Math.max(root.highlighted - 1, 0)
                                    list.positionViewAtIndex(root.highlighted, ListView.Contain)
                                    event.accepted = true
                                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    var it = root.filtered[root.highlighted]
                                    if (it) SettingsPicker.pick(it.value)
                                    event.accepted = true
                                } else if (event.key === Qt.Key_Escape) {
                                    // Close the picker only, not the whole settings window.
                                    SettingsPicker.close()
                                    event.accepted = true
                                }
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ListView {
                    id: list
                    anchors.fill: parent
                    clip: true
                    spacing: 2
                    model: root.filtered
                    boundsBehavior: Flickable.StopAtBounds

                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                    delegate: Rectangle {
                        id: row
                        required property int index
                        required property var modelData
                        readonly property bool isSelected: row.modelData.value === SettingsPicker.selectedValue

                        width: list.width
                        height: root.rowHeight
                        radius: root.controlRadius
                        color: row.isSelected ? Qt.alpha(Colors.accent, 0.22)
                             : (row.index === root.highlighted ? Colors.subBgMica : "transparent")

                        Behavior on color {
                            ColorAnimation { duration: ShellState.motionDuration(Motion.hoverMs) }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Dimens.paddingMedium
                            anchors.rightMargin: Dimens.paddingMedium

                            Text {
                                Layout.fillWidth: true
                                text: row.modelData.label
                                color: Colors.fg
                                font.family: Fonts.text
                                font.pixelSize: Dimens.fontSizeMd
                                font.weight: row.isSelected ? Font.DemiBold : Font.Normal
                                elide: Text.ElideRight
                            }

                            SymbolIcon {
                                visible: row.isSelected
                                name: "check"
                                size: Dimens.fontSizeMd
                                color: Colors.accent
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: root.highlighted = row.index
                            onClicked: SettingsPicker.pick(row.modelData.value)
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    visible: root.filtered.length === 0
                    text: (SettingsPicker.remote && SettingsPicker.status !== "")
                        ? SettingsPicker.status
                        : "No matches"
                    color: Colors.fgMuted
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeMd
                }
            }
        }
    }
}