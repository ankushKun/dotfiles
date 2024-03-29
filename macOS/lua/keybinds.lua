-- Set <Leader> to space
vim.g.mapleader = " "

-- Functional wrapper for mapping custom keybindings
local function map(mode, lhs, rhs, opts)
    local options = { noremap = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

map("n", "<Leader>q", ":q<CR>")                                     -- Quit current buffer
map("n", "<Leader>w", ":w<CR>")                                     -- Write current buffer
map("n", "<Leader>c", ":bd<CR>")                                     -- Close buffer
map("n", "<Leader>h", ":noh<CR>")                                   -- No highlight
map("n", "}", ":BufferLineCycleNext<CR>")                           -- Buffer previous
map("n", "{", ":BufferLineCyclePrev<CR>")                           -- Buffer next
map("n", "fo", ":foldopen<CR>")                                     -- Foldopen
map("n", "fc", ":foldclose<CR>")                                    -- Foldclose
map("n", "<Leader>r", ":RunCode<CR>")                               -- Run code
map("n", "<Leader>bf", ":Telescope buffers<CR>")                    -- Show open buffers
map("n", "<Leader>lf", ":lua vim.lsp.buf.format({async=true})<CR>") -- Format Code
map("n", "<Leader>ff", ":Telescope find_files<CR>")                 -- Find Files in cwd
map("n", "<Leader>rf", ":Telescope oldfiles<CR>")                   -- Recent Files

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
vim.cmd(":command! Config e ~/.config/nvim/")
