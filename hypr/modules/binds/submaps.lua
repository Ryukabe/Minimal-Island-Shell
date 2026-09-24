-- Capture submap (used by Settings > Keybinds while rebinding).
-- While active, no bind outside this submap can fire, so you can rebind a
-- combo that is already in use without triggering the old action.
-- Escape is the safety valve so you are never stuck if Quickshell closes mid-capture.
hl.define_submap("capture", function()
    hl.bind("Escape", hl.dsp.submap("reset"))
end)