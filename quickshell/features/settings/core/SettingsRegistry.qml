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
    readonly property string defaultMenuId: "bar"

    // Shown on the About page. Change the version here and nowhere else.
    readonly property string projectName: "Hermit-dots"
    readonly property string projectVersion: "v1.0.0"
    readonly property string projectRepo: "https://github.com/Ryukabe/hermit-dots"

    readonly property var clusters: [
        {
            id: "shell",
            menus: [
                {
                    id: "bar", title: "Bar & Island", subtitle: "Style, clock items and size of the island", icon: "dock_to_bottom",
                    tags: "island notch style top margin border flare height width collapsed expanded clock layout items chips add remove order move workspaces visualizer timer icon mic camera privacy recording dot click item card quick options 24 hour seconds date style bars color count dots capsule",
                    source: "../bar/BarSettings.qml",
                    views: [
                        { id: "workspaces", title: "Workspaces", subtitle: "Indicators and window icons", icon: "grid_view",
                          tags: "workspace workspaces shown count dots capsule active indicator trail occupied windows special per-monitor",
                          source: "../bar/WorkspacesSettings.qml" },
                        { id: "clock", title: "Clock", subtitle: "Time and date format", icon: "schedule",
                          tags: "time date format seconds leading zero am pm 24 hour short long timer toast recording",
                          source: "../bar/ClockSettings.qml" },
                        { id: "visualizer", title: "Music visualizer", subtitle: "Bars, speed and color", icon: "equalizer",
                          tags: "visualizer music audio bars width gap height speed color preview",
                          source: "../bar/VisualizerSettings.qml" },
                        { id: "behavior", title: "Behavior", subtitle: "Visibility, hover and scroll", icon: "tune",
                          tags: "persistent always visible show on hover reveal zone hide delay lift click outside dismiss scroll gestures volume brightness",
                          source: "../bar/BehaviorSettings.qml" }
                    ]
                },
                {
                    id: "dashboard", title: "Dashboard", subtitle: "Layout, components and size", icon: "dashboard",
                    tags: "status panel width height size grid columns rows layout components move resize corner undo reset quick note media cd system stats calendar",
                    views: [
                        { id: "layout", title: "Layout", subtitle: "Panel size, grid and components", icon: "dashboard",
                          tags: "width height size grid columns rows components move resize corner undo reset preview",
                          source: "../dashboard/DashboardSettings.qml" },
                        { id: "quicknote", title: "Quick note", subtitle: "Markdown note editor", icon: "edit_note",
                          tags: "note markdown toolbar bold italic heading bullet numbered list text size file save",
                          source: "../dashboard/DashboardQuickNoteSettings.qml" },
                        { id: "media", title: "Media", subtitle: "CD player card", icon: "album",
                          tags: "cd disc spin rotation cover blur background controls artist player",
                          source: "../dashboard/DashboardMediaSettings.qml" },
                        { id: "stats", title: "System stats", subtitle: "Rows, graphs and update rate", icon: "monitoring",
                          tags: "cpu gpu memory ram network battery temperature graph history update interval",
                          source: "../dashboard/DashboardStatsSettings.qml" },
                        { id: "calendar", title: "Calendar", subtitle: "Month view options", icon: "calendar_month",
                          tags: "calendar month week start sunday monday saturday days outside",
                          source: "../dashboard/DashboardCalendarSettings.qml" }
                    ]
                },
                {
                    id: "launcher", title: "Launcher", subtitle: "App search, tools and clipboard", icon: "rocket_launch",
                    tags: "app search width rows results match fuzzy prefix recent apps icons animate shrink preset",
                    source: "../launcher/LauncherPage.qml",
                    views: [
                        { id: "searchtools", title: "Search tools", subtitle: "Calculator, web, files and quick pickers", icon: "bolt",
                          tags: "calculator units web search commands files system emoji snippets notes trigger prefix",
                          source: "../launcher/SearchToolsPage.qml" },
                        { id: "clipboard", title: "Clipboard", subtitle: "History and panel size", icon: "content_paste",
                          tags: "clipboard history cliphist entries width rows",
                          source: "../clipboard/ClipboardPage.qml" },
                        { id: "notessnippets", title: "Notes & snippets", subtitle: "Where they are saved", icon: "edit_note",
                          tags: "quick notes snippets folder file json aliases pinned search engines storage",
                          source: "../launcher/NotesSnippetsPage.qml" }
                    ]
                },
                { id: "controlcenter", title: "Control Center", subtitle: "Tiles and layout", icon: "widgets",
                  tags: "quick settings tiles grid columns layout edit add remove resize move tidy undo reset",
                  source: "../control-center/ControlCenterSettings.qml" },
                {
                  id: "lockscreen", title: "Lock Screen", subtitle: "Look and unlock behaviour", icon: "lock",
                  tags: "pam password security idle lid clock blur dim username hint text nav actions reboot power hyprland notifications wallpaper preview folder weather city temperature celsius fahrenheit forecast hourly feels like media now playing album art progress cover hide track",
                  source: "../lockscreen/LockScreenPage.qml",
                  views: [
                      { id: "knowledge", title: "Knowledge", subtitle: "Facts and words on the lock screen", icon: "lightbulb",
                        tags: "fact word meaning vocabulary slide interesting did you know learn",
                        source: "../lockscreen/KnowledgePage.qml" }
                  ]
                },
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
                          source: "../network/WifiPage.qml" },
                        { id: "bluetooth", title: "Bluetooth", subtitle: "Paired and nearby devices", icon: "bluetooth",
                          tags: "bluetooth pair device headphones battery discoverable",
                          source: "../network/BluetoothPage.qml" }
                    ]
                },
                { id: "soundmedia", title: "Sound & Media", subtitle: "Volume, outputs and players", icon: "graphic_eq",
                  tags: "volume output mpris visualizer step max lyrics source backend preferred default player",
                  source: "../sound/SoundMediaSettings.qml" },
                { id: "display", title: "Displays", subtitle: "Monitors and scaling", icon: "desktop_windows",
                  tags: "resolution refresh rate scale transparency monitor",
                  source: "../display/DisplaySettings.qml" },
                { id: "trackpadmouse", title: "Trackpad & Mouse", subtitle: "Pointer, tap and scroll", icon: "mouse",
                  tags: "sensitivity scroll tap click natural scrolling touchpad",
                  source: "../hyprland/TrackpadMouseSettings.qml" },
                {
                    id: "keybinds", title: "Keybinds", subtitle: "Hyprland and shell shortcuts", icon: "keyboard",
                    tags: "keyboard shortcuts hyprland binds hotkeys rebind modifier super add custom conflict",
                    source: "../hyprland/KeybindsPage.qml",
                    views: [
                        { id: "windows", title: "Windows", subtitle: "Windows, workspaces and layout", icon: "window",
                          tags: "hyprland window workspace move focus tile float fullscreen close",
                          category: "Hyprland",
                          source: "../hyprland/KeybindListPage.qml" },
                        { id: "shell", title: "Shell", subtitle: "Launcher, panels and the island", icon: "dock_to_bottom",
                          tags: "quickshell launcher control center power menu clipboard settings island",
                          category: "Quickshell",
                          source: "../hyprland/KeybindListPage.qml" },
                        { id: "mediasystem", title: "Media & system", subtitle: "Volume, brightness and screenshots", icon: "perm_media",
                          tags: "media volume brightness screenshot play pause next previous lock",
                          category: "Media & System",
                          source: "../hyprland/KeybindListPage.qml" }
                    ]
                },
            ]
        },
        {
            id: "looks",
            menus: [
                {
                    id: "appearance", title: "Appearance", subtitle: "Theme, mode, wallpaper, type and motion", icon: "palette",
                    tags: "theme picker card preset fonts color dark light auto mode schedule sunrise sunset accent wallpaper",
                    source: "../theme/AppearanceSettings.qml",
                    views: [
                        { id: "wallpaper", title: "Wallpaper", subtitle: "Background image and rotation", icon: "wallpaper",
                          tags: "background image slideshow",
                          source: "../theme/WallpaperSettings.qml" },
                        // The theme picker and light/dark mode moved to the Appearance page; this view keeps
                        // the palette source and the manual colors. The id stays "theme" so nothing that links here breaks.
                        { id: "theme", title: "Colors", subtitle: "Palette source and custom colors", icon: "format_paint",
                          tags: "colors palette source prebuilt dynamic custom accent override hex dark light",
                          source: "../theme/ThemeSettings.qml" },
                        { id: "typography", title: "Typography", subtitle: "Fonts, size and icon style", icon: "text_fields",
                          tags: "fonts size icons weight",
                          source: "../theme/TypographySettings.qml" },
                        { id: "motion", title: "Motion", subtitle: "Speed, bounce and Hyprland animations", icon: "speed",
                          tags: "animations physics springs reduce bounce hyprland",
                          source: "../theme/MotionSettings.qml" },
                        // Corners, mica and shadow share one page. The id stays "opacity" so nothing that links here breaks.
                        { id: "opacity", title: "Surfaces", subtitle: "Corners, mica and shadows", icon: "opacity",
                          tags: "corner radius round universal island card control chip mica transparency opacity shadow depth blur",
                          source: "../theme/OpacitySettings.qml" },
                        { id: "windows", title: "Windows", subtitle: "Gaps, opacity, shadow and corner shape", icon: "web_asset",
                          tags: "windows hyprland gaps inner outer spacing border size corner shape rounding power squircle circle opacity transparency active inactive fullscreen dim dimming shadow range sharpness scale",
                          source: "../theme/WindowsSettings.qml" },                         
                        { id: "templates", title: "Templates", subtitle: "Re-theme other apps when your theme changes", icon: "dashboard_customize",
                          tags: "templates apps gtk qt kitty terminal vscode hyprland sync colors adapters",
                          source: "../theme/TemplatesSettings.qml" },
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
                          source: "../apps/DefaultAppsSettings.qml" },
                        { id: "startup", title: "Startup apps", subtitle: "Apps that open when you log in", icon: "play_circle",
                          tags: "startup login items autostart boot launch open at login command",
                          source: "../apps/StartupAppsSettings.qml" },
                        { id: "allapps", title: "All apps", subtitle: "Favourites and hidden apps", icon: "grid_view",
                          tags: "installed favourites favorites hidden library star",
                          source: "../apps/AllAppsSettings.qml" }
                    ]
                },
                {
                    id: "focusnotifications", title: "Focus & Notifications", subtitle: "Quiet modes and alerts", icon: "notifications",
                    tags: "peace mode do not disturb previews dnd notification center width height",
                    source: "../notifications/FocusNotificationsSettings.qml",
                    views: [
                        { id: "alerts", title: "Alerts", subtitle: "Timeout, expiry and grouping", icon: "notification_important",
                          tags: "timeout expire expanded group preview fullscreen",
                          source: "../notifications/AlertsSettings.qml" },
                        { id: "toasts", title: "Toasts", subtitle: "Small pop-ups and what triggers them", icon: "chat_bubble",
                          tags: "toast visible count fullscreen charging game mode audio output input",
                          source: "../notifications/ToastsSettings.qml" }
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
