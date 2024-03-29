return {
    "kevinhwang91/nvim-ufo",
    dependencies = {
     'kevinhwang91/promise-async'
    },
    config = function()
--        local capabilities = vim.lsp.protocol.make_client_capabilities()
--capabilities.textDocument.foldingRange = {
--    dynamicRegistration = false,
--    lineFoldingOnly = true
--}
--local language_servers = require("lspconfig").util.available_servers()
--for _, ls in ipairs(language_servers) do
--    require('lspconfig')[ls].setup({
--        capabilities = capabilities
--    })
--end
 --       use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}
require('ufo').setup({
    provider_selector = function(bufnr, filetype, buftype)
        return {'treesitter', 'indent'}
    end
})
require('ufo').setup()
    end
}
