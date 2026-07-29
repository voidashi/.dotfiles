-- =====================================================================
--  DECORAÇÃO (SHADOWS, TRANSPARÊNCIA)
-- =====================================================================
-- https://wiki.hypr.land/Configuring/Basics/Variables/
local palette = require("conf/palette")

hl.config({
    decoration = {
        -- A floating surface takes the system radius; anything docked to a
        -- screen edge stays square. Small enough to read as cut rather than
        -- moulded (was 10 under Kanagawa Dragon, then briefly 0). The value
        -- lives in scripts/theme/palette.json; see RICE-GUIDE.md, "Form".
        rounding = palette.geometry.radius_floating,

        active_opacity = 1.0,
        inactive_opacity = 1.0,
        fullscreen_opacity = 1.0,

        -- Blur settings
        blur = {
            enabled = true,
            size = 5,
            passes = 1,
        },

        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            -- void-00, not an invented gray (was rgba(1a1a1aee))
            color = "rgba(0a0908ee)",
        },
    },
})
