// shell.qml
import QtQuick
import Quickshell

ShellRoot {
    Component.onCompleted: {
        Qt.application.name = "quickshell"
        Qt.application.organization = "quickshell"
    }

    Island {}
}
