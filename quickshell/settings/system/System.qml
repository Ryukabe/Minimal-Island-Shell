// settings/system/System.qml
import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../../services"
import "../common"

Item {
    id: root

    property bool peaceMode: false
    property bool showNotificationPreviews: true
    property bool tapToClick: true
    property string newAppCommand: ""

    SettingsScrollView {
        SettingsHeader {
            icon: "tune"
            title: "System"
            subtitle: "Display, notifications, mouse, touchpad, and startup applications."
        }

        // Group 1: Display & Resolution
        SettingsGroup {
            title: "Display & Resolution"
            description: "Monitor settings, refresh rates, resolution, and transparency"
            icon: "desktop_windows"
            expanded: true

            Repeater {
                model: MonitorSettingsService.monitors
                delegate: ColumnLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: Dimens.spacingSmall

                    SettingsSectionLabel { label: parent.modelData.description }

                    SettingsDropdownRow {
                        id: resolutionDropdown
                        label: "Resolution & Refresh Rate"
                        options: parent.modelData.availableModes
                        selectedValue: parent.modelData.width + "x" + parent.modelData.height + "@" + Math.round(parent.modelData.refreshRate)
                        onToggled: resolutionDropdown.isOpen = !resolutionDropdown.isOpen
                        onOptionSelected: (value) => {
                            MonitorSettingsService.setMode(parent.modelData.name, value)
                            resolutionDropdown.isOpen = false
                        }
                    }

                    SettingsSliderRow {
                        label: "Scale"
                        from: 0.5; to: 3.0; stepSize: 0.05
                        value: parent.modelData.scale
                        decimals: 2
                        onMoved: (val) => MonitorSettingsService.setScale(parent.modelData.name, val)
                    }
                }
            }

            SettingsToggleRow {
                label: "Reduce Transparency"
                checked: Colors.reduceTransparency
                showDivider: false
                onToggled: (val) => {
                    Colors.reduceTransparency = val
                    HyprlandDecorationService.setBlurEnabled(!val)
                }
            }
        }

        // Group 2: Notifications & Peace Mode
        SettingsGroup {
            title: "Notifications & Peace Mode"
            description: "Alert preferences, Do Not Disturb, and preview visibility"
            icon: "notifications"
            expanded: true

            SettingsToggleRow {
                label: "Peace Mode (Do Not Disturb)"
                checked: root.peaceMode
                showDivider: true
                onToggled: (val) => root.peaceMode = val
            }

            SettingsToggleRow {
                label: "Show Notification Previews"
                checked: root.showNotificationPreviews
                showDivider: false
                onToggled: (val) => root.showNotificationPreviews = val
            }
        }

        // Group 3: Mouse & Touchpad
        SettingsGroup {
            title: "Mouse & Touchpad"
            description: "Pointer sensitivity, scroll behavior, and gesture settings"
            icon: "mouse"
            expanded: false

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
                checked: root.tapToClick
                showDivider: true
                onToggled: (val) => root.tapToClick = val
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

        // Group 4: Power Profile
        SettingsGroup {
            title: "Power Profile"
            description: "System performance and battery conservation profiles"
            icon: "bolt"
            expanded: false

            SettingsSegmentedRow {
                label: "Power Profile"
                options: PowerProfileService.profiles.map(p => p.name)
                selectedValue: {
                    let match = PowerProfileService.profiles.find(p => p.id === PowerProfileService.activeProfile)
                    return match ? match.name : ""
                }
                onOptionSelected: (name) => {
                    let match = PowerProfileService.profiles.find(p => p.name === name)
                    if (match) PowerProfileService.setProfile(match.id)
                }
            }
        }

        // Group 5: Startup Applications
        SettingsGroup {
            title: "Startup Applications"
            description: "Manage applications that launch automatically at login"
            icon: "rocket_launch"
            expanded: false

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 36
                radius: Dimens.radiusSmall
                color: Colors.subBgMica
                border.color: Colors.border
                border.width: 1

                TextInput {
                    id: newAppInput
                    anchors.fill: parent
                    anchors.margins: 8
                    color: Colors.fg
                    font.family: Fonts.mono
                    font.pixelSize: Dimens.fontSizeSm
                    onTextChanged: root.newAppCommand = text
                    onAccepted: {
                        if (root.newAppCommand.trim().length > 0) {
                            AutostartService.addApp(root.newAppCommand.trim())
                            text = ""
                        }
                    }
                    Text {
                        visible: parent.text.length === 0
                        text: "Command to launch, e.g. spotify"
                        color: Colors.subtext
                        font: parent.font
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.bottomMargin: Dimens.spacingSmall

                Item { Layout.fillWidth: true }

                SettingsButton {
                    primary: true
                    text: "Add"
                    enabled: root.newAppCommand.trim().length > 0
                    onClicked: {
                        AutostartService.addApp(root.newAppCommand.trim())
                        newAppInput.text = ""
                    }
                }
            }

            SettingsSectionLabel { label: "Starting Apps" }
            
            Repeater {
                model: AutostartService.apps
                delegate: RowLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.bottomMargin: Dimens.spacingSmall

                    Text {
                        text: modelData.command
                        color: Colors.fg
                        font.family: Fonts.mono
                        font.pixelSize: Dimens.fontSizeSm
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    SettingsButton {
                        text: "Remove"
                        onClicked: AutostartService.removeApp(modelData.command)
                    }
                }
            }
        }
    }
}