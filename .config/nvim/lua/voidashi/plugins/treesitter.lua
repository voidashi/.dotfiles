--- ~/nvim/lua/voidashi/plugins/treesitter.lua

-- Parsers a instalar (nomes de linguagem do tree-sitter).
local languages = {
    "bash",
    "c",
    "css",
    "dockerfile",
    "gitignore",
    "html",
    "javascript",
    "json",
    "lua",
    "markdown",
    "markdown_inline",
    "rust",
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
    "yaml",
}

-- Filetypes onde ligar highlight/indent. Não é a mesma lista acima:
-- filetype != nome do parser (ex.: parser "tsx" -> filetype
-- "typescriptreact"; "markdown_inline" não é um filetype).
local filetypes = {
    "bash",
    "c",
    "css",
    "dockerfile",
    "gitignore",
    "help",
    "html",
    "javascript",
    "javascriptreact",
    "json",
    "lua",
    "markdown",
    "rust",
    "sh",
    "typescript",
    "typescriptreact",
    "vim",
    "yaml",
}

return {
    "nvim-treesitter/nvim-treesitter",
    -- A branch main é a reescrita do plugin. A API antiga
    -- (require("nvim-treesitter.configs").setup{}) não existe mais nela.
    branch = "main",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "windwp/nvim-ts-autotag",
    },
    config = function()
        require("nvim-treesitter").setup()

        -- install() é assíncrono e só baixa o que ainda falta.
        require("nvim-treesitter").install(languages)

        -- Na branch main o plugin não liga mais o highlight sozinho:
        -- quem faz isso é o próprio Neovim, via vim.treesitter.start().
        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("VoidashiTreesitter", { clear = true }),
            pattern = filetypes,
            callback = function()
                pcall(vim.treesitter.start)
                -- Indentação por treesitter (upstream marca como experimental).
                vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end,
        })

        -- nvim-ts-autotag agora tem setup próprio; deixou de ser
        -- uma sub-tabela do setup do treesitter.
        require("nvim-ts-autotag").setup()
    end,
}
