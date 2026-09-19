// settings/controlcenter/ControlCenter.qml
import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../common"
import "../../components/control-center"

Item {
    id: root
    property bool compactSliders: false

    SettingsScrollView {

        SettingsToggleRow {
            label: "Compact Slider Layout"
            checked: root.compactSliders
            showDivider: false
            onToggled: (val) => root.compactSliders = val
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: Dimens.spacingMd
            Layout.bottomMargin: Dimens.spacingSm
            spacing: Dimens.spacingMd

            Row {
                spacing: Dimens.spacingSm

                Repeater {
                    model: [5, 6, 7, 8, 9]

                    delegate: Rectangle {
                        id: colBtn
                        required property int modelData
                        readonly property bool active: ControlCenterLayoutService.columns === modelData

                        width: 28
                        height: 28
                        radius: Dimens.radiusFull
                        color: colBtn.active ? Colors.accent : Colors.subBgMica
                        border.width: 1
                        border.color: Colors.border

                        Behavior on color { ColorAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            text: colBtn.modelData
                            font.family: Fonts.text
                            font.pixelSize: Dimens.fontSizeXSm
                            font.bold: true
                            color: colBtn.active ? Colors.bg : Colors.fg
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: ControlCenterLayoutService.setColumns(colBtn.modelData)
                        }
                    }
                }
            }

            Item { Layout.fillWidth: true }

            Row {
                spacing: Dimens.spacingSm

                SettingsButton {
                    text: "Tidy"
                    onClicked: ControlCenterLayoutService.tidyLayout()
                }

                SettingsButton {
                    text: "Undo"
                    enabled: ControlCenterLayoutService.undoStack.length > 0
                    onClicked: ControlCenterLayoutService.undo()
                }

                SettingsButton {
                    text: "Reset"
                    onClicked: ControlCenterLayoutService.resetToDefault()
                }
            }
        }

        ControlGrid {
            id: grid
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
            editMode: true
        }

        TileSizePicker {
            Layout.fillWidth: true
            Layout.topMargin: Dimens.spacingMd
            tileId: grid.selectedTileId
        }

        AddControlTray {
            Layout.fillWidth: true
            Layout.topMargin: Dimens.spacingMd
        }
    }
}