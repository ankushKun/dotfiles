--------------------------------------------------------------------
--                            KEYBINDS                            --
--------------------------------------------------------------------

-- Set <Leader> to space
vim.g.mapleader = " "

-- Functional wrapper for mapping custom keybindings
function map(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- no yank with dd
map("n", "dd", '"_dd')

map("n", "<Leader>ff", ":Telescope find_files<CR>")                                  -- Find files

-- Increment/decrement number
-- map("n", "+", "<C-a>")
-- map("n", "-", "<C-x>")

-- Splits
map("n", "<Leader>sh", ":sp<CR>")
map("n", "<Leader>sv", ":vsp<CR>")

-- Quit current buffer
map("n", "<Leader>q", ":q<CR>")

-- Write current buffer
map("n", "<Leader>w", ":w<CR>")

-- Close buffer
map("n", "<Leader>c", ":bd<CR>")

-- Toggle file explorer
map("n", "<Leader>e", ":NvimTreeToggle<CR>")
map("n", "<Leader>o", ":NvimTreeFocus<CR>")


map("n", "<Leader>ps", ":PackerSync<CR>")                                            -- Packer Sync

map("n", "<Leader>tf", ":ToggleTerm direction='float'<CR>")                          -- Open floating terminal

map("n", "<Leader>th", ":ToggleTerm<CR>")                                            -- Open horizontal terminal

map("t", "<Esc>", [[<C-\><C-n>:ToggleTerm<CR>]])                                     -- Close terminal

map("n", "<Leader>h", ":noh<CR>")                                                    -- No highlight

map("n", "<Leader>lf", ":lua vim.lsp.buf.format{async=true}<CR>", { silent = true }) -- format code

map("n", "<Leader>dd", ":Telescope diagnostics<CR>")                                 -- All diagnostics

map("n", "<Leader>dl", ":Lspsaga show_line_diagnostics<CR>")                         -- shoe currnet line diagnostics

map("n", "gD", ":Lspsaga goto_definition<CR>")                                       -- goto definition

map("n", "<Leader>lh", ":Lspsaga peek_definition<CR>")                               -- hover/peek definition

-- map("n", "<C-p>", ":MarkdownPreviewToggle<CR>") -- Markdown preview

map("n", "}", ":BufferLineCycleNext<CR>")               -- Buffer previous

map("n", "{", ":BufferLineCyclePrev<CR>")               -- buffer next

map("n", "fo", ":foldopen<CR>")                         -- foldopen

map("n", "fc", ":foldclose<CR>")                        -- foldclose

map("n", "<Leader>r", ":RunCode<CR>")                   -- run code

vim.keymap.set('n', 'fO', require('ufo').openAllFolds)  -- open all folds
vim.keymap.set('n', 'fC', require('ufo').closeAllFolds) -- close all folds

-- Indentation
map("v", "<", "<gv")
map("n", "<", "v<")
map("v", ">", ">gv")
map("n", ">", "v>")

-- Move lines
map("n", "K", ":<C-u>m-2<CR>==")
map("n", "J", ":<C-u>m+<CR>==")
map("v", "K", ":m-2<CR>gv=gv")
map("v", "J", ":m'>+<CR>gv=gv")

-- custom command to open config
vim.cmd(":command! Config e ~/.config/nvim/init.lua")
