--------------------------------------------------------------------
--                           LSP                                  --
--------------------------------------------------------------------


local ensure_installed = {
    'lua_language_server',
    'typescript_language_server',
    'tailwind_css_language_server',
    'html_lsp',
    'css_lsp',
    'python_lsp_server',
    'jdtls',
    'rust_analyzer',
}

local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
    -- see :help lsp-zero-keybindings
    -- to learn the available actions
    lsp_zero.default_keymaps({ buffer = bufnr })
end)

require("mason").setup({
    ensure_installed = ensure_installed,
    automatic_installation = true
})

require("mason-lspconfig").setup({
    ensure_installed = ensure_installed,
    handlers = {
        lsp_zero.default_setup,
    },
})

require('lspconfig').lua_ls.setup({
    settings = {
        Lua = {
            diagnostics = {
                globals = { 'vim', 'use' },
            },
        },
    },
})

-- LSP Saga
require('lspsaga').setup({})
