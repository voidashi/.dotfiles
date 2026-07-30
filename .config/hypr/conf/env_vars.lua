-- =====================================================================
--  ENVIRONMENT VARIABLES
-- =====================================================================
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
--
-- These are duplicated in ~/.config/environment.d/50-voidashi.conf, and the two
-- MUST AGREE. Sway has no way to set an environment variable from its own config,
-- so that file is the only source there; Hyprland sets them here and propagates
-- them into the systemd and D-Bus environment itself. Change one, change both.
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Prefer dark theme.
-- Most Qt applications here are KDE ones (dolphin, ark, gwenview, kate,
-- spectacle) and read their palette from kdeglobals, which is generated from
-- palette.json. The ones that are not, VLC among them, reach the same palette
-- through KDEPlasmaPlatformTheme6.so, which is what this variable loads and
-- which ships in plasma-integration. Without that package the variable is set
-- and nothing honours it, with no error.
--
-- This was "qt6ct", which is meant for Qt applications that are *not* KDE ones:
-- with no ~/.config/qt6ct to read, it served its own default light palette over
-- the dark kdeglobals behind it, which is why Dolphin came up white.
hl.env("QT_QPA_PLATFORMTHEME", "kde")
