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
        lualine_a = { 'mode'},
        lualine_b = { 'branch' },
        lualine_c = { 'filename' },
        lualine_x = { 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' }
    },
})
