// components/ViewList.qml — card listing the current menu's sub-pages (icon, title, subtitle, chevron).
// Used by LandingPage, and by any page that shows its own options above its sub-pages (Bar).
import QtQuick
import QtQuick.Layouts
import "../core"

GroupCard {
    id: root

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