-- =====================================================================
--  MONITORES
-- =====================================================================
-- Configuração para monitores e Multi-GPU (usando GPU integrada para Hyprland)
-- https://wiki.hypr.land/Configuring/Basics/Monitors/

-- hl.monitor({ output = "eDP-1", disabled = true })
hl.monitor({ output = "eDP-1", mode = "1920x1080@60", position = "0x0", scale = 1 })

hl.monitor({ output = "DP-1", mode = "1920x1080@144", position = "1920x0", scale = 1 })

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
