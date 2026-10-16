import QtQuick
import "../../../display"

SliderTile {
    iconGlyph: "brightness_medium"
    value: BrightnessService.percent
    label: BrightnessService.percent + "%"

    onValueRequested: (percent) => BrightnessService.setPercent(percent)
}