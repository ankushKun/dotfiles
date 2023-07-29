--------------------------------------------------------------------
--                         TELESCOPE                              --
--------------------------------------------------------------------

require('telescope').setup {
    defaults = {
        show_hidden = true,
        previewer = true,
        preview_cutoff = 1,
        shorten_path = true,
        layout_strategy = 'flex',
    }
}
