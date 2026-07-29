-- =====================================================================
--  VARIÁVEIS DE AMBIENTE
-- =====================================================================
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Prefer dark theme
-- Every Qt application on this machine is a KDE one (dolphin, ark, gwenview,
-- kate, spectacle, ...), and those read their palette from kdeglobals, which is
-- generated from palette.json. This was "qt6ct", which is meant for Qt apps
-- that are not KDE: with no ~/.config/qt6ct to read, it served its own default
-- light palette and overrode the dark kdeglobals sitting behind it, which is
-- why Dolphin came up white. Needs plasma-integration, already installed.
hl.env("QT_QPA_PLATFORMTHEME", "kde")
