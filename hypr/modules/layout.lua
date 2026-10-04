-- changeLayout3.sh writes the last layout to ~/.config/hypr/.layout,
-- so a reload or a shell switch keeps it. Falls back to dwindle.
local function saved_layout()
    local f = io.open(os.getenv("HOME") .. "/.config/hypr/.layout", "r")
    if not f then return "dwindle" end
    local value = f:read("l")
    f:close()
    if value == "dwindle" or value == "master" or value == "scrolling" then
        return value
    end
    return "dwindle"
end

hl.config({
    general = {
        layout = saved_layout(),
    },

    master = {
        new_status = "master",
    },

    -- Dwindle tuning kept disabled to preserve the current behavior.
    -- dwindle = {
    --     pseudotile = true,
    --     preserve_split = true,
    -- },
})