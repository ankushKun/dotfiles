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

map("n", "<Leader>q", ":q<CR>")                                   -- quit current budder

map("n", "<Leader>w", ":w<CR>")                                   -- Write current buffevr

map("n", "<Leader>c", ":bd<CR>")                                  -- Close buffer

map("n", "<Leader>h", ":noh<CR>")                                 -- No highlight

map("n", "}", ":BufferLineCycleNext<CR>")               -- Buffer previous

map("n", "{", ":BufferLineCyclePrev<CR>")               -- buffer next

map("n", "fo", ":foldopen<CR>")                         -- foldopen

map("n", "fc", ":foldclose<CR>")                        -- foldclose

map("n", "<Leader>r", ":RunCode<CR>")                   -- run code

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
