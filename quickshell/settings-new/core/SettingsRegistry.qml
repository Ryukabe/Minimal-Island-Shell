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
                {
                    id: "bar", title: "Bar & Island", subtitle: "Island size, shape and behaviour", icon: "dock_to_bottom",
                    tags: "top margin corner radius border notch mode height taskbar panel",
                    views: [
                        { id: "island", title: "Island", subtitle: "Margin, radius, border and notch", icon: "aspect_ratio",
                          tags: "top margin corner radius border notch flare hover lift click outside dismiss",
                          source: "pages/bar/island/IslandSettings.qml" },
                        { id: "sizes", title: "Sizes", subtitle: "Bar and module dimensions", icon: "straighten",
                          tags: "height width collapsed expanded launcher clipboard control center notification power menu status timer",
                          source: "pages/bar/sizes/SizeSettings.qml" },
                        { id: "behaviour", title: "Behaviour", subtitle: "Visibility and scroll actions", icon: "tune",
                          tags: "persistent show on hover drag threshold scroll workspaces volume brightness",
                          source: "pages/bar/behaviour/BehaviourSettings.qml" },
                        { id: "workspaces", title: "Workspaces", subtitle: "Indicators and window icons", icon: "grid_view",
                          tags: "workspace shown active indicator trail occupied windows special per-monitor",
                          source: "pages/bar/workspaces/WorkspacesSettings.qml" },
                        { id: "clock", title: "Clock", subtitle: "Time, date and bar indicators", icon: "schedule",
                          tags: "time date seconds leading zero am pm visualizer timer icon recording indicator preview",
                          source: "pages/bar/clock/ClockSettings.qml" }
                    ]
                },
                { id: "dashboard", title: "Dashboard", subtitle: "Tabs, widgets and opening", icon: "dashboard",
                  tags: "tabs media performance weather widgets battery gpu cpu memory storage drag threshold hover",
                  source: "pages/dashboard/DashboardSettings.qml" },
                { id: "launcher", title: "Launcher", subtitle: "App search and clipboard", icon: "rocket_launch",
                  tags: "app search calc clipboard recent apps features emoji snippets notes calculator units web",
                  source: "pages/launcher/LauncherPage.qml" },
                { id: "controlcenter", title: "Control Center", subtitle: "Tiles and layout", icon: "widgets",
                  tags: "quick settings tiles grid", placeholder: true },
                { id: "lockscreen", title: "Lock Screen", subtitle: "Look and unlock behaviour", icon: "lock",
                  tags: "pam password security idle clock blur dim username nav actions reboot power hyprland",
                  source: "pages/lockscreen/LockScreenPage.qml" }
            ]
        },
        {
            id: "devices",
            menus: [
                { id: "network", title: "Wi-Fi & Bluetooth", subtitle: "Networks and paired devices", icon: "wifi",
                  tags: "network wireless connect pair devices",
                  source: "pages/network/NetworkSettings.qml" },
                { id: "soundmedia", title: "Sound & Media", subtitle: "Volume, outputs and players", icon: "graphic_eq",
                  tags: "volume output mpris visualizer step max",
                  source: "pages/soundmedia/SoundMediaSettings.qml" },
                { id: "display", title: "Displays", subtitle: "Monitors and scaling", icon: "desktop_windows",
                  tags: "resolution refresh rate scale transparency monitor",
                  source: "pages/display/DisplaySettings.qml" },
                { id: "trackpadmouse", title: "Trackpad & Mouse", subtitle: "Pointer, tap and scroll", icon: "mouse",
                  tags: "sensitivity scroll tap click natural scrolling touchpad",
                  source: "pages/trackpadmouse/TrackpadMouseSettings.qml" },
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
                          tags: "background image slideshow",
                          source: "pages/appearance/wallpaper/WallpaperSettings.qml" },
                        // Theme and Colors used to be two separate views; they are one page now.
                        { id: "theme", title: "Theme", subtitle: "Theme, colors and palette overrides", icon: "format_paint",
                          tags: "theme card preset changer colors palette accent override theme tracking light dark",
                          source: "pages/appearance/theme/ThemeSettings.qml" },
                        { id: "typography", title: "Typography", subtitle: "Fonts, size and icon style", icon: "text_fields",
                          tags: "fonts size icons weight",
                          source: "pages/appearance/typography/TypographySettings.qml" },
                        { id: "motion", title: "Motion", subtitle: "Speed, bounce and Hyprland animations", icon: "speed",
                          tags: "animations physics springs reduce bounce hyprland",
                          source: "pages/appearance/motion/MotionSettings.qml" },
                        { id: "opacity", title: "Opacity", subtitle: "Mica, spacing and shadows", icon: "opacity",
                          tags: "mica transparency shadow depth",
                          source: "pages/appearance/opacity/OpacitySettings.qml" }
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
                          tags: "terminal browser file manager media player email video music image pdf text editor xdg mime",
                          source: "pages/apps/defaultapps/DefaultAppsSettings.qml" },
                        { id: "allapps", title: "All apps", subtitle: "Favourites and hidden apps", icon: "grid_view",
                          tags: "installed favourites favorites hidden library star",
                          source: "pages/apps/allapps/AllAppsSettings.qml" }
                    ]
                },
                { id: "focusnotifications", title: "Focus & Notifications", subtitle: "Quiet modes and alerts", icon: "notifications",
                  tags: "peace mode do not disturb previews dnd toasts timeout expire fullscreen",
                  source: "pages/focusnotifications/FocusNotificationsSettings.qml" },
                { id: "language", title: "Language & Region", subtitle: "Language, units and clock format", icon: "language",
                  tags: "locale language clock 12 24 hour temperature units weather location",
                  source: "pages/language/LanguageSettings.qml" },
                { id: "services", title: "Services", subtitle: "Update intervals and backends", icon: "build",
                  tags: "polling refresh interval media stats wifi rescan lyrics backend default player",
                  source: "pages/services/ServicesSettings.qml" },
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