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
    readonly property string projectVersion: "v1.0.0"
    readonly property string projectRepo: "https://github.com/Ryukabe/hermit-dots"

    readonly property var clusters: [
        {
            id: "shell",
            menus: [
                {
                    id: "bar", title: "Bar & Island", subtitle: "Shape, size and behaviour of the island", icon: "dock_to_bottom",
                    tags: "top margin corner radius border notch flare height width collapsed expanded hover lift click outside dismiss persistent show on hover drag threshold scroll gestures",
                    source: "pages/bar/BarSettings.qml",
                    views: [
                        { id: "workspaces", title: "Workspaces", subtitle: "Indicators and window icons", icon: "grid_view",
                          tags: "workspace shown active indicator trail occupied windows special per-monitor",
                          source: "pages/bar/workspaces/WorkspacesSettings.qml" },
                        { id: "clock", title: "Clock", subtitle: "Time, date and bar indicators", icon: "schedule",
                          tags: "time date seconds leading zero am pm visualizer timer icon recording indicator preview",
                          source: "pages/bar/clock/ClockSettings.qml" }
                    ]
                },
                { id: "dashboard", title: "Dashboard", subtitle: "Tabs, widgets and opening", icon: "dashboard",
                  tags: "status panel width height size tabs media performance weather widgets battery gpu cpu memory storage drag threshold hover",
                  source: "pages/dashboard/DashboardSettings.qml" },
                {
                    id: "launcher", title: "Launcher", subtitle: "App search, tools and clipboard", icon: "rocket_launch",
                    tags: "app search width rows results match fuzzy prefix recent apps icons animate shrink preset",
                    source: "pages/launcher/LauncherPage.qml",
                    views: [
                        { id: "searchtools", title: "Search tools", subtitle: "Calculator, web, files and quick pickers", icon: "bolt",
                          tags: "calculator units web search commands files system emoji snippets notes trigger prefix",
                          source: "pages/launcher/SearchToolsPage.qml" },
                        { id: "clipboard", title: "Clipboard", subtitle: "History and panel size", icon: "content_paste",
                          tags: "clipboard history cliphist entries width rows",
                          source: "pages/launcher/ClipboardPage.qml" },
                        { id: "notessnippets", title: "Notes & snippets", subtitle: "Where they are saved", icon: "edit_note",
                          tags: "quick notes snippets folder file json aliases pinned search engines storage",
                          source: "pages/launcher/NotesSnippetsPage.qml" }
                    ]
                },
                { id: "controlcenter", title: "Control Center", subtitle: "Tiles and layout", icon: "widgets",
                  tags: "quick settings tiles grid columns layout edit add remove resize move tidy undo reset",
                  source: "pages/controlcenter/ControlCenterSettings.qml" },
                { id: "lockscreen", title: "Lock Screen", subtitle: "Look and unlock behaviour", icon: "lock",
                  tags: "pam password security idle lid clock blur dim username hint text nav actions reboot power hyprland notifications",
                  source: "pages/lockscreen/LockScreenPage.qml" },
            ]
        },
        {
            id: "devices",
            menus: [
                {
                    id: "network", title: "Wi-Fi & Bluetooth", subtitle: "Networks and paired devices", icon: "wifi",
                    tags: "network wireless connect pair devices airplane",
                    views: [
                        { id: "wifi", title: "Wi-Fi", subtitle: "Networks and connections", icon: "wifi",
                          tags: "wifi wireless network password connect scan metered airplane",
                          source: "pages/network/WifiPage.qml" },
                        { id: "bluetooth", title: "Bluetooth", subtitle: "Paired and nearby devices", icon: "bluetooth",
                          tags: "bluetooth pair device headphones battery discoverable",
                          source: "pages/network/BluetoothPage.qml" }
                    ]
                },
                { id: "soundmedia", title: "Sound & Media", subtitle: "Volume, outputs and players", icon: "graphic_eq",
                  tags: "volume output mpris visualizer step max lyrics source backend preferred default player",
                  source: "pages/soundmedia/SoundMediaSettings.qml" },
                { id: "display", title: "Displays", subtitle: "Monitors and scaling", icon: "desktop_windows",
                  tags: "resolution refresh rate scale transparency monitor",
                  source: "pages/display/DisplaySettings.qml" },
                { id: "trackpadmouse", title: "Trackpad & Mouse", subtitle: "Pointer, tap and scroll", icon: "mouse",
                  tags: "sensitivity scroll tap click natural scrolling touchpad",
                  source: "pages/trackpadmouse/TrackpadMouseSettings.qml" },
                {
                    id: "keybinds", title: "Keybinds", subtitle: "Hyprland and shell shortcuts", icon: "keyboard",
                    tags: "keyboard shortcuts hyprland binds hotkeys rebind modifier super add custom conflict",
                    source: "pages/keybinds/KeybindsPage.qml",
                    views: [
                        { id: "windows", title: "Windows", subtitle: "Windows, workspaces and layout", icon: "window",
                          tags: "hyprland window workspace move focus tile float fullscreen close",
                          category: "Hyprland",
                          source: "pages/keybinds/KeybindListPage.qml" },
                        { id: "shell", title: "Shell", subtitle: "Launcher, panels and the island", icon: "dock_to_bottom",
                          tags: "quickshell launcher control center power menu clipboard settings island",
                          category: "Quickshell",
                          source: "pages/keybinds/KeybindListPage.qml" },
                        { id: "mediasystem", title: "Media & system", subtitle: "Volume, brightness and screenshots", icon: "perm_media",
                          tags: "media volume brightness screenshot play pause next previous lock",
                          category: "Media & System",
                          source: "pages/keybinds/KeybindListPage.qml" }
                    ]
                },
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
                    id: "apps", title: "Apps", subtitle: "Defaults, startup and app library", icon: "apps",
                    tags: "default applications terminal browser file manager favourites hidden startup autostart",
                    views: [
                        { id: "defaultapps", title: "Default apps", subtitle: "Terminal, browser, files and more", icon: "app_registration",
                          tags: "terminal browser file manager media player email video music image pdf text editor xdg mime",
                          source: "pages/apps/defaultapps/DefaultAppsSettings.qml" },
                        { id: "startup", title: "Startup apps", subtitle: "Apps that open when you log in", icon: "play_circle",
                          tags: "startup login items autostart boot launch open at login command",
                          source: "pages/apps/startup/StartupAppsSettings.qml" },
                        { id: "allapps", title: "All apps", subtitle: "Favourites and hidden apps", icon: "grid_view",
                          tags: "installed favourites favorites hidden library star",
                          source: "pages/apps/allapps/AllAppsSettings.qml" }
                    ]
                },
                {
                    id: "focusnotifications", title: "Focus & Notifications", subtitle: "Quiet modes and alerts", icon: "notifications",
                    tags: "peace mode do not disturb previews dnd notification center width height",
                    source: "pages/focusnotifications/FocusNotificationsSettings.qml",
                    views: [
                        { id: "alerts", title: "Alerts", subtitle: "Timeout, expiry and grouping", icon: "notification_important",
                          tags: "timeout expire expanded group preview fullscreen",
                          source: "pages/focusnotifications/AlertsSettings.qml" },
                        { id: "toasts", title: "Toasts", subtitle: "Small pop-ups and what triggers them", icon: "chat_bubble",
                          tags: "toast visible count fullscreen charging game mode audio output input",
                          source: "pages/focusnotifications/ToastsSettings.qml" }
                    ]
                },
                { id: "language", title: "Language & Region", subtitle: "Language, units and clock format", icon: "language",
                  tags: "locale language clock 12 24 hour temperature units weather location",
                  source: "pages/language/LanguageSettings.qml" },
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