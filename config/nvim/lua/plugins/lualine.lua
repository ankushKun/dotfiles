return {
    "nvim-lualine/lualine.nvim",
    config = function()
        local conf = {
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
                    'lsp_progress',
                },
                lualine_y = { 'filetype' },
                lualine_z = { 'location' }
            },
        }

        local function ins_right(component)
            table.insert(conf.sections.lualine_x, component)
        end

        ins_right {
            'lsp_progress',
            separators = {
                component = ' ',
                progress = ' | ',
                --message = { pre = '(', post = ')'},
                percentage = { pre = '', post = '%% ' },
                title = { pre = '', post = ': ' },
                lsp_client_name = { pre = '[', post = ']' },
                spinner = { pre = '', post = '' },
                message = { commenced = 'In Progress', completed = 'Completed' },
            },
            display_components = { 'lsp_client_name', 'spinner', { 'title', 'percentage', 'message' } },
            timer = { progress_enddelay = 500, spinner = 1000, lsp_client_name_enddelay = 1000 },
            spinner_symbols = { '🌑 ', '🌒 ', '🌓 ', '🌔 ', '🌕 ', '🌖 ', '🌗 ', '🌘 ' },
        }

        require('lualine').setup(conf)
    end,
}
