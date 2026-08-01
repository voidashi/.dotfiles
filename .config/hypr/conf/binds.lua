-- =====================================================================
--  KEYBINDINGS
-- =====================================================================
-- https://wiki.hypr.land/Configuring/Basics/Binds/
-- https://wiki.hypr.land/Configuring/Basics/Dispatchers/
-- Depends on conf/programs.lua for terminal, fileManager and menu, which
-- hyprland.lua loads before this file. That load order matters.
local mainMod = "SUPER"

-- Core bindings
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.kill()) -- force close (SIGKILL), for hung applications
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd(terminal .. " -e " .. terminalFileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))

-- Layout and pseudotiling
-- hl.bind(mainMod .. " + L", hl.dsp.layout("changelayout dwindle"))
-- hl.bind(mainMod .. " + T", hl.dsp.layout("changelayout master"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- Group and ungroup the active window into tabs
hl.bind(mainMod .. " + G", hl.dsp.group.toggle())

-- Resize mode, driven by the arrow keys. Escape leaves it.
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    hl.bind("right",  hl.dsp.window.resize({ x = 10, y = 0, relative = true }),  { repeating = true })
    hl.bind("left",   hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
    hl.bind("up",     hl.dsp.window.resize({ x = 0, y = 10, relative = true }),  { repeating = true })
    hl.bind("down",   hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
    hl.bind("escape", hl.dsp.submap("reset"))
end)

-- Focus and movement
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Move the active window with SHIFT and the arrow keys.
-- "swap" exchanges the window with its neighbour and preserves the dwindle
-- tree's geometry, so the result is what you see happen. "move" reinserts the
-- window into the split tree, which recalculates proportions and makes windows
-- change size as they move; in exchange it reaches a neighbouring monitor when
-- there is no window in that direction. To switch behaviour, swap the lines.
-- hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
-- hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
-- hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
-- hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.swap({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.swap({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.swap({ direction = "down" }))

-- Switch workspace with mainMod and [0-9]
-- Send the active window to another workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- workspace 10 maps to the 0 key
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scratchpad workspace
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Switch workspace by scrolling
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move and resize windows with mainMod plus the left or right mouse button
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Media keys: volume
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd("playerctl previous"),  { locked = true })
hl.bind("XF86AudioNext",        hl.dsp.exec_cmd("playerctl next"),      { locked = true })

-- Media keys: brightness
-- -e3 is load-bearing, not decoration: it makes the percentage a perceptual axis
-- instead of a raw one. Keep it in step with the same two binds in sway/config.
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e3 s 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e3 s 5%-"), { locked = true, repeating = true })

-- Screenshots
-- Screenshot of a window
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("hyprshot -m window"))
-- Screenshot of an output
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m output"))
-- Screenshot of a region
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m region"))

-- Clipboard
-- SUPER + V is already float, so the history sits on SHIFT of the same finger.
-- The whole pipeline lives in scripts/wm/clipboard-picker.sh rather than here,
-- because Sway needs exactly the same one and two copies drift.
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("$HOME/.dotfiles/scripts/wm/clipboard-picker.sh"))

-- Lid. Nothing here locks the screen, on purpose. Closing the lid makes logind
-- suspend, and hypridle's before_sleep_cmd locks on the way down, so a lock
-- bound here would be the second of two paths to the same screen. The bind that
-- used to sit here was also wrong in a way that is easy to write again: a bare
-- "switch:" fires on both transitions, because Hyprland calls onSwitchEvent
-- unconditionally before dispatching on or off, so it locked the screen when the
-- lid was opened. Sway has no lid bind at all, for the same reason.
-- docs/MAINTENANCE.md has the incident this came from.
--
-- The lock screen's appearance comes from ~/.config/swaylock/config, which is
-- tracked in this repo. An older lock.sh passed the same options as CLI flags
-- and overrode that file with a different theme, so do not reintroduce one.
--
-- Fires while the lid is closing
hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd('hyprctl keyword monitor "eDP-1, disable"'), { locked = true })
-- Fires while the lid is opening
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd('hyprctl keyword monitor "eDP-1, 1920x1080, 0x0, 1"'), { locked = true })
