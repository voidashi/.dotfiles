return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        -- O tema é declarado, não auto-detectado. Sem isto o lualine procura
        -- um tema com o nome do colorscheme ativo e cai no default quando não
        -- encontra, o que funciona por acaso e quebra em silêncio. Ele vive em
        -- lua/lualine/themes/voidashi.lua e deriva dos mesmos papéis que o
        -- colorscheme, então acompanha a paleta sozinho.
        require("lualine").setup({
            options = { theme = "voidashi" },
        })
    end,
}