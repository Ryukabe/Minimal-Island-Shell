// pages/trackpadmouse/TrackpadMouseSettings.qml — Trackpad & Mouse.
// Every control reads from and writes to InputSettingsService.
import QtQuick
import QtQuick.Layouts
import "../../components"
import "../../../services"
import "../../../styles"

PageScroll {
    id: root

    SectionLabel { text: "Pointer" }

    GroupCard {
        SliderRow {
            label: "Movement sensitivity"
            description: "Applies to every pointer device. 0 is the default"
            from: -1.0; to: 1.0; stepSize: 0.05
            value: InputSettingsService.sensitivity
            onMoved: (val) => InputSettingsService.setSensitivity(val)
            showDivider: false
        }
    }

    SectionLabel { text: "Mouse" }

    GroupCard {
        SliderRow {
            label: "Scroll speed"
            from: 0.1; to: 5.0; stepSize: 0.1
            value: InputSettingsService.scrollFactor
            onMoved: (val) => InputSettingsService.setScrollFactor(val)
            showDivider: false
        }
    }

    SectionLabel { text: "Touchpad" }

    GroupCard {
        ToggleRow {
            label: "Tap to click"
            checked: InputSettingsService.touchpadTapToClick
            onToggled: (val) => InputSettingsService.setTouchpadTapToClick(val)
        }

        ToggleRow {
            label: "Natural scrolling"
            description: "Content follows your fingers"
            checked: InputSettingsService.touchpadNaturalScroll
            onToggled: (val) => InputSettingsService.setTouchpadNaturalScroll(val)
        }

        SliderRow {
            label: "Scroll speed"
            from: 0.1; to: 5.0; stepSize: 0.1
            value: InputSettingsService.touchpadScrollFactor
            onMoved: (val) => InputSettingsService.setTouchpadScrollFactor(val)
        }

        SliderRow {
            label: "Movement sensitivity"
            description: "Overrides the global sensitivity for the touchpad"
            from: -1.0; to: 1.0; stepSize: 0.05
            value: InputSettingsService.touchpadSensitivity
            onMoved: (val) => InputSettingsService.setTouchpadSensitivity(val)
            showDivider: false
        }
    }
}