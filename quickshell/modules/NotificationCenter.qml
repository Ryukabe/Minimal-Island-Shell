// modules/NotificationCenter.qml
pragma ComponentBehavior: Bound

import QtQuick
import "../services"
import "../styles"
import "../components/notification-center"

Item {
    id: root
    implicitWidth: ShellState.notificationCenterWidth
    implicitHeight: Math.min(contentColumn.implicitHeight + contentColumn.anchors.margins * 2, ShellState.notificationCenterMaxHeight)

    focus: true
    Timer {
        id: focusTimer
        interval: 50
        repeat: false
        onTriggered: root.forceActiveFocus()
    }

    Component.onCompleted: focusTimer.restart()

    // The list may use whatever the max-height slider leaves after the margins, header and gap.
    // (This used to be a hardcoded 380, which made the slider stop working above ~480 px.)
    readonly property real listMaxHeight: ShellState.notificationCenterMaxHeight
        - contentColumn.anchors.margins * 2
        - headerRow.height
        - contentColumn.spacing

    // Notifications grouped by app, newest group first, newest notification first inside a group.
    // Assumes trackedNotifications.values is ordered oldest -> newest.
    readonly property var groups: {
        var vals = NotificationService.trackedNotifications.values
        var order = []
        var byApp = {}
        for (var i = vals.length - 1; i >= 0; i--) {
            var app = vals[i].appName || "Unknown"
            if (!byApp[app]) {
                byApp[app] = { app: app, items: [] }
                order.push(byApp[app])
            }
            byApp[app].items.push(vals[i])
        }
        return order
    }

    // Per-group open/closed choices made while the center is open. A group with no entry here
    // follows the "Open expanded" setting. Always reassigned (never mutated) so bindings update.
    property var expandedOverrides: ({})

    function isExpanded(app) {
        var o = root.expandedOverrides[app]
        return o !== undefined ? o : ShellState.notificationGroupExpanded
    }

    function toggleGroup(app, expanded) {
        var next = Object.assign({}, root.expandedOverrides)
        next[app] = expanded
        root.expandedOverrides = next
    }

    function clearGroup(items) {
        const list = [...items]
        for (let i = 0; i < list.length; i++) {
            list[i].dismiss()
        }
    }

    function clearAll() {
        const items = [...NotificationService.trackedNotifications.values]
        for (let i = 0; i < items.length; i++) {
            items[i].dismiss()
        }
    }

    Column {
        id: contentColumn
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 16
        spacing: 12

        Item {
            id: headerRow
            width: parent.width
            height: 28

            Text {
                text: "Notification Center"
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSize15
                font.bold: true
                color: Colors.fg
                anchors.centerIn: parent
            }

            Text {
                text: "Clear all"
                font.pixelSize: Dimens.fontSizeSm
                color: Colors.accent
                visible: NotificationService.trackedNotifications.values.length > 0
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    onClicked: root.clearAll()
                }
            }
        }

        Flickable {
            id: listFlick
            width: parent.width
            height: Math.min(listColumn.implicitHeight, root.listMaxHeight)
            contentWidth: width
            contentHeight: listColumn.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: listColumn
                width: parent.width
                spacing: 12

                Repeater {
                    model: root.groups

                    delegate: Column {
                        id: group
                        required property var modelData

                        readonly property string app: modelData.app
                        readonly property var items: modelData.items
                        readonly property bool expanded: root.isExpanded(group.app)
                        // Only groups longer than the preview count can be opened or closed.
                        readonly property bool collapsible: group.items.length > ShellState.notificationGroupPreviewCount
                        readonly property int shown: (group.expanded || !group.collapsible)
                            ? group.items.length
                            : ShellState.notificationGroupPreviewCount

                        width: listColumn.width
                        spacing: Dimens.spacingSmall

                        Item {
                            id: groupHeader
                            width: group.width
                            height: Math.max(appLabel.implicitHeight, headerActions.implicitHeight)

                            Text {
                                id: appLabel
                                text: group.app + "  ·  " + group.items.length
                                font.family: Fonts.text
                                font.pixelSize: Dimens.fontSizeSm
                                font.bold: true
                                color: Colors.fgMuted
                                elide: Text.ElideRight
                                anchors.left: parent.left
                                anchors.right: headerActions.left
                                anchors.rightMargin: Dimens.spacingMedium
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Row {
                                id: headerActions
                                spacing: Dimens.spacingMedium
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    visible: group.collapsible
                                    text: group.expanded ? "Show less" : "Show all"
                                    font.family: Fonts.text
                                    font.pixelSize: Dimens.fontSizeSm
                                    color: Colors.accent

                                    MouseArea {
                                        anchors.fill: parent
                                        anchors.margins: -6
                                        onClicked: root.toggleGroup(group.app, !group.expanded)
                                    }
                                }

                                Text {
                                    text: "Clear"
                                    font.family: Fonts.text
                                    font.pixelSize: Dimens.fontSizeSm
                                    color: Colors.accent

                                    MouseArea {
                                        anchors.fill: parent
                                        anchors.margins: -6
                                        onClicked: root.clearGroup(group.items)
                                    }
                                }
                            }
                        }

                        Repeater {
                            model: group.items.slice(0, group.shown)

                            delegate: NotificationRow {
                                required property var modelData

                                width: group.width
                                notification: modelData
                            }
                        }
                    }
                }

                Text {
                    text: "No notifications"
                    font.pixelSize: Dimens.fontSizeSm
                    color: Colors.fgMuted
                    visible: NotificationService.trackedNotifications.values.length === 0
                    anchors.horizontalCenter: parent.horizontalCenter
                    topPadding: 20
                    bottomPadding: 20
                }
            }
        }
    }
}