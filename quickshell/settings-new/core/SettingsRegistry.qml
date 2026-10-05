// core/SettingsRegistry.qml — the single list of every menu and view in the settings app.
// The sidebar, the landing lists, the title bar and (later) search all read from here,
// so adding a page means adding one entry.
//
//   menu  = { id, title, subtitle, icon, tags, placeholder?, source?, views? }
//   view  = { id, title, subtitle, icon, tags, placeholder?, source? }
//
// `source` is a path relative to SettingsApp.qml. A menu with `views` opens a landing list;
// a menu with `source` and no views is a leaf page; anything with neither shows "Coming soon".
pragma Singleton
import QtQuick

QtObject {
    id: root

    readonly property string appTitle: "Settings"
    readonly property string appSubtitle: "Hermit"
    readonly property string defaultMenuId: "appearance"

    // Shown on the About page. Change the version here and nowhere else.
    readonly property string projectName: "Hermit-dots"
    readonly property string projectVersion: "Beta v1.0.0"
    readonly property string projectRepo: "https://github.com/Ryukabe/hermit-dots"

    readonly property var clusters: [
        {
            id: "shell",
            menus: [
                { id: "bar", title: "Bar & Island", subtitle: "Island size, shape and behaviour", icon: "dock_to_bottom",
                  tags: "top margin corner radius border notch mode height", placeholder: true },
                { id: "launcher", title: "Launcher", subtitle: "App search and clipboard", icon: "rocket_launch",
                  tags: "app search calc clipboard", placeholder: true },
                { id: "controlcenter", title: "Control Center", subtitle: "Tiles and layout", icon: "widgets",
                  tags: "quick settings tiles grid", placeholder: true },
                { id: "lockscreen", title: "Lock Screen", subtitle: "Look and unlock behaviour", icon: "lock",
                  tags: "pam password security idle", placeholder: true }
            ]
        },
        {
            id: "devices",
            menus: [
                { id: "network", title: "Wi-Fi & Bluetooth", subtitle: "Networks and paired devices", icon: "wifi",
                  tags: "network wireless connect pair devices", placeholder: true },
                { id: "soundmedia", title: "Sound & Media", subtitle: "Volume, outputs and players", icon: "graphic_eq",
                  tags: "volume output mpris visualizer", placeholder: true },
                { id: "display", title: "Displays", subtitle: "Monitors and scaling", icon: "desktop_windows",
                  tags: "resolution refresh rate scale transparency monitor", placeholder: true },
                { id: "trackpadmouse", title: "Trackpad & Mouse", subtitle: "Pointer, tap and scroll", icon: "mouse",
                  tags: "sensitivity scroll tap click natural scrolling touchpad", placeholder: true },
                { id: "keyboard", title: "Keyboard", subtitle: "Layout and shortcuts", icon: "keyboard",
                  tags: "hyprland shortcuts binds hotkeys rebind", placeholder: true }
            ]
        },
        {
            id: "looks",
            menus: [
                {
                    id: "appearance", title: "Appearance", subtitle: "Wallpaper, theme, type and motion", icon: "palette",
                    tags: "theme fonts color dark mode accent wallpaper",
                    views: [
                        { id: "wallpaper", title: "Wallpaper", subtitle: "Background image and rotation", icon: "wallpaper",
                          tags: "background image slideshow", placeholder: true },
                        { id: "theme", title: "Theme", subtitle: "Theme card and theme changer", icon: "format_paint",
                          tags: "theme card preset", placeholder: true },
                        { id: "typography", title: "Typography", subtitle: "Fonts, size and icon style", icon: "text_fields",
                          tags: "fonts size icons weight", placeholder: true },
                        { id: "motion", title: "Motion", subtitle: "Speed, bounce and Hyprland animations", icon: "speed",
                          tags: "animations physics springs reduce bounce hyprland",
                          source: "pages/appearance/motion/MotionSettings.qml" },
                        { id: "opacity", title: "Opacity", subtitle: "Mica, spacing and shadows", icon: "opacity",
                          tags: "mica transparency shadow depth spacing", placeholder: true },
                        { id: "colors", title: "Colors", subtitle: "Theme tracking and palette overrides", icon: "invert_colors",
                          tags: "palette accent override theme tracking", placeholder: true }
                    ]
                }
            ]
        },
        {
            id: "system",
            menus: [
                {
                    id: "apps", title: "Apps", subtitle: "Default apps and app library", icon: "apps",
                    tags: "default applications terminal browser file manager favourites hidden",
                    views: [
                        { id: "defaultapps", title: "Default apps", subtitle: "Terminal, browser, files and more", icon: "app_registration",
                          tags: "terminal browser file manager media player", placeholder: true },
                        { id: "allapps", title: "All apps", subtitle: "Favourites and hidden apps", icon: "grid_view",
                          tags: "installed favourites hidden library", placeholder: true }
                    ]
                },
                { id: "focusnotifications", title: "Focus & Notifications", subtitle: "Quiet modes and alerts", icon: "notifications",
                  tags: "peace mode do not disturb previews dnd", placeholder: true },
                { id: "language", title: "Language & Region", subtitle: "Language, clock and date", icon: "language",
                  tags: "locale language clock 12 24 hour date format time zone", placeholder: true },
                { id: "general", title: "General", subtitle: "Startup and everyday options", icon: "tune",
                  tags: "startup login items light dark mode", placeholder: true },
                { id: "about", title: "About", subtitle: "This setup, system and updates", icon: "info",
                  tags: "hardware info updates hermit version license credits cpu gpu kernel power profile reset",
                  source: "pages/about/About.qml" }
            ]
        }
    ]

    function findMenu(id) {
        for (let c = 0; c < root.clusters.length; c++) {
            const menus = root.clusters[c].menus
            for (let m = 0; m < menus.length; m++) {
                if (menus[m].id === id) return menus[m]
            }
        }
        return null
    }

    function findView(menuId, viewId) {
        const menu = root.findMenu(menuId)
        if (!menu || !menu.views) return null
        for (let v = 0; v < menu.views.length; v++) {
            if (menu.views[v].id === viewId) return menu.views[v]
        }
        return null
    }
}
