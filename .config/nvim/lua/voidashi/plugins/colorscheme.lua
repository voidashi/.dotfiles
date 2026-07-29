-- ~/.config/nvim/lua/voidashi/plugins/colorscheme.lua
--
-- O tema é próprio e vive em lua/voidashi/theme/, sem plugin por trás. A
-- estrutura de três camadas foi copiada do kanagawa, mas nada depende dele em
-- runtime: um update do plugin não tem como quebrar nossas cores.
--
-- Isto substituiu um setup do kanagawa que carregava "kanagawa-dragon" logo
-- depois de declarar theme = "wave" dentro do próprio setup. O comando
-- explícito vencia, então aquela chave nunca fez efeito nenhum.

return {
  -- Rollback num comando: trocar enabled para true e chamar
  -- vim.cmd("colorscheme kanagawa-dragon") de volta. Fica declarado para o
  -- caso de aparecer algum grupo que o nosso tema não cubra e que valha mais
  -- reverter do que consertar na hora.
  {
    "rebelot/kanagawa.nvim",
    enabled = false,
    lazy = true,
    priority = 1000,
  },
}
