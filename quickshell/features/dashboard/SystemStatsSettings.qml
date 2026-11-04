// Dashboard > System stats.
import QtQuick
import "../settings/components"
import "."
import "../../core/shell"
import "../../core/styles"

PageScroll {
    id: root

    SectionLabel { text: "Rows" }

    GroupCard {
        ToggleRow {
            label: "CPU"
            checked: ShellState.dashboardStatCpu
            onToggled: ShellState.dashboardStatCpu = !ShellState.dashboardStatCpu
        }

        ToggleRow {
            label: "GPU"
            description: "NVIDIA (nvidia-smi) or AMD; other GPUs show as not detected"
            checked: ShellState.dashboardStatGpu
            onToggled: ShellState.dashboardStatGpu = !ShellState.dashboardStatGpu
        }

        ToggleRow {
            label: "Memory"
            checked: ShellState.dashboardStatMemory
            onToggled: ShellState.dashboardStatMemory = !ShellState.dashboardStatMemory
        }

        ToggleRow {
            label: "Network"
            checked: ShellState.dashboardStatNetwork
            onToggled: ShellState.dashboardStatNetwork = !ShellState.dashboardStatNetwork
        }

        ToggleRow {
            label: "Battery"
            description: "Only shown when a battery is found"
            checked: ShellState.dashboardStatBattery
            onToggled: ShellState.dashboardStatBattery = !ShellState.dashboardStatBattery
        }

        ToggleRow {
            label: "Temperature"
            checked: ShellState.dashboardStatTemperature
            onToggled: ShellState.dashboardStatTemperature = !ShellState.dashboardStatTemperature
        }
    }

    SectionLabel { text: "Graphs and updates" }

    GroupCard {
        ToggleRow {
            label: "Mini graphs"
            checked: ShellState.dashboardStatsShowGraphs
            onToggled: ShellState.dashboardStatsShowGraphs = !ShellState.dashboardStatsShowGraphs
        }

        Reveal {
            shown: ShellState.dashboardStatsShowGraphs

            SliderRow {
                label: "History length"
                description: "How many samples each graph keeps"
                from: 20
                to: 120
                stepSize: 10
                value: ShellState.dashboardStatsGraphSamples
                unit: ""
                onMoved: (v) => ShellState.dashboardStatsGraphSamples = v
            }
        }

        SliderRow {
            label: "Update every"
            description: "Stats are only read while the Dashboard is open"
            from: 1
            to: 5
            stepSize: 1
            value: ShellState.dashboardStatsIntervalSec
            unit: "s"
            onMoved: (v) => ShellState.dashboardStatsIntervalSec = v
        }

        InfoRow {
            label: "Temperature unit"
            value: ShellState.systemTempUnit
            showDivider: false
        }
    }
}