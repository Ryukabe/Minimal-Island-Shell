// pages/appearance/wallpaper/WallpaperSettings.qml — Appearance > Wallpaper.
import QtQuick
import QtQuick.Layouts
import "../../../components"
import "../../../../services"
import "../../../../styles"
import "../../../../components/theme"

PageScroll {
    id: root

    SectionLabel { text: "Wallpapers" }

    CardCarousel {
        id: wallpaperCarousel
        model: WallpaperService.wallpapersList
        cardDelegate: Component {
            WallpaperCard {
                required property var modelData
                required property int index

                wallpaperPath: modelData.path
                wallpaperName: modelData.name
                isApplied: WallpaperService.currentWallpaper === modelData.path
                isSelected: wallpaperCarousel.currentIndex === index
                onClicked: {
                    wallpaperCarousel.currentIndex = index
                    WallpaperService.applyWallpaper(modelData.path)
                }
            }
        }
    }

    SectionLabel { text: "Behaviour" }

    GroupCard {
        ToggleRow {
            label: "Auto-switch wallpaper with theme"
            description: "Changing the theme also changes the wallpaper to match it"
            checked: WallpaperService.autoSwitchOnThemeChange
            onToggled: (val) => WallpaperService.setAutoSwitch(val)
            showDivider: false
        }
    }
}
