// features/dashboard/Dashboard.qml — the "status" island page. Read-only grid of components;
// the layout is edited in Settings > Dashboard.
pragma ComponentBehavior: Bound

import QtQuick
import "."
import "../../core/shell"
import "../../core/styles"

Item {
    id: root

    implicitWidth: ShellState.statusPanelWidth
    implicitHeight: ShellState.statusPanelHeight

    focus: true
    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Escape) {
            ShellState.showPage("clock")
            event.accepted = true
        }
    }

    Timer {
        id: focusTimer
        interval: 50
        repeat: false
        onTriggered: root.forceActiveFocus()
    }
    Component.onCompleted: focusTimer.restart()

    DashboardGrid {
        anchors.fill: parent
        anchors.margins: Dimens.paddingMedium
        editMode: false
    }
}