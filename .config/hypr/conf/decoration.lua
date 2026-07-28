-- =====================================================================
--  DECORAÇÃO (SHADOWS, TRANSPARÊNCIA)
-- =====================================================================
-- https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    decoration = {
        -- Voidashi: "Sharp corners. Zero border radius wherever it can be set"
        -- is a non-negotiable (CLAUDE.md); was 10 (Kanagawa Dragon).
        rounding = 0,

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
