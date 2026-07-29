-- =====================================================================
--  VOIDASHI -- colorscheme
-- =====================================================================
-- Tema próprio, sem depender de plugin de terceiro em runtime. A estrutura
-- de três camadas veio do kanagawa, que é boa: palette crua, camada
-- semântica de papéis, e grupos que leem só dos papéis.
--
--   palette.lua  GERADO de scripts/theme/palette.json
--   roles.lua    papéis, escrito à mão, é onde moram as decisões
--   groups.lua   os grupos, lendo apenas de roles
--
-- Ver docs/design/RICE-GUIDE.md, "Editors and syntax themes".

local M = {}

---@param opts? { transparent?: boolean }
function M.load(opts)
  opts = opts or {}
  if opts.transparent == nil then
    opts.transparent = true
  end

  -- Um colorscheme precisa limpar o anterior antes de aplicar o seu, senão
  -- grupos que o outro definia e este não sobrevivem por baixo.
  if vim.g.colors_name then
    vim.cmd("highlight clear")
  end
  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end

  vim.o.termguicolors = true
  vim.g.colors_name = "voidashi"
  vim.o.background = "dark"

  for group, spec in pairs(require("voidashi.theme.groups").get(opts)) do
    vim.api.nvim_set_hl(0, group, spec)
  end

  -- ANSI do :terminal, verbatim do palette.json. "ANSI is identical across
  -- every terminal and TUI" é não-negociável, e um :terminal com outra tabela
  -- quebraria isso dentro do próprio editor.
  local ansi = require("voidashi.theme.palette").ansi
  for i = 0, 15 do
    vim.g["terminal_color_" .. i] = ansi[i]
  end
end

return M
