// welcome/WelcomeApp.qml — Hermit welcome window (centered floating window, 5 steps).
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Scope {
    id: root

    readonly property string setupName: "Hermit"
    readonly property string repoName: "hermit-dots"
    readonly property string repoUrl: "https://github.com/Ryukabe/hermit-dots"
    readonly property string configDir: Quickshell.env("HOME") + "/.config/quickshell"

    // The Settings buttons talk to the main Quickshell shell, so they need it to be the active one.
    readonly property bool mainActive: WelcomeStore.activeShell === "qs"

    // ── System details ────────────────────────────────────────
    QtObject {
        id: sys

        property string distro: "…"
        property string kernel: "…"
        property string host: "…"
        readonly property string desktop: Quickshell.env("XDG_CURRENT_DESKTOP") || "Hyprland"

        property FileView osRelease: FileView {
            path: "/etc/os-release"
            printErrors: false
            onLoaded: {
                const m = text().match(/^PRETTY_NAME="?([^"\n]*)"?/m)
                if (m) sys.distro = m[1]
            }
        }

        property FileView hostFile: FileView {
            path: "/etc/hostname"
            printErrors: false
            onLoaded: sys.host = text().trim()
        }

        property Process kernelProc: Process {
            command: ["uname", "-r"]
            running: true
            stdout: StdioCollector {
                onStreamFinished: sys.kernel = text.trim()
            }
        }
    }

    // ── Building blocks ───────────────────────────────────────
    component PageHeader: ColumnLayout {
        id: ph
        property string title
        property string subtitle

        Layout.fillWidth: true
        spacing: 0

        Text {
            Layout.fillWidth: true
            text: ph.title
            color: WelcomeTheme.fg
            font.family: WelcomeTheme.fontDisplay
            font.pixelSize: WelcomeTheme.fontXxl
            font.weight: Font.Bold
            wrapMode: Text.WordWrap
        }

        Text {
            Layout.fillWidth: true
            text: ph.subtitle
            color: WelcomeTheme.muted
            font.family: WelcomeTheme.fontText
            font.pixelSize: WelcomeTheme.fontMd
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
            spacing: WelcomeTheme.spacingLg
        }
    }

    component Card: Rectangle {
        id: card
        default property alias content: inner.data

        Layout.fillWidth: true
        implicitHeight: inner.implicitHeight + WelcomeTheme.padLg * 2
        radius: WelcomeTheme.radiusLg
        color: WelcomeTheme.surface
        border.color: WelcomeTheme.border
        border.width: 1

        ColumnLayout {
            id: inner
            anchors.fill: parent
            anchors.margins: WelcomeTheme.padLg
            spacing: WelcomeTheme.spacingMd
        }
    }

    component BodyText: Text {
        Layout.fillWidth: true
        color: WelcomeTheme.muted
        font.family: WelcomeTheme.fontText
        font.pixelSize: WelcomeTheme.fontMd
        wrapMode: Text.WordWrap
        lineHeight: 1.2
    }

    component WButton: Rectangle {
        id: btn
        property string text
        property bool primary: false
        signal clicked()

        implicitWidth: btnLabel.implicitWidth + WelcomeTheme.padLg * 2
        implicitHeight: btnLabel.implicitHeight + WelcomeTheme.padMd * 1.2
        radius: WelcomeTheme.radiusMd
        opacity: enabled ? 1.0 : 0.4
        color: primary
            ? (btnMouse.containsMouse ? Qt.lighter(WelcomeTheme.accent, 1.12) : WelcomeTheme.accent)
            : (btnMouse.containsMouse ? Qt.lighter(WelcomeTheme.elevated, 1.2) : WelcomeTheme.elevated)

        Behavior on color {
            ColorAnimation { duration: WelcomeTheme.animMs }
        }

        Text {
            id: btnLabel
            anchors.centerIn: parent
            text: btn.text
            color: btn.primary ? WelcomeTheme.bg : WelcomeTheme.fg
            font.family: WelcomeTheme.fontText
            font.pixelSize: WelcomeTheme.fontMd
            font.weight: Font.Medium
        }

        MouseArea {
            id: btnMouse
            anchors.fill: parent
            enabled: btn.enabled
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.clicked()
        }
    }

    component Badge: Rectangle {
        id: badge
        property string text

        implicitWidth: badgeText.implicitWidth + WelcomeTheme.padMd * 2
        implicitHeight: badgeText.implicitHeight + WelcomeTheme.padSm
        radius: WelcomeTheme.radiusFull
        color: WelcomeTheme.accent

        Text {
            id: badgeText
            anchors.centerIn: parent
            text: badge.text
            color: WelcomeTheme.bg
            font.family: WelcomeTheme.fontText
            font.pixelSize: WelcomeTheme.fontXs
            font.weight: Font.Bold
        }
    }

    component InfoLine: RowLayout {
        id: il
        property string label
        property string value

        Layout.fillWidth: true
        spacing: WelcomeTheme.spacingMd

        Text {
            Layout.preferredWidth: WelcomeTheme.labelWidth
            text: il.label
            color: WelcomeTheme.muted
            font.family: WelcomeTheme.fontText
            font.pixelSize: WelcomeTheme.fontMd
        }

        Text {
            Layout.fillWidth: true
            text: il.value
            color: WelcomeTheme.fg
            font.family: WelcomeTheme.fontText
            font.pixelSize: WelcomeTheme.fontMd
            elide: Text.ElideMiddle
            horizontalAlignment: Text.AlignRight
        }
    }

    component KeyCombo: Row {
        id: kc
        property string combo
        spacing: WelcomeTheme.spacingSm

        Repeater {
            model: kc.combo.split(" + ")

            delegate: Rectangle {
                id: chip
                required property string modelData

                width: keyText.implicitWidth + WelcomeTheme.padMd * 2
                height: keyText.implicitHeight + WelcomeTheme.padSm
                radius: WelcomeTheme.radiusSm
                color: WelcomeTheme.bg
                border.color: WelcomeTheme.outline
                border.width: 1

                Text {
                    id: keyText
                    anchors.centerIn: parent
                    text: chip.modelData
                    color: WelcomeTheme.fg
                    font.family: WelcomeTheme.fontMono
                    font.pixelSize: WelcomeTheme.fontSm
                }
            }
        }
    }

    component ShortcutRow: RowLayout {
        id: sr
        property string label
        property string combo

        Layout.fillWidth: true
        spacing: WelcomeTheme.spacingMd

        Text {
            Layout.fillWidth: true
            text: sr.label
            color: WelcomeTheme.fg
            font.family: WelcomeTheme.fontText
            font.pixelSize: WelcomeTheme.fontMd
            elide: Text.ElideRight
        }

        KeyCombo { combo: sr.combo }
    }

    component SideItem: Rectangle {
        id: si
        property int number
        property string title
        property string subtitle
        property bool selected: false
        signal clicked()

        Layout.fillWidth: true
        implicitHeight: sideCol.implicitHeight + WelcomeTheme.padMd * 2
        radius: WelcomeTheme.radiusMd
        color: selected ? WelcomeTheme.elevated : (sideMouse.containsMouse ? WelcomeTheme.surface : "transparent")

        Behavior on color {
            ColorAnimation { duration: WelcomeTheme.animMs }
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: WelcomeTheme.padMd
            spacing: WelcomeTheme.spacingMd

            Rectangle {
                Layout.preferredWidth: WelcomeTheme.fontLg * 1.6
                Layout.preferredHeight: WelcomeTheme.fontLg * 1.6
                radius: WelcomeTheme.radiusFull
                color: si.selected ? WelcomeTheme.accent : WelcomeTheme.elevated

                Text {
                    anchors.centerIn: parent
                    text: si.number
                    color: si.selected ? WelcomeTheme.bg : WelcomeTheme.muted
                    font.family: WelcomeTheme.fontText
                    font.pixelSize: WelcomeTheme.fontSm
                    font.weight: Font.Bold
                }
            }

            ColumnLayout {
                id: sideCol
                Layout.fillWidth: true
                spacing: 0

                Text {
                    Layout.fillWidth: true
                    text: si.title
                    color: WelcomeTheme.fg
                    font.family: WelcomeTheme.fontText
                    font.pixelSize: WelcomeTheme.fontMd
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: si.subtitle
                    color: WelcomeTheme.muted
                    font.family: WelcomeTheme.fontText
                    font.pixelSize: WelcomeTheme.fontXs
                    elide: Text.ElideRight
                }
            }
        }

        MouseArea {
            id: sideMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: si.clicked()
        }
    }

    // ── Window ────────────────────────────────────────────────
    FloatingWindow {
        id: window
        title: "Welcome to " + root.setupName
        visible: true
        color: WelcomeTheme.bg
        implicitWidth: 900
        implicitHeight: 600
        // Fixed size: Hyprland floats windows that cannot be resized.
        minimumSize: Qt.size(900, 600)
        maximumSize: Qt.size(900, 600)

        // Closed by the compositor, Escape or Get started: remember it was seen and quit.
        onVisibleChanged: if (!visible) WelcomeStore.finish()

        Item {
            id: contentRoot
            anchors.fill: parent
            focus: true

            property int index: 0
            // Shell name ("qs" | "ags") whose switch button was clicked once and awaits confirmation.
            property string confirmSwitch: ""
            property bool switching: false

            readonly property var steps: [
                { title: "Overview", subtitle: "What Hermit is" },
                { title: "Make it yours", subtitle: "Theme, wallpaper, settings" },
                { title: "Shells", subtitle: "Quickshell or AGS" },
                { title: "Shortcuts", subtitle: "Keys worth knowing" },
                { title: "All set", subtitle: "Get started" }
            ]

            readonly property bool isFirst: index === 0
            readonly property bool isLast: index === steps.length - 1

            function next() {
                if (isLast) WelcomeStore.finish()
                else index++
            }

            function back() {
                if (!isFirst) index--
            }

            function requestSwitch(name) {
                if (confirmSwitch === name) {
                    confirmSwitch = ""
                    switching = true
                    WelcomeStore.switchTo(name)
                } else {
                    confirmSwitch = name
                }
            }

            onIndexChanged: {
                confirmSwitch = ""
                pageFade.restart()
            }

            Component.onCompleted: forceActiveFocus()

            // The switch is done once .active-shell changes.
            Connections {
                target: WelcomeStore
                function onActiveShellChanged() { contentRoot.switching = false }
            }

            NumberAnimation {
                id: pageFade
                target: pages
                property: "opacity"
                from: 0
                to: 1
                duration: WelcomeTheme.animMs
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
                    WelcomeStore.finish()
                    event.accepted = true
                }
            }

            // Drag the window by its top edge.
            MouseArea {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: WelcomeTheme.padLg * 2
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
                    Layout.preferredWidth: WelcomeTheme.sidebarWidth
                    color: WelcomeTheme.surface

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: WelcomeTheme.padMd
                        spacing: WelcomeTheme.spacingMd

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: WelcomeTheme.spacingMd

                            Image {
                                Layout.preferredWidth: WelcomeTheme.fontXxl
                                Layout.preferredHeight: WelcomeTheme.fontXxl
                                source: Qt.resolvedUrl("../features/settings/pages/about/hermit-logo.svg")
                                sourceSize.width: WelcomeTheme.fontXxl * 2
                                sourceSize.height: WelcomeTheme.fontXxl * 2
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0

                                Text {
                                    text: root.setupName
                                    color: WelcomeTheme.fg
                                    font.family: WelcomeTheme.fontDisplay
                                    font.pixelSize: WelcomeTheme.fontLg
                                    font.weight: Font.Bold
                                }

                                Text {
                                    text: root.repoName
                                    color: WelcomeTheme.muted
                                    font.family: WelcomeTheme.fontText
                                    font.pixelSize: WelcomeTheme.fontXs
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 3

                            Repeater {
                                model: contentRoot.steps

                                delegate: SideItem {
                                    required property var modelData
                                    required property int index

                                    number: index + 1
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
                    Layout.margins: WelcomeTheme.padLg * 1.5
                    spacing: WelcomeTheme.spacingMd

                    StackLayout {
                        id: pages
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        currentIndex: contentRoot.index

                        // ── 1: Overview ───────────────────────
                        Page {
                            PageHeader {
                                title: "Welcome to " + root.setupName
                                subtitle: "A Hyprland setup with two shells, built to be tweaked."
                            }

                            Card {
                                BodyText {
                                    text: "Hermit's main shell is a custom Quickshell island: one floating bar that grows into the launcher, control center, notifications, dashboard and power menu, plus a lock screen and a full Settings app. An AGS shell ships alongside it, and you can switch between the two whenever you like."
                                }
                            }

                            Card {
                                InfoLine { label: "Setup"; value: root.setupName + " (" + root.repoName + ")" }
                                InfoLine { label: "Distro"; value: sys.distro }
                                InfoLine { label: "Kernel"; value: sys.kernel }
                                InfoLine { label: "Host"; value: sys.host }
                                InfoLine { label: "Desktop"; value: sys.desktop }
                                InfoLine { label: "Config"; value: root.configDir }
                            }
                        }

                        // ── 2: Make it yours ──────────────────
                        Page {
                            PageHeader {
                                title: "Make it yours"
                                subtitle: "Start with the look. Everything else lives in Settings."
                            }

                            Card {
                                BodyText {
                                    text: "These buttons open the real pickers in the Quickshell shell. Choose a theme and a wallpaper and the whole shell follows."
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: WelcomeTheme.spacingMd

                                    WButton {
                                        text: "Pick a theme"
                                        enabled: root.mainActive
                                        onClicked: WelcomeStore.requestMain("page", "theme")
                                    }

                                    WButton {
                                        text: "Pick a wallpaper"
                                        enabled: root.mainActive
                                        onClicked: WelcomeStore.requestMain("wallpaper", "")
                                    }
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: WelcomeTheme.spacingMd

                                    WButton {
                                        text: "Appearance settings"
                                        enabled: root.mainActive
                                        onClicked: WelcomeStore.requestMain("settings", "appearance")
                                    }

                                    WButton {
                                        text: "Open all settings"
                                        enabled: root.mainActive
                                        onClicked: WelcomeStore.requestMain("settings", "")
                                    }
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                visible: !root.mainActive
                                text: "AGS is the active shell, so these buttons are off. Switch back to Quickshell on the Shells step to use them."
                                color: WelcomeTheme.muted
                                font.family: WelcomeTheme.fontText
                                font.pixelSize: WelcomeTheme.fontSm
                                wrapMode: Text.WordWrap
                            }
                        }

                        // ── 3: Shells ─────────────────────────
                        Page {
                            PageHeader {
                                title: "Choose your shell"
                                subtitle: "Hermit has two shells. Only one runs at a time."
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: WelcomeTheme.spacingMd

                                Card {
                                    Layout.preferredWidth: 1
                                    Layout.alignment: Qt.AlignTop

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: WelcomeTheme.spacingSm

                                        Text {
                                            Layout.fillWidth: true
                                            text: "Quickshell"
                                            color: WelcomeTheme.fg
                                            font.family: WelcomeTheme.fontDisplay
                                            font.pixelSize: WelcomeTheme.fontLg
                                            font.weight: Font.Bold
                                        }

                                        Badge {
                                            visible: WelcomeStore.activeShell === "qs"
                                            text: "Active"
                                        }
                                    }

                                    BodyText {
                                        text: "The island shell, with the Settings app, lock screen and Control Center."
                                    }

                                    WButton {
                                        visible: WelcomeStore.activeShell === "ags"
                                        enabled: !contentRoot.switching
                                        primary: contentRoot.confirmSwitch === "qs"
                                        text: contentRoot.confirmSwitch === "qs" ? "Click again to switch" : "Switch to Quickshell"
                                        onClicked: contentRoot.requestSwitch("qs")
                                    }
                                }

                                Card {
                                    Layout.preferredWidth: 1
                                    Layout.alignment: Qt.AlignTop

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: WelcomeTheme.spacingSm

                                        Text {
                                            Layout.fillWidth: true
                                            text: "AGS"
                                            color: WelcomeTheme.fg
                                            font.family: WelcomeTheme.fontDisplay
                                            font.pixelSize: WelcomeTheme.fontLg
                                            font.weight: Font.Bold
                                        }

                                        Badge {
                                            visible: WelcomeStore.activeShell === "ags"
                                            text: "Active"
                                        }
                                    }

                                    BodyText {
                                        text: "The alternative shell. Switching stops Quickshell and starts AGS in its place."
                                    }

                                    WButton {
                                        visible: WelcomeStore.activeShell === "qs"
                                        enabled: !contentRoot.switching
                                        primary: contentRoot.confirmSwitch === "ags"
                                        text: contentRoot.confirmSwitch === "ags" ? "Click again to switch" : "Switch to AGS"
                                        onClicked: contentRoot.requestSwitch("ags")
                                    }
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                visible: contentRoot.switching
                                text: "Switching shells… this window stays open."
                                color: WelcomeTheme.accent
                                font.family: WelcomeTheme.fontText
                                font.pixelSize: WelcomeTheme.fontSm
                            }

                            Card {
                                BodyText {
                                    text: "You can also switch at any time, from either shell, with these shortcuts:"
                                }

                                ShortcutRow { label: "Switch to Quickshell"; combo: "SUPER + CTRL + ALT + Q" }
                                ShortcutRow { label: "Switch to AGS"; combo: "SUPER + CTRL + ALT + A" }
                            }
                        }

                        // ── 4: Shortcuts ──────────────────────
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

                            WButton {
                                text: "Open keybinds in Settings"
                                enabled: root.mainActive
                                onClicked: WelcomeStore.requestMain("settings", "keybinds")
                            }
                        }

                        // ── 5: All set ────────────────────────
                        Page {
                            PageHeader {
                                title: "You're all set"
                                subtitle: "Enjoy " + root.setupName + "."
                            }

                            Card {
                                BodyText {
                                    text: "Everything you saw here lives in Settings, so nothing is locked in. This window won't open again on its own. To bring it back, run:"
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: cmdText.implicitHeight + WelcomeTheme.padMd * 2
                                    radius: WelcomeTheme.radiusSm
                                    color: WelcomeTheme.bg
                                    border.color: WelcomeTheme.outline
                                    border.width: 1

                                    Text {
                                        id: cmdText
                                        anchors.centerIn: parent
                                        text: "~/.config/hypr/scripts/hermit-welcome.sh --force"
                                        color: WelcomeTheme.fg
                                        font.family: WelcomeTheme.fontMono
                                        font.pixelSize: WelcomeTheme.fontSm
                                    }
                                }
                            }

                            WButton {
                                text: root.repoName + " on GitHub"
                                onClicked: Qt.openUrlExternally(root.repoUrl)
                            }
                        }
                    }

                    // ── Footer ────────────────────────────────
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: WelcomeTheme.spacingMd

                        WButton {
                            text: contentRoot.isFirst ? "Skip" : "Back"
                            onClicked: contentRoot.isFirst ? WelcomeStore.finish() : contentRoot.back()
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: "Step " + (contentRoot.index + 1) + " of " + contentRoot.steps.length
                            color: WelcomeTheme.muted
                            font.family: WelcomeTheme.fontText
                            font.pixelSize: WelcomeTheme.fontXs
                        }

                        WButton {
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