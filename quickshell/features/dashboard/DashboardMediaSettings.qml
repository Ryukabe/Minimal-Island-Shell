// Dashboard > Media.
import QtQuick
import "../settings/components"
import "."
import "../../core/shell"
import "../../core/styles"

PageScroll {
    id: root

    SectionLabel { text: "CD" }

    GroupCard {
        ToggleRow {
            label: "Spinning disc"
            description: "The CD turns while a track is playing"
            checked: ShellState.dashboardCdSpin
            onToggled: ShellState.dashboardCdSpin = !ShellState.dashboardCdSpin
        }

        Reveal {
            shown: ShellState.dashboardCdSpin

            SliderRow {
                label: "Rotation time"
                description: "Seconds for one full turn"
                from: 2
                to: 20
                stepSize: 1
                value: ShellState.dashboardCdSpinSeconds
                unit: "s"
                onMoved: (v) => ShellState.dashboardCdSpinSeconds = v
            }
        }

        ToggleRow {
            label: "Blurred cover background"
            description: "The album art, blurred, behind the card"
            checked: ShellState.dashboardMediaBlurBackground
            onToggled: ShellState.dashboardMediaBlurBackground = !ShellState.dashboardMediaBlurBackground
        }
    }

    SectionLabel { text: "Details" }

    GroupCard {
        ToggleRow {
            label: "Playback buttons"
            description: "Previous, play / pause and next"
            checked: ShellState.dashboardMediaShowControls
            onToggled: ShellState.dashboardMediaShowControls = !ShellState.dashboardMediaShowControls
        }

        ToggleRow {
            label: "Artist name"
            checked: ShellState.dashboardMediaShowArtist
            onToggled: ShellState.dashboardMediaShowArtist = !ShellState.dashboardMediaShowArtist
        }
    }
}