// SettingsApp.qml — settings window: sidebar of menus on the left, a page host on the right.
// What exists, and where it lives, is defined in core/SettingsRegistry.qml.
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "./core"
import "./components"
import "./pages/about"
import "../services"
import "../styles"

Scope {
    id: root

    // Reading SettingsStore here creates it at shell start, so saved settings are applied
    // even before any page that uses the store is opened (pages now load lazily).
    readonly property bool storeLoaded: SettingsStore._loaded

    // Shell-wide services. They live here (not in the About page) so update checks keep running
    // while Settings is closed. A page receives one by declaring a property with the same name
    // (see the injection in pageLoader.onLoaded below).
    SystemInfoService { id: systemInfo }
    UpdateService { id: updateService }

    // Argument and return types must be spelled out or Quickshell does not register the function.
    IpcHandler {
        target: "settings"

        function open(): void { ShellState.openSettings() }
        function close(): void { ShellState.closeSettings() }
        function toggle(): void { ShellState.toggleSettings() }

        // qs ipc call settings section appearance   |   ... section appearance/motion
        function section(name: string): void {
            ShellState.openSettings()
            SettingsNav.openByName(name)
        }
    }

    FloatingWindow {
        id: window
        title: "Settings"
        visible: ShellState.settingsOpen
        color: Colors.mainBgMica
        implicitWidth: 1080
        implicitHeight: 720

        onVisibleChanged: {
            if (visible) {
                focusDelay.start()
                gearSpin.restart()
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

            // Escape steps back out of a view first, then closes the window.
            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Escape) {
                    if (SettingsNav.canGoBack) SettingsNav.back()
                    else ShellState.closeSettings()
                    event.accepted = true
                }
            }

            RowLayout {
                anchors.fill: parent
                spacing: 0

                // ============ SIDEBAR ============
                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 260
                    color: Colors.mainBgMica

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Dimens.paddingMedium
                        spacing: Dimens.spacingMedium

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Dimens.spacingSmall

                            Rectangle {
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                radius: 20
                                color: gearMouse.containsMouse ? Colors.elevatedBg : "transparent"

                                Behavior on color {
                                    ColorAnimation { duration: ShellState.motionDuration(Motion.hoverMs) }
                                }

                                SymbolIcon {
                                    id: gearIcon
                                    anchors.centerIn: parent
                                    name: "settings"
                                    size: Dimens.fontSizeLg
                                    color: Colors.accent
                                    transformOrigin: Item.Center

                                    RotationAnimation {
                                        id: gearSpin
                                        target: gearIcon
                                        from: 0
                                        to: 360
                                        duration: ShellState.motionDuration(Motion.glideMs)
                                        easing.type: Easing.OutCubic
                                    }
                                }

                                MouseArea {
                                    id: gearMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: gearSpin.restart()
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0

                                Text {
                                    text: SettingsRegistry.appTitle
                                    color: Colors.fg
                                    font.family: Fonts.display
                                    font.pixelSize: Dimens.fontSizeLg
                                    font.weight: Font.Bold
                                }

                                Text {
                                    text: SettingsRegistry.appSubtitle
                                    color: Colors.subtext
                                    font.family: Fonts.text
                                    font.pixelSize: Dimens.fontSizeXs
                                }
                            }
                        }

                        Flickable {
                            id: sidebarFlick
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            contentWidth: width
                            contentHeight: sidebarColumn.implicitHeight
                            clip: true
                            boundsBehavior: Flickable.StopAtBounds

                            ColumnLayout {
                                id: sidebarColumn
                                width: sidebarFlick.width
                                spacing: Dimens.spacingLarge

                                Repeater {
                                    model: SettingsRegistry.clusters

                                    delegate: ColumnLayout {
                                        id: cluster
                                        required property var modelData

                                        Layout.fillWidth: true
                                        spacing: 3

                                        Repeater {
                                            model: cluster.modelData.menus

                                            delegate: SidebarItem {
                                                required property var modelData

                                                icon: modelData.icon
                                                title: modelData.title
                                                subtitle: modelData.subtitle
                                                selected: SettingsNav.menuId === modelData.id
                                                onClicked: SettingsNav.openMenu(modelData.id)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    width: 1
                    color: Colors.border
                    opacity: 0.3
                }

                // ============ PAGE AREA ============
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"

                    // Drag the window by its top edge.
                    MouseArea {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 24
                        z: 10
                        acceptedButtons: Qt.LeftButton
                        onPressed: window.startSystemMove()
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Dimens.paddingLarge
                        spacing: Dimens.spacingMedium

                        PageTitle {
                            icon: SettingsNav.icon
                            title: SettingsNav.title
                            subtitle: SettingsNav.subtitle
                            canGoBack: SettingsNav.canGoBack
                            onBackClicked: SettingsNav.back()
                        }

                        Loader {
                            id: pageLoader
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            source: SettingsNav.pageSource !== "" ? Qt.resolvedUrl(SettingsNav.pageSource) : ""

                            // Loader does not reliably size its item inside a layout, so bind it.
                            onLoaded: {
                                item.width = Qt.binding(() => pageLoader.width)
                                item.height = Qt.binding(() => pageLoader.height)
                                if (item.updateService !== undefined) item.updateService = updateService
                                if (item.systemInfo !== undefined) item.systemInfo = systemInfo
                                loadFade.restart()
                            }

                            NumberAnimation {
                                id: loadFade
                                target: pageLoader
                                property: "opacity"
                                from: 0
                                to: 1
                                duration: ShellState.motionDuration(Motion.fadeMs)
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }
            }
        }
    }
}
