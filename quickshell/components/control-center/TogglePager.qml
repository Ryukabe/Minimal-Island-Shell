import QtQuick
import "../../styles"
import "tiles"

Item {
    id: root
    property int columns: 3
    property real tileSpacing: Dimens.spacingSm
    property real pageGap: 24
    property int currentPage: 0
    readonly property int pageCount: 2

    implicitHeight: pagesFlick.height + controlsRow.height + Dimens.spacingSm

    signal openWifi()
    signal openBluetooth()
    signal openFocus()
    signal openPowerProfile()
    signal openCaffeine()

    Flickable {
        id: pagesFlick
        width: parent.width
        height: 168
        contentWidth: width * root.pageCount + root.pageGap * (root.pageCount - 1)
        contentHeight: height
        flickableDirection: Flickable.HorizontalFlick
        boundsBehavior: Flickable.StopAtBounds
        clip: true

        property real velocityThreshold: 400
        property real positionThreshold: 0.12

        onMovementEnded: {
            var pageStride = width + root.pageGap
            var pageStartX = root.currentPage * pageStride
            var delta = contentX - pageStartX
            var velocity = horizontalVelocity

            var target = root.currentPage
            if (velocity < -pagesFlick.velocityThreshold || delta > width * pagesFlick.positionThreshold) {
                target = root.currentPage + 1
            } else if (velocity > pagesFlick.velocityThreshold || delta < -width * pagesFlick.positionThreshold) {
                target = root.currentPage - 1
            }
            target = Math.max(0, Math.min(root.pageCount - 1, target))
            root.goToPage(target)
        }

        Row {
            spacing: root.pageGap

            // ---- Page 1: 6 tiles, full grid ----
            Item {
                width: pagesFlick.width
                height: pagesFlick.height

                Grid {
                    id: grid1
                    width: parent.width
                    columns: root.columns
                    rowSpacing: root.tileSpacing
                    columnSpacing: root.tileSpacing

                    WifiToggleTile {
                        compact: true
                        width: (grid1.width - (root.columns - 1) * root.tileSpacing) / root.columns
                        onSubviewRequested: root.openWifi()
                    }
                    BluetoothToggleTile {
                        compact: true
                        width: (grid1.width - (root.columns - 1) * root.tileSpacing) / root.columns
                        onSubviewRequested: root.openBluetooth()
                    }
                    NightLightToggleTile {
                        compact: true
                        width: (grid1.width - (root.columns - 1) * root.tileSpacing) / root.columns
                    }
                    FocusToggleTile {
                        compact: true
                        width: (grid1.width - (root.columns - 1) * root.tileSpacing) / root.columns
                        onSubviewRequested: root.openFocus()
                    }
                    AirplaneModeToggleTile {
                        compact: true
                        width: (grid1.width - (root.columns - 1) * root.tileSpacing) / root.columns
                    }
                    CaffeineToggleTile {
                        compact: true
                        width: (grid1.width - (root.columns - 1) * root.tileSpacing) / root.columns
                        onSubviewRequested: root.openCaffeine()
                    }
                }
            }

            // ---- Page 2: remaining 3 tiles, room for 3 more before a 3rd page is needed ----
            Item {
                width: pagesFlick.width
                height: pagesFlick.height

                Grid {
                    id: grid2
                    width: parent.width
                    columns: root.columns
                    rowSpacing: root.tileSpacing
                    columnSpacing: root.tileSpacing

                    RecordingToggleTile {
                        compact: true
                        width: (grid2.width - (root.columns - 1) * root.tileSpacing) / root.columns
                    }
                    PowerProfileToggleTile {
                        compact: true
                        width: (grid2.width - (root.columns - 1) * root.tileSpacing) / root.columns
                        onSubviewRequested: root.openPowerProfile()
                    }
                    LightModeToggleTile {
                        compact: true
                        width: (grid2.width - (root.columns - 1) * root.tileSpacing) / root.columns
                    }
                }
            }
        }
    }

    NumberAnimation {
        id: snapAnim
        target: pagesFlick
        property: "contentX"
        duration: 260
        easing.type: Easing.OutCubic
    }

    function goToPage(index) {
        root.currentPage = index
        snapAnim.stop()
        snapAnim.to = index * (pagesFlick.width + root.pageGap)
        snapAnim.start()
    }

    Row {
        id: controlsRow
        anchors.top: pagesFlick.bottom
        anchors.topMargin: Dimens.spacingSm
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        Text {
            text: "chevron_left"
            font.family: Fonts.icon
            font.pixelSize: Dimens.fontSizeMd
            color: root.currentPage > 0 ? Colors.fg : Colors.border
            anchors.verticalCenter: parent.verticalCenter

            MouseArea {
                anchors.fill: parent
                anchors.margins: -6
                enabled: root.currentPage > 0
                cursorShape: Qt.PointingHandCursor
                onClicked: root.goToPage(root.currentPage - 1)
            }
        }

        Row {
            spacing: 6
            anchors.verticalCenter: parent.verticalCenter

            Repeater {
                model: root.pageCount
                delegate: Rectangle {
                    required property int index
                    width: 6
                    height: 6
                    radius: 3
                    color: index === root.currentPage ? Colors.accent : Colors.fgMuted
                    Behavior on color { ColorAnimation { duration: 150 } }

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -6
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.goToPage(index)
                    }
                }
            }
        }

        Text {
            text: "chevron_right"
            font.family: Fonts.icon
            font.pixelSize: Dimens.fontSizeMd
            color: root.currentPage < root.pageCount - 1 ? Colors.fg : Colors.border
            anchors.verticalCenter: parent.verticalCenter

            MouseArea {
                anchors.fill: parent
                anchors.margins: -6
                enabled: root.currentPage < root.pageCount - 1
                cursorShape: Qt.PointingHandCursor
                onClicked: root.goToPage(root.currentPage + 1)
            }
        }
    }
}