// settings/trackpadmouse/TrackpadMouse.qml — was System.qml's "Mouse & Touchpad" group
import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../../services"
import "../common"

Item {
    id: root

    SettingsScrollView {
        SettingsGroup {
            title: "Mouse & Touchpad"
            description: "Pointer sensitivity, scroll behavior, and gesture settings"
            icon: "mouse"
            expanded: true

            SettingsSliderRow {
                label: "Movement Sensitivity (Global)"
                from: -1.0; to: 1.0; stepSize: 0.05
                value: InputSettingsService.sensitivity
                decimals: 2
                onMoved: (val) => InputSettingsService.setSensitivity(val)
            }

            SettingsSliderRow {
                label: "Scroll Speed (Mouse)"
                from: 0.1; to: 5.0; stepSize: 0.1
                value: InputSettingsService.scrollFactor
                decimals: 1
                onMoved: (val) => InputSettingsService.setScrollFactor(val)
            }

            SettingsToggleRow {
                label: "Tap to Click"
                checked: InputSettingsService.touchpadTapToClick
                showDivider: true
                onToggled: (val) => InputSettingsService.setTouchpadTapToClick(val)
            }

            SettingsToggleRow {
                label: "Natural Scrolling (Touchpad)"
                checked: InputSettingsService.touchpadNaturalScroll
                showDivider: true
                onToggled: (val) => InputSettingsService.setTouchpadNaturalScroll(val)
            }

            SettingsSliderRow {
                label: "Scroll Speed (Touchpad)"
                from: 0.1; to: 5.0; stepSize: 0.1
                value: InputSettingsService.touchpadScrollFactor
                decimals: 1
                onMoved: (val) => InputSettingsService.setTouchpadScrollFactor(val)
            }

            SettingsSliderRow {
                label: "Movement Sensitivity (Touchpad Override)"
                from: -1.0; to: 1.0; stepSize: 0.05
                value: InputSettingsService.touchpadSensitivity
                decimals: 2
                onMoved: (val) => InputSettingsService.setTouchpadSensitivity(val)
            }
        }
    }
}