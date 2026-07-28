-- =====================================================================
--  PROGRAMAS
-- =====================================================================
-- https://wiki.hypr.land/Configuring/Basics/Binds/
-- Configuração dos programas padrão e apps iniciais
-- Definidas como globais (sem "local") para conf.d/binds.lua poder usá-las.

-- terminal = "foot"
-- terminal = "ghostty"
terminal = "kitty"

-- fileManager = "dolphin"
fileManager = "cosmic-files"

-- hyprlauncher is themed through .config/hypr/hyprtoolkit.conf rather than any
-- config of its own -- that file stays in place, so switching back is a matter
-- of swapping these two lines.
-- menu = "hyprlauncher"
menu = "wofi --show drun"
