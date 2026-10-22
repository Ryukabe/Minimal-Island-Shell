// features/dashboard/Dashboard.qml — the "status" island page. Read-only grid of components;
// the layout is edited in Settings > Dashboard. The panel is exactly as big as its grid
// (plus padding), so adding, removing or resizing components changes the panel size.
pragma ComponentBehavior: Bound

import QtQuick
import "."
import "../../core/shell"
import "../../core/styles"

Item {
    id: root

    implicitWidth: grid.implicitWidth + Dimens.paddingMedium * 2
    implicitHeight: grid.implicitHeight + Dimens.paddingMedium * 2

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
        id: grid
        x: Dimens.paddingMedium
        y: Dimens.paddingMedium
        width: implicitWidth
        height: implicitHeight
        editMode: false
    }

    /*DashboardSideButtons {
        anchors.fill: parent
    }*/
}