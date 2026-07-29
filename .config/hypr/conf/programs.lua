-- =====================================================================
--  PROGRAMAS
-- =====================================================================
-- https://wiki.hypr.land/Configuring/Basics/Binds/
-- Configuração dos programas padrão e apps iniciais
-- Definidas como globais (sem "local") para conf.d/binds.lua poder usá-las.

-- terminal = "foot"
-- terminal = "ghostty"
terminal = "kitty"

-- This pointed at cosmic-files, which is not installed, so SUPER+E ran a binary
-- that does not exist. Dolphin is themed through kdeglobals; yazi below is the
-- terminal counterpart and inherits the emulator's palette.
fileManager = "dolphin"
terminalFileManager = "yazi"

-- hyprlauncher is themed through .config/hypr/hyprtoolkit.conf rather than any
-- config of its own -- that file stays in place, so switching back is a matter
-- of swapping these two lines.
-- menu = "hyprlauncher"
menu = "wofi --show drun"
