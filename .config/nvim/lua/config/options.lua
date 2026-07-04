vim.opt.number = true -- Show line numbers
vim.opt.relativenumber = false -- Keep left gutter to absolute line numbers only
vim.opt.mouse = "a" -- Enable mouse support
vim.opt.ignorecase = true -- Case insensitive search
vim.opt.smartcase = true -- Unless uppercase is used
vim.opt.hlsearch = true -- Highlight search results
vim.opt.incsearch = true -- Incremental search
vim.opt.wrap = true -- Wrap lines
vim.opt.breakindent = true -- Preserve indentation in wrapped text
vim.opt.tabstop = 2 -- Tab width
vim.opt.shiftwidth = 2 -- Indent width
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.smartindent = true -- Smart auto-indenting
vim.opt.smarttab = true -- Smart tab behavior
vim.opt.clipboard = "unnamedplus" -- Use system clipboard
vim.opt.scrolloff = 8 -- Keep 8 lines above/below cursor
vim.opt.sidescrolloff = 8 -- Keep 8 columns left/right of cursor
vim.opt.signcolumn = "yes" -- Always show sign column
vim.opt.cursorline = false -- Highlight current line
vim.opt.termguicolors = true -- Enable 24-bit colors
vim.opt.updatetime = 250 -- Faster completion
vim.opt.timeoutlen = 300 -- Faster which-key popup
vim.opt.undofile = true -- Enable persistent undo
vim.opt.undolevels = 10000 -- Keep deeper undo history
vim.opt.autoread = true -- Reload files changed outside Neovim when safe
vim.opt.confirm = true -- Prompt to save changed buffers instead of failing commands
vim.opt.backup = false -- Disable backup files
vim.opt.writebackup = false -- Disable backup before writing
vim.opt.swapfile = false -- Disable swap files
vim.opt.splitright = true -- Vertical splits go right
vim.opt.splitbelow = true -- Horizontal splits go below
vim.opt.splitkeep = "screen" -- Keep screen position stable when splits change
vim.opt.showmode = false -- Don't show mode (we have statusline)
vim.opt.conceallevel = 0 -- Don't hide characters (like in markdown)
vim.opt.pumheight = 10 -- Popup menu height
vim.opt.completeopt = "menu,menuone,noselect" -- Better completion experience
vim.opt.list = false -- Toggle visible whitespace with <leader>tw
vim.opt.listchars = { tab = "> ", trail = ".", nbsp = "_", extends = ">", precedes = "<" }
pcall(function()
	vim.opt.winborder = "rounded"
end)

-- Set leader key to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "
