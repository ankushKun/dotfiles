--------------------------------------------------------------------
--                        TREESITTER                              --
--------------------------------------------------------------------

local ensure_installed = {
    'lua',
    'json',
    'tsx',
    'typescript',
    'javascript',
    'html',
    'css',
    'bash',
    'python',
    'rust',
    'markdown',
    'markdown_inline'
}

require('nvim-treesitter.configs').setup({
    ensure_installed = ensure_installed,
    highlight = {
        enable = true
    },
    autotag = {
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
