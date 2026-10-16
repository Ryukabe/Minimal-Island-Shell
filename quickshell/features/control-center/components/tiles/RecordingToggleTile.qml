import QtQuick
import ".."
import "../../../../core/styles"
import "../../../recording"

ToggleTile {
    title: "Recording"
    active: RecordingService.enabled
    subtitle: RecordingService.enabled ? "Recording" : "Off"
    iconGlyph: "screen_record"
    iconColor: Colors.red
    external: false
    onToggled: RecordingService.toggle()
}