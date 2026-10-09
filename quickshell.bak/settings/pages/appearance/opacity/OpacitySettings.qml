// pages/appearance/opacity/OpacitySettings.qml — Appearance > Opacity.
// Mica transparency and the island's drop shadow. Opacity and shadow values are 0-1 numbers on
// Colors, shown here as percentages so the sliders need no decimals.
import QtQuick
import QtQuick.Layouts
import "../../../components"
import "../../../../services"
import "../../../../styles"

PageScroll {
    id: root

    SectionLabel { text: "Mica" }

    GroupCard {
        SliderRow {
            label: "Main opacity"
            description: "Window and panel backgrounds"
            from: 0; to: 100; stepSize: 1
            value: Math.round(Colors.micaAlpha * 100)
            unit: " %"
            onMoved: (val) => Colors.micaAlpha = val / 100
        }

        SliderRow {
            label: "Secondary opacity"
            description: "Cards and raised surfaces"
            from: 0; to: 100; stepSize: 1
            value: Math.round(Colors.micaBeta * 100)
            unit: " %"
            onMoved: (val) => Colors.micaBeta = val / 100
            showDivider: false
        }
    }

    SectionLabel { text: "Shadow" }

    GroupCard {
        ToggleRow {
            label: "Enable shadow"
            description: "Soft shadow around the island"
            checked: Colors.islandShadowEnabled
            onToggled: (val) => Colors.islandShadowEnabled = val
        }

        ColorRow {
            label: "Shadow color"
            value: Colors.shadowColor
            enabled: Colors.islandShadowEnabled
            opacity: Colors.islandShadowEnabled ? 1.0 : 0.4
            onCommitted: (hex) => Colors.shadowColor = hex
        }

        SliderRow {
            label: "Shadow softness"
            from: 0; to: 100; stepSize: 1
            value: Math.round(Colors.shadowBlur * 100)
            unit: " %"
            enabled: Colors.islandShadowEnabled
            onMoved: (val) => Colors.shadowBlur = val / 100
        }

        SliderRow {
            label: "Shadow spread"
            description: "How far the shadow reaches past the island"
            from: 0; to: 100; stepSize: 5
            value: Math.round((Colors.shadowScale - 1) * 100)
            unit: " %"
            enabled: Colors.islandShadowEnabled
            onMoved: (val) => Colors.shadowScale = 1 + val / 100
            showDivider: false
        }
    }
}
