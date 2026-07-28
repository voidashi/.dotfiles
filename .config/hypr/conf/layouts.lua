-- =====================================================================
--  LAYOUTS: DWINDLE E MASTER
-- =====================================================================
-- https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/
hl.config({
    dwindle = {
        -- pseudotile = true,
        preserve_split = true, -- You probably want this
        -- "no_gaps_when_only" saiu do dwindle; ver "smart gaps" em conf.d/window_rules.lua
    },
})

-- https://wiki.hypr.land/Configuring/Layouts/Master-Layout/
hl.config({
    master = {
        new_status = "master",
    },
})
