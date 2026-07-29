-- =====================================================================
--  PROGRAMAS
-- =====================================================================
-- https://wiki.hypr.land/Configuring/Basics/Binds/
-- Default programs and startup apps.
-- Declared global (no "local") so that conf/binds.lua can reach them.

-- terminal = "foot"
-- terminal = "ghostty"
terminal = "kitty"

-- This pointed at cosmic-files, which is not installed, so SUPER+E ran a binary
-- that does not exist. Dolphin is themed through kdeglobals; yazi below is the
-- terminal counterpart and inherits the emulator's palette.
fileManager = "dolphin"
terminalFileManager = "yazi"

-- hyprlauncher is themed through .config/hypr/hyprtoolkit.conf rather than any
-- config of its own; that file stays in place, so switching back is a matter
-- of swapping these two lines.
-- menu = "hyprlauncher"
menu = "wofi --show drun"
