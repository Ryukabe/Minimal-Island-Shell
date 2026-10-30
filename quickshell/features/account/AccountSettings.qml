// features/account/AccountSettings.qml — the Accounts menu.
// Pick an account at the top; the cards below act on it. Adding an account opens a form.
// Everything runs through AccountService, which asks for authentication through polkit.
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../settings/components"
import "."
import "../../core/shell"
import "../../core/styles"

PageScroll {
    id: root

    property string selectedUser: AccountService.currentUser
    property bool adding: false
    property bool newAdmin: false
    property bool confirmRemove: false

    readonly property var selected: AccountService.findUser(root.selectedUser)
    readonly property bool isSelf: root.selectedUser === AccountService.currentUser
    readonly property var userNames: AccountService.users.map(u => u.name)

    function syncName() {
        nameField.text = root.selected ? root.selected.fullName : ""
    }

    onSelectedChanged: root.syncName()
    onSelectedUserChanged: root.confirmRemove = false
    Component.onCompleted: root.syncName()

    // An account that was removed can no longer stay selected.
    onUserNamesChanged: {
        if (root.userNames.length > 0 && root.userNames.indexOf(root.selectedUser) < 0)
            root.selectedUser = AccountService.currentUser
    }

    function submitPassword() {
        if (pw1.text !== pw2.text) {
            AccountService.report("The two passwords don't match", false)
            return
        }
        AccountService.setPassword(root.selectedUser, pw1.text)
    }

    function submitAdd() {
        if (newPw.text !== newPw2.text) {
            AccountService.report("The two passwords don't match", false)
            return
        }
        AccountService.addUser(newName.text, newFull.text, newPw.text, root.newAdmin)
    }

    // Password fields are always cleared once a request finishes, whether it worked or not.
    Connections {
        target: AccountService

        function onFinished(op, ok) {
            if (op === "password") {
                pw1.text = ""
                pw2.text = ""
            } else if (op === "add") {
                newPw.text = ""
                newPw2.text = ""
                if (ok) {
                    newName.text = ""
                    newFull.text = ""
                    root.newAdmin = false
                    root.adding = false
                }
            } else if (op === "remove" && ok) {
                root.selectedUser = AccountService.currentUser
            }
        }
    }

    Timer {
        id: confirmTimer
        interval: 4000
        onTriggered: root.confirmRemove = false
    }

    // ---- Small building blocks ----
    component AccountField: Item {
        id: field

        property string label: ""
        property string placeholder: ""
        property bool secret: false
        property string buttonText: ""
        property bool buttonBusy: false
        property bool buttonEnabled: true
        property alias text: input.text
        signal submitted()

        Layout.fillWidth: true
        implicitHeight: 56

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Dimens.paddingMedium
            anchors.rightMargin: Dimens.paddingMedium
            spacing: Dimens.spacingMedium

            Text {
                Layout.preferredWidth: 150
                text: field.label
                elide: Text.ElideRight
                color: Colors.fg
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeMd
            }

            // Underline style: no box, just a line that lights up in the accent color on focus.
            TextField {
                id: input
                Layout.fillWidth: true
                echoMode: field.secret ? TextInput.Password : TextInput.Normal
                placeholderText: field.placeholder
                selectByMouse: true
                leftPadding: 0
                rightPadding: 0
                color: Colors.fg
                placeholderTextColor: Colors.subtext
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeMd
                onAccepted: field.submitted()

                background: Item {
                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: input.activeFocus ? 2 : 1
                        radius: height / 2
                        color: input.activeFocus ? Colors.accent : Colors.fgMuted

                        Behavior on color {
                            ColorAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
                        }
                    }
                }
            }

            ActionButton {
                visible: field.buttonText !== ""
                text: field.buttonText
                primary: true
                busy: field.buttonBusy
                enabled: field.buttonEnabled
                onClicked: field.submitted()
            }
        }
    }

    component Note: Text {
        Layout.fillWidth: true
        leftPadding: Dimens.paddingSmall
        wrapMode: Text.WordWrap
        color: Colors.subtext
        font.family: Fonts.text
        font.pixelSize: Dimens.fontSizeXs
    }

    // ---- Result of the last action ----
    Reveal {
        shown: AccountService.statusText !== ""

        Text {
            Layout.fillWidth: true
            leftPadding: Dimens.paddingSmall
            wrapMode: Text.WordWrap
            text: AccountService.statusText
            color: AccountService.statusOk ? Colors.green : Colors.red
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeMd
        }
    }

    // ---- Account ----
    SectionLabel { text: "Account" }

    GroupCard {
        DropdownRow {
            label: "Account"
            options: root.userNames
            selectedValue: root.selectedUser
            onOptionSelected: (value) => root.selectedUser = value
        }

        InfoRow {
            label: "Login name"
            value: root.selected ? root.selected.name : ""
        }

        InfoRow {
            label: "Account type"
            value: AccountService.isAdmin(root.selectedUser) ? "Administrator" : "Standard"
        }

        InfoRow {
            label: "Home folder"
            value: root.selected ? root.selected.home : ""
            showDivider: false
        }
    }

    // ---- Display name ----
    SectionLabel { text: "Display name" }

    GroupCard {
        AccountField {
            id: nameField
            label: "Display name"
            placeholder: "Full name"
            buttonText: "Save"
            buttonBusy: AccountService.busy && AccountService.busyOp === "name"
            buttonEnabled: !AccountService.busy && root.selected !== null
            onSubmitted: AccountService.setFullName(root.selectedUser, nameField.text)
        }
    }

    Note {
        text: "The full name that some apps and login screens show. The login name itself is not changed."
    }

    // ---- Password ----
    SectionLabel { text: "Password" }

    GroupCard {
        AccountField {
            id: pw1
            label: "New password"
            secret: true
            placeholder: "New password"
        }

        AccountField {
            id: pw2
            label: "Confirm"
            secret: true
            placeholder: "Type it again"
            buttonText: "Change"
            buttonBusy: AccountService.busy && AccountService.busyOp === "password"
            buttonEnabled: !AccountService.busy && root.selected !== null
            onSubmitted: root.submitPassword()
        }
    }

    Note {
        text: "You'll be asked to authenticate as an administrator. The current password is not needed."
    }

    // ---- Add account ----
    SectionLabel { text: "Add account" }

    GroupCard {
        ButtonRow {
            label: "New account"
            description: "Create another user on this computer"
            buttonText: root.adding ? "Cancel" : "Add"
            showDivider: false
            onClicked: root.adding = !root.adding
        }
    }

    Reveal {
        shown: root.adding

        GroupCard {
            AccountField {
                id: newName
                label: "Login name"
                placeholder: "lowercase, for example sam"
            }

            AccountField {
                id: newFull
                label: "Display name"
                placeholder: "Full name (optional)"
            }

            AccountField {
                id: newPw
                label: "Password"
                secret: true
                placeholder: "Password"
            }

            AccountField {
                id: newPw2
                label: "Confirm"
                secret: true
                placeholder: "Type it again"
                onSubmitted: root.submitAdd()
            }

            ToggleRow {
                visible: AccountService.adminGroup !== ""
                label: "Administrator"
                description: "Can run admin commands (member of the " + AccountService.adminGroup + " group)"
                checked: root.newAdmin
                onToggled: (val) => root.newAdmin = val
            }

            ButtonRow {
                label: "Create account"
                description: "Makes the account and its home folder"
                buttonText: "Create"
                enabled: !AccountService.busy
                showDivider: false
                onClicked: root.submitAdd()
            }
        }
    }

    // ---- Remove account ----
    SectionLabel { text: "Remove account" }

    GroupCard {
        ButtonRow {
            label: root.isSelf ? "Remove account" : "Remove " + root.selectedUser
            description: root.isSelf
                ? "You can't remove the account you're signed in to"
                : (root.confirmRemove
                    ? "Press again to confirm. The home folder is kept."
                    : "The account is deleted but its home folder stays on disk")
            buttonText: root.confirmRemove ? "Confirm" : "Remove"
            enabled: !root.isSelf && !AccountService.busy && root.selected !== null
            showDivider: false
            onClicked: {
                if (!root.confirmRemove) {
                    root.confirmRemove = true
                    confirmTimer.restart()
                } else {
                    root.confirmRemove = false
                    confirmTimer.stop()
                    AccountService.removeUser(root.selectedUser)
                }
            }
        }
    }
}