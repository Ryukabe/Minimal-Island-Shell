// pages/lockscreen/knowledge/KnowledgePage.qml — Knowledge: the fact / word slide on the lock screen.
import QtQuick
import QtQuick.Layouts
import "../settings/components"
import "."
import "../../core/styles"

PageScroll {
    id: root

    Component.onCompleted: if (!KnowledgeSettings.current) KnowledgeSettings.pickNext()

    SectionLabel { text: "Preview (click for another)" }

    GroupCard {
        Item {
            id: previewItem
            Layout.fillWidth: true
            implicitHeight: 150
            opacity: KnowledgeSettings.slideEnabled ? 1.0 : 0.4

            readonly property var entry: KnowledgeSettings.current

            Column {
                anchors.centerIn: parent
                width: Math.min(parent.width - 48, 520)
                spacing: Dimens.spacingSmall

                Text {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: previewItem.entry
                        ? (previewItem.entry.kind === "word" ? "WORD" : "DID YOU KNOW")
                        : "NOTHING TO SHOW"
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeXs
                    font.letterSpacing: 2
                    color: Colors.fgMuted
                }

                Text {
                    visible: previewItem.entry && previewItem.entry.kind === "fact"
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: previewItem.entry && previewItem.entry.kind === "fact" ? previewItem.entry.text : ""
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeMd
                    color: Colors.fg
                }

                Text {
                    visible: previewItem.entry && previewItem.entry.kind === "word"
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: previewItem.entry && previewItem.entry.kind === "word"
                        ? previewItem.entry.word + "  ·  " + previewItem.entry.pos : ""
                    font.family: Fonts.display
                    font.pixelSize: Dimens.fontSizeLg
                    font.weight: Font.Bold
                    color: Colors.fg
                }

                Text {
                    visible: previewItem.entry && previewItem.entry.kind === "word"
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: previewItem.entry && previewItem.entry.kind === "word" ? previewItem.entry.meaning : ""
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeSm
                    color: Colors.fg
                }

                Text {
                    visible: previewItem.entry && previewItem.entry.kind === "word"
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: previewItem.entry && previewItem.entry.kind === "word" ? "\"" + previewItem.entry.example + "\"" : ""
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeXs
                    font.italic: true
                    color: Colors.fgMuted
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: KnowledgeSettings.pickNext()
            }
        }
    }

    SectionLabel { text: "Lock screen slide" }

    GroupCard {
        ToggleRow {
            label: "Show a slide when locking"
            description: "A fact or a word with its meaning, picked fresh each time you lock"
            checked: KnowledgeSettings.slideEnabled
            onToggled: (val) => KnowledgeSettings.slideEnabled = val
            showDivider: KnowledgeSettings.slideEnabled
        }

        Reveal {
            shown: KnowledgeSettings.slideEnabled

            ToggleRow {
                label: "Interesting facts"
                checked: KnowledgeSettings.showFacts
                onToggled: (val) => KnowledgeSettings.showFacts = val
            }
        }

        Reveal {
            shown: KnowledgeSettings.slideEnabled

            ToggleRow {
                label: "Words and meanings"
                description: "If both are off, no slide appears"
                checked: KnowledgeSettings.showWords
                onToggled: (val) => KnowledgeSettings.showWords = val
                showDivider: false
            }
        }
    }
}