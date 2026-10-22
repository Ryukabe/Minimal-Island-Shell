// Days left until dates you add (an exam, a deadline). The nearest upcoming date is shown big.
pragma ComponentBehavior: Bound

import QtQuick
import ".."
import "../../../core/shell"
import "../../../core/styles"

DashCard {
    id: card

    property bool adding: false
    property var now: new Date()

    readonly property real pad: Dimens.paddingMedium

    // Upcoming dates first (nearest on top), then past ones (most recent first).
    readonly property var entries: {
        var list = DashboardDataService.countdowns
        var out = []
        for (var i = 0; i < list.length; i++) {
            out.push({ id: list[i].id, label: list[i].label, days: card.daysUntil(list[i].date) })
        }
        out.sort(function (a, b) {
            var an = a.days < 0
            var bn = b.days < 0
            if (an !== bn) return an ? 1 : -1
            return an ? b.days - a.days : a.days - b.days
        })
        return out
    }

    function daysUntil(dateStr) {
        var p = dateStr.split("-")
        var target = new Date(parseInt(p[0]), parseInt(p[1]) - 1, parseInt(p[2]))
        var today = new Date(card.now.getFullYear(), card.now.getMonth(), card.now.getDate())
        return Math.round((target.getTime() - today.getTime()) / 86400000)
    }

    function bigText(days) { return days === 0 ? "Today" : String(Math.abs(days)) }

    function unitText(days) {
        if (days === 0) return ""
        var n = Math.abs(days)
        return (n === 1 ? "day" : "days") + (days > 0 ? " left" : " ago")
    }

    function shortText(days) {
        return days === 0 ? "Today" : Math.abs(days) + "d" + (days < 0 ? " ago" : "")
    }

    function submit() {
        if (!DashboardDataService.isValidDate(dateInput.text)) {
            dateInput.invalid = true
            return
        }
        if (labelInput.text.trim() === "") {
            labelInput.invalid = true
            return
        }
        DashboardDataService.addCountdown(labelInput.text, dateInput.text)
        labelInput.clear()
        dateInput.clear()
        card.adding = false
    }

    // Only replaces "now" when the day changes, so the list is not rebuilt every minute.
    Timer {
        interval: 60000
        repeat: true
        running: true
        onTriggered: {
            var n = new Date()
            if (n.getDate() !== card.now.getDate() || n.getMonth() !== card.now.getMonth()
                    || n.getFullYear() !== card.now.getFullYear()) {
                card.now = n
            }
        }
    }

    Item {
        anchors.fill: parent
        anchors.margins: card.pad

        Item {
            id: header
            width: parent.width
            height: Dimens.fontSizeXl * 1.6

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Countdown"
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeMd
                font.bold: true
                color: Colors.fg
            }

            DashIconButton {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: card.adding ? "close" : "add"
                onClicked: card.adding = !card.adding
            }
        }

        Column {
            id: form
            anchors.top: header.bottom
            width: parent.width
            visible: card.adding
            height: visible ? implicitHeight : 0
            spacing: Dimens.spacingSm

            DashInput {
                id: labelInput
                width: parent.width
                placeholder: "Name (e.g. Final exam)"
                onAccepted: dateInput.focusInput()
            }

            Item {
                width: parent.width
                height: dateInput.implicitHeight

                DashInput {
                    id: dateInput
                    anchors.left: parent.left
                    anchors.right: addButton.left
                    anchors.rightMargin: Dimens.spacingSm
                    placeholder: "YYYY-MM-DD"
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
                    model: card.entries

                    delegate: Item {
                        id: row
                        required property int index
                        required property var modelData
                        readonly property bool hero: index === 0

                        width: list.width
                        height: row.hero ? heroColumn.implicitHeight : Dimens.fontSizeMd * 1.8

                        Column {
                            id: heroColumn
                            visible: row.hero
                            width: parent.width

                            Text {
                                text: card.bigText(row.modelData.days)
                                font.family: Fonts.display
                                font.pixelSize: Dimens.fontSizeHuge
                                font.bold: true
                                color: Colors.accent
                            }

                            Text {
                                width: parent.width - Dimens.fontSizeLg * 1.5
                                elide: Text.ElideRight
                                text: card.unitText(row.modelData.days) === ""
                                    ? row.modelData.label
                                    : card.unitText(row.modelData.days) + "  ·  " + row.modelData.label
                                font.family: Fonts.text
                                font.pixelSize: Dimens.fontSizeSm
                                color: Colors.fgMuted
                            }
                        }

                        Item {
                            visible: !row.hero
                            anchors.fill: parent

                            Text {
                                anchors.left: parent.left
                                anchors.right: daysText.left
                                anchors.rightMargin: Dimens.spacingSm
                                anchors.verticalCenter: parent.verticalCenter
                                elide: Text.ElideRight
                                text: row.modelData.label
                                font.family: Fonts.text
                                font.pixelSize: Dimens.fontSizeSm
                                color: Colors.fg
                            }

                            Text {
                                id: daysText
                                anchors.right: removeButton.left
                                anchors.rightMargin: Dimens.spacingSm
                                anchors.verticalCenter: parent.verticalCenter
                                text: card.shortText(row.modelData.days)
                                font.family: Fonts.text
                                font.pixelSize: Dimens.fontSizeSm
                                color: Colors.fgMuted
                            }
                        }

                        DashIconButton {
                            id: removeButton
                            x: row.width - width
                            y: row.hero ? 0 : (row.height - height) / 2
                            text: "close"
                            onClicked: DashboardDataService.removeCountdown(row.modelData.id)
                        }
                    }
                }
            }
        }

        Text {
            anchors.centerIn: flick
            visible: card.entries.length === 0 && !card.adding
            text: "No dates yet"
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeSm
            color: Colors.fgMuted
        }
    }
}