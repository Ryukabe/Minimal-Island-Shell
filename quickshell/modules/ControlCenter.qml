// modules/ControlCenter.qml
pragma ComponentBehavior: Bound

import QtQuick
import "../styles"
import "../services"
import "../components/control-center"
import "../components/control-center/subviews"

Item {
    id: root
    property string activeSubview: ""
    property bool _subviewFirstLoad: true

    implicitWidth: ShellState.controlCenterWidth
    implicitHeight: ShellState.controlCenterHeight

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
        anchors.top: parent.top
        anchors.left: parent.left
        sourceComponent: {
            switch (root.activeSubview) {
            case "wifi": return wifiSubviewComp
            case "bluetooth": return bluetoothSubviewComp
            case "focus": return focusSubviewComp
            case "powerprofile": return powerProfileSubviewComp
            case "caffeine": return caffeineSubviewComp
            default: return mainViewComp
            }
        }

        onItemChanged: {
            if (item) {
                contentAnimSpring.stop()
                contentAnimEase.stop()
                if (root._subviewFirstLoad) {
                    item.opacity = 1
                    item.scale = 1.0
                    root._subviewFirstLoad = false
                } else {
                    item.opacity = 0
                    item.scale = 0.95
                    if (ShellState.motionSpringEnabled && !ShellState.motionReduced) {
                        contentAnimSpring.start()
                    } else {
                        contentAnimEase.start()
                    }
                }
            }
        }

        // Subview swap — ease variant (spring toggle off / reduced motion)
        ParallelAnimation {
            id: contentAnimEase
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
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.15, 1.0, 0.05, 1.0, 1, 1]
            }
        }

        // Subview swap — real spring variant (spring toggle on)
        ParallelAnimation {
            id: contentAnimSpring
            NumberAnimation {
                target: pageLoader.item
                property: "opacity"
                from: 0
                to: 1
                duration: ShellState.motionDuration(Motion.fadeMs)
                easing.type: Easing.OutCubic
            }
            SpringAnimation {
                target: pageLoader.item
                property: "scale"
                to: 1.0
                spring: Motion.glideSpring
                damping: Motion.glideDamping
                mass: Motion.glideMass
                epsilon: Motion.epsilon
            }
        }
    }

    Component {
        id: mainViewComp
        MainToggleView {
            onOpenWifi: root.activeSubview = "wifi"
            onOpenBluetooth: root.activeSubview = "bluetooth"
            onOpenFocus: root.activeSubview = "focus"
            onOpenPowerProfile: root.activeSubview = "powerprofile"
            onOpenCaffeine: root.activeSubview = "caffeine"
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
}