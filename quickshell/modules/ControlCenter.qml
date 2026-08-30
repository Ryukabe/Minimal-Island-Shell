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

    implicitWidth: pageLoader.item ? pageLoader.item.implicitWidth : 580
    implicitHeight: pageLoader.item ? pageLoader.item.implicitHeight : 400

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
                subviewAnim.stop()
                item.opacity = 0
                item.scale = 0.95
                subviewAnim.start()
            }
        }

        ParallelAnimation {
            id: subviewAnim
            NumberAnimation {
                target: pageLoader.item
                property: "opacity"
                from: 0
                to: 1
                duration: 220
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: pageLoader.item
                property: "scale"
                from: 0.95
                to: 1.0
                duration: 280
                easing.type: Easing.OutBack
                easing.overshoot: 1.15
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