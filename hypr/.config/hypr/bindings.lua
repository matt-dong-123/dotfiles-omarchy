-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

local mainMod = "SUPER + CTRL + SHIFT + ALT"
local function focus_or_launch(key, app_class, launch_cmd)
    hl.bind(key, function()
        -- Try to find a window with the specific class
        local window = hl.get_window("class:" .. app_class)
        if window then
            -- Focus the existing window (switches workspace if needed)
            hl.dispatch(hl.dsp.focus({ window = window }))
        else
            -- Launch the application
            hl.dispatch(hl.dsp.exec_cmd(launch_cmd))
        end
    end, { description = "Focus or launch " .. app_class })
end

-- WM
o.bind("ALT + H", "Focus left", hl.dsp.focus({ direction = "l" }))
o.bind("ALT + J", "Focus down", hl.dsp.focus({ direction = "d" }))
o.bind("ALT + K", "Focus up", hl.dsp.focus({ direction = "u" }))
o.bind("ALT + L", "Focus right", hl.dsp.focus({ direction = "r" }))
o.bind("SHIFT + ALT + H", "Move left", hl.dsp.window.move({ direction = "l" }))
o.bind("SHIFT + ALT + J", "Move down", hl.dsp.window.move({ direction = "d" }))
o.bind("SHIFT + ALT + K", "Move up", hl.dsp.window.move({ direction = "u" }))
o.bind("SHIFT + ALT + L", "Move right", hl.dsp.window.move({ direction = "r" }))
o.bind("SHIFT + ALT + MINUS", "Resize smart -50", hl.dsp.window.resize({ x = -49, y = -50, relative = true }))
o.bind("SHIFT + ALT + EQUAL", "Resize smart +50", hl.dsp.window.resize({ x = 50, y = 50, relative = true }))
o.bind("CTRL + ALT + RETURN", "Fullscreen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

-- rmpc
o.bind("SHIFT + SPACE", "Play/Pause Music", hl.dsp.exec_cmd("omarchy-shell -q mpd toggle"))
o.bind(mainMod .. " + Q", "Open RMPC", hl.dsp.exec_cmd("omarchy-shell matjam.omajam client"))

-- Misc
o.bind(mainMod .. " + SPACE", "Open Clipboard", hl.dsp.exec_cmd("omarchy menu clipboard"))
hl.unbind("SUPER + CTRL + SPACE")
o.bind(mainMod .. " + B", "Backgrounds", hl.dsp.exec_cmd("omarchy background"))
o.bind(mainMod .. " + T", "Themes", hl.dsp.exec_cmd("omarchy theme switcher"))
o.bind("SUPER + CTRL + SPACE", "Emoji Picker", hl.dsp.exec_cmd("omarchy menu emoji"))

-- Apps
focus_or_launch(mainMod .. " + RETURN", "kitty", "kitty")
focus_or_launch(mainMod .. " + A", "chromium", "chromium")
focus_or_launch(mainMod .. " + G", "Clash", "clash-verge")

hl.window_rule({
    match = { class = "chromium" },
    workspace = "1"
})

hl.window_rule({
    match = { class = "kitty" },
    workspace = "2"
})
