-- =====================================================================
--  VOIDASHI -- camada semântica
-- =====================================================================
-- Traduz a paleta crua em papéis. Os grupos de highlight leem daqui e nunca
-- de palette.lua: é essa separação que permite recolorir o tema inteiro sem
-- reescrever trezentas definições, e foi o que valeu copiar da estrutura do
-- kanagawa.
--
-- Escrito à mão, não gerado, pela mesma razão que swaylock, starship e yazi
-- são: aqui cor se mistura com decisão de design. As decisões seguem
-- docs/design/RICE-GUIDE.md, seção "Editors and syntax themes".

local p = require("voidashi.theme.palette")

local M = {}

-- ===== Superfícies ===================================================
-- O guia pede void-00 de fundo. Com transparent = true o Normal não é
-- pintado e o editor mostra o terminal, mas estes valores continuam valendo
-- para popups, menus e janelas flutuantes, que não são transparentes.
M.ui = {
  fg         = p.ink["1"],
  fg_dim     = p.ink["3"],
  fg_reverse = p.void["00"],

  bg         = p.void["00"],
  bg_dim     = p.void["10"],
  bg_gutter  = p.void["10"],

  -- Escala de profundidade. bg_m* recua, bg_p* avança.
  bg_m3      = p.void["00"],
  bg_m2      = p.void["00"],
  bg_m1      = p.void["10"],
  bg_p1      = p.void["20"],
  bg_p2      = p.void["30"],

  border     = p.edge["20"],
  special    = p.verdigris["400"],
  nontext    = p.ink["5"],
  whitespace = p.ink["5"],

  -- Seleção é Ice, como o foco em todo o desktop. Busca é bronze: são
  -- estados diferentes e não devem se confundir na tela.
  bg_visual  = p.ice["800"],
  bg_search  = p.bronze["800"],
  bg_cursorline = p.void["10"],

  pmenu = {
    fg      = p.ink["1"],
    fg_sel  = p.ink["0"],
    bg      = p.void["20"],
    bg_sel  = p.ice["800"],
    bg_sbar = p.void["10"],
    bg_thumb = p.edge["30"],
  },
}

-- ===== Sintaxe =======================================================
-- As cinco famílias de identidade mais Verdigris. Bordeaux é a marca da
-- identidade, então fica na keyword, que é o token mais estrutural; Ice é
-- foco em todo o desktop, então fica na função; Verdigris entrou na paleta
-- exatamente para o slot que faltava, e cobre tipos.
M.syn = {
  keyword    = p.bordeaux["300"],
  statement  = p.bordeaux["300"],
  fun        = p.ice["300"],
  string     = p.moss["300"],
  number     = p.bronze["300"],
  constant   = p.bronze["200"],
  operator   = p.bronze["300"],
  type       = p.verdigris["300"],
  parameter  = p.ash["200"],
  preproc    = p.ash["300"],
  identifier = p.ink["1"],
  variable   = p.ink["1"],
  punct      = p.ink["3"],
  regex      = p.bronze["200"],
  comment    = p.ink["4"],   -- o guia especifica este valor nominalmente
  deprecated = p.ink["5"],
  special1   = p.verdigris["400"],
  special2   = p.bordeaux["200"],
  special3   = p.ash["300"],
}

-- ===== Estados =======================================================
-- Alert tones, os mesmos que a barra e as notificações usam.
M.diag = {
  ok      = p.alert.good.fg,
  error   = p.alert.critical.fg,
  warning = p.alert.caution.fg,
  info    = p.alert.neutral.fg,
  hint    = p.verdigris["400"],
}

M.vcs = {
  added   = p.alert.good.fg,
  removed = p.alert.critical.fg,
  changed = p.alert.caution.fg,
}

-- Estes são fundos, então saem do bg dos alert tones e não do fg.
M.diff = {
  add    = p.alert.good.bg,
  delete = p.alert.critical.bg,
  change = p.alert.caution.bg,
  text   = p.alert.caution.border,
}

M.palette = p

return M
