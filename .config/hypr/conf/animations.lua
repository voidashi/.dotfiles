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

-- Speed is in deciseconds (1 = 100ms). The previous 6-10 range meant 600-1000ms
-- per animation, which is what made the desktop feel sluggish in daily use.
-- These sit just above RICE-GUIDE.md's motion table -- the table's numbers were
-- written for UI transitions and read as abrupt on full windows, so the desktop
-- band is a notch longer while staying far from the old values. myBezier is
-- applied everywhere rather than only to `windows`: the table asks for ease-out
-- throughout, and the others were still on Hyprland's default curve.
hl.animation({ leaf = "windows",     enabled = true, speed = 3,   bezier = "myBezier" })  -- open: 300ms
-- "popin" is named explicitly in RICE-GUIDE.md as one of the terms compositors
-- use for overshoot curves -- dropped in favor of a plain fade/slide close.
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 3,   bezier = "myBezier" })  -- close: 300ms
hl.animation({ leaf = "border",      enabled = true, speed = 1.5, bezier = "myBezier" })  -- focus change: 150ms
hl.animation({ leaf = "borderangle", enabled = true, speed = 1.5, bezier = "myBezier" })  -- focus change: 150ms
hl.animation({ leaf = "fade",        enabled = true, speed = 2,   bezier = "myBezier" })  -- reveal: 200ms
hl.animation({ leaf = "workspaces",  enabled = true, speed = 3.5, bezier = "myBezier" })  -- switch: 350ms
