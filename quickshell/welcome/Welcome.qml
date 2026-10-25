// features/welcome/Welcome.qml — one-time Hermit welcome window (centered floating window).
// Shown automatically on first run; reopen with: qs ipc call welcome show
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../settings/components"
import "../settings/core"
import "../theme"
import "../../core/shell"
import "../../core/styles"

Scope {
    id: root

    readonly property string setupName: "Hermit"
    readonly property string repoName: "hermit-dots"
    readonly property string repoUrl: "https://github.com/Ryukabe/hermit-dots"
    readonly property string switchScript: "$HOME/.config/hypr/scripts/switch-shell.sh"

    // Reading this creates the singleton at shell start, so the first-run check actually runs.
    readonly property bool serviceReady: WelcomeService.ready

    IpcHandler {
        target: "welcome"

        function show(): void { WelcomeService.show() }
        function close(): void { WelcomeService.finish() }
        // Clears the saved flag and shows the screen again (for testing).
        function reset(): void { WelcomeService.reset() }
    }

    // ── System details (read only while the window is open) ───
    QtObject {
        id: sys

        property string distro: "…"
        property string kernel: "…"
        property string host: "…"
        readonly property string desktop: Quickshell.env("XDG_CURRENT_DESKTOP") || "Hyprland"

        property FileView osRelease: FileView {
            path: WelcomeService.open ? "/etc/os-release" : ""
            printErrors: false
            onLoaded: {
                const m = text().match(/^PRETTY_NAME="?([^"\n]*)"?/m)
                if (m) sys.distro = m[1]
            }
        }

        property FileView hostFile: FileView {
            path: WelcomeService.open ? "/etc/hostname" : ""
            printErrors: false
            onLoaded: sys.host = text().trim()
        }

        property Process kernelProc: Process {
            command: ["uname", "-r"]
            running: WelcomeService.open
            stdout: StdioCollector {
                onStreamFinished: sys.kernel = text.trim()
            }
        }
    }

    // ── Shell switching ───────────────────────────────────────
    // The switch script kills Quickshell, so the welcome is marked as seen first and the script is
    // started detached after a short delay (lets the saved flag reach the disk).
    Timer {
        id: switchTimer
        property string shellName: ""
        interval: 300
        onTriggered: Quickshell.execDetached(["sh", "-c", root.switchScript + " " + switchTimer.shellName])
    }

    function switchTo(name) {
        WelcomeService.finish()
        switchTimer.shellName = name
        switchTimer.start()
    }

    // ── Small building blocks ─────────────────────────────────
    component PageHeader: ColumnLayout {
        id: ph
        property string title
        property string subtitle

        Layout.fillWidth: true
        spacing: 0

        Text {
            Layout.fillWidth: true
            text: ph.title
            color: Colors.fg
            font.family: Fonts.display
            font.pixelSize: Dimens.fontSizeXxl
            font.weight: Font.Bold
            wrapMode: Text.WordWrap
        }

        Text {
            Layout.fillWidth: true
            text: ph.subtitle
            color: Colors.subtext
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeMd
            wrapMode: Text.WordWrap
        }
    }

    component Page: Flickable {
        id: pg
        default property alias content: col.data

        contentWidth: width
        contentHeight: col.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: col
            width: pg.width
            spacing: Dimens.spacingLarge
        }
    }

    component Card: Rectangle {
        id: card
        default property alias content: inner.data

        Layout.fillWidth: true
        implicitHeight: inner.implicitHeight + Dimens.paddingLarge * 2
        radius: Dimens.radiusLarge
        color: Colors.elevatedBg

        ColumnLayout {
            id: inner
            anchors.fill: parent
            anchors.margins: Dimens.paddingLarge
            spacing: Dimens.spacingMedium
        }
    }

    component KeyCombo: Row {
        id: kc
        property string combo
        spacing: Dimens.spacingSmall

        Repeater {
            model: kc.combo.split(" + ")

            delegate: Rectangle {
                id: chip
                required property string modelData

                width: keyText.implicitWidth + Dimens.paddingMedium * 2
                height: keyText.implicitHeight + Dimens.paddingSmall
                radius: Dimens.radiusSmall
                color: Colors.mainBgMica
                border.color: Colors.border
                border.width: 1

                Text {
                    id: keyText
                    anchors.centerIn: parent
                    text: chip.modelData
                    color: Colors.fg
                    font.family: Fonts.mono
                    font.pixelSize: Dimens.fontSizeSm
                }
            }
        }
    }

    component ShortcutRow: RowLayout {
        id: sr
        property string label
        property string combo

        Layout.fillWidth: true
        spacing: Dimens.spacingMedium

        Text {
            Layout.fillWidth: true
            text: sr.label
            color: Colors.fg
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeMd
            elide: Text.ElideRight
        }

        KeyCombo { combo: sr.combo }
    }

    // ── Window ────────────────────────────────────────────────
    FloatingWindow {
        id: window
        title: "Welcome to " + root.setupName
        visible: WelcomeService.open
        color: Colors.mainBgMica
        implicitWidth: 900
        implicitHeight: 600
        // Fixed size: Hyprland floats windows that cannot be resized.
        minimumSize: Qt.size(900, 600)
        maximumSize: Qt.size(900, 600)

        onVisibleChanged: {
            if (visible) {
                contentRoot.index = 0
                contentRoot.confirmAgs = false
                focusDelay.start()
            } else {
                // Closed by the compositor, Escape or Get started: remember it was seen.
                WelcomeService.finish()
            }
        }

        Timer {
            id: focusDelay
            interval: 50
            onTriggered: contentRoot.forceActiveFocus()
        }

        Item {
            id: contentRoot
            anchors.fill: parent
            focus: true

            property int index: 0
            // First click on "Switch to AGS" arms the button; the second one switches.
            property bool confirmAgs: false

            readonly property var steps: [
                { icon: "waving_hand", title: "Overview", subtitle: "What Hermit is" },
                { icon: "tune", title: "Quick setup", subtitle: "Look and behaviour" },
                { icon: "swap_horiz", title: "Shells", subtitle: "Quickshell or AGS" },
                { icon: "keyboard", title: "Shortcuts", subtitle: "Keys worth knowing" },
                { icon: "rocket_launch", title: "All set", subtitle: "Get started" }
            ]

            readonly property bool isFirst: index === 0
            readonly property bool isLast: index === steps.length - 1

            function next() {
                if (isLast) WelcomeService.finish()
                else index++
            }

            function back() {
                if (!isFirst) index--
            }

            onIndexChanged: {
                confirmAgs = false
                pageFade.restart()
            }

            NumberAnimation {
                id: pageFade
                target: pages
                property: "opacity"
                from: 0
                to: 1
                duration: ShellState.motionDuration(Motion.fadeMs)
                easing.type: Easing.OutCubic
            }

            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Right || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    contentRoot.next()
                    event.accepted = true
                } else if (event.key === Qt.Key_Left) {
                    contentRoot.back()
                    event.accepted = true
                } else if (event.key === Qt.Key_Escape) {
                    WelcomeService.finish()
                    event.accepted = true
                }
            }

            // Drag the window by its top edge.
            MouseArea {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: Dimens.paddingLarge * 2
                z: 10
                acceptedButtons: Qt.LeftButton
                onPressed: window.startSystemMove()
            }

            RowLayout {
                anchors.fill: parent
                spacing: 0

                // ============ SIDEBAR ============
                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 260
                    color: "transparent"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Dimens.paddingMedium
                        spacing: Dimens.spacingMedium

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Dimens.spacingMedium

                            Image {
                                Layout.preferredWidth: Dimens.fontSizeXxxl
                                Layout.preferredHeight: Dimens.fontSizeXxxl
                                source: Qt.resolvedUrl("../settings/pages/about/hermit-logo.svg")
                                sourceSize.width: Dimens.fontSizeXxxl * 2
                                sourceSize.height: Dimens.fontSizeXxxl * 2
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0

                                Text {
                                    text: root.setupName
                                    color: Colors.fg
                                    font.family: Fonts.display
                                    font.pixelSize: Dimens.fontSizeLg
                                    font.weight: Font.Bold
                                }

                                Text {
                                    text: root.repoName
                                    color: Colors.subtext
                                    font.family: Fonts.text
                                    font.pixelSize: Dimens.fontSizeXs
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 3

                            Repeater {
                                model: contentRoot.steps

                                delegate: SidebarItem {
                                    required property var modelData
                                    required property int index

                                    Layout.fillWidth: true
                                    icon: modelData.icon
                                    title: modelData.title
                                    subtitle: modelData.subtitle
                                    selected: contentRoot.index === index
                                    onClicked: contentRoot.index = index
                                }
                            }
                        }

                        Item { Layout.fillHeight: true }
                    }
                }

                // ============ CONTENT ============
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: Dimens.paddingLarge
                    spacing: Dimens.spacingMedium

                    StackLayout {
                        id: pages
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        currentIndex: contentRoot.index

                        // ── 0: Overview ───────────────────────
                        Page {
                            PageHeader {
                                title: "Welcome to " + root.setupName
                                subtitle: "A Hyprland setup with two shells, built to be tweaked."
                            }

                            Card {
                                Text {
                                    Layout.fillWidth: true
                                    text: "Hermit's main shell is a custom Quickshell island: one floating bar that grows into the launcher, control center, notifications, dashboard and power menu, plus a lock screen and a full Settings app. An AGS shell ships alongside it, and you can switch between the two whenever you like."
                                    color: Colors.subtext
                                    font.family: Fonts.text
                                    font.pixelSize: Dimens.fontSizeMd
                                    wrapMode: Text.WordWrap
                                    lineHeight: 1.2
                                }
                            }

                            Card {
                                InfoRow { Layout.fillWidth: true; label: "Setup"; value: root.setupName + " (" + root.repoName + ")" }
                                InfoRow { Layout.fillWidth: true; label: "Distro"; value: sys.distro }
                                InfoRow { Layout.fillWidth: true; label: "Kernel"; value: sys.kernel }
                                InfoRow { Layout.fillWidth: true; label: "Host"; value: sys.host }
                                InfoRow { Layout.fillWidth: true; label: "Desktop"; value: sys.desktop }
                                InfoRow { Layout.fillWidth: true; label: "Config"; value: Quickshell.shellDir }
                            }
                        }

                        // ── 1: Quick setup ────────────────────
                        Page {
                            PageHeader {
                                title: "Quick setup"
                                subtitle: "The basics. Everything here can be changed later in Settings."
                            }

                            Card {
                                ToggleRow {
                                    Layout.fillWidth: true
                                    label: "Light mode"
                                    description: "Switch the whole shell between dark and light."
                                    checked: Colors.lightModeEnabled
                                    onToggled: Colors.toggleLightMode()
                                }

                                ToggleRow {
                                    Layout.fillWidth: true
                                    label: "24-hour clock"
                                    description: "Show 14:30 instead of 2:30 PM."
                                    checked: ShellState.clockUse24Hour
                                    onToggled: ShellState.clockUse24Hour = !ShellState.clockUse24Hour
                                }

                                ToggleRow {
                                    Layout.fillWidth: true
                                    label: "Auto-hide the island"
                                    description: "Slide the island away when idle; hover the top edge to bring it back."
                                    checked: !ShellState.islandAlwaysVisible
                                    onToggled: ShellState.islandAlwaysVisible = !ShellState.islandAlwaysVisible
                                }

                                ToggleRow {
                                    Layout.fillWidth: true
                                    label: "Reduce motion"
                                    description: "Turn off shell and Hyprland animations."
                                    checked: ShellState.motionReduced
                                    onToggled: ShellState.motionReduced = !ShellState.motionReduced
                                }

                                ToggleRow {
                                    Layout.fillWidth: true
                                    label: "Check for updates automatically"
                                    description: "Look for new Hermit versions in the background."
                                    checked: ShellState.updateAutoCheck
                                    onToggled: ShellState.updateAutoCheck = !ShellState.updateAutoCheck
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Dimens.spacingMedium

                                ActionButton {
                                    text: "Pick a theme"
                                    onClicked: ShellState.showPage("theme")
                                }

                                ActionButton {
                                    text: "Pick a wallpaper"
                                    onClicked: {
                                        WallpaperService.isOpen = true
                                        ShellState.showPage("wallpaper")
                                    }
                                }

                                ActionButton {
                                    text: "Appearance settings"
                                    onClicked: {
                                        ShellState.openSettings()
                                        SettingsNav.openByName("appearance")
                                    }
                                }
                            }
                        }

                        // ── 2: Shells ─────────────────────────
                        Page {
                            PageHeader {
                                title: "Choose your shell"
                                subtitle: "Hermit has two shells. Only one runs at a time."
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Dimens.spacingMedium

                                Card {
                                    Layout.preferredWidth: 1
                                    Layout.alignment: Qt.AlignTop

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: Dimens.spacingSmall

                                        SymbolIcon {
                                            name: "bubble_chart"
                                            size: Dimens.fontSizeXl
                                            color: Colors.accent
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: "Quickshell"
                                            color: Colors.fg
                                            font.family: Fonts.display
                                            font.pixelSize: Dimens.fontSizeLg
                                            font.weight: Font.Bold
                                        }

                                        Rectangle {
                                            width: runningText.implicitWidth + Dimens.paddingMedium * 2
                                            height: runningText.implicitHeight + Dimens.paddingSmall
                                            radius: Dimens.radiusFull
                                            color: Colors.accent

                                            Text {
                                                id: runningText
                                                anchors.centerIn: parent
                                                text: "Running"
                                                color: Colors.bg
                                                font.family: Fonts.text
                                                font.pixelSize: Dimens.fontSizeXs
                                                font.weight: Font.Bold
                                            }
                                        }
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: "The island shell you are using right now, with the Settings app, lock screen and Control Center."
                                        color: Colors.subtext
                                        font.family: Fonts.text
                                        font.pixelSize: Dimens.fontSizeMd
                                        wrapMode: Text.WordWrap
                                    }
                                }

                                Card {
                                    Layout.preferredWidth: 1
                                    Layout.alignment: Qt.AlignTop

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: Dimens.spacingSmall

                                        SymbolIcon {
                                            name: "widgets"
                                            size: Dimens.fontSizeXl
                                            color: Colors.accent
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: "AGS"
                                            color: Colors.fg
                                            font.family: Fonts.display
                                            font.pixelSize: Dimens.fontSizeLg
                                            font.weight: Font.Bold
                                        }
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: "The alternative shell. Switching closes Quickshell and starts AGS in its place."
                                        color: Colors.subtext
                                        font.family: Fonts.text
                                        font.pixelSize: Dimens.fontSizeMd
                                        wrapMode: Text.WordWrap
                                    }

                                    ActionButton {
                                        text: contentRoot.confirmAgs ? "Click again to switch" : "Switch to AGS"
                                        primary: contentRoot.confirmAgs
                                        onClicked: {
                                            if (contentRoot.confirmAgs) root.switchTo("ags")
                                            else contentRoot.confirmAgs = true
                                        }
                                    }
                                }
                            }

                            Card {
                                Text {
                                    Layout.fillWidth: true
                                    text: "You can switch any time, from either shell, with these shortcuts:"
                                    color: Colors.subtext
                                    font.family: Fonts.text
                                    font.pixelSize: Dimens.fontSizeMd
                                    wrapMode: Text.WordWrap
                                }

                                ShortcutRow { label: "Switch to Quickshell"; combo: "SUPER + CTRL + ALT + Q" }
                                ShortcutRow { label: "Switch to AGS"; combo: "SUPER + CTRL + ALT + A" }
                            }
                        }

                        // ── 3: Shortcuts ──────────────────────
                        Page {
                            PageHeader {
                                title: "Shortcuts worth knowing"
                                subtitle: "The defaults from your Hyprland config. Rebind any of them in Settings."
                            }

                            Card {
                                ShortcutRow { label: "Terminal"; combo: "SUPER + RETURN" }
                                ShortcutRow { label: "Browser"; combo: "SUPER + B" }
                                ShortcutRow { label: "Code editor"; combo: "SUPER + E" }
                                ShortcutRow { label: "Notes"; combo: "SUPER + O" }
                                ShortcutRow { label: "Music"; combo: "SUPER + S" }
                                ShortcutRow { label: "Files"; combo: "SUPER + F" }
                                ShortcutRow { label: "Lock screen"; combo: "SHIFT + ALT + L" }
                                ShortcutRow { label: "Power menu"; combo: "SUPER + F4" }
                                ShortcutRow { label: "Reload Hyprland"; combo: "SUPER + SHIFT + R" }
                            }

                            ActionButton {
                                text: "Open keybinds in Settings"
                                onClicked: {
                                    ShellState.openSettings()
                                    SettingsNav.openByName("keybinds")
                                }
                            }
                        }

                        // ── 4: All set ────────────────────────
                        Page {
                            PageHeader {
                                title: "You're all set"
                                subtitle: "Enjoy " + root.setupName + "."
                            }

                            Card {
                                Text {
                                    Layout.fillWidth: true
                                    text: "Everything you saw here lives in Settings, so nothing is locked in. This screen won't open again on its own. To bring it back, run:"
                                    color: Colors.subtext
                                    font.family: Fonts.text
                                    font.pixelSize: Dimens.fontSizeMd
                                    wrapMode: Text.WordWrap
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: cmdText.implicitHeight + Dimens.paddingMedium * 2
                                    radius: Dimens.radiusSmall
                                    color: Colors.mainBgMica
                                    border.color: Colors.border
                                    border.width: 1

                                    Text {
                                        id: cmdText
                                        anchors.centerIn: parent
                                        text: "qs ipc call welcome show"
                                        color: Colors.fg
                                        font.family: Fonts.mono
                                        font.pixelSize: Dimens.fontSizeSm
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Dimens.spacingMedium

                                ActionButton {
                                    text: "Open Settings"
                                    onClicked: ShellState.openSettings()
                                }

                                ActionButton {
                                    text: root.repoName + " on GitHub"
                                    onClicked: Qt.openUrlExternally(root.repoUrl)
                                }
                            }
                        }
                    }

                    // ── Footer ────────────────────────────────
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Dimens.spacingMedium

                        ActionButton {
                            text: contentRoot.isFirst ? "Skip" : "Back"
                            onClicked: contentRoot.isFirst ? WelcomeService.finish() : contentRoot.back()
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: "Step " + (contentRoot.index + 1) + " of " + contentRoot.steps.length
                            color: Colors.subtext
                            font.family: Fonts.text
                            font.pixelSize: Dimens.fontSizeXs
                        }

                        ActionButton {
                            text: contentRoot.isLast ? "Get started" : "Next"
                            primary: true
                            onClicked: contentRoot.next()
                        }
                    }
                }
            }
        }
    }
}