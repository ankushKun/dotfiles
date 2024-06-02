-- Vim options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.textwidth = 9999
vim.opt.wrap = false
vim.opt.linebreak = false
vim.opt.termguicolors = true
vim.opt.showmode = false
vim.opt.scrolloff = 999
vim.opt.sidescrolloff = 25
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.smarttab = true
vim.opt.clipboard = "unnamedplus"
vim.opt.guifont = "JetBrainsMono Nerd Font:h14"
vim.opt.fillchars = [[eob: ,fold: ,foldopen:v,foldsep: ,foldclose:>]]
vim.opt.background = "dark"
vim.opt.cursorline = false
vim.opt.foldcolumn = "1"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true
vim.g.mapleader = " "

-- Neovide options
if (vim.fn.exists('neovide') == 1) then
    vim.g.neovide_transparency = 0.90
    vim.g.neovide_input_use_logo = 1
    vim.g.neovide_remember_window_size = 1
end
