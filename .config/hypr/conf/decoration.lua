-- =====================================================================
--  DECORAÇÃO (SHADOWS, TRANSPARÊNCIA)
-- =====================================================================
-- https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    decoration = {
        -- Compositor windows are the one Voidashi surface allowed a radius, and
        -- it stays small: sharp enough to read as cut, not moulded (was 10 under
        -- Kanagawa Dragon, then briefly 0). Every other surface -- bar, launcher,
        -- notifications -- is still square. See RICE-GUIDE.md, "Geometry".
        rounding = 4,

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
