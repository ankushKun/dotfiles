--------------------------------------------------------------------
--                           LSP                                  --
--------------------------------------------------------------------

require('nvim-lsp-installer').setup {
    automatic_installation = false
}

local lspconfig = require("lspconfig")
local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
-- capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

lspconfig.sumneko_lua.setup {
    capabilities = capabilities,
    settings = {
        Lua = {
            diagnostics = {
                globals = { "vim", "use" },
                disable = { "lowercase-global" }
            }
        }
    }
}

-- lspconfig.omnisharp.setup {
--    cmd = { "mono", "/Users/ankush/.local/share/nvim/lsp_servers/omnisharp/omnisharp-mono/OmniSharp.exe",
--        "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
--    root_dir = lspconfig.util.root_pattern("*.sln");
--    capabilities = capabilities,
--    use_mono = true
--}
lspconfig.pyright.setup { capabilities = capabilities }
lspconfig.clangd.setup { capabilities = capabilities }
-- lspconfig.jdtls.setup { capabilities = capabilities } -- minimum java17
lspconfig.tsserver.setup { capabilities = capabilities }
lspconfig.tailwindcss.setup { capabilities = capabilities }
-- lspconfig.yamlls.setup { capabilities = capabilities }
lspconfig.html.setup { capabilities = capabilities }
lspconfig.cssls.setup { capabilities = capabilities }
-- lspconfig.svelte.setup { capabilities = capabilities }

local nls = require('null-ls')
nls.setup {
    sources = {
        nls.builtins.formatting.black,
        -- nls.builtins.formatting.prettierd
    }
}
