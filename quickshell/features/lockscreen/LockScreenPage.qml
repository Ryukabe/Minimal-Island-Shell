// pages/lockscreen/LockScreenPage.qml — Lock Screen. Real: everything bound to LockScreenSettings,
// plus the lock timer, which lives in hypridle.conf (LockTimerService), and the weather city,
// which lives in WeatherService.
// The lid row stays a greyed placeholder: it belongs to logind / a Hyprland bind, not to the shell.
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import "../settings/components"
import "."
import "../../core/shell"
import "../../core/styles"
import "../settings/core"
import "../theme/components"

PageScroll {
    id: root

    readonly property var sampleNotifs: [
        "Messages: hey, are you free?",
        "Mail: Your order has shipped",
        "Calendar: Study block at 8"
    ]

    Component.onCompleted: if (!KnowledgeSettings.current) KnowledgeSettings.pickNext()

    SystemClock {
        id: previewClock
        enabled: root.visible
        precision: SystemClock.Minutes
    }

    SectionLabel { text: "Preview" }

    GroupCard {
        Item {
            Layout.fillWidth: true
            implicitHeight: 282

            Rectangle {
                id: frame
                height: 260
                width: height * 16 / 9
                anchors.centerIn: parent
                color: Colors.mainBgMica
                border.width: 1
                border.color: Colors.border
                clip: true

                // Drawn at 1366x768, then scaled down to fit the frame.
                Item {
                    id: stage
                    width: 1366
                    height: 768
                    scale: frame.width / 1366
                    transformOrigin: Item.TopLeft

                    Image {
                        id: previewWall
                        anchors.fill: parent
                        source: LockScreenSettings.effectiveWallpaper
                            ? LockScreenSettings.folderUrl(LockScreenSettings.effectiveWallpaper) : ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        sourceSize.width: 1366
                        visible: !LockScreenSettings.frostedBlurEnabled
                    }

                    FastBlur {
                        anchors.fill: previewWall
                        source: previewWall
                        radius: LockScreenSettings.frostedBlurRadius
                        visible: LockScreenSettings.frostedBlurEnabled
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: Colors.darkMode
                            ? Qt.rgba(0, 0, 0, LockScreenSettings.wallpaperDimOpacity)
                            : Qt.rgba(1, 1, 1, LockScreenSettings.wallpaperDimOpacity)
                    }

                    // Top-left: clock, date, notifications
                    Column {
                        x: stage.width * 0.05
                        y: stage.height * 0.06
                        spacing: Dimens.spacingSmall

                        Text {
                            text: Qt.formatDateTime(previewClock.date, LockScreenSettings.clockFormat24h ? "HH:mm" : "h:mm AP")
                            font.family: Fonts.display
                            font.pixelSize: Dimens.fontSizeDisplay
                            font.weight: Font.Bold
                            color: Colors.fg
                        }

                        Text {
                            visible: LockScreenSettings.showDate
                            text: Qt.formatDateTime(previewClock.date, "dddd, MMMM d").toUpperCase()
                            font.family: Fonts.text
                            font.pixelSize: Dimens.fontSizeXs
                            font.letterSpacing: 2
                            color: Colors.fgMuted
                        }

                        Text {
                            visible: LockScreenSettings.showNotifications
                            topPadding: Dimens.spacingMedium
                            text: "3 NOTIFICATIONS"
                            font.family: Fonts.text
                            font.pixelSize: Dimens.fontSizeXs
                            font.letterSpacing: 2
                            color: Colors.fgMuted
                        }

                        Repeater {
                            model: LockScreenSettings.showNotifications
                                ? Math.min(LockScreenSettings.notificationLimit, root.sampleNotifs.length) : 0

                            Text {
                                required property int index
                                text: root.sampleNotifs[index]
                                font.family: Fonts.text
                                font.pixelSize: Dimens.fontSizeSm
                                color: Colors.fg
                            }
                        }
                    }

                    // Top-right: weather
                    Column {
                        visible: LockScreenSettings.showWeather
                        x: stage.width * 0.95 - width
                        y: stage.height * 0.06
                        spacing: Dimens.spacingSmall

                        Text {
                            anchors.right: parent.right
                            text: WeatherService.hasData ? WeatherService.fmt(WeatherService.tempC)
                                : (ShellState.weatherUnit === "°F" ? "82°" : "28°")
                            font.family: Fonts.display
                            font.pixelSize: Dimens.fontSizeDisplay
                            font.weight: Font.Light
                            color: Colors.fg
                        }

                        Text {
                            anchors.right: parent.right
                            text: (WeatherService.hasData
                                ? WeatherService.conditionText + "  ·  " + WeatherService.placeName
                                : "Partly cloudy  ·  Your city").toUpperCase()
                            font.family: Fonts.text
                            font.pixelSize: Dimens.fontSizeXs
                            font.letterSpacing: 2
                            color: Colors.fgMuted
                        }

                        Text {
                            anchors.right: parent.right
                            text: WeatherService.hasData
                                ? ("H " + WeatherService.fmt(WeatherService.highC) + "  L " + WeatherService.fmt(WeatherService.lowC)
                                   + (LockScreenSettings.weatherShowFeelsLike ? "  ·  FEELS " + WeatherService.fmt(WeatherService.feelsC) : ""))
                                : "H 31°  L 24°" + (LockScreenSettings.weatherShowFeelsLike ? "  ·  FEELS 33°" : "")
                            font.family: Fonts.mono
                            font.pixelSize: Dimens.fontSizeXs
                            font.letterSpacing: 1.5
                            color: Colors.fgMuted
                        }

                        Row {
                            visible: LockScreenSettings.weatherShowHourly
                            anchors.right: parent.right
                            topPadding: Dimens.spacingMedium
                            spacing: 44

                            Repeater {
                                model: 6
                                Rectangle {
                                    required property int index
                                    width: 5; height: 5; radius: 2.5
                                    color: Colors.fg
                                    // a gentle arc so it reads as a curve
                                    y: Math.abs(index - 2.5) * 4
                                }
                            }
                        }
                    }

                    // Bottom-left: media card (sits above Hyprland when that is shown)
                    Rectangle {
                        visible: LockScreenSettings.showMedia
                        x: stage.width * 0.05
                        y: stage.height * 0.94 - height
                            - (previewHyprland.visible ? previewHyprland.height + Dimens.spacingLg : 0)
                        width: 340
                        height: 96
                        radius: ShellState.islandCornerRadius
                        color: Colors.darkMode ? Qt.rgba(0, 0, 0, 0.35) : Qt.rgba(1, 1, 1, 0.35)
                        border.width: 1
                        border.color: Qt.rgba(Colors.border.r, Colors.border.g, Colors.border.b, 0.5)

                        Row {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 14

                            Rectangle {
                                width: 72; height: 72
                                radius: Math.max(4, ShellState.islandCornerRadius - 12)
                                color: Colors.subBgMica

                                Text {
                                    anchors.centerIn: parent
                                    text: "music_note"
                                    font.family: Fonts.icon
                                    font.pixelSize: Dimens.fontSizeHuge
                                    font.variableAxes: Fonts.iconAxes
                                    color: Colors.fgMuted
                                }
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2

                                Text {
                                    text: "NOW PLAYING"
                                    font.family: Fonts.text
                                    font.pixelSize: Dimens.fontSizeXs
                                    font.letterSpacing: 2
                                    color: Colors.fgMuted
                                }

                                Text {
                                    text: LockScreenSettings.mediaHideDetails ? "Hidden while locked" : "Song title"
                                    font.family: Fonts.text
                                    font.pixelSize: Dimens.fontSizeBase
                                    font.bold: true
                                    color: Colors.fg
                                }

                                Text {
                                    visible: !LockScreenSettings.mediaHideDetails
                                    text: "Artist"
                                    font.family: Fonts.text
                                    font.pixelSize: Dimens.fontSizeSm
                                    color: Colors.fgMuted
                                }

                                Rectangle {
                                    visible: LockScreenSettings.mediaShowProgress
                                    width: 200; height: 2; radius: 1
                                    color: Colors.fg
                                    opacity: 0.15
                                    Rectangle { width: parent.width * 0.4; height: 2; radius: 1; color: Colors.accent }
                                }
                            }
                        }
                    }

                    // Bottom-left: Hyprland
                    Text {
                        id: previewHyprland
                        visible: LockScreenSettings.showHyprlandAction
                        x: stage.width * 0.05
                        y: stage.height * 0.94 - height
                        text: "HYPRLAND"
                        font.family: Fonts.mono
                        font.pixelSize: Dimens.fontSizeXs
                        font.letterSpacing: 1.5
                        color: Colors.fgMuted
                    }

                    // Bottom-centre: knowledge slide
                    Column {
                        id: previewSlide
                        readonly property var entry: KnowledgeSettings.current
                        visible: KnowledgeSettings.slideEnabled && !!entry
                        width: Math.min(520, stage.width * 0.36)
                        x: (stage.width - width) / 2
                        y: stage.height * 0.94 - height
                        spacing: Dimens.spacingSmall

                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            text: previewSlide.entry ? (previewSlide.entry.kind === "word" ? "WORD" : "DID YOU KNOW") : ""
                            font.family: Fonts.text
                            font.pixelSize: Dimens.fontSizeXs
                            font.letterSpacing: 2
                            color: Colors.fgMuted
                        }

                        Text {
                            visible: previewSlide.entry && previewSlide.entry.kind === "fact"
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            text: previewSlide.entry && previewSlide.entry.kind === "fact" ? previewSlide.entry.text : ""
                            font.family: Fonts.text
                            font.pixelSize: Dimens.fontSizeMd
                            color: Colors.fg
                        }

                        Text {
                            visible: previewSlide.entry && previewSlide.entry.kind === "word"
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            text: previewSlide.entry && previewSlide.entry.kind === "word"
                                ? previewSlide.entry.word + "  ·  " + previewSlide.entry.pos : ""
                            font.family: Fonts.display
                            font.pixelSize: Dimens.fontSizeLg
                            font.weight: Font.Bold
                            color: Colors.fg
                        }

                        Text {
                            visible: previewSlide.entry && previewSlide.entry.kind === "word"
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            text: previewSlide.entry && previewSlide.entry.kind === "word" ? previewSlide.entry.meaning : ""
                            font.family: Fonts.text
                            font.pixelSize: Dimens.fontSizeSm
                            color: Colors.fg
                        }

                        Text {
                            visible: previewSlide.entry && previewSlide.entry.kind === "word"
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            text: previewSlide.entry && previewSlide.entry.kind === "word" ? "\"" + previewSlide.entry.example + "\"" : ""
                            font.family: Fonts.text
                            font.pixelSize: Dimens.fontSizeXs
                            font.italic: true
                            color: Colors.fgMuted
                        }
                    }

                    // Bottom-right: username, password box, buttons
                    Column {
                        x: stage.width * 0.95 - width
                        y: stage.height * 0.94 - height
                        spacing: Dimens.spacingSmall

                        Text {
                            visible: LockScreenSettings.showUsername
                            anchors.right: parent.right
                            text: (Quickshell.env("USER") || "user").toUpperCase()
                            font.family: Fonts.display
                            font.pixelSize: Dimens.fontSizeMd
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                            color: Colors.fg
                        }

                        Item {
                            width: 220
                            height: 30 + Dimens.spacingMedium

                            Text {
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 8
                                text: LockScreenSettings.passwordPlaceholder.toUpperCase()
                                font.family: Fonts.text
                                font.pixelSize: Dimens.fontSizeXs
                                font.letterSpacing: 1.5
                                color: Colors.fgMuted
                                opacity: 0.7
                            }

                            Rectangle {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: 1
                                color: Colors.border
                                opacity: 0.4
                            }
                        }

                        Row {
                            anchors.right: parent.right
                            spacing: Dimens.spacingLg

                            Text {
                                visible: LockScreenSettings.showRebootAction
                                text: "RESTART"
                                font.family: Fonts.mono
                                font.pixelSize: Dimens.fontSizeXs
                                font.letterSpacing: 1.5
                                color: Colors.fgMuted
                            }

                            Text {
                                visible: LockScreenSettings.showPowerAction
                                text: "SHUT DOWN"
                                font.family: Fonts.mono
                                font.pixelSize: Dimens.fontSizeXs
                                font.letterSpacing: 1.5
                                color: Colors.fgMuted
                            }
                        }
                    }
                }
            }
        }
    }

    SectionLabel { text: "Wallpaper source" }

    GroupCard {
        ToggleRow {
            label: "Use its own wallpaper"
            description: "Pick a lock screen wallpaper separate from the desktop one"
            checked: LockScreenSettings.useOwnWallpaper
            onToggled: (val) => LockScreenSettings.useOwnWallpaper = val
            showDivider: LockScreenSettings.useOwnWallpaper
        }

        TextRow {
            visible: LockScreenSettings.useOwnWallpaper
            label: "Lock screen folder"
            description: LockScreenSettings.wallpaperList.length === 0
                ? "No images found in this folder"
                : "Press Enter to apply. Example: ~/Pictures/Wallpapers"
            placeholderText: "~/Pictures/Wallpapers"
            monospace: true
            fieldWidth: 280
            value: LockScreenSettings.wallpaperFolder
            showDivider: false
            onCommitted: (v) => LockScreenSettings.setWallpaperFolder(v)
        }
    }

    CardCarousel {
        id: lockWallpaperCarousel
        enabled: LockScreenSettings.useOwnWallpaper
        opacity: enabled ? 1.0 : 0.4
        model: LockScreenSettings.wallpaperList
        cardDelegate: Component {
            WallpaperCard {
                required property var modelData
                required property int index

                wallpaperPath: modelData.path
                wallpaperName: modelData.name
                isApplied: LockScreenSettings.effectiveWallpaper === modelData.path
                isSelected: LockScreenSettings.effectiveWallpaper === modelData.path
                onClicked: LockScreenSettings.wallpaperFile = modelData.path
            }
        }
    }

    SectionLabel { text: "Wallpaper" }

    GroupCard {
        ToggleRow {
            label: "Frosted glass"
            description: "Blur the wallpaper behind the lock screen"
            checked: LockScreenSettings.frostedBlurEnabled
            onToggled: (val) => LockScreenSettings.frostedBlurEnabled = val
            showDivider: LockScreenSettings.frostedBlurEnabled
        }

        Reveal {
            shown: LockScreenSettings.frostedBlurEnabled

            SliderRow {
                label: "Blur strength"
                from: 0; to: 64; stepSize: 1
                value: LockScreenSettings.frostedBlurRadius
                onMoved: (val) => LockScreenSettings.frostedBlurRadius = val
            }
        }

        SliderRow {
            label: "Dimming"
            description: "Darkens the wallpaper so the text stays readable"
            from: 0; to: 0.8; stepSize: 0.01
            value: LockScreenSettings.wallpaperDimOpacity
            onMoved: (val) => LockScreenSettings.wallpaperDimOpacity = val
        }

        ToggleRow {
            label: "Entrance animation"
            description: "Fade and slide the lock screen in. Off: it appears fully drawn"
            checked: LockScreenSettings.playEntranceAnimation
            onToggled: (val) => LockScreenSettings.playEntranceAnimation = val
            showDivider: false
        }
    }

    SectionLabel { text: "Clock and name" }

    GroupCard {
        ToggleRow {
            label: "24-hour clock"
            checked: LockScreenSettings.clockFormat24h
            onToggled: (val) => LockScreenSettings.clockFormat24h = val
        }

        ToggleRow {
            label: "Show the date"
            checked: LockScreenSettings.showDate
            onToggled: (val) => LockScreenSettings.showDate = val
        }

        ToggleRow {
            label: "Show your username"
            checked: LockScreenSettings.showUsername
            onToggled: (val) => LockScreenSettings.showUsername = val
            showDivider: false
        }
    }

    SectionLabel { text: "Notifications" }

    GroupCard {
        ToggleRow {
            label: "Show notifications on the lock screen"
            description: "A count and the latest few, under the clock. Respects Show previews"
            checked: LockScreenSettings.showNotifications
            onToggled: (val) => LockScreenSettings.showNotifications = val
            showDivider: LockScreenSettings.showNotifications
        }

        Reveal {
            shown: LockScreenSettings.showNotifications

            SliderRow {
                label: "Notifications shown"
                from: 1; to: 6; stepSize: 1
                value: LockScreenSettings.notificationLimit
                onMoved: (val) => LockScreenSettings.notificationLimit = val
                showDivider: false
            }
        }
    }

       SectionLabel { text: "Weather" }

    GroupCard {
        ToggleRow {
            label: "Show weather"
            description: "Temperature and forecast in the top-right corner"
            checked: LockScreenSettings.showWeather
            onToggled: (val) => LockScreenSettings.showWeather = val
            showDivider: LockScreenSettings.showWeather
        }

        Reveal {
            shown: LockScreenSettings.showWeather

            ButtonRow {
                label: "Location"
                description: LocationService.hasLocation
                    ? LocationService.label
                    : "Not set. Pick or detect one in Language & Region"
                buttonText: "Change"
                onClicked: SettingsNav.openMenu("language")
            }
        }

        Reveal {
            shown: LockScreenSettings.showWeather

            ToggleRow {
                label: "Hourly forecast"
                description: "The next few hours as a small curve"
                checked: LockScreenSettings.weatherShowHourly
                onToggled: (val) => LockScreenSettings.weatherShowHourly = val
            }
        }

        Reveal {
            shown: LockScreenSettings.showWeather

            ToggleRow {
                label: "Show feels-like"
                checked: LockScreenSettings.weatherShowFeelsLike
                onToggled: (val) => LockScreenSettings.weatherShowFeelsLike = val
                showDivider: false
            }
        }
    }

    SectionLabel { text: "Media" }

    GroupCard {
        ToggleRow {
            label: "Show now playing"
            description: "A card above the Hyprland button while something is playing"
            checked: LockScreenSettings.showMedia
            onToggled: (val) => LockScreenSettings.showMedia = val
            showDivider: LockScreenSettings.showMedia
        }

        Reveal {
            shown: LockScreenSettings.showMedia

            ToggleRow {
                label: "Blurred album art background"
                checked: LockScreenSettings.mediaBlurBackdrop
                onToggled: (val) => LockScreenSettings.mediaBlurBackdrop = val
            }
        }

        Reveal {
            shown: LockScreenSettings.showMedia

            ToggleRow {
                label: "Progress line"
                description: "Only appears if the player reports its position"
                checked: LockScreenSettings.mediaShowProgress
                onToggled: (val) => LockScreenSettings.mediaShowProgress = val
            }
        }

        Reveal {
            shown: LockScreenSettings.showMedia

            ToggleRow {
                label: "Hide track details"
                description: "Hides the title, artist and cover, so anyone near your screen can't see what you're playing"
                checked: LockScreenSettings.mediaHideDetails
                onToggled: (val) => LockScreenSettings.mediaHideDetails = val
                showDivider: false
            }
        }
    }

    SectionLabel { text: "Password box" }

    GroupCard {
        TextRow {
            label: "Hint text"
            description: "Shown inside the empty password box"
            value: LockScreenSettings.passwordPlaceholder
            fieldWidth: 220
            onCommitted: (v) => LockScreenSettings.passwordPlaceholder = v
        }

        ToggleRow {
            label: "Shake on wrong password"
            checked: LockScreenSettings.shakeOnWrongPassword
            onToggled: (val) => LockScreenSettings.shakeOnWrongPassword = val
        }

        ToggleRow {
            label: "Accent colour for wrong passwords"
            description: "Flash the accent colour instead of red"
            checked: LockScreenSettings.errorUsesAccent
            onToggled: (val) => LockScreenSettings.errorUsesAccent = val
            showDivider: false
        }
    }

    SectionLabel { text: "Buttons" }

    GroupCard {
        ToggleRow {
            label: "Hyprland"
            description: "Leave the lock screen and go back to Hyprland"
            checked: LockScreenSettings.showHyprlandAction
            onToggled: (val) => LockScreenSettings.showHyprlandAction = val
        }

        ToggleRow {
            label: "Reboot"
            checked: LockScreenSettings.showRebootAction
            onToggled: (val) => LockScreenSettings.showRebootAction = val
        }

        ToggleRow {
            label: "Power"
            checked: LockScreenSettings.showPowerAction
            onToggled: (val) => LockScreenSettings.showPowerAction = val
            showDivider: false
        }
    }

    SectionLabel { text: "Locking" }

    GroupCard {
        SliderRow {
            label: "Lock after idle"
            description: LockTimerService.available
                ? "Changes the lock timer in your hypridle.conf and restarts hypridle. Screen-off keeps its delay after locking"
                : LockTimerService.status
            from: 1; to: 25; stepSize: 1
            value: LockTimerService.lockMinutes
            unit: " min"
            enabled: LockTimerService.available
            onMoved: (val) => LockTimerService.setLockMinutes(val)
        }

        ToggleRow {
            label: "Lock when the lid closes"
            checked: true
            placeholder: true
            showDivider: false
        }
    }

    SectionLabel { text: "Parts of the lock screen" }

    ViewList {}
}