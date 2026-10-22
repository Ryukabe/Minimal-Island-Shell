// A simple checklist. Type at the bottom and press Enter to add; tap the box to tick an item.
pragma ComponentBehavior: Bound

import QtQuick
import ".."
import "../../../core/shell"
import "../../../core/styles"

DashCard {
    id: card

    readonly property real pad: Dimens.paddingMedium
    readonly property int total: DashboardDataService.checklist.length
    readonly property int doneCount: {
        var list = DashboardDataService.checklist
        var n = 0
        for (var i = 0; i < list.length; i++) if (list[i].done) n++
        return n
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
                    text: "Checklist"
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeMd
                    font.bold: true
                    color: Colors.fg
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: card.total > 0
                    text: card.doneCount + "/" + card.total
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeSm
                    color: Colors.fgMuted
                }
            }

            DashIconButton {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                visible: card.doneCount > 0
                text: "delete_sweep"
                onClicked: DashboardDataService.clearDone()
            }
        }

        Flickable {
            id: flick
            anchors.top: header.bottom
            anchors.topMargin: Dimens.spacingSm
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: input.top
            anchors.bottomMargin: Dimens.spacingSm
            clip: true
            contentWidth: width
            contentHeight: list.height
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: list
                width: flick.width

                Repeater {
                    model: DashboardDataService.checklist

                    delegate: Item {
                        id: row
                        required property var modelData

                        width: list.width
                        height: Math.max(check.height, label.height) + Dimens.spacingSm / 2

                        DashIconButton {
                            id: check
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: row.modelData.done ? "check_box" : "check_box_outline_blank"
                            active: row.modelData.done
                            onClicked: DashboardDataService.toggleItem(row.modelData.id)
                        }

                        Text {
                            id: label
                            anchors.left: check.right
                            anchors.leftMargin: Dimens.spacingSm
                            anchors.right: removeButton.left
                            anchors.rightMargin: Dimens.spacingSm
                            anchors.verticalCenter: parent.verticalCenter
                            wrapMode: Text.WordWrap
                            text: row.modelData.text
                            font.family: Fonts.text
                            font.pixelSize: Dimens.fontSizeSm
                            font.strikeout: row.modelData.done
                            color: row.modelData.done ? Colors.fgMuted : Colors.fg
                        }

                        DashIconButton {
                            id: removeButton
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: "close"
                            onClicked: DashboardDataService.removeItem(row.modelData.id)
                        }
                    }
                }
            }
        }

        Text {
            anchors.centerIn: flick
            visible: card.total === 0
            text: "Nothing to do"
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeSm
            color: Colors.fgMuted
        }

        DashInput {
            id: input
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            placeholder: "Add an item"
            onAccepted: {
                DashboardDataService.addItem(input.text)
                input.clear()
            }
        }
    }
}