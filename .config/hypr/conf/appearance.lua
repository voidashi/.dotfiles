-- =====================================================================
--  APARÊNCIA (LOOK AND FEEL)
-- =====================================================================
-- https://wiki.hypr.land/Configuring/Basics/Variables/
local palette = require("conf/palette")

hl.config({
    general = {
        border_size = 2,
        gaps_in = 3,
        gaps_out = 10,

        col = {
            -- Voidashi: foco/ativo = Ice (RICE-GUIDE.md role table), inativa = edge-30
            -- (era rgba(8ba4b0ee) / rgba(625e5aaa) -- tema Kanagawa Dragon)
            active_border = "rgba(" .. palette.ice["300"]:gsub("#", "") .. "ee)",
            inactive_border = "rgba(" .. palette.edge["30"]:gsub("#", "") .. "bb)",
        },

        layout = "dwindle",

        resize_on_border = false,
        allow_tearing = false,
    },
})
