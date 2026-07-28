
return {
    -- norcalli/nvim-colorizer.lua está sem manutenção desde 2021 e usa
    -- vim.tbl_flatten, que será removido no nvim 0.13. Este fork é o
    -- mantido atualmente.
    "catgoose/nvim-colorizer.lua",
    event = "BufReadPre",
    opts = {
        filetypes = { "*" },
    },
}