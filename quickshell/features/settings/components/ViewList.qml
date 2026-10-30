// components/ViewList.qml — card listing the current menu's sub-pages (icon, title, subtitle, chevron).
// Used by LandingPage, and by any page that shows its own options above its sub-pages (Bar).
// `excludeIds` hides sub-pages a page already reaches another way (the Bar page hides the ones its
// item cards open).
pragma ComponentBehavior: Bound

import QtQuick
import "../core"

GroupCard {
    id: root

    property var excludeIds: []

    readonly property var shownViews: {
        const all = SettingsNav.menu ? SettingsNav.menu.views : []
        return all.filter(v => root.excludeIds.indexOf(v.id) < 0
                            && SettingsRegistry.isViewVisible(v))
    }

    Repeater {
        model: root.shownViews

        delegate: LandingRow {
            required property var modelData
            required property int index

            icon: modelData.icon
            title: modelData.title
            subtitle: modelData.subtitle
            placeholder: modelData.placeholder === true
            showDivider: index < root.shownViews.length - 1
            onClicked: SettingsNav.openView(SettingsNav.menuId, modelData.id)
        }
    }
}
