return {
    "nvim-telescope/telescope.nvim",
    -- 0.1.6 usava vim.tbl_islist/vim.tbl_flatten, que serão removidos no
    -- nvim 0.13 e já avisavam a cada picker aberto.
    -- Atenção: as tags novas usam prefixo "v" (a antiga 0.1.6 não usava).
    tag = "v0.2.2",
    dependencies = { "nvim-lua/plenary.nvim", "sharkdp/fd", "nvim-tree/nvim-web-devicons", "BurntSushi/ripgrep" },
    config = function()
        require("telescope").setup()

        -- set keymaps
        local keymap = vim.keymap

        keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
        keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Grep string in cwd" })
        keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find open buffer" })
        keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Find recent file" })
        keymap.set("n", "<leader>fs", "<cmd>Telescope git_status<cr>", { desc = "Find changed file (git status)" })
        -- "git commits" (com espaço) faz o telescope procurar uma extensão
        -- chamada "git", que não existe. O picker se chama git_commits.
        keymap.set("n", "<leader>fc", "<cmd>Telescope git_commits<cr>", { desc = "Find git commit" })
    end,
}
