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
        lualine_b = { { 'filename', file_status = true, path = 1 } },
        lualine_c = { 'branch' },
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
