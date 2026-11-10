// features/control-center/ControlCenter.qml — the Control Center page: the tile grid and its sub-panels.
pragma ComponentBehavior: Bound

import QtQuick
import "../../core/styles"
import "../../core/shell"
import "components"
import "components/subviews"

Item {
    id: root
    property string activeSubview: ""
    property bool _subviewFirstLoad: true

    // The width is the same for the grid and every sub-panel; the height follows what is shown.
    implicitWidth: ShellState.controlCenterWidth
    implicitHeight: pageLoader.item ? pageLoader.item.implicitHeight : ShellState.controlCenterHeight

    focus: true
    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Escape) {
            if (root.activeSubview !== "") {
                root.activeSubview = ""
            } else {
                ShellState.showPage("clock")
            }
            event.accepted = true
        }
    }

    Timer {
        id: focusTimer
        interval: 50
        repeat: false
        onTriggered: root.forceActiveFocus()
    }
    Component.onCompleted: focusTimer.restart()

    Loader {
        id: pageLoader
        anchors.fill: parent

        sourceComponent: {
            switch (root.activeSubview) {
            case "wifi": return wifiSubviewComp
            case "bluetooth": return bluetoothSubviewComp
            case "focus": return focusSubviewComp
            case "powerprofile": return powerProfileSubviewComp
            case "caffeine": return caffeineSubviewComp
            case "brightness": return brightnessSubviewComp
            case "volume": return volumeSubviewComp
            case "audiosink": return audioSinkSubviewComp
            case "nightlight": return nightlightSubviewComp
            case "shades": return shadesSubviewComp
            default: return mainViewComp
            }
        }

        // Switching between the grid and a sub-panel: fade in and grow a little, with the island's curves.
        onItemChanged: {
            if (item) {
                contentAnim.stop()
                if (root._subviewFirstLoad) {
                    item.opacity = 1
                    item.scale = 1.0
                    root._subviewFirstLoad = false
                } else {
                    item.opacity = 0
                    item.scale = 0.95
                    contentAnim.start()
                }
            }
        }

        ParallelAnimation {
            id: contentAnim
            NumberAnimation {
                target: pageLoader.item
                property: "opacity"
                from: 0
                to: 1
                duration: ShellState.motionDuration(Motion.fadeMs)
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: pageLoader.item
                property: "scale"
                from: 0.95
                to: 1.0
                duration: ShellState.motionDuration(Motion.glideMs)
                easing.type: Easing.OutBack
                easing.overshoot: ShellState.motionIslandOvershoot() * 0.8
            }
        }
    }

    Component {
        id: mainViewComp
        MainToggleView {
            onSubviewRequestedFor: (viewName) => root.activeSubview = viewName
        }
    }

    Component {
        id: wifiSubviewComp
        WifiSubView { onBackRequested: root.activeSubview = "" }
    }

    Component {
        id: bluetoothSubviewComp
        BluetoothSubView { onBackRequested: root.activeSubview = "" }
    }

    Component {
        id: focusSubviewComp
        FocusSubView { onBackRequested: root.activeSubview = "" }
    }

    Component {
        id: powerProfileSubviewComp
        PowerProfileSubView { onBackRequested: root.activeSubview = "" }
    }

    Component {
        id: caffeineSubviewComp
        CaffeineSubview { onBackRequested: root.activeSubview = "" }
    }

    Component {
        id: volumeSubviewComp
        VolumeSubView {
            onBackRequested: root.activeSubview = ""
            onSinkRequested: root.activeSubview = "audiosink"
        }
    }

    Component {
        id: brightnessSubviewComp
        BrightnessSubView { onBackRequested: root.activeSubview = "" }
    }

    Component {
        id: audioSinkSubviewComp
        AudioSinkSubView { onBackRequested: root.activeSubview = "volume" }
    }

    Component {
        id: nightlightSubviewComp
        NightLightSubView { onBackRequested: root.activeSubview = "" }
    }

    Component {
        id: shadesSubviewComp
        ShadesSubView { onBackRequested: root.activeSubview = "" }
    }
}