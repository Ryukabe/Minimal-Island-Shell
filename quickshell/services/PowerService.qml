pragma Singleton
import QtQuick

Item {
    id: root

    property bool active: false

    function toggle() {
        active = !active
    }

    function show() {
        active = true
    }

    function hide() {
        active = false
    }
}