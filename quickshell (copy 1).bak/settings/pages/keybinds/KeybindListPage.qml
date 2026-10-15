// pages/keybinds/KeybindListPage.qml — the shortcuts of one category. The category comes from the
// registry view that opened this page (its `category` field), so one file serves every sub-page.
import QtQuick
import QtQuick.Layouts
import "../../components"
import "../../core"
import "../../../services"
import "../../../styles"

PageScroll {
    id: root

    readonly property string category: SettingsNav.view ? (SettingsNav.view.category || "") : ""
    readonly property var binds: HyprlandKeybindsService.binds.filter(b => b.category === root.category)

    GroupCard {
        InfoRow {
            visible: root.binds.length === 0
            label: "No shortcuts in this category"
            showDivider: false
        }

        Repeater {
            model: root.binds

            delegate: KeybindRow {
                required property var modelData
                required property int index

                label: HyprlandKeybindsService.friendlyName(modelData)
                isAutoLabel: HyprlandKeybindsService.isAutoNamed(modelData)
                actionPreview: modelData.actionPreview
                keyDisplay: modelData.keyDisplay
                isCustom: modelData.isCustom
                isMultiline: modelData.isMultiline
                hasConflict: (HyprlandKeybindsService.conflictCounts[modelData.keyDisplay] || 0) > 1
                showDivider: index < root.binds.length - 1

                onRebindRequested: (newKey) => HyprlandKeybindsService.rebindKey(modelData.id, newKey)
                onRemoveRequested: HyprlandKeybindsService.removeCustomBind(modelData.id)
                onFlattenRequested: HyprlandKeybindsService.flattenBind(modelData.id)
                onRenameRequested: (newLabel) => HyprlandKeybindsService.setLabel(modelData.actionKey, newLabel)
            }
        }
    }
}