// Subjects with a percentage covered. Drag a bar to set it; the header shows the average.
pragma ComponentBehavior: Bound

import QtQuick
import ".."
import "../../../core/shell"
import "../../../core/styles"

DashCard {
    id: card

    property bool adding: false

    readonly property real pad: Dimens.paddingMedium
    readonly property int overall: {
        var list = DashboardDataService.subjects
        if (list.length === 0) return 0
        var sum = 0
        for (var i = 0; i < list.length; i++) sum += list[i].percent
        return Math.round(sum / list.length)
    }

    function submit() {
        if (DashboardDataService.addSubject(nameInput.text)) {
            nameInput.clear()
            card.adding = false
        } else {
            nameInput.invalid = true
        }
    }

    Item {
        anchors.fill: parent
        anchors.margins: card.pad

        Item {
            id: header
            width: parent.width
            height: Dimens.fontSizeXl * 1.6

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: Dimens.spacingSm

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Study"
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeMd
                    font.bold: true
                    color: Colors.fg
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: DashboardDataService.subjects.length > 0
                    text: card.overall + "%"
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeSm
                    color: Colors.accent
                }
            }

            DashIconButton {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: card.adding ? "close" : "add"
                onClicked: card.adding = !card.adding
            }
        }

        Item {
            id: form
            anchors.top: header.bottom
            width: parent.width
            visible: card.adding
            height: visible ? nameInput.implicitHeight : 0

            DashInput {
                id: nameInput
                anchors.left: parent.left
                anchors.right: addButton.left
                anchors.rightMargin: Dimens.spacingSm
                placeholder: "Subject name"
                onAccepted: card.submit()
            }

            DashIconButton {
                id: addButton
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: "check"
                onClicked: card.submit()
            }
        }

        Flickable {
            id: flick
            anchors.top: form.bottom
            anchors.topMargin: Dimens.spacingSm
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            clip: true
            contentWidth: width
            contentHeight: list.height
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: list
                width: flick.width
                spacing: Dimens.spacingSm

                Repeater {
                    model: DashboardDataService.subjects

                    delegate: Item {
                        id: row
                        required property var modelData

                        // While dragging, the bar follows the pointer; the value is saved on release
                        // (saving rebuilds the list, which would end the drag).
                        property real dragPercent: -1
                        readonly property real shown: dragPercent >= 0 ? dragPercent : modelData.percent

                        width: list.width
                        height: nameText.height + Dimens.spacingSm / 2 + track.height + Dimens.spacingSm

                        Text {
                            id: nameText
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: percentText.left
                            anchors.rightMargin: Dimens.spacingSm
                            elide: Text.ElideRight
                            text: row.modelData.name
                            font.family: Fonts.text
                            font.pixelSize: Dimens.fontSizeSm
                            color: Colors.fg
                        }

                        Text {
                            id: percentText
                            anchors.top: parent.top
                            anchors.right: removeButton.left
                            anchors.rightMargin: Dimens.spacingSm
                            text: Math.round(row.shown) + "%"
                            font.family: Fonts.text
                            font.pixelSize: Dimens.fontSizeSm
                            color: Colors.fgMuted
                        }

                        DashIconButton {
                            id: removeButton
                            anchors.right: parent.right
                            anchors.verticalCenter: nameText.verticalCenter
                            text: "close"
                            onClicked: DashboardDataService.removeSubject(row.modelData.id)
                        }

                        Rectangle {
                            id: track
                            anchors.top: nameText.bottom
                            anchors.topMargin: Dimens.spacingSm / 2
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: Dimens.spacingSm
                            radius: height / 2
                            color: Colors.elevatedBg

                            Rectangle {
                                width: parent.width * row.shown / 100
                                height: parent.height
                                radius: parent.radius
                                color: Colors.accent
                            }
                        }

                        MouseArea {
                            anchors.fill: track
                            anchors.topMargin: -Dimens.spacingSm
                            anchors.bottomMargin: -Dimens.spacingSm
                            preventStealing: true
                            cursorShape: Qt.PointingHandCursor

                            function pointerPercent(mouse) {
                                return Math.max(0, Math.min(100, Math.round(mouse.x / width * 100)))
                            }

                            onPressed: (mouse) => row.dragPercent = pointerPercent(mouse)
                            onPositionChanged: (mouse) => { if (pressed) row.dragPercent = pointerPercent(mouse) }
                            onReleased: {
                                if (row.dragPercent >= 0) {
                                    DashboardDataService.setSubjectPercent(row.modelData.id, row.dragPercent)
                                }
                                row.dragPercent = -1
                            }
                        }
                    }
                }
            }
        }

        Text {
            anchors.centerIn: flick
            visible: DashboardDataService.subjects.length === 0 && !card.adding
            text: "No subjects yet"
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeSm
            color: Colors.fgMuted
        }
    }
}