return {
    "akinsho/bufferline.nvim",
    config = function()
        require('bufferline').setup {
    options = {
        indicator = {
            icon = ""
        },
        offsets = { { filetype = "NvimTree", text = "File Explorer", text_align = "center" } },
        diagnostics = "nvim_lsp",
        diagnostics_update_in_insert = false,
        diagnostics_indicator = function(count)
            return "(" .. count .. ")"
        end,
        show_buffer_close_icons = false,
        show_close_icon = false,
        sort_by = "insert_at_end"
    }
}
    end
}
