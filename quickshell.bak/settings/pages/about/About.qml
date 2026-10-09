// pages/about/About.qml — About: Hermit-dots card, device tiles, device info, software, power, updates, project.
// Leaf page, no qmldir. The two services are created once in SettingsApp.qml and handed in below.
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../../components"
import "../../core"
import "../../../services"
import "../../../styles"

PageScroll {
    id: root

    // Injected by SettingsApp when the page loads. Empty objects keep every binding quiet until then.
    property var updateService: ({})
    property var systemInfo: ({})

    // Refresh uptime / memory / disk each time the page opens (the old page only read them once at startup).
    onSystemInfoChanged: {
        if (root.systemInfo.refresh) root.systemInfo.refresh()
    }

    function _v(x) { return x ? String(x) : "—" }
    function _fmt(d) { return root.updateService.formatTime ? root.updateService.formatTime(d) : "" }
    function _part(s, i) {
        const p = String(s || "").split(" / ")
        return p.length > i ? p[i] : ""
    }

    readonly property string deviceInfoText: [
        "Device name: " + root._v(root.systemInfo.hostname),
        "Processor: " + root._v(root.systemInfo.cpuName),
        "Graphics: " + root._v(root.systemInfo.gpuName),
        "Operating system: " + root._v(root.systemInfo.osName),
        "Kernel: " + root._v(root.systemInfo.kernel),
        "Uptime: " + root._v(root.systemInfo.uptime),
        "Memory: " + root._v(root.systemInfo.memoryUsed),
        "Storage: " + root._v(root.systemInfo.diskUsed)
    ].join("\n")

    property bool _copied: false
    property bool _confirmReset: false

    // Needs wl-clipboard (wl-copy). If it's missing the button just does nothing.
    Process {
        id: copyProc
        command: ["wl-copy", "--", root.deviceInfoText]
    }

    Timer {
        id: copiedReset
        interval: 1500
        onTriggered: root._copied = false
    }

    Timer {
        id: resetConfirmTimer
        interval: 3000
        onTriggered: root._confirmReset = false
    }

    // ================= Hermit-dots card =================
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: heroColumn.implicitHeight + Dimens.paddingLarge * 2
        radius: Dimens.settingsContainerRadius
        color: Colors.subBgMica

        ColumnLayout {
            id: heroColumn
            anchors.centerIn: parent
            width: parent.width - Dimens.paddingLarge * 2
            spacing: Dimens.spacingSmall

            // Logo: the hermit spiral only, no background. File sits next to this page.
            Image {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 72
                Layout.preferredHeight: 77
                source: Qt.resolvedUrl("hermit-logo.svg")
                sourceSize: Qt.size(216, 232)
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: SettingsRegistry.projectName
                color: Colors.fg
                font.family: Fonts.display
                font.pixelSize: 26
                font.weight: Font.Bold
            }

            Item {
                Layout.alignment: Qt.AlignHCenter
                implicitWidth: versionText.implicitWidth + Dimens.paddingMedium * 2
                implicitHeight: versionText.implicitHeight + Dimens.paddingSmall

                Rectangle {
                    anchors.fill: parent
                    radius: height / 2
                    color: Colors.accent
                    opacity: 0.18
                }

                Text {
                    id: versionText
                    anchors.centerIn: parent
                    text: SettingsRegistry.projectVersion
                    color: Colors.accent
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeSm
                    font.weight: Font.DemiBold
                }
            }
        }
    }

    // ================= Windows-style summary tiles =================
    RowLayout {
        Layout.fillWidth: true
        spacing: Dimens.spacingSmall
        uniformCellSizes: true

        InfoTile {
            icon: "memory"
            label: "Processor"
            value: root._v(root.systemInfo.cpuName)
        }

        InfoTile {
            icon: "developer_board"
            label: "Memory"
            value: root._v(root._part(root.systemInfo.memoryUsed, 1))
            caption: root._part(root.systemInfo.memoryUsed, 0) !== "" ? root._part(root.systemInfo.memoryUsed, 0) + " in use" : ""
        }

        InfoTile {
            icon: "monitor"
            label: "Graphics"
            value: root._v(root.systemInfo.gpuName)
        }

        InfoTile {
            icon: "storage"
            label: "Storage"
            value: root._v(root._part(root.systemInfo.diskUsed, 1))
            caption: root._part(root.systemInfo.diskUsed, 0) !== "" ? root._part(root.systemInfo.diskUsed, 0) + " used" : ""
        }
    }

    // ================= Device info =================
    RowLayout {
        Layout.fillWidth: true
        spacing: Dimens.spacingSmall

        SectionLabel { text: "Device info" }

        ActionButton {
            text: root._copied ? "Copied" : "Copy"
            onClicked: {
                copyProc.running = true
                root._copied = true
                copiedReset.restart()
            }
        }
    }

    GroupCard {
        InfoRow { label: "Device name"; value: root._v(root.systemInfo.hostname) }
        InfoRow { label: "Processor"; value: root._v(root.systemInfo.cpuName) }
        InfoRow { label: "Graphics"; value: root._v(root.systemInfo.gpuName) }
        InfoRow { label: "Operating system"; value: root._v(root.systemInfo.osName) }
        InfoRow { label: "Kernel"; value: root._v(root.systemInfo.kernel) }
        InfoRow { label: "Uptime"; value: root._v(root.systemInfo.uptime) }
        InfoRow { label: "Memory"; value: root._v(root.systemInfo.memoryUsed) }
        InfoRow { label: "Storage"; value: root._v(root.systemInfo.diskUsed); showDivider: false }
    }

    // ================= Software =================
    SectionLabel { text: "Software" }

    GroupCard {
        InfoRow { label: "Shell"; value: SettingsRegistry.projectName + " " + SettingsRegistry.projectVersion }
        InfoRow { label: "Quickshell"; value: root._v(root.systemInfo.quickshellVersion) }
        InfoRow { label: "Qt"; value: Qt.version }
        InfoRow { label: "Hyprland"; value: root._v(root.systemInfo.hyprlandVersion); showDivider: false }
    }

    // ================= Power =================
    SectionLabel { text: "Power" }

    GroupCard {
        SegmentRow {
            label: "Power profile"
            options: PowerProfileService.profiles.map(p => p.name)
            selectedValue: {
                let match = PowerProfileService.profiles.find(p => p.id === PowerProfileService.activeProfile)
                return match ? match.name : ""
            }
            onOptionSelected: (name) => {
                let match = PowerProfileService.profiles.find(p => p.name === name)
                if (match) PowerProfileService.setProfile(match.id)
            }
            showDivider: false
        }
    }

    // ================= Updates =================
    SectionLabel { text: "Updates" }

    UpdateCard {
        icon: "system_update"
        title: "System Packages"
        statusText: !root.updateService.systemChecked ? "Not checked yet"
            : root.updateService.systemUpdateCount === 0 ? "Up to date"
            : root.updateService.systemUpdateCount + " package(s) can be updated"
        checking: !!root.updateService.systemChecking
        actionEnabled: !!(root.updateService.systemChecked && root.updateService.systemUpdateCount > 0)
        actionText: "Update Now"
        lastCheckedText: root._fmt(root.updateService.systemLastChecked)
        lastUpdatedText: root._fmt(root.updateService.systemLastUpdated)
        noteText: root.updateService.systemJustUpdated ? "Update ran — some packages may need a reboot to fully apply." : ""
        onCheckRequested: root.updateService.checkSystemUpdates()
        onActionRequested: root.updateService.runSystemUpdate()
    }

    UpdateCard {
        icon: "auto_awesome"
        title: "Hermit-dots"
        statusText: root.updateService.shellError !== "" ? "Couldn't check for updates"
            : !root.updateService.shellChecked ? "Not checked yet"
            : !root.updateService.shellUpdateAvailable ? "Up to date"
            : root.updateService.shellCommitsBehind + " commit(s) behind"
        checking: !!root.updateService.shellChecking
        actionEnabled: !!(root.updateService.shellChecked && root.updateService.shellUpdateAvailable)
        actionText: "Update Shell"
        busy: !!root.updateService.shellUpdating
        lastCheckedText: root._fmt(root.updateService.shellLastChecked)
        lastUpdatedText: root._fmt(root.updateService.shellLastUpdated)
        noteText: root.updateService.shellError !== "" ? root.updateService.shellError
            : root.updateService.shellJustUpdated ? "Updated — restart the shell (pkill qs && qs) to apply." : ""
        onCheckRequested: root.updateService.checkShellUpdate()
        onActionRequested: root.updateService.runShellUpdate()
    }

    // ================= Project =================
    SectionLabel { text: "Project" }

    GroupCard {
        InfoRow { label: "Repository"; value: "Ryukabe/hermit-dots"; link: SettingsRegistry.projectRepo }
        InfoRow { label: "License"; value: "MIT © Ryukabe" }
        InfoRow { label: "Island concept"; value: "SaneAspect"; showDivider: false }
    }

    // ================= Reset =================
    ActionButton {
        Layout.fillWidth: true
        Layout.topMargin: Dimens.spacingMedium
        text: root._confirmReset ? "Click again to reset everything" : "Reset all to defaults"
        onClicked: {
            if (root._confirmReset) {
                SettingsStore.resetAllDefaults()
                root._confirmReset = false
                resetConfirmTimer.stop()
            } else {
                root._confirmReset = true
                resetConfirmTimer.restart()
            }
        }
    }
}
