// modules/AppLauncher.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import Quickshell
import "../services"
import "../styles"

Item {
    id: root

    readonly property int rowHeight: 54
    readonly property int maxVisibleRows: ShellState.launcherMaxRows
    readonly property int maxWidth: ShellState.launcherWidth
    readonly property int chromeHeight: 76 

    property string query: ""
    property var results: AppLauncherService.filteredApps(query)
    property int selectedIndex: 0

    implicitWidth: maxWidth
    implicitHeight: Math.min(
        chromeHeight + Math.max(results.length, 1) * rowHeight,
        chromeHeight + maxVisibleRows * rowHeight
    )

    onQueryChanged: {
        selectedIndex = 0
        if (query.startsWith(":")) {
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
        radius: Dimens.borderRadiusLarge
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
                            if (root.results.length > 0) {
                                AppLauncherService.launch(root.results[root.selectedIndex])
                                ShellState.showPage("clock")
                            }
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
            radius: Dimens.borderRadiusLarge
            color: (delegateRoot.index !== undefined && delegateRoot.index === root.selectedIndex) ? Colors.subBgMica : "transparent"

            scale: delegateRoot.index === root.selectedIndex ? 1.015 : 1.0

            NumberAnimation {
                id: scaleEaseAnim
                duration: ShellState.motionDuration(ShellState.motionHoverMs)
                easing.type: Easing.OutBack
                easing.overshoot: ShellState.motionOvershoot()
            }

            SpringAnimation {
                id: scaleSpringAnim
                spring: ShellState.springStiffness()
                damping: ShellState.springDamping()
            }

            Behavior on scale {
                animation: (ShellState.motionSpringEnabled && !ShellState.motionReduced) ? scaleSpringAnim : scaleEaseAnim
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
                        radius: Dimens.borderRadiusMedium
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
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 1
                    width: parent.width - 44

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
                onClicked: {
                    AppLauncherService.launch(delegateRoot.modelData)
                    ShellState.showPage("clock")
                }
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