-- =====================================================================
--  INPUT (TECLADO E MOUSE)
-- =====================================================================
-- https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    input = {
        kb_layout = "us", -- "br"
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",
        follow_mouse = 1,

        sensitivity = 0,
        accel_profile = "flat",
        -- force_no_accel removido: ignora accel_profile e a wiki recomenda
        -- evitar por causar dessincronia do cursor.
        left_handed = false,

        -- Touchpad settings
        touchpad = {
            natural_scroll = true,
        },
    },

    cursor = {
        no_hardware_cursors = false,
    },
})
