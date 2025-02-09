-- ~/nvim/lua/voidashi/plugins/colorscheme.lua

-- return {
--     "tiagovla/tokyodark.nvim",
--     lazy = false,
--     priority = 1000,
--     config = function()
--         vim.cmd("colorscheme tokyodark")
--     end,
-- }

return {
    {
        "rebelot/kanagawa.nvim",
        lazy = false,
        priority = 1000,
        transparent = true,
        config = function()
            require('kanagawa').setup({
            compile = false,             -- enable compiling the colorscheme
            undercurl = true,            -- enable undercurls
            commentStyle = { italic = true },
            functionStyle = {},
            keywordStyle = { italic = true},
            statementStyle = { bold = true },
            typeStyle = {},
            transparent = true,         -- do not set background color Default = false
            dimInactive = false,         -- dim inactive window `:h hl-NormalNC`
            terminalColors = true,       -- define vim.g.terminal_color_{0,17}
            colors = {                   -- add/modify theme and palette colors
                palette = {},
                theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
            },
            overrides = function(colors) -- add/modify highlights
                return {}
            end,
            theme = "wave",              -- Load "wave" theme when 'background' option is not set
            background = {               -- map the value of 'background' option to a theme
                dark = "wave",           -- try "dragon" !
                light = "lotus"
            },
        })


            vim.cmd("colorscheme kanagawa-dragon")
        end,
    },

    --{
    --   'kepano/flexoki-neovim',
    --    name = 'flexoki',
    --    lazy = false,
    --    priority = 1000,
    --    config = function()
    --        vim.cmd("colorscheme flexoki-dark")
    --    end,
    --}
}
