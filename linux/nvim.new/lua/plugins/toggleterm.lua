return {{
    'akinsho/toggleterm.nvim',
    config = function()
        require("toggleterm").setup {
        float_opts = {
            border = "curved"
        }
        }
         vim.keymap.set("n", "<Leader>tf", ":ToggleTerm direction='float'<CR>", {})
         vim.keymap.set("n", "<Leader>th", ":ToggleTerm<CR>", {})
         vim.keymap.set("t", "<Esc>", [[<C-\><C-n>:ToggleTerm<CR>]], {})


    end
}}
