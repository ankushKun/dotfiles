--------------------------------------------------------------------
--                            KEYBINDS                            --
--------------------------------------------------------------------

-- Set <Leader> to space
vim.g.mapleader = " "

-- Functional wrapper for mapping custom keybindings
function map(mode, lhs, rhs, opts)
    local options = { noremap = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- quite current budder
map("n", "<Leader>q", ":q<CR>")

-- Write current buffevr
map("n", "<Leader>w", ":w<CR>")

-- Close buffer
map("n", "<Leader>c", ":bd<CR>")

-- Toggle file explorer
map("n", "<Leader>e", ":NvimTreeToggle<CR>")
map("n", "<Leader>o", ":NvimTreeFocus<CR>")

-- Packer Sync
map("n", "<Leader>ps", ":PackerSync<CR>")

map("n", "<Leader>tf", ":ToggleTerm direction='float'<CR>") -- Open floating terminal

map("n", "<Leader>th", ":ToggleTerm<CR>") -- Open horizontal terminal

map("t", "<Esc>", [[<C-\><C-n>:ToggleTerm<CR>]]) -- Close terminal

map("n", "<Leader>h", ":noh<CR>") -- No highlight

map("n", "<Leader>lf", ":lua vim.lsp.buf.format{async=true}<CR>") -- format code

map("n", "gd", ":Telescope diagnostics<CR>") -- line diagnostics

map("n", "ge", ":lua vim.diagnostic.open_float()<CR>") -- shoe currnet line diagnostics

map("n", "gD", ":lua vim.lsp.buf.definition()<CR>") -- goto definition

map("n", "K", ":lua vim.lsp.buf.hover()<CR>") -- hover

-- map("n", "<C-p>", ":MarkdownPreviewToggle<CR>") -- Markdown preview

map("n", "L", ":BufferLineCycleNext<CR>") -- Buffer previous

map("n", "H", ":BufferLineCyclePrev<CR>") -- buffer next

map("n", "fo", ":foldopen<CR>") -- foldopen

map("n", "fc", ":foldclose<CR>") -- foldclose

map("n", "<Leader>r", ":RunCode<CR>") -- run code

vim.keymap.set('n', 'fO', require('ufo').openAllFolds) -- open all folds
vim.keymap.set('n', 'fC', require('ufo').closeAllFolds) -- close all folds

-- custom command to open config
vim.cmd(":command! Config e ~/.config/nvim/init.lua")
