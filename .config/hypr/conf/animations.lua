-- =====================================================================
--  ANIMAÇÕES
-- =====================================================================
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.config({
    animations = {
        enabled = true,
    },
})

-- Voidashi: "No bounce, spring, or overshoot animation" is a non-negotiable
-- (CLAUDE.md). The old curve's y=1.1 control point overshot past its endpoint
-- (a literal bounce); this is RICE-GUIDE.md's documented standard curve
-- (cubic-bezier(.4,0,.2,1)) instead.
hl.curve("myBezier", { type = "bezier", points = { { 0.4, 0 }, { 0.2, 1 } } })

hl.animation({ leaf = "windows",     enabled = true, speed = 7,  bezier = "myBezier" })
-- "popin" is named explicitly in RICE-GUIDE.md as one of the terms compositors
-- use for overshoot curves -- dropped in favor of a plain fade/slide close.
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 7,  bezier = "default" })
hl.animation({ leaf = "border",      enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8,  bezier = "default" })
hl.animation({ leaf = "fade",        enabled = true, speed = 7,  bezier = "default" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 6,  bezier = "default" })
