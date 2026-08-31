-- Autostart services hook
hl.on("hyprland.start", function()

    -- System tools
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("hyprctl setcursor macOS 24")
    hl.exec_cmd("quickshell")
    --hl.exec_cmd("hypridle")
    
    -- Applications
    hl.exec_cmd("pcloud")
    
    -- Clipboard Management
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("wl-clip-persist --clipboard regular")

end)