import QtQuick
import "../../../services"

SliderTile {
    iconGlyph: VolumeService.muted ? "volume_off" : "volume_up"
    value: VolumeService.muted ? 0 : VolumeService.percent
    label: VolumeService.muted ? "Muted" : VolumeService.percent + "%"
    iconClickable: true

    onValueRequested: (percent) => VolumeService.setPercent(percent)
    onIconClicked: VolumeService.toggleMute()
}