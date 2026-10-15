// features/lockscreen/WeatherBlock.qml
import QtQuick
import QtQuick.Layouts
import "."
import "../../core/state"
import "../../core/styles"

Item {
    id: root

    property var now: new Date()
    property bool entrance: false   // lock screen: fade/slide in like the other blocks

    readonly property real ageMin: (root.now.getTime() - WeatherService.updatedAt) / 60000
    readonly property bool stale: root.ageMin > 90

    visible: LockScreenSettings.showWeather && WeatherService.hasPlace && WeatherService.hasData
    width: column.implicitWidth
    height: column.implicitHeight
    opacity: 0

    transform: Translate { id: slide; y: 18 }

    Component.onCompleted: {
        if (root.entrance) {
            enterAnim.start()
        } else {
            root.opacity = 1
            slide.y = 0
        }
    }

    SequentialAnimation {
        id: enterAnim
        PauseAnimation { duration: ShellState.motionDuration(420) }
        ParallelAnimation {
            NumberAnimation { target: root; property: "opacity"; from: 0; to: 1; duration: ShellState.motionDuration(450); easing.type: Easing.OutCubic }
            NumberAnimation { target: slide; property: "y"; from: 18; to: 0; duration: ShellState.motionDuration(520); easing.type: Easing.OutCubic }
        }
    }

    function hourLabel(h) {
        if (LockScreenSettings.clockFormat24h) return (h < 10 ? "0" : "") + h
        return (h % 12 === 0 ? 12 : h % 12) + (h < 12 ? "A" : "P")
    }

    ColumnLayout {
        id: column
        spacing: Dimens.spacingSmall

        Text {
            Layout.alignment: Qt.AlignRight
            text: WeatherService.fmt(WeatherService.tempC)
            font.family: Fonts.display
            font.pixelSize: Dimens.fontSizeDisplay
            font.weight: Font.Light
            color: Colors.fg
        }

        Text {
            Layout.alignment: Qt.AlignRight
            text: (WeatherService.conditionText + "  ·  " + WeatherService.placeName).toUpperCase()
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeXs
            font.letterSpacing: 2
            color: Colors.fgMuted
        }

        Text {
            Layout.alignment: Qt.AlignRight
            text: ("H " + WeatherService.fmt(WeatherService.highC)
                + "  L " + WeatherService.fmt(WeatherService.lowC)
                + (LockScreenSettings.weatherShowFeelsLike
                    ? "  ·  FEELS " + WeatherService.fmt(WeatherService.feelsC) : ""))
            font.family: Fonts.mono
            font.pixelSize: Dimens.fontSizeXs
            font.letterSpacing: 1.5
            color: Colors.fgMuted
        }

        Text {
            Layout.alignment: Qt.AlignRight
            visible: root.stale
            text: "UPDATED " + (root.ageMin < 120
                ? Math.round(root.ageMin) + " MIN" : Math.round(root.ageMin / 60) + " H") + " AGO"
            font.family: Fonts.mono
            font.pixelSize: Dimens.fontSizeXs
            font.letterSpacing: 1.5
            color: Colors.fgMuted
            opacity: 0.6
        }

        // Hourly curve: temps above, curve with dots, hours below.
        ColumnLayout {
            id: strip
            visible: LockScreenSettings.weatherShowHourly && WeatherService.hourly.length > 1
            Layout.alignment: Qt.AlignRight
            Layout.topMargin: Dimens.spacingMedium
            Layout.preferredWidth: 320
            spacing: 4

            Row {
                Layout.fillWidth: true
                Repeater {
                    model: WeatherService.hourly
                    Text {
                        required property var modelData
                        width: strip.width / WeatherService.hourly.length
                        horizontalAlignment: Text.AlignHCenter
                        text: WeatherService.fmt(modelData.tempC)
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeXs
                        color: Colors.fg
                    }
                }
            }

            Canvas {
                id: curve
                Layout.fillWidth: true
                Layout.preferredHeight: 40

                onWidthChanged: requestPaint()
                Connections { target: WeatherService; function onHourlyChanged() { curve.requestPaint() } }
                Connections { target: Colors; function onFgChanged() { curve.requestPaint() } }

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    var h = WeatherService.hourly
                    if (!h || h.length < 2) return

                    var lo = 1e9, hi = -1e9
                    for (var i = 0; i < h.length; i++) {
                        lo = Math.min(lo, h[i].tempC)
                        hi = Math.max(hi, h[i].tempC)
                    }
                    var span = Math.max(hi - lo, 1)
                    var step = width / h.length
                    var xs = [], ys = []
                    for (i = 0; i < h.length; i++) {
                        xs.push(step * (i + 0.5))
                        ys.push(6 + (1 - (h[i].tempC - lo) / span) * (height - 12))
                    }

                    ctx.globalAlpha = 0.6
                    ctx.strokeStyle = Colors.fgMuted
                    ctx.lineWidth = 1.5
                    ctx.beginPath()
                    ctx.moveTo(xs[0], ys[0])
                    for (i = 1; i < h.length; i++) {
                        var mx = (xs[i - 1] + xs[i]) / 2
                        ctx.bezierCurveTo(mx, ys[i - 1], mx, ys[i], xs[i], ys[i])
                    }
                    ctx.stroke()

                    ctx.globalAlpha = 1
                    ctx.fillStyle = Colors.fg
                    for (i = 0; i < h.length; i++) {
                        ctx.beginPath()
                        ctx.arc(xs[i], ys[i], 2.5, 0, Math.PI * 2)
                        ctx.fill()
                    }
                }
            }

            Row {
                Layout.fillWidth: true
                Repeater {
                    model: WeatherService.hourly
                    Text {
                        required property var modelData
                        width: strip.width / WeatherService.hourly.length
                        horizontalAlignment: Text.AlignHCenter
                        text: root.hourLabel(modelData.hour)
                        font.family: Fonts.mono
                        font.pixelSize: Dimens.fontSizeXs
                        color: Colors.fgMuted
                    }
                }
            }
        }
    }
}