// Quick note: a small Markdown editor. Buttons insert the Markdown markers, and the note is shown
// formatted when you are not editing. The Save button writes at once; the note also autosaves.
pragma ComponentBehavior: Bound

import QtQuick
import ".."
import "../../../core/shell"
import "../../../core/styles"

DashCard {
    id: card

    readonly property real pad: Dimens.paddingMedium
    property bool editing: false

    component FmtButton: Rectangle {
        id: btn
        property string glyph: ""
        signal clicked()

        width: Dimens.fontSizeXl * 1.35
        height: width
        radius: Dimens.radiusControl
        color: area.containsMouse ? Colors.elevatedBg : "transparent"

        Behavior on color { ColorAnimation { duration: Motion.hoverMs } }

        Text {
            anchors.centerIn: parent
            text: btn.glyph
            font.family: Fonts.icon
            font.pixelSize: Dimens.fontSizeLg
            font.variableAxes: Fonts.iconAxes
            color: Colors.fg
        }

        MouseArea {
            id: area
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.clicked()
        }
    }

    // ---------- editing helpers ----------
    function focusEditor() {
        Qt.callLater(function () {
            edit.forceActiveFocus()
            edit.cursorPosition = edit.length
        })
    }

    function toggleEditing() {
        card.editing = !card.editing
        if (card.editing) card.focusEditor()
    }

    // **bold** and _italic_: wraps the selection, unwraps it if it is already wrapped,
    // or inserts an empty pair with the cursor between.
    function wrap(marker) {
        var s = edit.selectionStart
        var e = edit.selectionEnd
        var t = edit.text
        var m = marker.length
        if (s === e) {
            edit.insert(s, marker + marker)
            edit.cursorPosition = s + m
        } else if (s >= m && t.substr(s - m, m) === marker && t.substr(e, m) === marker) {
            edit.remove(e, e + m)
            edit.remove(s - m, s)
            edit.select(s - m, e - m)
        } else {
            var sel = t.substring(s, e)
            edit.remove(s, e)
            edit.insert(s, marker + sel + marker)
            edit.select(s + m, e + m)
        }
        edit.forceActiveFocus()
    }

    function _lineRange() {
        var t = edit.text
        var s = edit.selectionStart
        var e = edit.selectionEnd
        var eEff = (e > s && t.charAt(e - 1) === "\n") ? e - 1 : e
        var from = s > 0 ? t.lastIndexOf("\n", s - 1) + 1 : 0
        var to = t.indexOf("\n", eEff)
        if (to < 0) to = t.length
        return { from: from, to: to }
    }

    function _stripPrefix(line) {
        return line.replace(/^(#{1,6} |[-*+] |\d+\. )/, "")
    }

    // kind: "h" = heading, "b" = bullet list, "n" = numbered list. Toggles on the selected lines.
    function toggleLinePrefix(kind) {
        var r = card._lineRange()
        var lines = edit.text.substring(r.from, r.to).split("\n")
        var re = kind === "h" ? /^# / : kind === "b" ? /^- / : /^\d+\. /
        var allHave = lines.every(function (l) { return re.test(l) })
        var out = lines.map(function (l, i) {
            var base = card._stripPrefix(l)
            if (allHave) return base
            return (kind === "h" ? "# " : kind === "b" ? "- " : (i + 1) + ". ") + base
        })
        var block = out.join("\n")
        edit.remove(r.from, r.to)
        edit.insert(r.from, block)
        edit.cursorPosition = r.from + block.length
        edit.forceActiveFocus()
    }

    Component.onDestruction: QuickNoteService.flush()

    Item {
        id: body
        anchors.fill: parent
        anchors.margins: card.pad

        Item {
            id: header
            width: parent.width
            height: modeButton.height

            Row {
                id: toolbar
                spacing: 2
                visible: card.editing && ShellState.dashboardNoteShowToolbar

                FmtButton { glyph: "format_h1"; onClicked: card.toggleLinePrefix("h") }
                FmtButton { glyph: "format_list_bulleted"; onClicked: card.toggleLinePrefix("b") }
                FmtButton { glyph: "format_list_numbered"; onClicked: card.toggleLinePrefix("n") }
                FmtButton { glyph: "format_bold"; onClicked: card.wrap("**") }
                FmtButton { glyph: "format_italic"; onClicked: card.wrap("_") }
            }

            Text {
                id: titleLabel
                anchors.verticalCenter: parent.verticalCenter
                visible: !toolbar.visible
                text: "Quick note"
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeSm
                font.bold: true
                color: Colors.fgMuted
            }

            FmtButton {
                id: modeButton
                anchors.right: parent.right
                glyph: card.editing ? "visibility" : "edit"
                onClicked: card.toggleEditing()
            }

            // Accent Save button: icon + label when there is room, icon only on a narrow card.
            Rectangle {
                id: saveButton

                property bool justSaved: false
                readonly property real padX: Dimens.paddingSm
                readonly property real fullWidth: saveIcon.implicitWidth + 4 + saveLabel.implicitWidth + padX * 2
                readonly property real leftWidth: toolbar.visible ? toolbar.implicitWidth : titleLabel.implicitWidth
                readonly property bool roomy: header.width >= leftWidth + modeButton.width + fullWidth + Dimens.spacingSm * 2

                anchors.right: modeButton.left
                anchors.rightMargin: Dimens.spacingSm
                anchors.verticalCenter: parent.verticalCenter
                height: modeButton.height
                width: roomy ? fullWidth : height
                radius: Dimens.radiusControl
                color: saveMouse.pressed ? Qt.darker(Colors.accent, 1.15) : Colors.accent

                Behavior on color { ColorAnimation { duration: Motion.hoverMs } }

                Row {
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        id: saveIcon
                        anchors.verticalCenter: parent.verticalCenter
                        text: saveButton.justSaved ? "check" : "save"
                        font.family: Fonts.icon
                        font.pixelSize: Dimens.fontSizeLg
                        font.variableAxes: Fonts.iconAxes
                        color: Colors.bg
                    }

                    Text {
                        id: saveLabel
                        anchors.verticalCenter: parent.verticalCenter
                        visible: saveButton.roomy
                        text: saveButton.justSaved ? "Saved" : "Save"
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeSm
                        font.bold: true
                        color: Colors.bg
                    }
                }

                Timer {
                    id: savedReset
                    interval: 1200
                    onTriggered: saveButton.justSaved = false
                }

                MouseArea {
                    id: saveMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        QuickNoteService.saveNow()
                        saveButton.justSaved = true
                        savedReset.restart()
                    }
                }
            }
        }

        Flickable {
            id: flick
            anchors.top: header.bottom
            anchors.topMargin: Dimens.spacingSm
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            contentWidth: width
            contentHeight: card.editing ? edit.height : Math.max(preview.height, flick.height)

            function ensureVisible(r) {
                if (contentY >= r.y) contentY = r.y
                else if (contentY + height <= r.y + r.height) contentY = r.y + r.height - height
            }

            TextEdit {
                id: edit
                width: flick.width
                height: Math.max(contentHeight, flick.height)
                visible: card.editing
                wrapMode: TextEdit.Wrap
                selectByMouse: true
                persistentSelection: true
                textFormat: TextEdit.PlainText
                color: Colors.fg
                selectionColor: Colors.accent
                selectedTextColor: Colors.bg
                font.family: Fonts.text
                font.pixelSize: Dimens.scaledFont(ShellState.dashboardNoteFontSize)

                Component.onCompleted: text = QuickNoteService.text
                onTextChanged: if (text !== QuickNoteService.text) QuickNoteService.setText(text)
                onCursorRectangleChanged: flick.ensureVisible(cursorRectangle)

                // Enter continues a bullet or numbered list; Enter on an empty item ends it.
                Keys.onPressed: (event) => {
                    if ((event.key !== Qt.Key_Return && event.key !== Qt.Key_Enter) || (event.modifiers & Qt.ShiftModifier)) return
                    var pos = edit.cursorPosition
                    var t = edit.text
                    var from = pos > 0 ? t.lastIndexOf("\n", pos - 1) + 1 : 0
                    var line = t.substring(from, pos)
                    var m = /^(- |(\d+)\. )/.exec(line)
                    if (!m) return
                    if (line.length === m[0].length) {
                        edit.remove(from, pos)
                    } else {
                        var next = m[2] !== undefined ? (parseInt(m[2]) + 1) + ". " : "- "
                        edit.insert(pos, "\n" + next)
                        edit.cursorPosition = pos + 1 + next.length
                    }
                    event.accepted = true
                }

                Text {
                    visible: edit.text === ""
                    text: "Write in Markdown…"
                    font: edit.font
                    color: Colors.fgMuted
                }
            }

            Text {
                id: preview
                width: flick.width
                visible: !card.editing
                wrapMode: Text.Wrap
                textFormat: Text.MarkdownText
                text: QuickNoteService.text !== "" ? QuickNoteService.text : "*Tap to write a note…*"
                color: QuickNoteService.text !== "" ? Colors.fg : Colors.fgMuted
                font.family: Fonts.text
                font.pixelSize: Dimens.scaledFont(ShellState.dashboardNoteFontSize)
            }
        }

        // Tap the formatted note to start editing.
        MouseArea {
            anchors.fill: flick
            visible: !card.editing
            cursorShape: Qt.IBeamCursor
            onClicked: card.toggleEditing()
        }
    }

    Connections {
        target: QuickNoteService
        function onTextChanged() {
            if (edit.text !== QuickNoteService.text) edit.text = QuickNoteService.text
        }
    }
}