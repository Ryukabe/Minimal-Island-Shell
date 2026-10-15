// pages/appearance/wallpaper/WallpaperSettings.qml — Appearance > Wallpaper.
import QtQuick
import QtQuick.Layouts
import "../settings/components"
import "."
import "../../core/styles"
import "components/theme"

PageScroll {
    id: root

    // Only show wallpapers matching the Static / Animated mode.
    readonly property var shownWallpapers: {
        var animated = WallpaperService.animatedMode;
        return (WallpaperService.wallpapersList || []).filter(function(item) {
            return item.animated === animated;
        });
    }

    SectionLabel { text: "Wallpapers" }

    CardCarousel {
        id: wallpaperCarousel
        model: root.shownWallpapers
        cardDelegate: Component {
            WallpaperCard {
                required property var modelData
                required property int index

                wallpaperPath: modelData.path
                wallpaperName: modelData.name
                isAnimated: modelData.animated
                isVideo: modelData.video
                thumbPath: modelData.thumb
                isApplied: WallpaperService.currentWallpaper === modelData.path
                isSelected: wallpaperCarousel.currentIndex === index
                onClicked: {
                    wallpaperCarousel.currentIndex = index
                    WallpaperService.applyWallpaper(modelData.path)
                }
            }
        }
    }

    SectionLabel { text: "Source" }

    GroupCard {
        ToggleRow {
            label: "Use a custom folder"
            description: "List wallpapers from your own folder instead of the theme folders"
            checked: WallpaperService.useCustomFolder
            onToggled: (val) => WallpaperService.setUseCustomFolder(val)
        }

        TextRow {
            label: "Custom folder"
            description: "Press Enter to apply. Example: ~/Pictures/Wallpapers"
            placeholderText: "~/Pictures/Wallpapers"
            monospace: true
            fieldWidth: 280
            value: WallpaperService.customFolderPath
            enabled: WallpaperService.useCustomFolder
            showDivider: false
            onCommitted: (v) => WallpaperService.setCustomFolderPath(v)
        }
    }

    SectionLabel { text: "Behaviour" }

    GroupCard {
        ToggleRow {
            label: "Animated wallpapers"
            description: "Show GIF and video wallpapers instead of still images"
            checked: WallpaperService.animatedMode
            onToggled: (val) => WallpaperService.setAnimatedMode(val)
        }

        ToggleRow {
            label: "Auto-switch wallpaper with theme"
            description: WallpaperService.useCustomFolder
                ? "Unavailable while a custom folder is in use"
                : "Changing the theme also changes the wallpaper to match it"
            enabled: !WallpaperService.useCustomFolder
            opacity: enabled ? 1.0 : 0.4
            checked: WallpaperService.autoSwitchOnThemeChange
            onToggled: (val) => WallpaperService.setAutoSwitch(val)
            showDivider: false
        }
    }
}