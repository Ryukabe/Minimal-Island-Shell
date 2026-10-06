// pages/services/ServicesSettings.qml — Services. Polling sliders are greyed placeholders until the
// services read ShellState values; the two dropdowns work on the page for now.
import QtQuick
import QtQuick.Layouts
import "../../components"
import "../../../services"
import "../../../styles"

PageScroll {
    id: root

    property string lyricsBackend: "Auto"
    property string defaultPlayer: "Spotify"

    SectionLabel { text: "Update intervals" }

    GroupCard {
        SliderRow {
            label: "Media position"
            description: "How often the playback position updates"
            from: 100; to: 2000; stepSize: 100
            value: 500
            unit: " ms"
            placeholder: true
        }

        SliderRow {
            label: "System stats"
            description: "CPU, memory and GPU refresh interval"
            from: 1; to: 10; stepSize: 1
            value: 1
            unit: " s"
            placeholder: true
        }

        SliderRow {
            label: "Wi-Fi rescan"
            description: "How often available networks are rescanned"
            from: 5; to: 60; stepSize: 5
            value: 15
            unit: " s"
            placeholder: true
            showDivider: false
        }
    }

    SectionLabel { text: "Media and lyrics" }

    GroupCard {
        DropdownRow {
            label: "Lyrics backend"
            options: ["Auto", "LRCLIB", "Local files"]
            selectedValue: root.lyricsBackend
            onOptionSelected: (value) => root.lyricsBackend = value
        }

        DropdownRow {
            label: "Default player"
            options: ["Spotify", "Firefox", "mpv", "Any"]
            selectedValue: root.defaultPlayer
            onOptionSelected: (value) => root.defaultPlayer = value
            showDivider: false
        }
    }
}