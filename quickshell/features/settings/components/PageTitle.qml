// components/PageTitle.qml — header card at the top of every page.
// Shows a breadcrumb ("Bar & Island › Clock"). Inside a view the icon badge is replaced by a back arrow,
// and every crumb except the last is clickable (it goes back). The badge icon plays its own motion
// whenever the page changes; the back arrow nudges on hover.
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../../core/styles"
import "../../../core/shell"

Rectangle {
    id: root

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property var crumbs: []
    property bool showSubtitle: false
    property bool canGoBack: false
    signal backClicked()
    signal crumbClicked(int index)

    readonly property var shownCrumbs: root.crumbs.length > 0 ? root.crumbs : [root.title]

    Layout.fillWidth: true
    implicitHeight: 64
    radius: Dimens.settingsContainerRadius
    color: Colors.subBgMica
    border.color: Colors.border
    border.width: 1

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Dimens.paddingMedium
        anchors.rightMargin: Dimens.paddingMedium
        spacing: Dimens.spacingMedium

        Rectangle {
            visible: root.canGoBack
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            radius: 20
            color: backMouse.containsMouse ? Colors.elevatedBg : "transparent"

            Behavior on color {
                ColorAnimation { duration: ShellState.motionDuration(Motion.hoverMs) }
            }

            SymbolIcon {
                anchors.centerIn: parent
                name: "arrow_back"
                size: Dimens.fontSizeXxl
                color: Colors.fg
                animated: true
                hovered: backMouse.containsMouse
            }

            MouseArea {
                id: backMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.backClicked()
            }
        }

        Rectangle {
            visible: !root.canGoBack
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            radius: 20
            color: Colors.elevatedBg

            SymbolIcon {
                anchors.centerIn: parent
                name: root.icon
                size: Dimens.fontSizeXxl
                color: Colors.accent
                animated: true
                playOnLoad: true
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            RowLayout {
                Layout.fillWidth: true
                spacing: Dimens.spacingSmall

                Repeater {
                    model: root.shownCrumbs

                    delegate: RowLayout {
                        id: crumb

                        required property string modelData
                        required property int index
                        readonly property bool isLast: crumb.index === root.shownCrumbs.length - 1

                        Layout.fillWidth: crumb.isLast
                        spacing: Dimens.spacingSmall

                        SymbolIcon {
                            visible: crumb.index > 0
                            name: "chevron_right"
                            size: Dimens.fontSizeXxl
                            color: Colors.fgMuted
                        }

                        Text {
                            Layout.fillWidth: crumb.isLast
                            text: crumb.modelData
                            color: (crumb.isLast || crumbMouse.containsMouse) ? Colors.fg : Colors.fgMuted
                            font.family: Fonts.display
                            font.pixelSize: Dimens.fontSizeXl
                            font.weight: crumb.isLast ? Font.Bold : Font.Normal
                            elide: Text.ElideRight

                            Behavior on color {
                                ColorAnimation { duration: ShellState.motionDuration(Motion.hoverMs) }
                            }

                            MouseArea {
                                id: crumbMouse
                                anchors.fill: parent
                                enabled: !crumb.isLast
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.crumbClicked(crumb.index)
                            }
                        }
                    }
                }
            }

            Text {
                visible: root.showSubtitle && root.subtitle !== ""
                Layout.fillWidth: true
                text: root.subtitle
                color: Colors.fgMuted
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeXs
                elide: Text.ElideRight
            }
        }
    }
}