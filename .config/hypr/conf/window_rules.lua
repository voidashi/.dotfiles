-- =====================================================================
--  REGRAS PARA JANELAS E WORKSPACES
-- =====================================================================
-- https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })

-- Smart gaps ("no gaps when only")
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })

hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, rounding = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]" },   border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]" },   rounding = 0 })
