--------------------------------------------------------------------
--                        TREESITTER                              --
--------------------------------------------------------------------

require('nvim-treesitter.configs').setup({
    highlight = {
        enable = true
    },
    indent = {
        enable = true
    },
    context_commentstring = {
        enable = true,
        config = {
            javascript = {
                __default = '// %s',
                jsx_element = '{/* %s */}',
                jsx_fragment = '{/* %s */}',
                jsx_attribute = '// %s',
                comment = '// %s'
            },
            csharp = {
                __default = '// %s',
                comment = '// %s'
            },
        }
    }
})
require('nvim-ts-autotag').setup()

