--------------------------------------------------------------------
--                           LSP                                  --
--------------------------------------------------------------------

require("mason").setup({
    ensure_installed = { 'lua-language-server', 'typescript-language-server', 'html-lsp', 'css-lsp', 'python-lsp-server', 'jdtls' },
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
    -- Next, you can provide a dedicated handler for specific servers.
    -- For example, a handler override for the `rust_analyzer`:
    -- ["lua-language-server"] = function()
    --     require('lspconfig').sumneko_lua.setup({
    --         settings = {
    --             Lua = {
    --                 diagnostics = {
    --                     globals = { "vim", "use" },
    --                     disable = { "lowercase-global" }
    --                 }
    --             }
    --         }
    --     })
    -- end
}

require("mason-null-ls").setup({
    automatic_setup = true,
})

-- require("mason-null-ls").setup_handlers {
--    function(source_name, methods)
--        require("mason-null-ls.automatic_setup")(source_name, methods)
--    end
--}
require("null-ls").setup()

require("lspsaga").setup({
    ui={
        code_action=''
    }
})
