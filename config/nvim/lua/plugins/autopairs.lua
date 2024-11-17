return {
    "windwp/nvim-autopairs",
    config = function()
        require('nvim-autopairs').setup {
            enable_check_bracket_line = true
        }
    end
}
