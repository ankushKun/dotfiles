return {
    {'ghifarit53/tokyonight-vim',
    lazy=false,
    name='tokyonight',
    config = function()
        vim.g.tokyonight_enable_italic = true
        vim.g.tokyonight_transparent_background = true
        if (vim.fn.exists('neovide') == 1) then
            vim.g.tokyonight_transparent_background = false
        end
        vim.cmd [[colorscheme tokyonight]]
    end
}

}
