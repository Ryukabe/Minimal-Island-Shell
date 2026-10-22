// Disk usage, uptime and the busiest processes. Refreshes on the Dashboard stats interval.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import "../../../core/shell"
import "../../../core/styles"

DashCard {
    id: card

    property string diskUsed: "-"
    property string diskSize: "-"
    property int diskPercent: 0
    property string uptimeText: "-"
    property var processes: []

    readonly property real pad: Dimens.paddingMedium
    // The commands below show up in their own process list; hide them.
    readonly property var ignoredProcesses: ["ps", "sh", "sed"]

    function formatUptime(seconds) {
        var d = Math.floor(seconds / 86400)
        var h = Math.floor((seconds % 86400) / 3600)
        var m = Math.floor((seconds % 3600) / 60)
        return (d > 0 ? d + "d " : "") + h + "h " + m + "m"
    }

    // Line 1: disk "used size pcent". Line 2: uptime seconds. Rest: "name cpu%" by CPU use.
    function parse(output) {
        var lines = output.trim().split("\n")
        if (lines.length < 2) return
        var disk = lines[0].trim().split(/\s+/)
        card.diskUsed = disk[0]
        card.diskSize = disk[1]
        card.diskPercent = parseInt(disk[2]) || 0
        card.uptimeText = card.formatUptime(parseFloat(lines[1]) || 0)

        var procs = []
        for (var i = 2; i < lines.length && procs.length < 3; i++) {
            var line = lines[i].trim()
            var cut = line.lastIndexOf(" ")
            if (cut < 0) continue
            var name = line.substring(0, cut).trim()
            if (card.ignoredProcesses.indexOf(name) >= 0) continue
            procs.push({ name: name, cpu: line.substring(cut + 1) })
        }
        card.processes = procs
    }

    Process {
        id: proc
        command: ["sh", "-c",
            "df -h --output=used,size,pcent / | tail -n 1; cut -d' ' -f1 /proc/uptime; ps -eo comm,pcpu --sort=-pcpu | sed -n '2,8p'"]
        stdout: StdioCollector {
            onStreamFinished: card.parse(text)
        }
    }

    Timer {
        interval: ShellState.dashboardStatsIntervalSec * 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: if (!proc.running) proc.running = true
    }

    component InfoLine: Item {
        id: line
        property string label
        property string value

        width: parent ? parent.width : 0
        height: Dimens.fontSizeSm * 1.7

        Text {
            anchors.left: parent.left
            anchors.right: valueText.left
            anchors.rightMargin: Dimens.spacingSm
            anchors.verticalCenter: parent.verticalCenter
            elide: Text.ElideRight
            text: line.label
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeSm
            color: Colors.fgMuted
        }

        Text {
            id: valueText
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: line.value
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeSm
            color: Colors.fg
        }
    }

    Item {
        anchors.fill: parent
        anchors.margins: card.pad

        Text {
            id: title
            text: "System"
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeMd
            font.bold: true
            color: Colors.fg
        }

        Column {
            anchors.top: title.bottom
            anchors.topMargin: Dimens.spacingSm
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Dimens.spacingSm / 2

            InfoLine { label: "Disk"; value: card.diskUsed + " / " + card.diskSize }

            Rectangle {
                width: parent.width
                height: Dimens.spacingSm
                radius: height / 2
                color: Colors.elevatedBg

                Rectangle {
                    width: parent.width * card.diskPercent / 100
                    height: parent.height
                    radius: parent.radius
                    color: card.diskPercent > 90 ? Colors.red : Colors.accent
                }
            }

            InfoLine { label: "Uptime"; value: card.uptimeText }

            Text {
                topPadding: Dimens.spacingSm
                text: "Busiest"
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeXs
                color: Colors.fgMuted
            }

            Repeater {
                model: card.processes

                delegate: InfoLine {
                    required property var modelData
                    label: modelData.name
                    value: modelData.cpu + "%"
                }
            }
        }
    }
}