// settings/system/System.qml — consolidated Display, Notifications, and
// Mouse & Touchpad settings under one "System" page.
// NOTE: this pass adds UI-only rows/sections — new properties are plain
// local state (matching the existing peaceMode/naturalScrolling pattern),
// not yet wired to any real backend service. Wire each to its actual
// service once the backend exists, the same way ControlCenter's tiles
// were only wired after their services were confirmed real.
import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../common"

Item {
    id: root

    property bool peaceMode: false
    property bool naturalScrolling: true

    // ---- new UI-only state ----
    property string displayScale: "100%"
    property bool reduceTransparency: false
    property bool autoHideBar: false

    property bool showNotificationPreviews: true
    property string notificationPosition: "Top"

    property bool tapToClick: true
    property real cursorSize: 24
    property real scrollSpeed: 50

    property bool autoStartOnBoot: true
    property string powerProfile: "Balanced"

    SettingsScrollView {
        SettingsHeader {
            icon: "settings"
            title: "System"
            subtitle: "Display, notifications, and mouse behavior."
        }

        SettingsSectionLabel { label: "Display" }

        SettingsRow {
            label: "Display Scale Factor"
            value: root.displayScale
            showChevron: false
            showDivider: true
        }

        SettingsToggleRow {
            label: "Reduce Transparency"
            checked: root.reduceTransparency
            showDivider: true
            onToggled: (val) => root.reduceTransparency = val
        }

        SettingsToggleRow {
            label: "Auto-hide Bar"
            checked: root.autoHideBar
            showDivider: false
            onToggled: (val) => root.autoHideBar = val
        }

        SettingsSectionLabel { label: "Notifications" }

        SettingsToggleRow {
            label: "Peace Mode (Do Not Disturb)"
            checked: root.peaceMode
            showDivider: true
            onToggled: (val) => root.peaceMode = val
        }

        SettingsToggleRow {
            label: "Show Notification Previews"
            checked: root.showNotificationPreviews
            showDivider: true
            onToggled: (val) => root.showNotificationPreviews = val
        }

        SettingsSegmentedRow {
            label: "Notification Position"
            options: ["Top", "Top Right", "Bottom Right"]
            selectedValue: root.notificationPosition
            onOptionSelected: (value) => root.notificationPosition = value
        }

        SettingsSectionLabel { label: "Mouse & Touchpad" }

        SettingsToggleRow {
            label: "Natural Scrolling"
            checked: root.naturalScrolling
            showDivider: true
            onToggled: (val) => root.naturalScrolling = val
        }

        SettingsToggleRow {
            label: "Tap to Click"
            checked: root.tapToClick
            showDivider: true
            onToggled: (val) => root.tapToClick = val
        }

        SettingsSliderRow {
            label: "Cursor Size"
            from: 16; to: 48; stepSize: 2
            value: root.cursorSize
            unit: " px"
            onMoved: (val) => root.cursorSize = val
        }

        SettingsSliderRow {
            label: "Scroll Speed"
            from: 0; to: 100; stepSize: 5
            value: root.scrollSpeed
            unit: "%"
            onMoved: (val) => root.scrollSpeed = val
        }

        SettingsSectionLabel { label: "Power" }

        SettingsSegmentedRow {
            label: "Power Profile"
            options: ["Power Saver", "Balanced", "Performance"]
            selectedValue: root.powerProfile
            onOptionSelected: (value) => root.powerProfile = value
        }

        SettingsToggleRow {
            label: "Start Shell on Boot"
            checked: root.autoStartOnBoot
            showDivider: false
            onToggled: (val) => root.autoStartOnBoot = val
        }
    }
}