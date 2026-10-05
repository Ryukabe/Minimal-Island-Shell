// components/LandingPage.qml — list of a menu's views (Caelestia-style). Driven entirely by SettingsRegistry.
import QtQuick
import QtQuick.Layouts
import "../core"

PageScroll {
    id: root

    GroupCard {
        Repeater {
            model: SettingsNav.menu ? SettingsNav.menu.views : []

            delegate: LandingRow {
                required property var modelData
                required property int index

                icon: modelData.icon
                title: modelData.title
                subtitle: modelData.subtitle
                placeholder: modelData.placeholder === true
                showDivider: index < SettingsNav.menu.views.length - 1
                onClicked: SettingsNav.openView(SettingsNav.menuId, modelData.id)
            }
        }
    }
}
