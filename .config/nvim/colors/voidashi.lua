-- Ponto de entrada do :colorscheme voidashi.
--
-- O Neovim descobre colorschemes por colors/<nome>.lua no runtimepath, então
-- este arquivo existe só para tornar o tema carregável pelo nome, como
-- qualquer outro. A implementação está em lua/voidashi/theme/.
--
-- A transparência é decisão registrada: o editor acompanha o fundo do
-- terminal, que roda a 0.92 com blur do compositor atrás. Popups e flutuantes
-- continuam opacos, porque texto sobre texto não se lê.
require("voidashi.theme").load({ transparent = true })
