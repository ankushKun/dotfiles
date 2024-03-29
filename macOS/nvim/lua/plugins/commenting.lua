return {
    {
        'JoosepAlviste/nvim-ts-context-commentstring',
        config = function()
            vim.g.skip_ts_context_commentstring_module = true
            require('ts_context_commentstring').setup {}
        end
    },
    {
        'tpope/vim-commentary'
    }
}
