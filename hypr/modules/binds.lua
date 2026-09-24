local home  = os.getenv("HOME")
local shell = "qs"

local f = io.open(home .. "/.config/hypr/.active-shell")
if f then
    if f:read("l") == "ags" then shell = "ags" end
    f:close()
end

-- Force every bind file to re-run on reload
package.loaded["modules.binds.mainmod"] = nil

for _, name in ipairs({ "submaps", "common", shell, "custom" }) do
    local mod = "modules.binds." .. name
    package.loaded[mod] = nil
    require(mod)
end