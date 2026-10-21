// Month calendar. Arrows change month. Tap the month name and type a month and year to jump
// anywhere ("3/2018", "2018-03", "Mar 2018" or just "2018"). The "today" button returns to now.
pragma ComponentBehavior: Bound

import QtQuick
import "../../../core/shell"
import "../../../core/styles"

DashCard {
    id: card

    property int monthOffset: 0
    property var now: new Date()
    property bool editingTitle: false
    property bool titleInvalid: false

    readonly property real pad: Dimens.paddingMedium
    readonly property int weekStart: ({ "Sunday": 0, "Monday": 1, "Saturday": 6 })[ShellState.dashboardCalendarWeekStart] || 0
    readonly property var viewDate: new Date(now.getFullYear(), now.getMonth() + monthOffset, 1)
    readonly property int daysInMonth: new Date(viewDate.getFullYear(), viewDate.getMonth() + 1, 0).getDate()
    readonly property int leading: (viewDate.getDay() - weekStart + 7) % 7
    readonly property int weeks: Math.ceil((leading + daysInMonth) / 7)

    readonly property var cells: {
        var out = []
        for (var i = 0; i < card.weeks * 7; i++) {
            var d = new Date(card.viewDate.getFullYear(), card.viewDate.getMonth(), i - card.leading + 1)
            out.push({
                day: d.getDate(),
                inMonth: d.getMonth() === card.viewDate.getMonth(),
                today: d.getFullYear() === card.now.getFullYear()
                    && d.getMonth() === card.now.getMonth()
                    && d.getDate() === card.now.getDate()
            })
        }
        return out
    }

    readonly property real cellFont: Math.max(Dimens.fontSizeXs, Math.min(Dimens.fontSizeLg,
        Math.min(calGrid.width / 7, calGrid.height / Math.max(1, card.weeks)) * 0.4))

    readonly property var englishMonths: ["january", "february", "march", "april", "may", "june",
        "july", "august", "september", "october", "november", "december"]

    // Returns { month: 0-11, year } or null when the text cannot be read.
    function parseMonthYear(raw) {
        var s = raw.trim()
        var mo = 0
        var yr = 0
        var m = /^(\d{1,2})\s*[\/\-.\s]\s*(\d{4})$/.exec(s)
        if (m) {
            mo = parseInt(m[1])
            yr = parseInt(m[2])
        } else if ((m = /^(\d{4})\s*[\/\-.\s]\s*(\d{1,2})$/.exec(s))) {
            yr = parseInt(m[1])
            mo = parseInt(m[2])
        } else if ((m = /^([A-Za-z]{3,})\.?\s*,?\s*(\d{4})$/.exec(s))) {
            var name = m[1].toLowerCase()
            yr = parseInt(m[2])
            for (var i = 0; i < 12; i++) {
                var local = Qt.locale().monthName(i, Locale.LongFormat).toLowerCase()
                if (local.indexOf(name) === 0 || card.englishMonths[i].indexOf(name) === 0) {
                    mo = i + 1
                    break
                }
            }
        } else if (/^\d{4}$/.test(s)) {
            yr = parseInt(s)
            mo = card.viewDate.getMonth() + 1
        }
        if (mo < 1 || mo > 12 || yr < 1000 || yr > 9999) return null
        return { month: mo - 1, year: yr }
    }

    function startTitleEdit() {
        titleInput.text = (card.viewDate.getMonth() + 1) + "/" + card.viewDate.getFullYear()
        card.titleInvalid = false
        card.editingTitle = true
        Qt.callLater(function () {
            titleInput.forceActiveFocus()
            titleInput.selectAll()
        })
    }

    function applyTitle(raw) {
        var parsed = card.parseMonthYear(raw)
        if (!parsed) {
            card.titleInvalid = true
            return
        }
        card.monthOffset = (parsed.year - card.now.getFullYear()) * 12 + (parsed.month - card.now.getMonth())
        card.editingTitle = false
    }

    // Only replaces "now" when the day actually changes, so the grid is not rebuilt every minute.
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

            Item {
                id: titleBox
                height: parent.height
                width: card.editingTitle ? titleInput.width : titleText.implicitWidth

                Text {
                    id: titleText
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !card.editingTitle
                    text: Qt.locale().monthName(card.viewDate.getMonth(), Locale.LongFormat) + " " + card.viewDate.getFullYear()
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeMd
                    font.bold: true
                    color: titleMouse.containsMouse ? Colors.accent : Colors.fg

                    MouseArea {
                        id: titleMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.IBeamCursor
                        onClicked: card.startTitleEdit()
                    }
                }

                TextInput {
                    id: titleInput
                    anchors.verticalCenter: parent.verticalCenter
                    visible: card.editingTitle
                    width: Math.max(implicitWidth, Dimens.fontSizeMd * 7)
                    clip: true
                    selectByMouse: true
                    inputMethodHints: Qt.ImhNoPredictiveText
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeMd
                    font.bold: true
                    color: Colors.fg
                    selectionColor: Colors.accent
                    selectedTextColor: Colors.bg

                    onTextChanged: card.titleInvalid = false
                    onAccepted: card.applyTitle(text)
                    Keys.onEscapePressed: (event) => {
                        card.editingTitle = false
                        event.accepted = true
                    }
                    onActiveFocusChanged: if (!activeFocus) card.editingTitle = false

                    Text {
                        visible: titleInput.text === ""
                        text: "month/year"
                        font: titleInput.font
                        color: Colors.fgMuted
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: -2
                        height: 1
                        color: card.titleInvalid ? Colors.red : Colors.accent
                    }
                }
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: Dimens.spacingSm

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: card.monthOffset !== 0
                    text: "today"
                    font.family: Fonts.icon
                    font.pixelSize: Dimens.fontSizeLg
                    font.variableAxes: Fonts.iconAxes
                    color: todayMouse.containsMouse ? Colors.accent : Colors.fgMuted

                    MouseArea {
                        id: todayMouse
                        anchors.fill: parent
                        anchors.margins: -Dimens.spacingSm / 2
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: card.monthOffset = 0
                    }
                }

                Repeater {
                    model: ["chevron_left", "chevron_right"]

                    delegate: Text {
                        id: arrow
                        required property int index
                        required property string modelData
                        text: arrow.modelData
                        font.family: Fonts.icon
                        font.pixelSize: Dimens.fontSizeXl
                        font.variableAxes: Fonts.iconAxes
                        color: arrowMouse.containsMouse ? Colors.accent : Colors.fg

                        MouseArea {
                            id: arrowMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: card.monthOffset += arrow.index === 0 ? -1 : 1
                        }
                    }
                }
            }
        }

        Row {
            id: weekdays
            anchors.top: header.bottom
            width: parent.width

            Repeater {
                model: 7

                delegate: Text {
                    required property int index
                    width: weekdays.width / 7
                    horizontalAlignment: Text.AlignHCenter
                    text: Qt.locale().dayName((card.weekStart + index) % 7, Locale.NarrowFormat)
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeXSm
                    color: Colors.fgMuted
                }
            }
        }

        Item {
            id: calGrid
            anchors.top: weekdays.bottom
            anchors.topMargin: Dimens.spacingSm
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            Repeater {
                model: card.cells

                delegate: Item {
                    id: cell
                    required property int index
                    required property var modelData

                    x: (index % 7) * (calGrid.width / 7)
                    y: Math.floor(index / 7) * (calGrid.height / card.weeks)
                    width: calGrid.width / 7
                    height: calGrid.height / card.weeks
                    visible: cell.modelData.inMonth || ShellState.dashboardCalendarShowOutsideDays

                    Rectangle {
                        anchors.centerIn: parent
                        width: Math.min(parent.width, parent.height) * 0.86
                        height: width
                        radius: width / 2
                        color: Colors.accent
                        visible: cell.modelData.today
                    }

                    Text {
                        anchors.centerIn: parent
                        text: cell.modelData.day
                        font.family: Fonts.text
                        font.pixelSize: card.cellFont
                        font.bold: cell.modelData.today
                        color: cell.modelData.today ? Colors.bg : (cell.modelData.inMonth ? Colors.fg : Colors.fgMuted)
                        opacity: cell.modelData.inMonth ? 1.0 : 0.5
                    }
                }
            }
        }
    }
}