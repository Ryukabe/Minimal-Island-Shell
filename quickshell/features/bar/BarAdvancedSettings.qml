// features/bar/BarAdvancedSettings.qml — Bar > Advanced: the smallest size the island takes while a page is open.
// No Reset row: the Bar page resets the whole menu. Magnify on hover is on the Behavior page.
import QtQuick
import QtQuick.Layouts
import "../settings/components"
import "../../core/shell"
import "../../core/styles"

PageScroll {
    id: root

    SectionLabel { text: "Expanded size" }

    GroupCard {
        SliderRow {
            label: "Minimum expanded height"
            description: "The island is never shorter than this while a page is open"
            from: 80; to: 300; stepSize: 5
            value: ShellState.islandExpandedHeight
            unit: " px"
            onMoved: (val) => ShellState.islandExpandedHeight = val
        }

        SliderRow {
            label: "Minimum expanded width"
            description: "The island is never narrower than this while a page is open"
            from: 300; to: 900; stepSize: 10
            value: ShellState.islandMinExpandedWidth
            unit: " px"
            onMoved: (val) => ShellState.islandMinExpandedWidth = val
            showDivider: false
        }
    }
}