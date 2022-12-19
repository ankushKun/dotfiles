--------------------------------------------------------------------
--                         LUALINE                                --
--------------------------------------------------------------------

require('lualine').setup({
    options = {
        globalstatus = true,
        section_seperators = '',
        component_seperators = '',
        icons_enabled = true,
    },
    sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'filename' },
        lualine_c = {},
        lualine_x = {
            'fileformat',
            {
                'diagnostics', sources = { 'nvim_diagnostic' }, sections = { 'error', 'warn', 'info', 'hint' }
            }
        },
        lualine_y = { 'filetype', 'lsp' },
        lualine_z = { 'location' }
    },
})

