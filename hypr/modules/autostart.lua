-- Autostart services hook
hl.on("hyprland.start", function()
    -- Polkit Authentication Agent
    --hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    --hl.exec_cmd("hyprpolkitagent")
    
    -- System tools
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("hyprctl setcursor macOS 24")
    
    -- Launch Quickshell once cleanly with OpenGL backend
    hl.exec_cmd("quickshell")

    --hl.exec_cmd("swaync")
    --hl.exec_cmd("hypridle")
    
    -- Applications
    hl.exec_cmd("pcloud")
    
    -- Clipboard Management
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("wl-clip-persist --clipboard regular")

    
    hl.exec_cmd("killall mako dunst swaync 2>/dev/null")
end)