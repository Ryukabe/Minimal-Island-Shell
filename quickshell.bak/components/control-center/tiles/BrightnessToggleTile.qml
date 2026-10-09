import QtQuick
import "../../../services"

SliderTile {
    iconGlyph: "brightness_medium"
    value: BrightnessService.percent
    label: BrightnessService.percent + "%"

    onValueRequested: (percent) => BrightnessService.setPercent(percent)
}