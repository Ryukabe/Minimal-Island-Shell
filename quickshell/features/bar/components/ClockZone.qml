// features/bar/components/ClockZone.qml — one row of clock items.
// In Island and Notch style one "all" row shows every item. In Bar style there are three rows
// (left, center, right), and an item shows in the zone chosen for it in Settings > Bar.
// Items keep the order they have in the layout editor.
import QtQuick
import QtQuick.Layouts
import "../../../core/shell"
import ".."

RowLayout {
    id: root

    property string zone: "all"          // "all" | "left" | "center" | "right"
    property bool zoneActive: true
    property var itemShown: null         // function(type) -> bool
    property var componentFor: null      // function(type) -> Component

    spacing: 14

    Repeater {
        model: ClockLayoutService.layoutModel

        delegate: Loader {
            id: slot
            required property string itemId

            readonly property bool inZone: root.zone === "all" || ShellState.clockZoneOf(slot.itemId) === root.zone

            Layout.alignment: Qt.AlignVCenter
            active: root.zoneActive && slot.inZone
            visible: slot.active && root.itemShown !== null && root.itemShown(slot.itemId)
            sourceComponent: root.componentFor !== null ? root.componentFor(slot.itemId) : null
        }
    }
}