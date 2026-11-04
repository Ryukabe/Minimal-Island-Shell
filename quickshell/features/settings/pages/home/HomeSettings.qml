// pages/home/HomeSettings.qml — the Home page: quick links to the settings people open most.
// Rows are built from SettingsRegistry, so a title or icon change there shows up here too.
pragma ComponentBehavior: Bound

import QtQuick
import "../../components"
import "../../core"

PageScroll {
    id: root

    readonly property var quickIds: ["appearance", "network", "display", "soundmedia", "keybinds", "about"]
    readonly property var quickMenus: root.quickIds
        .map(id => SettingsRegistry.findMenu(id))
        .filter(m => m !== null)

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