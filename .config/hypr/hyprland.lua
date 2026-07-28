-- =====================================================================
-- HYPRLAND CONFIG PRINCIPAL
-- =====================================================================
-- Migrado de hyprlang (.conf) para Lua (Hyprland >= 0.55)
-- https://wiki.hypr.land/Configuring/Start/

-- Inclui cada seção modularizada (ordem importa: programs define globais
-- usados por binds)
require("conf/programs")
require("conf/monitors")
require("conf/env_vars")
require("conf/autostart")
require("conf/appearance")
require("conf/decoration")
require("conf/animations")
require("conf/layouts")
require("conf/misc")
require("conf/input")
require("conf/gestures")
require("conf/binds")
require("conf/window_rules")
