-- Tema do lualine, derivado da mesma camada semântica que o colorscheme.
--
-- O lualine descobre temas por lua/lualine/themes/<nome>.lua no runtimepath,
-- que é por onde este é encontrado. Derivar dos papéis em vez de repetir
-- hexadecimais é o que mantém a statusline em sincronia quando a paleta muda.
--
-- O modo é a marca de identidade: Bordeaux no normal, como o prompt do
-- starship e o cursor do terminal. Os demais modos usam famílias distintas,
-- porque o modo é um estado e precisa ser lido de relance.

local r = require("voidashi.theme.roles")
local ui, syn, diag = r.ui, r.syn, r.diag
local p = r.palette

local function mode(accent)
  return {
    a = { bg = accent, fg = ui.bg, gui = "bold" },
    b = { bg = ui.bg_p2, fg = accent },
    c = { bg = ui.bg_p1, fg = ui.fg },
  }
end

return {
  normal   = mode(p.bordeaux["300"]),
  insert   = mode(diag.ok),
  visual   = mode(p.ice["300"]),
  replace  = mode(diag.error),
  command  = mode(p.bronze["300"]),
  terminal = mode(syn.type),
  inactive = {
    a = { bg = ui.bg_m1, fg = ui.fg_dim },
    b = { bg = ui.bg_m1, fg = ui.fg_dim },
    c = { bg = ui.bg_m1, fg = ui.nontext },
  },
}
