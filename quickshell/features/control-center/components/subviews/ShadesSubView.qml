pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../../../core/shell"
import "../../../../core/styles"
import "../../../display"

Item {
    id: root
    implicitWidth: 380
    implicitHeight: 20 * 2 + header.implicitHeight + listFlick.Layout.preferredHeight + Dimens.spacingLg

    signal backRequested()

    readonly property real rowHeight: 44
    readonly property int maxVisibleRows: 6

    Component.onCompleted: HyprshadeService.refresh()

    component ShadeRow: Rectangle {
        id: row
        property string label: ""
        property bool active: false
        signal clicked()

        Layout.fillWidth: true
        Layout.preferredHeight: root.rowHeight
        radius: Dimens.radiusMedium
        color: row.active ? Colors.accent : (rowMouse.containsMouse ? Colors.elevatedBg : Colors.subBgMica)
        border.width: 1
        border.color: Colors.border

        Behavior on color { ColorAnimation { duration: ShellState.motionDuration(Motion.fadeMs) } }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: Dimens.paddingMedium
            anchors.verticalCenter: parent.verticalCenter
            text: row.label
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeSm
            color: row.active ? Colors.mainBgMica : Colors.fg
        }

        Text {
            visible: row.active
            anchors.right: parent.right
            anchors.rightMargin: Dimens.paddingMedium
            anchors.verticalCenter: parent.verticalCenter
            text: "check"
            font.family: Fonts.icon
            font.pixelSize: Dimens.fontSizeMd
            font.variableAxes: Fonts.iconAxes
            color: Colors.mainBgMica
        }

        MouseArea {
            id: rowMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: row.clicked()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: Dimens.spacingLg

        RowLayout {
            id: header
            spacing: Dimens.spacingSm

            Text {
                text: "arrow_back"
                font.family: Fonts.icon
                font.pixelSize: Dimens.fontSizeLg
                font.variableAxes: Fonts.iconAxes
                color: backMouse.containsMouse ? Colors.accent : Colors.fg

                MouseArea {
                    id: backMouse
                    anchors.fill: parent
                    anchors.margins: -8
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.backRequested()
                }
            }

            Text {
                text: "Shades"
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeLg
                font.bold: true
                color: Colors.fg
            }
        }

        // Scrolls once there are more shades than maxVisibleRows.
        Flickable {
            id: listFlick
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(list.implicitHeight, root.maxVisibleRows * (root.rowHeight + Dimens.spacingSm))
            contentWidth: width
            contentHeight: list.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: list
                width: listFlick.width
                spacing: Dimens.spacingSm

                ShadeRow {
                    label: "Off"
                    active: !HyprshadeService.enabled
                    onClicked: HyprshadeService.turnOff()
                }

                Repeater {
                    model: HyprshadeService.shades

                    delegate: ShadeRow {
                        required property string modelData
                        label: HyprshadeService.prettyName(modelData)
                        active: HyprshadeService.current === modelData
                        onClicked: HyprshadeService.select(modelData)
                    }
                }
            }
        }
    }
}