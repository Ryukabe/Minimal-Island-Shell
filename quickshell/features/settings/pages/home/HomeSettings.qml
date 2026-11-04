// pages/home/HomeSettings.qml — the Home page: quick settings and quick links.
// The quick settings are second controls for options that live on other pages; they use the same
// labels and the same ShellState properties, so changing one changes the other.
// The links are built from SettingsRegistry, so a title or icon change there shows up here too.
pragma ComponentBehavior: Bound

import QtQuick
import "../../components"
import "../../core"
import "../../../../core/shell"

PageScroll {
    id: root

    readonly property string barStyle: ShellState.islandNotchMode ? "Notch" : "Island"

    readonly property var quickIds: ["appearance", "network", "display", "soundmedia", "keybinds", "about"]
    readonly property var quickMenus: root.quickIds
        .map(id => SettingsRegistry.findMenu(id))
        .filter(m => m !== null)

    SectionLabel { text: "Quick settings" }

    GroupCard {
        SegmentRow {
            label: "Bar style"
            description: root.barStyle === "Notch"
                ? "Attached to the top edge like a display notch"
                : "A floating island with a gap above it"
            options: ["Island", "Notch"]
            selectedValue: root.barStyle
            onOptionSelected: (name) => ShellState.islandNotchMode = (name === "Notch")
        }

        ToggleRow {
            label: "Always visible"
            description: "Off: the island slides away while it is idle and windows get the space back"
            checked: ShellState.islandAlwaysVisible
            onToggled: (val) => ShellState.islandAlwaysVisible = val
            showDivider: false
        }
    }

    SectionLabel { text: "Quick links" }

    GroupCard {
        Repeater {
            model: root.quickMenus

            delegate: LandingRow {
                required property var modelData
                required property int index

                icon: modelData.icon
                title: modelData.title
                subtitle: modelData.subtitle
                showDivider: index < root.quickMenus.length - 1
                onClicked: SettingsNav.openMenu(modelData.id)
            }
        }
    }
}