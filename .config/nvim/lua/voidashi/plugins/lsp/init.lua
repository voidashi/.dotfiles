-- ~/nvim/lua/voidashi/plugins/lsp/init.lua
--
-- IMPORTANTE: este arquivo PRECISA se chamar init.lua.
-- O lazy.nvim (lazy/core/util.lua -> lsmod) só importa arquivos .lua no topo
-- de plugins/ e subdiretórios que contenham um init.lua. Sem ele, todo este
-- diretório era ignorado silenciosamente e nenhum plugin de LSP era instalado.

-- Lista única de servidores: usada pelo mason (para instalar os binários)
-- e pelo vim.lsp.enable (para ativar as configs).
local servers = {
    "cssls",
    "eslint",
    "html",
    "jsonls",
    "lua_ls",
    "pyright",
    "tailwindcss",
    "ts_ls", -- renomeado; antes se chamava "tsserver"
}

return {
    {
        -- O projeto mason migrou de williamboman/* para mason-org/*
        "mason-org/mason.nvim",
        dependencies = {
            "mason-org/mason-lspconfig.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",
        },
        config = function()
            require("mason").setup()

            require("mason-lspconfig").setup({
                ensure_installed = servers,
                -- Os servidores são ativados manualmente no vim.lsp.enable()
                -- abaixo, para manter a configuração em um lugar só.
                automatic_enable = false,
            })

            require("mason-tool-installer").setup({
                ensure_installed = {
                    "prettier",
                    "stylua", -- lua formatter
                    "isort", -- python formatter
                    "black", -- python formatter
                    "pylint",
                    "eslint_d",
                },
            })
        end,
    },

    {
        -- Continua necessário: fornece as definições de servidor (lsp/*.lua)
        -- que o vim.lsp.config/enable consome.
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            -- neodev.nvim foi arquivado; lazydev.nvim é o sucessor.
            { "folke/lazydev.nvim", ft = "lua", opts = {} },
        },
        config = function()
            -- API nativa do nvim 0.11+. Substitui o mason-lspconfig
            -- setup_handlers(), que foi removido na v2.
            vim.lsp.config("*", {
                capabilities = require("cmp_nvim_lsp").default_capabilities(),
            })

            vim.lsp.enable(servers)

            -- Formatação ao salvar fica a cargo do conform.nvim
            -- (ver plugins/formatter.lua), para não formatar duas vezes.
        end,
    },
}
