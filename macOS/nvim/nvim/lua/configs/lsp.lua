--------------------------------------------------------------------
--                           LSP                                  --
--------------------------------------------------------------------

require("mason").setup({
    ensure_installed = {
        'lua_language_server',
        'typescript_language_server',
        'html_lsp',
        'css_lsp',
        'python_lsp_server',
        'jdtls'
    },
    automatic_installation = true
})

require("mason-lspconfig").setup()
require("mason-lspconfig").setup_handlers {
    -- The first entry (without a key) will be the default handler
    -- and will be called for each installed server that doesn't have
    -- a dedicated handler.
    function(server_name) -- default handler (optional)
        require("lspconfig")[server_name].setup {}
    end,
    ["rust_analyzer"] = function()
        require("rust-tools").setup {}
    end
}

require("mason-null-ls").setup({
    automatic_setup = true,
})

require("null-ls").setup()
