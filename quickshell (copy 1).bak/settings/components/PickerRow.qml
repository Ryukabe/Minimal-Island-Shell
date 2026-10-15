// components/PickerRow.qml — label + text field + "Choose" button that opens the select page.
// Reusable for any list: icon themes now, fonts and locations later.
//   strict: true  -> typed text must match an item (or be empty), otherwise it reverts
//   strict: false -> any typed text is accepted
//   searchable: true -> the list comes from searchHandler(query, done) as you type
//       (done(items | null, status)); pressing Enter in the field opens the select page
//       with that text already searched. Clearing the field and pressing Enter commits "".
// `placeholder: true` greys the row out, adds the "Coming soon" tag and ignores clicks
// (same meaning as ToggleRow). `hint` is the grey text shown in an empty field.
import QtQuick
import QtQuick.Layouts
import "../core"
import "../../services"
import "../../styles"

Item {
    id: root

    property string label: ""
    property string description: ""
    property string value: ""
    property string hint: ""
    property string pickerTitle: label
    property string searchHint: "Search..."
    property var items: []            // [{ value, label }] or plain strings
    property bool strict: true
    property bool searchable: false
    property var searchHandler: null  // function(query, done)
    property bool placeholder: false
    property bool showDivider: true

    signal committed(string value)

    readonly property real controlRadius: ShellState.radiusUniversal
        ? ShellState.islandCornerRadius
        : ShellState.customRadiusControl

    Layout.fillWidth: true
    implicitHeight: root.description !== "" ? 58 : 44
    enabled: !root.placeholder
    opacity: root.enabled ? 1.0 : 0.4

    Behavior on opacity {
        NumberAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
    }

    function _valueOf(it) { return typeof it === "string" ? it : it.value }
    function _labelOf(it) {
        return typeof it === "string" ? it : (it.label !== undefined ? it.label : it.value)
    }

    function _commit(raw) {
        var t = raw.trim()
        if (t === root.value) { input.text = root.value; return }
        if (t === "" || !root.strict) { root.committed(t); return }

        var lower = t.toLowerCase()
        for (var i = 0; i < root.items.length; i++) {
            var it = root.items[i]
            if (_valueOf(it).toLowerCase() === lower || _labelOf(it).toLowerCase() === lower) {
                root.committed(_valueOf(it))
                return
            }
        }
        // No match: put the current value back.
        input.text = root.value
    }

    function _accept(raw) {
        if (!root.searchable) { root._commit(raw); return }
        var t = raw.trim()
        if (t === root.value) return
        if (t === "") { root.committed(""); return }
        root.openPicker(t)
    }

    function _blur(raw) {
        if (!root.searchable) { root._commit(raw); return }
        input.text = root.value
    }

    function openPicker(initialQuery) {
        var opts = {
            title: root.pickerTitle,
            searchHint: root.searchHint,
            items: root.searchable ? [] : root.items,
            selectedValue: root.searchable ? "" : root.value,
            initialQuery: initialQuery || "",
            onPick: function (v) { root.committed(v) }
        }
        if (root.searchable) {
            opts.onSearch = function (q) {
                if (!root.searchHandler) return
                root.searchHandler(q, function (items, status) {
                    if (items !== null && items !== undefined) SettingsPicker.setItems(items)
                    SettingsPicker.status = status || ""
                })
            }
        }
        SettingsPicker.open(opts)
    }

    onValueChanged: input.text = root.value
    Component.onCompleted: input.text = root.value

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Dimens.paddingMedium
        anchors.rightMargin: Dimens.paddingMedium
        spacing: Dimens.spacingSmall

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: root.label
                color: Colors.fg
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeBase
                elide: Text.ElideRight
            }

            Text {
                visible: root.description !== ""
                Layout.fillWidth: true
                text: root.description
                color: Colors.subtext
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeXs
                elide: Text.ElideRight
            }
        }

        ComingSoonTag {
            visible: root.placeholder
        }

        Rectangle {
            Layout.preferredWidth: 180
            Layout.preferredHeight: 32
            Layout.alignment: Qt.AlignVCenter
            radius: root.controlRadius
            color: Colors.subBgMica
            border.width: 1
            border.color: input.activeFocus ? Colors.accent : "transparent"

            Behavior on border.color {
                ColorAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Dimens.paddingMedium
                text: root.hint
                color: Colors.fgMuted
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeMd
                elide: Text.ElideRight
                visible: input.text.length === 0 && !input.activeFocus
            }

            TextInput {
                id: input
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Dimens.paddingMedium
                color: Colors.fg
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeMd
                clip: true
                selectByMouse: true

                onAccepted: root._accept(text)
                onActiveFocusChanged: if (!activeFocus) root._blur(text)

                Keys.onEscapePressed: (event) => {
                    text = root.value
                    focus = false
                    event.accepted = true
                }
            }
        }

        ActionButton {
            Layout.alignment: Qt.AlignVCenter
            text: "Choose"
            onClicked: root.openPicker("")
        }
    }

    Rectangle {
        visible: root.showDivider
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Dimens.paddingMedium
        anchors.rightMargin: Dimens.paddingMedium
        height: 1
        color: Colors.border
        opacity: 0.35
    }
}