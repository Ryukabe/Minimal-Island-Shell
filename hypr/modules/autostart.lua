local home = os.getenv("HOME")

local function active_shell()
    local f = io.open(home .. "/.config/hypr/.active-shell")
    if not f then return "qs" end
    local v = f:read("l")
    f:close()
    return v == "ags" and "ags" or "qs"
end

hl.on("hyprland.start", function()
    --hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    --hl.exec_cmd("hyprpolkitagent")

    -- System tools
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 24")
    hl.exec_cmd("hypridle")

    -- Shell (whichever one was active last)
    if active_shell() == "ags" then
        hl.exec_cmd(home .. "/.config/ags/ags-launch-kill.sh")
    else
        hl.exec_cmd("quickshell")
    end

    -- Applications
    hl.exec_cmd("pcloud")

    -- Clipboard management
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("wl-clip-persist --clipboard regular")
end)