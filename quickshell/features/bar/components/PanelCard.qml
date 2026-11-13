// features/bar/components/PanelCard.qml — the card that drops down below the bar in Bar style.
// Every page except the idle ones (clock, timer toast) opens here instead of inside the bar.
// It grows from nothing to the page's size with the island's own motion (OutBack when growing, an
// ease-out when shrinking) and shrinks back up into the bar when the page closes.
import QtQuick
import QtQuick.Effects
import "../../../core/shell"
import "../../../core/styles"

Item {
    id: root

    // The page to show ("" = closed), and a function that turns a page name into its Component.
    property string page: ""
    property var componentFor: null

    readonly property bool hovered: pointer.hovered

    // The page being shown. It stays while the card shrinks, so the content does not vanish early.
    property string shownPage: ""
    onPageChanged: if (root.page !== "") root.shownPage = root.page

    // Pages that size themselves from their content. The others get at least the minimum expanded
    // size, the same as inside the island.
    readonly property bool sizesItself:
        ["hover", "notification", "eventtoast", "apptoast", "volume", "brightness"].indexOf(root.shownPage) >= 0

    // ---- Size ----
    // What the page wants (0 while closed).
    property int targetWidth: {
        if (root.page === "" || !loader.item) return 0
        return Math.max(loader.implicitWidth, root.sizesItself ? 0 : ShellState.islandMinExpandedWidth)
    }
    property int targetHeight: {
        if (root.page === "" || !loader.item) return 0
        return Math.max(loader.implicitHeight, root.sizesItself ? 0 : ShellState.islandExpandedHeight)
    }

    // The size on screen, animated by hand: OutBack when growing, an ease-out when shrinking.
    property real animWidth: 0
    property real animHeight: 0
    property bool _sized: false

    width: Math.max(0, Math.round(root.animWidth))
    height: Math.max(0, Math.round(root.animHeight))
    visible: root.width > 0 && root.height > 0

    Component.onCompleted: root._sized = true

    onTargetWidthChanged: if (root._sized)
        root._morph(widthAnim, "animWidth", root.animWidth, root.targetWidth, ShellState.motionIslandOvershoot())
    onTargetHeightChanged: if (root._sized)
        root._morph(heightAnim, "animHeight", root.animHeight, root.targetHeight, ShellState.motionIslandOvershoot() * 0.85)

    function _morph(anim, prop, from, to, overshoot) {
        anim.stop()
        if (Math.abs(to - from) < 0.5) {
            root[prop] = to
            return
        }
        anim.from = from
        anim.to = to
        if (to > from) {
            anim.easing.type = Easing.OutBack
            anim.easing.overshoot = overshoot
            anim.duration = ShellState.motionDuration(Motion.glideMs)
        } else {
            anim.easing.type = Easing.BezierSpline
            anim.easing.bezierCurve = [0.15, 1.0, 0.05, 1.0, 1, 1]
            anim.duration = ShellState.motionDuration(Motion.glideMs * 0.75)
        }
        anim.restart()
    }

    NumberAnimation { id: widthAnim; target: root; property: "animWidth" }
    NumberAnimation { id: heightAnim; target: root; property: "animHeight" }

    // ---- Look: shadow, then the shape ----
    Rectangle {
        id: shadowSource
        anchors.fill: parent
        radius: ShellState.islandCornerRadius
        color: Colors.mainBgMica
        visible: Colors.islandShadowEnabled
    }

    MultiEffect {
        anchors.fill: shadowSource
        source: shadowSource
        visible: Colors.islandShadowEnabled
        autoPaddingEnabled: true
        shadowEnabled: true
        shadowColor: Colors.shadowColor
        shadowOpacity: Colors.shadowOpacity
        shadowBlur: Colors.shadowBlur
        shadowScale: Colors.shadowScale
        shadowVerticalOffset: Colors.shadowVerticalOffset
        shadowHorizontalOffset: 0
    }

    IslandShape {
        bodyWidth: root.width
        bodyHeight: root.height
        topRadius: ShellState.islandCornerRadius
        bottomRadius: ShellState.islandCornerRadius
        progress: 0
        fillColor: Colors.mainBgMica
    }

    // Clicks on the card stay on the card.
    MouseArea {
        anchors.fill: parent
        enabled: root.page !== ""
        onClicked: {}
    }

    // ---- Content ----
    Item {
        anchors.fill: parent
        clip: true

        Loader {
            id: loader
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            // Loaded while a page is open and until the card has shrunk away.
            active: root.page !== "" || root.width > 1
            sourceComponent: (root.componentFor && root.shownPage !== "") ? root.componentFor(root.shownPage) : null
            opacity: root.page === "" ? 0 : 1

            Behavior on opacity {
                NumberAnimation {
                    duration: ShellState.motionDuration(Motion.fadeMs)
                    easing.type: Easing.OutCubic
                }
            }

            // Content entrance: the card leads, the content follows after Motion.contentDelayMs.
            onItemChanged: {
                const item = loader.item as Item
                if (item) {
                    contentAnim.stop()
                    item.opacity = 0
                    item.scale = 0.94
                    contentAnim.start()
                }
            }

            SequentialAnimation {
                id: contentAnim
                PauseAnimation { duration: ShellState.motionDuration(Motion.contentDelayMs) }
                ParallelAnimation {
                    NumberAnimation {
                        target: loader.item
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: ShellState.motionDuration(Motion.fadeMs)
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: loader.item
                        property: "scale"
                        from: 0.94
                        to: 1.0
                        duration: ShellState.motionDuration(Motion.glideMs)
                        easing.type: Easing.OutBack
                        easing.overshoot: ShellState.motionIslandOvershoot() * 0.8
                    }
                }
            }
        }
    }

    HoverHandler { id: pointer }
}