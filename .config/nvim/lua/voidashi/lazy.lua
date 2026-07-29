-- ~/nvim/lua/voidashi/lazy.lua

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- install.colorscheme diz ao lazy qual tema usar na janela dele durante a
-- instalação de plugins, que acontece antes de qualquer config rodar.
require("lazy").setup("voidashi.plugins", {
  install = { colorscheme = { "voidashi" } },
})

-- O tema é nosso e não é plugin, então é carregado aqui em vez de por uma
-- spec: vive em lua/voidashi/theme/ e não depende de nada de terceiro. Vem
-- depois do lazy para que os grupos que os plugins registram já existam
-- quando os highlights forem aplicados.
vim.cmd("colorscheme voidashi")

