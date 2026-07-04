local close_buffer = require("config.buffers").close_buffer

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Resize windows
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- Buffer navigation (LunarVim style: ]b / [b)
vim.keymap.set("n", "}", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "{", ":bprevious<CR>", { desc = "Previous buffer" })

-- Buffer operations (LunarVim style: <leader>b group>)
vim.keymap.set("n", "<leader>c", function()
	close_buffer(0, false)
end, { desc = "Close buffer" })
vim.keymap.set("n", "<leader>bd", function()
	close_buffer(0, false)
end, { desc = "Delete buffer" })
vim.keymap.set("n", "<leader>ba", ":%bd|e#<CR>", { desc = "Delete all buffers except current" })
vim.keymap.set("n", "<leader>bD", ":%bd!|e#|bd#<CR>", { desc = "Force delete all buffers except current" })

-- Move lines up and down
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Clear search highlighting
vim.keymap.set("n", "<Esc><Esc>", ":nohlsearch<CR>", { desc = "Clear search highlight", silent = true })
vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>", { desc = "Clear search highlight" })

-- Quick save / quit (LunarVim style)
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>Q", ":qa!<CR>", { desc = "Quit all without saving" })

-- Dashboard (LunarVim style)
vim.keymap.set("n", "<leader>;", ":Alpha<CR>", { desc = "Dashboard" })

-- Split windows (using | and - for intuitive vertical/horizontal split)
vim.keymap.set("n", "<leader>|", ":vsplit<CR>", { desc = "Split vertically" })
vim.keymap.set("n", "<leader>-", ":split<CR>", { desc = "Split horizontally" })

-- Better paste (don't yank replaced text)
vim.keymap.set("v", "p", '"_dP', { desc = "Paste without yanking" })

-- Select all (Note: This overrides increment number, use g<C-a> for that)
vim.keymap.set("n", "<C-a>", "gg<S-v>G", { desc = "Select all" })

-- Stay in visual mode when indenting
vim.keymap.set("v", "<", "<gv", { desc = "Indent left (stay in visual)" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right (stay in visual)" })

-- Better page up/down (keep cursor centered)
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Page up (centered)" })

-- Fold controls
vim.keymap.set("n", "fo", "zo", { desc = "Open fold under cursor" })
vim.keymap.set("n", "fc", "zc", { desc = "Close fold under cursor" })

-- Keep search results centered
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- Join lines but keep cursor position
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines (keep cursor)" })

-- Better undo break points in insert mode
vim.keymap.set("i", ",", ",<C-g>u", { desc = "Comma with undo break" })
vim.keymap.set("i", ".", ".<C-g>u", { desc = "Period with undo break" })
vim.keymap.set("i", "!", "!<C-g>u", { desc = "Exclamation with undo break" })
vim.keymap.set("i", "?", "?<C-g>u", { desc = "Question mark with undo break" })

vim.keymap.set(
	"n",
	"<leader>sn",
	":e ~/.config/nvim/init.lua<CR>",
	{ desc = "Open Nvim config" }
)

-- Toggle format on save for current buffer (conform respects vim.b.autoformat)
vim.keymap.set("n", "<leader>tf", function()
	if vim.b.autoformat == nil then
		vim.b.autoformat = false
	else
		vim.b.autoformat = not vim.b.autoformat
	end
	local status = vim.b.autoformat and "enabled" or "disabled"
	vim.notify("Format on save " .. status, vim.log.levels.INFO)
end, { desc = "Toggle format on save" })

vim.keymap.set("n", "<leader>tw", function()
	vim.opt.list = not vim.opt.list:get()
end, { desc = "Toggle whitespace" })
