import QtQuick
import "../"
import "../../../styles"
import "../../../services"

ToggleTile {
    title: "Recording"
    active: RecordingService.enabled
    subtitle: RecordingService.enabled ? "Recording" : "Off"
    iconGlyph: "videocam"
    iconColor: Colors.red
    external: false
    onToggled: RecordingService.toggle()
}