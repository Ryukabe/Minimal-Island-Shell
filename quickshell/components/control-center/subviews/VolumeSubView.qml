pragma ComponentBehavior: Bound

import QtQuick
import "../../../styles"
import "../../../services"
import ".."

Item {
    id: root
    implicitWidth: 380
    implicitHeight: contentColumn.implicitHeight + 32

    signal backRequested()
    signal sinkRequested()

    Column {
        id: contentColumn
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 16
        spacing: 16

        // ---- Header with Back Button ----
        Item {
            width: parent.width
            height: 32

            Text {
                id: backBtn
                text: "arrow_back"
                font.family: Fonts.icon
                font.pixelSize: Dimens.fontSizeLg
                font.variableAxes: Fonts.iconAxes
                color: backMouse.containsMouse ? Colors.accent : Colors.fg
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

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
                text: "Volume"
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSize15
                font.bold: true
                color: Colors.fg
                anchors.left: backBtn.right
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // ---- Output device row (opens the device list) ----
        Rectangle {
            width: parent.width
            height: 48
            radius: ShellState.islandCornerRadius
            color: Colors.subBgMica
            border.width: 1
            border.color: Colors.border

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.sinkRequested()
            }

            Text {
                id: outIcon
                text: "speaker"
                font.family: Fonts.icon
                font.pixelSize: Dimens.fontSizeLg
                font.variableAxes: Fonts.iconAxes
                color: Colors.accent
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
            }

            Column {
                anchors.left: outIcon.right
                anchors.leftMargin: 10
                anchors.right: outChevron.left
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                spacing: 0

                Text {
                    text: "Output"
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeXs
                    color: Colors.fgMuted
                }
                Text {
                    width: parent.width
                    text: VolumeService.sinkLabel(VolumeService.sink)
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeSm
                    font.bold: true
                    color: Colors.fg
                    elide: Text.ElideRight
                }
            }

            Text {
                id: outChevron
                text: "chevron_right"
                font.family: Fonts.icon
                font.pixelSize: Dimens.fontSizeMd
                font.variableAxes: Fonts.iconAxes
                color: Colors.fgMuted
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // ---- Master volume ----
        Rectangle {
            width: parent.width
            height: masterColumn.implicitHeight + 24
            radius: ShellState.islandCornerRadius
            color: Colors.subBgMica
            border.width: 1
            border.color: Colors.border

            Column {
                id: masterColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8

                Item {
                    width: parent.width
                    height: 24

                    Text {
                        id: masterIcon
                        text: VolumeService.muted ? "volume_off" : "volume_up"
                        font.family: Fonts.icon
                        font.pixelSize: Dimens.fontSizeLg
                        font.variableAxes: Fonts.iconAxes
                        color: VolumeService.muted ? Colors.fgMuted : Colors.accent
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -6
                            cursorShape: Qt.PointingHandCursor
                            onClicked: VolumeService.toggleMute()
                        }
                    }

                    Text {
                        id: masterPct
                        text: VolumeService.muted ? "Muted" : VolumeService.percent + "%"
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeXs
                        color: Colors.fgMuted
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "Master"
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeSm
                        font.bold: true
                        color: Colors.fg
                        anchors.left: masterIcon.right
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                SliderControl {
                    id: masterSlider
                    width: parent.width
                    from: 0
                    to: 100
                    stepSize: 1
                    onMoved: (v) => VolumeService.setPercent(v)

                    Binding {
                        target: masterSlider
                        property: "value"
                        value: VolumeService.muted ? 0 : VolumeService.percent
                    }
                }
            }
        }

        // ---- Apps section label ----
        Text {
            text: "Apps"
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeXs
            font.bold: true
            color: Colors.fgMuted
        }

        // ---- Empty state ----
        Text {
            visible: VolumeService.appStreams.length === 0
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: "No apps are playing audio"
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeSm
            color: Colors.fgMuted
        }

        // ---- Per-app list (scrolls if there are many streams) ----
        Flickable {
            id: listFlick
            visible: VolumeService.appStreams.length > 0
            width: parent.width
            height: Math.min(listColumn.implicitHeight, 240)
            contentWidth: width
            contentHeight: listColumn.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: listColumn
                width: listFlick.width
                spacing: Dimens.spacingSm

                Repeater {
                    model: VolumeService.appStreams

                    delegate: Rectangle {
                        id: card
                        required property var modelData

                        width: listColumn.width
                        height: cardColumn.implicitHeight + 24
                        radius: ShellState.islandCornerRadius
                        color: Colors.subBgMica
                        border.width: 1
                        border.color: Colors.border

                        Column {
                            id: cardColumn
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 8

                            Item {
                                width: parent.width
                                height: 24

                                Text {
                                    id: muteIcon
                                    text: VolumeService.appMuted(card.modelData) ? "volume_off" : "volume_up"
                                    font.family: Fonts.icon
                                    font.pixelSize: Dimens.fontSizeLg
                                    font.variableAxes: Fonts.iconAxes
                                    color: VolumeService.appMuted(card.modelData) ? Colors.fgMuted : Colors.accent
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter

                                    MouseArea {
                                        anchors.fill: parent
                                        anchors.margins: -6
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: VolumeService.toggleAppMute(card.modelData)
                                    }
                                }

                                Text {
                                    id: pctText
                                    text: VolumeService.appMuted(card.modelData)
                                        ? "Muted"
                                        : VolumeService.appPercent(card.modelData) + "%"
                                    font.family: Fonts.text
                                    font.pixelSize: Dimens.fontSizeXs
                                    color: Colors.fgMuted
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: VolumeService.appName(card.modelData)
                                    font.family: Fonts.text
                                    font.pixelSize: Dimens.fontSizeSm
                                    font.bold: true
                                    color: Colors.fg
                                    elide: Text.ElideRight
                                    anchors.left: muteIcon.right
                                    anchors.leftMargin: 10
                                    anchors.right: pctText.left
                                    anchors.rightMargin: 10
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            SliderControl {
                                id: slider
                                width: parent.width
                                from: 0
                                to: 100
                                stepSize: 1
                                onMoved: (v) => VolumeService.setAppPercent(card.modelData, v)

                                Binding {
                                    target: slider
                                    property: "value"
                                    value: Math.min(100, VolumeService.appPercent(card.modelData))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}