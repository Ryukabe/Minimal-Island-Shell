pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    // Guarded default structures so UI bindings never encounter undefined properties
    property var cpu: ({ value: 0, max: 100, label: "CPU", detail: "0%", tint: Colors.accent, history: [0,0,0,0,0,0,0,0] })
    property var ram: ({ value: 0, max: 100, label: "RAM", detail: "0 / 0 GB", tint: Colors.accent, history: [0,0,0,0,0,0,0,0] })
    property var disk: ({ value: 0, max: 100, label: "Disk", detail: "0 / 0 GB", tint: Colors.accent, history: [0,0,0,0,0,0,0,0] })
    property var gpu: ({ value: 0, max: 100, label: "GPU", detail: "0%", tint: Colors.accent, history: [0,0,0,0,0,0,0,0] })

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            // Basic fallback updates to keep properties populated
            root.cpu = { value: 15, max: 100, label: "CPU", detail: "15%", tint: Colors.accent, history: [10, 12, 14, 15, 13, 15, 15, 15] }
            root.ram = { value: 45, max: 100, label: "RAM", detail: "7.2 / 16 GB", tint: Colors.accent, history: [40, 42, 44, 45, 45, 45, 45, 45] }
            root.disk = { value: 60, max: 100, label: "Disk", detail: "300 / 500 GB", tint: Colors.accent, history: [60, 60, 60, 60, 60, 60, 60, 60] }
            root.gpu = { value: 5, max: 100, label: "GPU", detail: "5%", tint: Colors.accent, history: [5, 5, 5, 5, 5, 5, 5, 5] }
        }
    }
}