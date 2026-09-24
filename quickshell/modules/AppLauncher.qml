// modules/AppLauncher.qml
pragma ComponentBehavior: Bound

import "../services"
import "../styles"
import QtQuick
import QtQuick.Controls
import Quickshell

Item {
    id: root

    readonly property int rowHeight: 54
    readonly property int maxVisibleRows: ShellState.launcherMaxRows
    readonly property int maxWidth: Math.round(ShellState.launcherWidth * LauncherSettings.widthScale)
    readonly property int minWidth: Math.round(maxWidth * 0.72)
    readonly property int chromeHeight: 76

    // AppLauncher fills the island directly (no settings-window layer in
    // between), so its containers derive straight off the master with
    // their own real margin (12px, matching Dimens.paddingMedium below).
    readonly property real _outerRadius: ShellState.islandCornerRadius

    property string query: ""
        property var results: buildResults(query)

    // Calculator result (if the query is a calculation) goes on top of the app list.
    function buildResults(q) {
        var apps = AppLauncherService.filteredApps(q)
        var calc = LauncherSettings.inlineCalculator ? CalculatorService.evaluate(q) : null
        if (!calc) return apps
        return [{
            kind: "calc",
            name: "= " + calc.text,
            comment: q.trim() + "  ·  Enter to copy",
            value: calc.text
        }].concat(apps)
    }

    function activate(item) {
        if (!item) return
        if (item.kind === "calc") CalculatorService.copy(item.value)
        else AppLauncherService.launch(item)
        ShellState.showPage("clock")
    }
    property int selectedIndex: 0

    implicitWidth: (LauncherSettings.shrinkForFewResults && results.length <= 1) ? minWidth : maxWidth
    implicitHeight: Math.min(
        chromeHeight + Math.max(results.length, 1) * rowHeight,
        chromeHeight + maxVisibleRows * rowHeight
    )

    onQueryChanged: {
        selectedIndex = 0
        if (LauncherSettings.clipboardHistory && query.startsWith(":")) {
            ClipboardService.searchQuery = query.substring(1)
            ShellState.showPage("clipboard")
        }
    }

    Timer {
        id: focusTimer
        interval: 50
        repeat: false
        onTriggered: searchInput.forceActiveFocus()
    }

    onVisibleChanged: {
        if (visible && ShellState.activePage === "launcher") {
            focusTimer.restart()
        }
    }

    Component.onCompleted: focusTimer.restart()

    Rectangle {
        id: searchBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 12
        height: 44
        radius: root._outerRadius
        color: Colors.subBgMica

        MouseArea {
            anchors.fill: parent
            onClicked: searchInput.forceActiveFocus()
        }

        Row {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: Dimens.spacingLg

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "search"
                font.family: Fonts.icon
                font.pixelSize: Dimens.fontSizeLg
                font.variableAxes: Fonts.iconAxes
                font.features: { "liga": 1, "dlig": 1 }
                color: Colors.fgMuted
            }

            Item {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 24
                height: searchInput.height

                Text {
                    text: "Search..."
                    color: Colors.fgMuted
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeMd
                    anchors.verticalCenter: parent.verticalCenter
                    visible: searchInput.text.length === 0
                }

                TextInput {
                    id: searchInput
                    width: parent.width
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeLg
                    color: Colors.fg
                    clip: true
                    focus: true
                    onTextChanged: root.query = text

                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Down) {
                            root.selectedIndex = Math.min(root.selectedIndex + 1, root.results.length - 1)
                            appList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                            event.accepted = true
                        } else if (event.key === Qt.Key_Up) {
                            root.selectedIndex = Math.max(root.selectedIndex - 1, 0)
                            appList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                            event.accepted = true
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            root.activate(root.results[root.selectedIndex])
                            event.accepted = true
                        }
                    }
                }
            }
        }
    }

    ListView {
        id: appList
        anchors.top: searchBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: 8
        anchors.margins: 12
        clip: true
        spacing: 2
        model: root.results
        currentIndex: root.selectedIndex

        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        WheelHandler {
            onWheel: (event) => {
                appList.contentY = Math.max(
                    0,
                    Math.min(appList.contentY - event.angleDelta.y, Math.max(0, appList.contentHeight - appList.height))
                )
            }
        }

        delegate: Rectangle {
            id: delegateRoot
            required property int index
            required property var modelData

            width: appList.width
            height: root.rowHeight - appList.spacing
            radius: root._outerRadius
            color: (delegateRoot.index !== undefined && delegateRoot.index === root.selectedIndex) ? Colors.subBgMica : "transparent"

            scale: delegateRoot.index === root.selectedIndex ? 1.015 : 1.0

            // Fade-in when a row is created (runs on every filter change too)
            readonly property bool fadeEnabled: LauncherSettings.animateResults && !ShellState.motionReduced
            opacity: fadeEnabled ? 0 : 1
            Behavior on opacity {
                enabled: delegateRoot.fadeEnabled
                NumberAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
            }
            Component.onCompleted: delegateRoot.opacity = 1

            // Row selection is snap tier — small, frequent, must not lag key repeats
            SpringAnimation {
                id: selectSpringAnim
                spring: Motion.snapSpring
                damping: Motion.snapDamping
                mass: Motion.snapMass
                epsilon: Motion.epsilon
            }
            NumberAnimation {
                id: selectEaseAnim
                duration: ShellState.motionDuration(Motion.snapMs)
                easing.type: Easing.OutCubic
            }
            Behavior on scale {
                animation: (ShellState.motionSpringEnabled && !ShellState.motionReduced) ? selectSpringAnim : selectEaseAnim
            }

            Row {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: Dimens.spacingMd

                Item {
                    width: 32
                    height: 32
                    anchors.verticalCenter: parent.verticalCenter
                    visible: LauncherSettings.showIcons

                    Image {
                        id: appIcon
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectFit
                        source: {
                            if (!delegateRoot.modelData.icon) return ""
                            if (delegateRoot.modelData.icon.startsWith("/")) {
                                return "file://" + delegateRoot.modelData.icon
                            }
                            var resolved = Quickshell.iconPath(delegateRoot.modelData.icon, "Papirus-Dark")
                            return resolved !== "" ? resolved : "image://icon/" + delegateRoot.modelData.icon
                        }
                        visible: status === Image.Ready
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: ShellState.islandCornerRadius
                        color: (delegateRoot.index !== undefined && delegateRoot.index === root.selectedIndex) ? Colors.mainBgMica : Colors.subBgMica
                        visible: appIcon.status !== Image.Ready

                        Text {
                            anchors.centerIn: parent
                            text: delegateRoot.modelData.name ? delegateRoot.modelData.name.charAt(0).toUpperCase() : "?"
                            font.family: Fonts.text
                            font.pixelSize: Dimens.fontSizeMd
                            font.weight: Font.Bold
                            color: Colors.fg
                        }
                                                Text {
                            anchors.centerIn: parent
                            visible: delegateRoot.modelData.kind === "calc"
                            text: "calculate"
                            font.family: Fonts.icon
                            font.pixelSize: Dimens.fontSizeLg
                            font.variableAxes: Fonts.iconAxes
                            font.features: { "liga": 1, "dlig": 1 }
                            color: Colors.accent
                        }
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 1
                    width: parent.width - (LauncherSettings.showIcons ? 44 : 0)

                    Text {
                        text: delegateRoot.modelData.name
                        color: Colors.fg
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeMd
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                        width: parent.width
                    }

                    Text {
                        text: delegateRoot.modelData.comment || ""
                        color: Colors.fgMuted
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeSm
                        visible: text.length > 0
                        elide: Text.ElideRight
                        width: parent.width
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: root.selectedIndex = delegateRoot.index
                onClicked: root.activate(delegateRoot.modelData)
            }
        }
    }

    Text {
        anchors.top: searchBar.bottom
        anchors.topMargin: 24
        anchors.horizontalCenter: parent.horizontalCenter
        text: "No apps found"
        color: Colors.fgMuted
        font.family: Fonts.text
        font.pixelSize: Dimens.fontSizeMd
        visible: root.results.length === 0
    }

    Connections {
        target: ShellState
        function onActivePageChanged() {
            if (ShellState.activePage === "launcher") {
                searchInput.text = ""
                root.selectedIndex = 0
                focusTimer.restart()
            }
        }
    }
}