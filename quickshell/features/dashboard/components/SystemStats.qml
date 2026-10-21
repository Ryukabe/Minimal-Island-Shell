// System stats card: one row per metric, in the style of a menu-bar stats popup.
// The row list is a fixed set of six keys, so rows are never destroyed and recreated while the
// numbers update; each row shows or hides itself instead.
pragma ComponentBehavior: Bound

import QtQuick
import ".."
import "../../../core/shell"
import "../../../core/styles"

DashCard {
    id: card

    readonly property real pad: Dimens.paddingMedium
    readonly property real rowGap: Dimens.spacingSm
    readonly property real minRowH: Dimens.fontSizeXl * 2
    readonly property real maxRowH: Dimens.fontSizeXl * 3

    readonly property var allKeys: ["cpu", "gpu", "memory", "network", "battery", "temperature"]

    function isOn(key) {
        switch (key) {
        case "cpu": return ShellState.dashboardStatCpu
        case "gpu": return ShellState.dashboardStatGpu
        case "memory": return ShellState.dashboardStatMemory
        case "network": return ShellState.dashboardStatNetwork
        case "battery": return ShellState.dashboardStatBattery && StatsService.hasBattery
        case "temperature": return ShellState.dashboardStatTemperature
        }
        return false
    }

    // Position of a row among the rows that are switched on (0 = first).
    function rankOf(key) {
        var n = 0
        for (var i = 0; i < card.allKeys.length; i++) {
            if (card.allKeys[i] === key) return n
            if (card.isOn(card.allKeys[i])) n++
        }
        return n
    }

    readonly property int activeCount: {
        var n = 0
        for (var i = 0; i < card.allKeys.length; i++) {
            if (card.isOn(card.allKeys[i])) n++
        }
        return n
    }

    // How many rows fit at the minimum row height, and the height each one then gets.
    readonly property int fit: Math.max(1, Math.floor((height - pad * 2 + rowGap) / (minRowH + rowGap)))
    readonly property int shown: Math.min(activeCount, fit)
    readonly property real rowH: shown > 0
        ? Math.min(maxRowH, (height - pad * 2 - rowGap * (shown - 1)) / shown) : 0

    function rowData(key) {
        switch (key) {
        case "cpu":
            return { icon: "memory", label: "CPU", value: Math.round(StatsService.cpu) + "%", detail: "",
                     history: StatsService.cpuHistory, max: 100, tint: Colors.blue }
        case "gpu":
            return { icon: "developer_board", label: "GPU",
                     value: StatsService.hasGpu ? Math.round(StatsService.gpu) + "%" : "Not detected", detail: "",
                     history: StatsService.gpuHistory, max: 100, tint: Colors.purple }
        case "memory":
            return { icon: "memory_alt", label: "Memory", value: Math.round(StatsService.memory) + "%",
                     detail: StatsService.formatGb(StatsService.memUsedKb) + " / " + StatsService.formatGb(StatsService.memTotalKb) + " GB",
                     history: StatsService.memHistory, max: 100, tint: Colors.green }
        case "network":
            return { icon: "language", label: "Network", value: "↓ " + StatsService.formatRate(StatsService.rxBps),
                     detail: "↑ " + StatsService.formatRate(StatsService.txBps),
                     history: StatsService.netHistory, max: 0, tint: Colors.cyan }
        case "battery":
            return { icon: StatsService.charging ? "battery_charging_full" : "battery_full", label: "Battery",
                     value: StatsService.battery + "%", detail: StatsService.batteryStatus,
                     history: StatsService.batteryHistory, max: 100, tint: Colors.yellow }
        case "temperature":
            return { icon: "thermostat", label: "Temperature",
                     value: StatsService.hasTemp ? StatsService.formatTemp(StatsService.tempC) : "N/A", detail: "",
                     history: StatsService.tempHistory, max: 100, tint: Colors.red }
        }
        return { icon: "", label: "", value: "", detail: "", history: [], max: 100, tint: Colors.accent }
    }

    Component.onCompleted: StatsService.viewers += 1
    Component.onDestruction: StatsService.viewers -= 1

    Column {
        anchors.fill: parent
        anchors.margins: card.pad
        spacing: card.rowGap

        Repeater {
            model: card.allKeys

            delegate: StatRow {
                id: statRow
                required property string modelData

                readonly property var d: card.rowData(statRow.modelData)
                readonly property bool show: card.isOn(statRow.modelData) && card.rankOf(statRow.modelData) < card.shown

                visible: show
                width: parent.width
                height: show ? card.rowH : 0
                icon: statRow.d.icon
                label: statRow.d.label
                value: statRow.d.value
                detail: statRow.d.detail
                history: statRow.d.history
                graphMax: statRow.d.max
                tint: statRow.d.tint
                showGraph: ShellState.dashboardStatsShowGraphs
            }
        }
    }

    Text {
        anchors.centerIn: parent
        visible: card.activeCount === 0
        text: "No rows enabled"
        font.family: Fonts.text
        font.pixelSize: Dimens.fontSizeSm
        color: Colors.fgMuted
    }
}