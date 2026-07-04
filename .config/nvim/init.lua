-- ============================================================================
-- Neovim Configuration - Enhanced with Better LSP & QoL Features
-- ============================================================================

-- ============================================================================
-- Basic Settings
-- ============================================================================
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

-- Kitty-matched Tokyo Night palette.
local ui_colors = {
	bg = "#101015",
	surface = "#15161e",
	surface_alt = "#1a1b26",
	selection = "#283457",
	border = "#7aa2f7",
	border_dim = "#292e42",
	fg = "#c0caf5",
	fg_dim = "#a9b1d6",
	muted = "#545c7e",
	blue = "#7aa2f7",
	cyan = "#7dcfff",
	green = "#9ece6a",
	yellow = "#e0af68",
	orange = "#ff9e64",
	red = "#f7768e",
	red_dark = "#db4b4b",
	purple = "#bb9af7",
	tab_fg = "#16161e",
}

local function blend_hex(fg, bg, alpha)
	local function channel(hex, index)
		return tonumber(hex:sub(index, index + 1), 16) or 0
	end

	local function blend_channel(fg_channel, bg_channel)
		return math.floor((fg_channel * alpha) + (bg_channel * (1 - alpha)) + 0.5)
	end

	return string.format(
		"#%02x%02x%02x",
		blend_channel(channel(fg, 2), channel(bg, 2)),
		blend_channel(channel(fg, 4), channel(bg, 4)),
		blend_channel(channel(fg, 6), channel(bg, 6))
	)
end

local function apply_kitty_highlights(hl)
	local function merge_highlight(group, opts)
		local existing = type(hl[group]) == "table" and hl[group] or {}
		hl[group] = vim.tbl_extend("force", existing, opts)
	end

	local transparent_groups = {
		"Normal",
		"NormalNC",
		"SignColumn",
		"FoldColumn",
		"LineNr",
		"CursorLineNr",
		"EndOfBuffer",
		"StatusLine",
		"StatusLineNC",
		"WinBar",
		"WinBarNC",
		"NvimTreeNormal",
		"NvimTreeNormalNC",
		"NvimTreeEndOfBuffer",
		"NvimTreeVertSplit",
		"BufferLineFill",
		"BufferLineBackground",
		"BufferLineTab",
		"BufferLineTabClose",
	}

	for _, group in ipairs(transparent_groups) do
		merge_highlight(group, { bg = "NONE" })
	end

	local surface_groups = {
		"NormalFloat",
		"FloatTitle",
		"Pmenu",
		"WhichKeyFloat",
		"LazyNormal",
		"MasonNormal",
		"TelescopeNormal",
		"TelescopePromptNormal",
		"TelescopeResultsNormal",
		"TelescopePreviewNormal",
		"TroubleNormal",
		"TroubleNormalNC",
		"DiagnosticFloatingError",
		"DiagnosticFloatingWarn",
		"DiagnosticFloatingInfo",
		"DiagnosticFloatingHint",
		"LspInfoBorder",
		"NotifyBackground",
	}

	for _, group in ipairs(surface_groups) do
		merge_highlight(group, { fg = ui_colors.fg, bg = "NONE" })
	end

	hl.FloatBorder = { fg = ui_colors.border, bg = "NONE" }
	hl.FloatTitle = { fg = ui_colors.blue, bg = "NONE", bold = true }
	hl.WinSeparator = { fg = ui_colors.border_dim, bg = "NONE" }
	hl.PmenuSel = { fg = ui_colors.tab_fg, bg = ui_colors.blue, bold = true }
	hl.PmenuSbar = { bg = "NONE" }
	hl.PmenuThumb = { bg = ui_colors.border_dim }
	hl.Visual = { bg = ui_colors.selection }
	hl.Search = { fg = ui_colors.tab_fg, bg = ui_colors.yellow }
	hl.IncSearch = { fg = ui_colors.tab_fg, bg = ui_colors.orange }
	hl.CurSearch = { fg = ui_colors.tab_fg, bg = ui_colors.orange }
	hl.CursorLine = { bg = ui_colors.surface }
	hl.ColorColumn = { bg = ui_colors.surface }

	hl.TelescopeBorder = { fg = ui_colors.border_dim, bg = "NONE" }
	hl.TelescopePromptBorder = { fg = ui_colors.blue, bg = "NONE" }
	hl.TelescopePromptTitle = { fg = ui_colors.blue, bg = "NONE", bold = true }
	hl.TelescopePreviewTitle = { fg = ui_colors.purple, bg = "NONE", bold = true }
	hl.TelescopeResultsTitle = { fg = ui_colors.muted, bg = "NONE" }
	hl.TelescopeSelection = { fg = ui_colors.fg, bg = ui_colors.selection, bold = true }
	hl.TelescopeMatching = { fg = ui_colors.cyan, bold = true }

	hl.NvimTreeRootFolder = { fg = ui_colors.blue, bold = true }
	hl.NvimTreeFolderName = { fg = ui_colors.fg_dim }
	hl.NvimTreeOpenedFolderName = { fg = ui_colors.blue, bold = true }
	hl.NvimTreeGitDirty = { fg = ui_colors.orange }
	hl.NvimTreeGitNew = { fg = ui_colors.green }
	hl.NvimTreeGitDeleted = { fg = ui_colors.red }
	hl.NvimTreeIndentMarker = { fg = ui_colors.border_dim }

	hl.AlphaHeader = { fg = ui_colors.blue }
	hl.AlphaButtons = { fg = ui_colors.fg }
	hl.AlphaShortcut = { fg = ui_colors.cyan, bold = true }
	hl.AlphaFooter = { fg = ui_colors.muted }

	hl.DiagnosticVirtualTextError = { fg = ui_colors.red, bg = "NONE" }
	hl.DiagnosticVirtualTextWarn = { fg = ui_colors.yellow, bg = "NONE" }
	hl.DiagnosticVirtualTextInfo = { fg = ui_colors.cyan, bg = "NONE" }
	hl.DiagnosticVirtualTextHint = { fg = ui_colors.green, bg = "NONE" }
	hl.DiagnosticSignError = { fg = ui_colors.red, bg = "NONE" }
	hl.DiagnosticSignWarn = { fg = ui_colors.yellow, bg = "NONE" }
	hl.DiagnosticSignInfo = { fg = ui_colors.cyan, bg = "NONE" }
	hl.DiagnosticSignHint = { fg = ui_colors.green, bg = "NONE" }
	hl.DiagnosticFloatingError = { fg = ui_colors.red, bg = "NONE" }
	hl.DiagnosticFloatingWarn = { fg = ui_colors.yellow, bg = "NONE" }
	hl.DiagnosticFloatingInfo = { fg = ui_colors.cyan, bg = "NONE" }
	hl.DiagnosticFloatingHint = { fg = ui_colors.green, bg = "NONE" }
	hl.LspFloatWinNormal = { fg = ui_colors.fg, bg = "NONE" }
	hl.LspFloatWinBorder = { fg = ui_colors.border, bg = "NONE" }
	hl.LspSignatureActiveParameter = { fg = ui_colors.tab_fg, bg = ui_colors.yellow, bold = true }

	hl.NotifyBackground = { bg = "NONE" }
	hl.NotifyERRORBorder = { fg = ui_colors.red, bg = "NONE" }
	hl.NotifyWARNBorder = { fg = ui_colors.yellow, bg = "NONE" }
	hl.NotifyINFOBorder = { fg = ui_colors.cyan, bg = "NONE" }
	hl.NotifyDEBUGBorder = { fg = ui_colors.muted, bg = "NONE" }
	hl.NotifyTRACEBorder = { fg = ui_colors.purple, bg = "NONE" }
	hl.NotifyERRORTitle = { fg = ui_colors.red, bg = "NONE", bold = true }
	hl.NotifyWARNTitle = { fg = ui_colors.yellow, bg = "NONE", bold = true }
	hl.NotifyINFOTitle = { fg = ui_colors.cyan, bg = "NONE", bold = true }
	hl.NotifyDEBUGTitle = { fg = ui_colors.muted, bg = "NONE", bold = true }
	hl.NotifyTRACETitle = { fg = ui_colors.purple, bg = "NONE", bold = true }
	hl.NotifyERRORIcon = { fg = ui_colors.red, bg = "NONE" }
	hl.NotifyWARNIcon = { fg = ui_colors.yellow, bg = "NONE" }
	hl.NotifyINFOIcon = { fg = ui_colors.cyan, bg = "NONE" }
	hl.NotifyDEBUGIcon = { fg = ui_colors.muted, bg = "NONE" }
	hl.NotifyTRACEIcon = { fg = ui_colors.purple, bg = "NONE" }

	hl.WhichKey = { fg = ui_colors.cyan }
	hl.WhichKeyGroup = { fg = ui_colors.blue }
	hl.WhichKeyDesc = { fg = ui_colors.fg }
	hl.WhichKeySeparator = { fg = ui_colors.muted }
	hl.WhichKeyValue = { fg = ui_colors.muted }

	hl.TroubleNormal = { fg = ui_colors.fg, bg = "NONE" }
	hl.TroubleNormalNC = { fg = ui_colors.fg_dim, bg = "NONE" }
	hl.TroubleText = { fg = ui_colors.fg_dim, bg = "NONE" }
	hl.TroubleCount = { fg = ui_colors.blue, bg = "NONE", bold = true }
	hl.TroubleIndent = { fg = ui_colors.border_dim, bg = "NONE" }
	hl.TroubleIndentTop = { fg = ui_colors.border_dim, bg = "NONE" }
	hl.TroubleIndentMiddle = { fg = ui_colors.border_dim, bg = "NONE" }
	hl.TroubleIndentLast = { fg = ui_colors.border_dim, bg = "NONE" }
	hl.TroubleIndentWs = { fg = ui_colors.border_dim, bg = "NONE" }
	hl.TroubleIndentFoldOpen = { fg = ui_colors.blue, bg = "NONE" }
	hl.TroubleIndentFoldClosed = { fg = ui_colors.blue, bg = "NONE" }
	hl.TroublePreview = { bg = ui_colors.selection }

	local satellite_colors = {
		blue = blend_hex(ui_colors.blue, ui_colors.bg, 0.5),
		cyan = blend_hex(ui_colors.cyan, ui_colors.bg, 0.5),
		green = blend_hex(ui_colors.green, ui_colors.bg, 0.5),
		yellow = blend_hex(ui_colors.yellow, ui_colors.bg, 0.5),
		orange = blend_hex(ui_colors.orange, ui_colors.bg, 0.5),
		red = blend_hex(ui_colors.red, ui_colors.bg, 0.5),
		purple = blend_hex(ui_colors.purple, ui_colors.bg, 0.5),
	}

	hl.SatelliteBackground = { bg = "NONE" }
	hl.SatelliteBar = { bg = "NONE" }
	hl.SatelliteCursor = { fg = satellite_colors.blue, bg = "NONE" }
	hl.SatelliteSearch = { fg = satellite_colors.yellow, bg = "NONE" }
	hl.SatelliteSearchCurrent = { fg = satellite_colors.orange, bg = "NONE" }
	hl.SatelliteDiagnosticError = { fg = satellite_colors.red, bg = "NONE" }
	hl.SatelliteDiagnosticWarn = { fg = satellite_colors.yellow, bg = "NONE" }
	hl.SatelliteDiagnosticInfo = { fg = satellite_colors.cyan, bg = "NONE" }
	hl.SatelliteDiagnosticHint = { fg = satellite_colors.green, bg = "NONE" }
	hl.SatelliteGitSignsAdd = { fg = satellite_colors.green, bg = "NONE" }
	hl.SatelliteGitSignsChange = { fg = satellite_colors.cyan, bg = "NONE" }
	hl.SatelliteGitSignsDelete = { fg = satellite_colors.red, bg = "NONE" }
	hl.SatelliteQuickfix = { fg = satellite_colors.purple, bg = "NONE" }
	hl.SatelliteMark = { fg = satellite_colors.cyan, bg = "NONE" }
end

-- Neovide specific settings
if vim.g.neovide then
	-- Font configuration (matching Kitty: MesloLGS NF, size 13)
	vim.o.guifont = "MesloLGS NF:h13"

	-- Padding (minimal, like Kitty)
	vim.g.neovide_padding_top = 5
	vim.g.neovide_padding_bottom = 5
	vim.g.neovide_padding_right = 5
	vim.g.neovide_padding_left = 5

	-- Opacity (matching Kitty: 0.75 opacity with blur)
	-- Note: neovide_transparency is deprecated, use neovide_background_color alpha channel instead
	vim.g.neovide_window_blurred = true

	-- Set background color with alpha channel for transparency
	-- Format: #RRGGBBAA where AA is alpha (00 = transparent, FF = opaque)
	-- BF is roughly 75% opacity, matching Kitty's background_opacity.
	vim.g.neovide_background_color = ui_colors.bg .. "BF"

	-- Floating blur
	vim.g.neovide_floating_blur_amount_x = 2.0
	vim.g.neovide_floating_blur_amount_y = 2.0

	-- Hide mouse when typing
	vim.g.neovide_hide_mouse_when_typing = true

	-- Underline stroke scale
	vim.g.neovide_underline_stroke_scale = 1.0

	-- Theme (can be "auto", "light", or "dark")
	vim.g.neovide_theme = "auto"

	-- Refresh rate
	vim.g.neovide_refresh_rate = 60

	-- Idle refresh rate (when not focused)
	vim.g.neovide_refresh_rate_idle = 5

	-- Confirm quit
	vim.g.neovide_confirm_quit = true

	-- Fullscreen
	vim.g.neovide_fullscreen = false

	-- Remember window size
	vim.g.neovide_remember_window_size = true

	-- Cursor settings
	vim.g.neovide_cursor_animation_length = 0.13
	vim.g.neovide_cursor_trail_size = 0.3
	vim.g.neovide_cursor_antialiasing = true
	vim.g.neovide_cursor_animate_in_insert_mode = true
	vim.g.neovide_cursor_animate_command_line = true
	vim.g.neovide_cursor_vfx_mode = "railgun" -- Options: "", "railgun", "torpedo", "pixiedust", "sonicboom", "ripple", "wireframe"

	-- Scroll animation
	vim.g.neovide_scroll_animation_length = 0.15

	-- Keyboard shortcuts for Neovide
	-- Cmd+V for paste (macOS style)
	vim.keymap.set({ "n", "v", "i", "c" }, "<D-v>", function()
		if vim.fn.mode() == "i" or vim.fn.mode() == "c" then
			return "<C-r>+"
		else
			return '"+p'
		end
	end, { expr = true, desc = "Paste from system clipboard" })

	-- Cmd+C for copy (macOS style)
	vim.keymap.set("v", "<D-c>", '"+y', { desc = "Copy to system clipboard" })

	-- Cmd+= to increase font size
	vim.keymap.set("n", "<D-=>", function()
		local current_font = vim.o.guifont
		local size = tonumber(string.match(current_font, ":h(%d+)"))
		if size then
			vim.o.guifont = string.gsub(current_font, ":h%d+", ":h" .. (size + 1))
		end
	end, { desc = "Increase font size" })

	-- Cmd+- to decrease font size
	vim.keymap.set("n", "<D-->", function()
		local current_font = vim.o.guifont
		local size = tonumber(string.match(current_font, ":h(%d+)"))
		if size and size > 6 then
			vim.o.guifont = string.gsub(current_font, ":h%d+", ":h" .. (size - 1))
		end
	end, { desc = "Decrease font size" })

	-- Cmd+0 to reset font size
	vim.keymap.set("n", "<D-0>", function()
		vim.o.guifont = "MesloLGS NF:h13"
	end, { desc = "Reset font size" })
end

-- ============================================================================
-- Bootstrap lazy.nvim Plugin Manager
-- ============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

local function listed_file_buffers()
	local buffers = {}
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted and vim.bo[buf].buftype == "" then
			table.insert(buffers, buf)
		end
	end
	return buffers
end

local function open_fallback_buffer()
	if pcall(vim.cmd, "Alpha") then
		return vim.api.nvim_get_current_buf()
	end
	vim.cmd("enew")
	vim.bo.buflisted = false
	return vim.api.nvim_get_current_buf()
end

local function close_buffer(bufnr, force)
	if bufnr == nil or bufnr == 0 then
		bufnr = vim.api.nvim_get_current_buf()
	end
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end

	if vim.bo[bufnr].modified and not force then
		vim.notify("Buffer has unsaved changes. Save it or use <leader>bD to force close.", vim.log.levels.WARN)
		return
	end

	local alternate
	local target_windows = {}

	for _, buf in ipairs(listed_file_buffers()) do
		if buf ~= bufnr then
			alternate = buf
			break
		end
	end

	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == bufnr then
			table.insert(target_windows, win)
		end
	end

	if alternate then
		for _, win in ipairs(target_windows) do
			vim.api.nvim_win_set_buf(win, alternate)
		end
	elseif #target_windows > 0 then
		local current_win = vim.api.nvim_get_current_win()
		vim.api.nvim_set_current_win(target_windows[1])
		local fallback = open_fallback_buffer()
		for i = 2, #target_windows do
			vim.api.nvim_win_set_buf(target_windows[i], fallback)
		end
		if vim.api.nvim_win_is_valid(current_win) then
			vim.api.nvim_set_current_win(current_win)
		end
	end

	pcall(vim.api.nvim_buf_delete, bufnr, { force = force or false })
end

-- ============================================================================
-- Keybindings
-- ============================================================================

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

-- ============================================================================
-- Auto Commands
-- ============================================================================

-- Refresh files changed outside Neovim, similar to VS Code/Cursor.
local external_file_changes = vim.api.nvim_create_augroup("external_file_changes", { clear = true })

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
	group = external_file_changes,
	callback = function()
		if vim.fn.mode() ~= "c" then
			vim.cmd("silent! checktime")
		end
	end,
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
	group = external_file_changes,
	callback = function()
		vim.notify("Reloaded file changed outside Neovim", vim.log.levels.INFO)
	end,
})

vim.api.nvim_create_autocmd("CursorHold", {
	group = vim.api.nvim_create_augroup("diagnostic_float_on_idle", { clear = true }),
	callback = function()
		if vim.bo.buftype ~= "" or vim.fn.mode() ~= "n" then
			return
		end
		vim.diagnostic.open_float(nil, {
			border = "rounded",
			focus = false,
			header = { " Diagnostics ", "FloatTitle" },
			prefix = "● ",
			source = "always",
			scope = "cursor",
		})
	end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
	callback = function()
		(vim.hl or vim.highlight).on_yank({ timeout = 200 })
	end,
})

-- Create missing parent directories when saving new nested files.
vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("auto_create_parent_dirs", { clear = true }),
	callback = function(event)
		if event.match:match("^%w%w+://") then
			return
		end
		local dir = vim.fn.fnamemodify(event.match, ":p:h")
		if dir ~= "" and vim.fn.isdirectory(dir) == 0 then
			vim.fn.mkdir(dir, "p")
		end
	end,
})

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("trim_whitespace", { clear = true }),
	pattern = "*",
	callback = function()
		local save_cursor = vim.fn.getpos(".")
		vim.cmd([[%s/\s\+$//e]])
		vim.fn.setpos(".", save_cursor)
	end,
})

-- Remember cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
	group = vim.api.nvim_create_augroup("restore_cursor", { clear = true }),
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Format-on-save is handled by conform.nvim (see plugin section).
-- Toggle per buffer with <leader>tf (sets vim.b.autoformat).
-- Disable globally with: vim.g.autoformat = false

-- ============================================================================
-- Plugin Configuration
-- ============================================================================
require("lazy").setup({
	-- Tokyo Night theme with transparent background
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("tokyonight").setup({
				style = "night", -- Tokyo Night theme (matches Kitty)
				transparent = true,
				terminal_colors = true, -- Configure colors for terminal windows
				styles = {
					sidebars = "transparent",
					floats = "transparent",
					comments = { italic = true },
					keywords = { italic = true },
				},
				-- Override specific colors to match Kitty if needed
				on_colors = function(colors)
					colors.bg = ui_colors.bg
					colors.bg_dark = ui_colors.bg
					colors.bg_float = ui_colors.surface
					colors.bg_popup = ui_colors.surface
					colors.bg_sidebar = ui_colors.bg
					colors.bg_statusline = ui_colors.bg
					colors.fg = ui_colors.fg
					colors.border = ui_colors.border_dim
					colors.blue = ui_colors.blue
					colors.cyan = ui_colors.cyan
					colors.green = ui_colors.green
					colors.yellow = ui_colors.yellow
					colors.orange = ui_colors.orange
					colors.red = ui_colors.red
					colors.purple = ui_colors.purple
				end,
				-- Override highlights for less eye strain
				on_highlights = function(hl, c)
					apply_kitty_highlights(hl)

					-- Change JSX/HTML tags from red to purple
					hl["@tag"] = { fg = ui_colors.purple }
					hl["@tag.tsx"] = { fg = ui_colors.purple }
					hl["@tag.javascript"] = { fg = ui_colors.purple }
					hl["@tag.delimiter"] = { fg = ui_colors.muted } -- Muted color for < > /
					hl["@tag.attribute"] = { fg = ui_colors.cyan } -- Cyan for attributes
				end,
			})
			vim.cmd([[colorscheme tokyonight]])
		end,
	},

	-- Statusline
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local lualine_theme = require("lualine.themes.tokyonight")
			local mode_accents = {
				normal = ui_colors.blue,
				insert = ui_colors.green,
				visual = ui_colors.purple,
				replace = ui_colors.red,
				command = ui_colors.yellow,
				terminal = ui_colors.cyan,
			}

			for mode, accent in pairs(mode_accents) do
				lualine_theme[mode] = lualine_theme[mode] or {}
				lualine_theme[mode].a = { fg = accent, bg = "NONE", gui = "bold" }
				lualine_theme[mode].b = { fg = ui_colors.fg, bg = "NONE" }
				lualine_theme[mode].c = { fg = ui_colors.fg_dim, bg = "NONE" }
				lualine_theme[mode].x = { fg = ui_colors.fg_dim, bg = "NONE" }
				lualine_theme[mode].y = { fg = accent, bg = "NONE" }
				lualine_theme[mode].z = { fg = accent, bg = "NONE", gui = "bold" }
			end
			lualine_theme.inactive = {
				a = { fg = ui_colors.muted, bg = "NONE" },
				b = { fg = ui_colors.muted, bg = "NONE" },
				c = { fg = ui_colors.muted, bg = "NONE" },
				x = { fg = ui_colors.muted, bg = "NONE" },
				y = { fg = ui_colors.muted, bg = "NONE" },
				z = { fg = ui_colors.muted, bg = "NONE" },
			}

			require("lualine").setup({
				options = {
					theme = lualine_theme,
					icons_enabled = true,
					component_separators = { left = "|", right = "|" },
					section_separators = { left = "", right = "" },
					globalstatus = true,
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = {
						{ "filename", path = 1 },
						{
							function()
								local navic_ok, navic = pcall(require, "nvim-navic")
								if navic_ok then
									return navic.get_location()
								end
								return ""
							end,
							cond = function()
								local navic_ok, navic = pcall(require, "nvim-navic")
								return navic_ok and navic.is_available()
							end,
						},
					},
					lualine_x = { "encoding", "fileformat", "filetype" },
					lualine_y = { "progress" },
					lualine_z = {
						"location",
					},
				},
			})
		end,
	},

	-- Smooth scrolling
	{
		"karb94/neoscroll.nvim",
		config = function()
			require("neoscroll").setup({
				mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
				hide_cursor = true,
				stop_eof = true,
				respect_scrolloff = false,
				cursor_scrolls_alone = true,
				easing_function = "quadratic",
			})
		end,
	},

	-- Telescope fuzzy finder
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		},
		config = function()
			require("telescope").setup({
				defaults = {
					prompt_prefix = "  ",
					selection_caret = "▸ ",
					layout_strategy = "horizontal",
					layout_config = {
						horizontal = {
							preview_width = 0.55,
						},
					},
					border = true,
					borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
					color_devicons = true,
					file_ignore_patterns = { "node_modules", ".git/", "dist/", "build/" },
				},
				pickers = {
					find_files = {
						theme = "dropdown",
						previewer = false,
						layout_config = { width = 0.75 },
					},
					buffers = {
						theme = "dropdown",
						previewer = false,
						layout_config = { width = 0.7 },
					},
					commands = {
						theme = "dropdown",
						layout_config = { width = 0.7 },
					},
					keymaps = {
						theme = "dropdown",
						layout_config = { width = 0.8 },
					},
				},
				extensions = {
					fzf = {
						fuzzy = true,
						override_generic_sorter = true,
						override_file_sorter = true,
						case_mode = "smart_case",
					},
				},
			})

			-- Load fzf extension
			pcall(require("telescope").load_extension, "fzf")

			-- Keybindings (using <leader>s for search to free up <leader>f for format)
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "Search files" })
			vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "Search grep" })
			vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "Search buffers" })
			vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "Search help" })
			vim.keymap.set("n", "<leader>sH", builtin.highlights, { desc = "Search highlight groups" })
			vim.keymap.set("n", "<leader>so", builtin.oldfiles, { desc = "Search old files" })
			vim.keymap.set("n", "<leader>sc", builtin.commands, { desc = "Search commands" })
			vim.keymap.set("n", "<leader>sC", builtin.colorscheme, { desc = "Colorscheme" })
			vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "Search keymaps" })
			vim.keymap.set("n", "<leader>sM", builtin.man_pages, { desc = "Man pages" })
			vim.keymap.set("n", "<leader>sR", builtin.registers, { desc = "Registers" })
			vim.keymap.set("n", "<leader>ss", builtin.lsp_document_symbols, { desc = "Search symbols" })
			vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "Search word under cursor" })
			vim.keymap.set("n", "<leader>sB", builtin.git_branches, { desc = "Checkout branch" })
			vim.keymap.set("n", "<leader>s,", builtin.git_commits, { desc = "Checkout commit" })
		end,
	},

	-- Project-wide search and replace
	{
		"nvim-pack/nvim-spectre",
		dependencies = { "nvim-lua/plenary.nvim" },
		cmd = "Spectre",
		keys = {
			{
				"<leader>sr",
				function()
					require("spectre").open()
				end,
				desc = "Search/replace",
			},
			{
				"<leader>sW",
				function()
					require("spectre").open_visual({ select_word = true })
				end,
				desc = "Search/replace word",
			},
			{
				"<leader>sr",
				function()
					require("spectre").open_visual()
				end,
				mode = "v",
				desc = "Search/replace selection",
			},
		},
		config = function()
			require("spectre").setup()
		end,
	},

	-- Which-key for keybinding hints
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			local wk = require("which-key")
			wk.setup({
				win = {
					border = "rounded",
				},
			})
			wk.add({
				{ "<leader>;", desc = "Dashboard" },
				{ "<leader>c", desc = "Close buffer" },
				{ "<leader>h", desc = "Clear highlight" },
				{ "<leader>q", desc = "Quit" },
				{ "<leader>w", desc = "Save" },
				{ "<leader>b", group = "buffers" },
				{ "<leader>d", group = "debug" },
				{ "<leader>f", desc = "Format" },
				{ "<leader>g", group = "git" },
				{ "<leader>gd", group = "diffview" },
				{ "<leader>l", group = "LSP" },
				{ "<leader>S", group = "session" },
				{ "<leader>s", group = "search" },
				{ "<leader>t", group = "toggle/term" },
				{ "<leader>x", group = "trouble" },
			})
		end,
	},

	-- Indent guides
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		config = function()
			require("ibl").setup({
				indent = {
					char = "│",
				},
				scope = {
					enabled = true,
					show_start = false,
					show_end = false,
				},
			})
		end,
	},

	-- Git signs in gutter
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup({
				signs = {
					add = { text = "│" },
					change = { text = "│" },
					delete = { text = "_" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
					untracked = { text = "┆" },
				},
				current_line_blame = false,
				on_attach = function(bufnr)
					local gs = package.loaded.gitsigns
					local function map(mode, l, r, opts)
						opts = opts or {}
						opts.buffer = bufnr
						vim.keymap.set(mode, l, r, opts)
					end

					-- Navigation
					map("n", "]c", function()
						if vim.wo.diff then
							return "]c"
						end
						vim.schedule(function()
							gs.next_hunk()
						end)
						return "<Ignore>"
					end, { expr = true, desc = "Next hunk" })

					map("n", "[c", function()
						if vim.wo.diff then
							return "[c"
						end
						vim.schedule(function()
							gs.prev_hunk()
						end)
						return "<Ignore>"
					end, { expr = true, desc = "Previous hunk" })

					-- Actions (LunarVim style: <leader>g prefix)
					map("n", "<leader>gj", function()
						gs.next_hunk({ navigation_message = false })
					end, { desc = "Next hunk" })
					map("n", "<leader>gk", function()
						gs.prev_hunk({ navigation_message = false })
					end, { desc = "Prev hunk" })
					map("n", "<leader>gs", gs.stage_hunk, { desc = "Stage hunk" })
					map("n", "<leader>gr", gs.reset_hunk, { desc = "Reset hunk" })
					map("n", "<leader>gu", gs.undo_stage_hunk, { desc = "Undo stage hunk" })
					map("n", "<leader>gp", gs.preview_hunk, { desc = "Preview hunk" })
					map("n", "<leader>gb", function()
						gs.blame_line({ full = true })
					end, { desc = "Blame line" })
					map("n", "<leader>gd", gs.diffthis, { desc = "Diff this" })
					map("n", "<leader>gR", gs.reset_buffer, { desc = "Reset buffer" })
				end,
			})
		end,
	},

	-- Neogit - Magit-like Git interface
	{
		"NeogitOrg/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"sindrets/diffview.nvim",
			"nvim-telescope/telescope.nvim",
		},
		config = function()
			require("neogit").setup({
				integrations = {
					telescope = true,
					diffview = true,
				},
				signs = {
					section = { "", "" },
					item = { "", "" },
					hunk = { "", "" },
				},
			})
			vim.keymap.set("n", "<leader>gg", ":Neogit<CR>", { desc = "Open Neogit" })
			vim.keymap.set("n", "<leader>gc", ":Neogit commit<CR>", { desc = "Git commit" })
			vim.keymap.set("n", "<leader>gp", ":Neogit push<CR>", { desc = "Git push" })
			vim.keymap.set("n", "<leader>gl", ":Neogit pull<CR>", { desc = "Git pull" })
		end,
	},

	-- Diffview for better diff visualization
	{
		"sindrets/diffview.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("diffview").setup({})
			vim.keymap.set("n", "<leader>gdo", ":DiffviewOpen<CR>", { desc = "Open Diffview" })
			vim.keymap.set("n", "<leader>gdc", ":DiffviewClose<CR>", { desc = "Close Diffview" })
			vim.keymap.set("n", "<leader>gdh", ":DiffviewFileHistory %<CR>", { desc = "File history" })
			vim.keymap.set("n", "<leader>gdf", ":DiffviewFileHistory<CR>", { desc = "Branch history" })
		end,
	},

	-- Bufferline for better buffer tabs
	{
		"akinsho/bufferline.nvim",
		dependencies = "nvim-tree/nvim-web-devicons",
		config = function()
			require("bufferline").setup({
				options = {
					mode = "buffers",
					separator_style = "thin",
					diagnostics = "nvim_lsp",
					show_buffer_close_icons = true,
					show_close_icon = false,
					always_show_bufferline = true,
					close_command = function(bufnum)
						close_buffer(bufnum, false)
					end,
					right_mouse_command = function(bufnum)
						close_buffer(bufnum, false)
					end,
					offsets = {
						{
							filetype = "NvimTree",
							text = "File Explorer",
							text_align = "left",
							separator = true,
						},
					},
				},
				highlights = {
					fill = { bg = "NONE" },
					background = { fg = ui_colors.muted, bg = "NONE" },
					buffer_visible = { fg = ui_colors.fg_dim, bg = "NONE" },
					buffer_selected = { fg = ui_colors.fg, bg = "NONE", bold = true, italic = false },
					tab = { fg = ui_colors.muted, bg = "NONE" },
					tab_selected = { fg = ui_colors.tab_fg, bg = ui_colors.blue, bold = true },
					separator = { fg = ui_colors.border_dim, bg = "NONE" },
					separator_visible = { fg = ui_colors.border_dim, bg = "NONE" },
					separator_selected = { fg = ui_colors.blue, bg = "NONE" },
					indicator_selected = { fg = ui_colors.blue, bg = "NONE" },
					modified = { fg = ui_colors.orange, bg = "NONE" },
					modified_visible = { fg = ui_colors.orange, bg = "NONE" },
					modified_selected = { fg = ui_colors.orange, bg = "NONE" },
					duplicate = { fg = ui_colors.muted, bg = "NONE", italic = true },
					duplicate_selected = { fg = ui_colors.fg_dim, bg = "NONE", italic = true },
					offset_separator = { fg = ui_colors.border_dim, bg = "NONE" },
				},
			})
		end,
	},

	-- Alpha dashboard
	{
		"goolord/alpha-nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local alpha = require("alpha")
			local dashboard = require("alpha.themes.dashboard")

			dashboard.section.header.val = {
				[[                                                                   ]],
				[[            :\     /;               _                              ]],
				[[           ;  \___/  ;             ; ;                             ]],
				[[          ,:-"'   `"-:.            / ;                             ]],
				[[     _  /,---.   ,---.\  _       _; /                              ]],
				[[    _:>((  |  ) (  |  ))<:_ ,-""_,"                                ]],
				[[        \`````   `````/""""",-""                                   ]],
				[[         '-.._ v _..-'      )                                      ]],
				[[           / ___   ____,..  \                                      ]],
				[[          / /   | |   | ( \. \                                     ]],
				[[         / /    | |    | |  \ \                                    ]],
				[[         `"     `"     `"    `"                                    ]],
				[[                                                                   ]],
			}

			dashboard.section.buttons.val = {
				dashboard.button("f", "f  Find file", ":Telescope find_files <CR>"),
				dashboard.button("r", "r  Recent files", ":Telescope oldfiles <CR>"),
				dashboard.button("g", "g  Search text", ":Telescope live_grep <CR>"),
				dashboard.button("p", "p  Projects", ":Telescope projects <CR>"),
				dashboard.button("n", "n  New file", ":ene <BAR> startinsert <CR>"),
				dashboard.button("c", "c  Config", ":e ~/.config/nvim/init.lua <CR>"),
				dashboard.button("q", "q  Quit", ":qa<CR>"),
			}

			dashboard.section.footer.val = "Kitty palette: #101015 / #7aa2f7 / #c0caf5"

			dashboard.config.layout = {
				{ type = "padding", val = 2 },
				dashboard.section.header,
				{ type = "padding", val = 2 },
				dashboard.section.buttons,
				{ type = "padding", val = 1 },
				dashboard.section.footer,
			}

			-- Colors
			dashboard.section.header.opts.hl = "AlphaHeader"
			dashboard.section.buttons.opts.hl = "AlphaButtons"
			dashboard.section.footer.opts.hl = "AlphaFooter"

			alpha.setup(dashboard.config)

			-- Disable for nvim-tree
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "alpha",
				callback = function()
					vim.opt_local.foldenable = false
				end,
			})
		end,
	},

	-- File tree explorer
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = {
			"nvim-tree/nvim-web-devicons", -- File icons
		},
		config = function()
			-- Disable netrw (built-in file explorer)
			vim.g.loaded_netrw = 1
			vim.g.loaded_netrwPlugin = 1

			require("nvim-tree").setup({
				view = {
					width = 30,
					side = "left",
					signcolumn = "yes",
				},
				renderer = {
					group_empty = true,
					highlight_git = true,
					highlight_opened_files = "name",
					indent_width = 2,
					icons = {
						show = {
							file = true,
							folder = true,
							folder_arrow = true,
							git = true,
						},
						glyphs = {
							folder = {
								arrow_closed = "▸",
								arrow_open = "▾",
							},
							git = {
								unstaged = "~",
								staged = "+",
								unmerged = "=",
								renamed = "»",
								untracked = "?",
								deleted = "_",
								ignored = ".",
							},
						},
					},
				},
				filters = {
					dotfiles = false,
				},
				git = {
					enable = true,
					ignore = false,
				},
				update_focused_file = {
					enable = true,
					update_root = true,
				},
			})

			-- Keybindings for nvim-tree
			vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file tree" })
			vim.keymap.set("n", "<leader>o", ":NvimTreeFocus<CR>", { desc = "Focus file tree" })
		end,
	},

	-- Treesitter for better syntax highlighting
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
		config = function()
			-- Check if nvim-treesitter.configs exists (for compatibility)
			local has_configs, ts_configs = pcall(require, "nvim-treesitter.configs")
			if has_configs then
				ts_configs.setup({
					-- Don't auto-install parsers (managed by lazy.nvim)
					ensure_installed = {
						"lua",
						"vim",
						"vimdoc",
						"query",
						"javascript",
						"typescript",
						"tsx",
						"json",
						"html",
						"css",
						"python",
						"go",
						"rust",
						"c",
						"nix",
						"bash",
						"markdown",
						"yaml",
						"toml",
					},
					-- Install parsers synchronously (only applied to `ensure_installed`)
					sync_install = false,
					-- Automatically install missing parsers when entering buffer
					auto_install = true,
					highlight = {
						enable = true,
						additional_vim_regex_highlighting = false,
					},
					indent = {
						enable = true,
					},
					incremental_selection = {
						enable = true,
						keymaps = {
							init_selection = "<C-space>",
							node_incremental = "<C-space>",
							scope_incremental = false,
							node_decremental = "<bs>",
						},
					},
					textobjects = {
						select = {
							enable = true,
							lookahead = true,
							keymaps = {
								["af"] = "@function.outer",
								["if"] = "@function.inner",
								["ac"] = "@class.outer",
								["ic"] = "@class.inner",
								["aa"] = "@parameter.outer",
								["ia"] = "@parameter.inner",
								["al"] = "@loop.outer",
								["il"] = "@loop.inner",
								["ai"] = "@conditional.outer",
								["ii"] = "@conditional.inner",
							},
						},
						move = {
							enable = true,
							set_jumps = true,
							goto_next_start = {
								["]f"] = "@function.outer",
								["]o"] = "@class.outer",
							},
							goto_previous_start = {
								["[f"] = "@function.outer",
								["[o"] = "@class.outer",
							},
						},
					},
				})
			end
		end,
	},

	-- Auto close HTML/JSX tags
	{
		"windwp/nvim-ts-autotag",
		dependencies = "nvim-treesitter/nvim-treesitter",
		event = "InsertEnter",
		config = function()
			local has_autotag, autotag = pcall(require, "nvim-ts-autotag")
			if has_autotag then
				autotag.setup()
			end
		end,
	},

	-- Comment toggling
	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup({
				toggler = {
					line = "gcc", -- Line-comment toggle
					block = "gbc", -- Block-comment toggle
				},
				opleader = {
					line = "gc", -- Line-comment operator
					block = "gb", -- Block-comment operator
				},
				mappings = {
					basic = true,
					extra = true,
				},
			})
		end,
	},

	-- Surround text objects (cs"' to change " to ', ds" to delete ", ysiw" to surround word)
	{
		"kylechui/nvim-surround",
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({})
		end,
	},

	-- TODO/FIXME/NOTE highlighting
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("todo-comments").setup({
				signs = true,
				keywords = {
					FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
					TODO = { icon = " ", color = "info" },
					HACK = { icon = " ", color = "warning" },
					WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
					PERF = { icon = " ", color = "default", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
					NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
				},
			})

			-- Keybindings
			vim.keymap.set("n", "]t", function()
				require("todo-comments").jump_next()
			end, { desc = "Next todo comment" })
			vim.keymap.set("n", "[t", function()
				require("todo-comments").jump_prev()
			end, { desc = "Previous todo comment" })
			vim.keymap.set("n", "<leader>st", ":TodoTelescope<CR>", { desc = "Search todos" })
		end,
	},

	-- Better diagnostics UI
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("trouble").setup({
				auto_preview = false,
				focus = false,
				indent_guides = false,
				max_items = 120,
				multiline = false,
				open_no_results = false,
				win = {
					type = "split",
					position = "bottom",
					size = 10,
					wo = {
						foldcolumn = "0",
						number = false,
						relativenumber = false,
						signcolumn = "no",
						wrap = false,
						winhighlight = table.concat({
							"Normal:TroubleNormal",
							"NormalNC:TroubleNormalNC",
							"EndOfBuffer:TroubleNormal",
							"CursorLine:Visual",
							"WinSeparator:WinSeparator",
						}, ","),
					},
				},
				preview = {
					type = "float",
					border = "rounded",
					title = " Preview ",
					title_pos = "center",
					position = { 0, -2 },
					size = { width = 0.45, height = 0.35 },
					zindex = 200,
				},
				icons = {
					indent = {
						top = "  ",
						middle = "  ",
						last = "  ",
						fold_open = "▾ ",
						fold_closed = "▸ ",
						ws = "  ",
					},
				},
				modes = {
					diagnostics = {
						groups = {
							{ "filename", format = "{file_icon} {basename:Title} {count}" },
						},
					},
				},
			})

			vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
			vim.keymap.set(
				"n",
				"<leader>xd",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				{ desc = "Buffer Diagnostics (Trouble)" }
			)
			vim.keymap.set("n", "<leader>xl", "<cmd>Trouble loclist toggle<cr>", { desc = "Location List (Trouble)" })
			vim.keymap.set("n", "<leader>xp", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Problems" })
			vim.keymap.set("n", "<leader>xq", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix List (Trouble)" })
		end,
	},

	-- DAP (Debug Adapter Protocol)
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"theHamsta/nvim-dap-virtual-text",
			"nvim-neotest/nvim-nio",
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			-- Setup dap-ui
			dapui.setup({
				icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
				mappings = {
					expand = { "<CR>", "<2-LeftMouse>" },
					open = "o",
					remove = "d",
					edit = "e",
					repl = "r",
					toggle = "t",
				},
				layouts = {
					{
						elements = {
							{ id = "scopes", size = 0.25 },
							{ id = "breakpoints", size = 0.25 },
							{ id = "stacks", size = 0.25 },
							{ id = "watches", size = 0.25 },
						},
						size = 40,
						position = "left",
					},
					{
						elements = {
							{ id = "repl", size = 0.5 },
							{ id = "console", size = 0.5 },
						},
						size = 10,
						position = "bottom",
					},
				},
			})

			-- Setup virtual text
			require("nvim-dap-virtual-text").setup({
				enabled = true,
				enabled_commands = true,
				highlight_changed_variables = true,
				highlight_new_as_changed = false,
				show_stop_reason = true,
				commented = false,
			})

			-- Auto open/close dap-ui
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			-- Keybindings
			vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
			vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
			vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
			vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })
			vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
			vim.keymap.set("n", "<leader>dB", function()
				dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end, { desc = "Debug: Conditional Breakpoint" })
			vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Debug: Open REPL" })
			vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "Debug: Run Last" })
			vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Debug: Toggle UI" })
			vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "Debug: Terminate" })
		end,
	},

	-- Session persistence
	{
		"folke/persistence.nvim",
		event = "BufReadPre",
		config = function()
			require("persistence").setup({
				dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"),
				options = { "buffers", "curdir", "tabpages", "winsize" },
			})

			-- Keybindings
			vim.keymap.set("n", "<leader>Sl", function()
				require("persistence").load()
			end, { desc = "Restore session" })
			vim.keymap.set("n", "<leader>Ss", function()
				require("persistence").load({ last = true })
			end, { desc = "Restore last session" })
			vim.keymap.set("n", "<leader>Sd", function()
				require("persistence").stop()
			end, { desc = "Don't save session on exit" })
		end,
	},

	-- Project management
	{
		"ahmedkhalf/project.nvim",
		config = function()
			local function git_outermost_root(start_dir)
				if start_dir == "" then
					start_dir = vim.fn.getcwd()
				end

				local root = vim.fn.systemlist({ "git", "-C", start_dir, "rev-parse", "--show-toplevel" })[1]
				if vim.v.shell_error ~= 0 or root == nil or root == "" then
					return nil
				end

				while true do
					local superproject =
						vim.fn.systemlist({ "git", "-C", root, "rev-parse", "--show-superproject-working-tree" })[1]
					if vim.v.shell_error ~= 0 or superproject == nil or superproject == "" then
						return root
					end
					root = superproject
				end
			end

			require("project_nvim").setup({
				detection_methods = { "pattern", "lsp" },
				patterns = { ".git", "Makefile", "package.json", "Cargo.toml", "go.mod" },
				silent_chdir = false,
			})

			local project = require("project_nvim.project")
			local original_get_project_root = project.get_project_root
			project.get_project_root = function()
				local git_root = git_outermost_root(vim.fn.expand("%:p:h", true))
				if git_root ~= nil then
					return git_root, "git outermost root"
				end

				return original_get_project_root()
			end

			-- Integrate with telescope
			require("telescope").load_extension("projects")
			vim.keymap.set("n", "<leader>sp", ":Telescope projects<CR>", { desc = "Search projects" })
		end,
	},

	-- Symbol outline (like VSCode's outline)
	{
		"hedyhli/outline.nvim",
		config = function()
			require("outline").setup({
				outline_window = {
					position = "right",
					width = 25,
					relative_width = true,
					auto_close = false,
				},
				symbol_folding = {
					autofold_depth = 1,
					auto_unfold_hover = true,
				},
			})

			vim.keymap.set("n", "<leader>cs", ":Outline<CR>", { desc = "Toggle code outline" })
		end,
	},

	-- Incremental rename with preview
	{
		"smjonas/inc-rename.nvim",
		config = function()
			require("inc_rename").setup()
			vim.keymap.set("n", "<leader>rn", function()
				return ":IncRename " .. vim.fn.expand("<cword>")
			end, { expr = true, desc = "Incremental rename" })
		end,
	},

	-- Better quickfix/location list
	{
		"kevinhwang91/nvim-bqf",
		ft = "qf",
		config = function()
			require("bqf").setup({
				auto_resize_height = true,
				preview = {
					win_height = 12,
					win_vheight = 12,
					delay_syntax = 80,
					border = "rounded",
				},
			})
		end,
	},
	-- Terminal integration
	{
		"akinsho/toggleterm.nvim",
		config = function()
			require("toggleterm").setup({
				size = function(term)
					if term.direction == "horizontal" then
						return 15
					elseif term.direction == "vertical" then
						return vim.o.columns * 0.4
					end
				end,
				open_mapping = [[<C-\>]],
				hide_numbers = true,
				shade_terminals = true,
				shading_factor = 2,
				start_in_insert = true,
				insert_mappings = true,
				persist_size = true,
				direction = "horizontal",
				close_on_exit = true,
				shell = vim.o.shell,
				float_opts = {
					border = "curved",
					winblend = 0,
				},
			})

			-- Terminal keybindings
			function _G.set_terminal_keymaps()
				local opts = { buffer = 0 }
				vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
				vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
				vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
				vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
				vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
			end

			vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

			-- Specific terminal commands
			vim.keymap.set("n", "<leader>th", ":ToggleTerm direction=horizontal<CR>", { desc = "Terminal horizontal" })
			vim.keymap.set("n", "<leader>tv", ":ToggleTerm direction=vertical<CR>", { desc = "Terminal vertical" })
			vim.keymap.set("n", "<leader>tF", ":ToggleTerm direction=float<CR>", { desc = "Terminal float" })
		end,
	},

	-- Snacks.nvim - Collection of small utility plugins
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			input = {}, -- Better vim.ui.input
			picker = {}, -- Better vim.ui.select
			terminal = {}, -- Terminal management
		},
	},

	-- Better notification UI
	{
		"rcarriga/nvim-notify",
		config = function()
			local notify = require("notify")
			notify.setup({
				stages = "slide",
				timeout = 3000,
				background_colour = "NotifyBackground",
				minimum_width = 36,
				render = "wrapped-compact",
				icons = {
					ERROR = "",
					WARN = "",
					INFO = "",
					DEBUG = "",
					TRACE = "✎",
				},
			})
			vim.notify = notify
		end,
	},

	-- UI components library (required by some plugins)
	{
		"MunifTanjim/nui.nvim",
	},

	-- Better vim.ui interfaces
	{
		"stevearc/dressing.nvim",
		config = function()
			require("dressing").setup({
				input = {
					enabled = true,
					default_prompt = "-> ",
					border = "rounded",
					win_options = {
						winblend = 0,
						winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
					},
				},
				select = {
					enabled = true,
					backend = { "telescope", "builtin" },
					telescope = require("telescope.themes").get_dropdown({
						winblend = 0,
					}),
					builtin = {
						border = "rounded",
						win_options = {
							winblend = 0,
							winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
						},
					},
				},
			})
		end,
	},

	-- Illuminate word under cursor
	{
		"RRethy/vim-illuminate",
		config = function()
			require("illuminate").configure({
				providers = {
					"lsp",
					"treesitter",
					"regex",
				},
				delay = 100,
				filetypes_denylist = {
					"dirvish",
					"fugitive",
					"alpha",
					"NvimTree",
					"lazy",
					"neogitstatus",
					"Trouble",
					"lir",
					"Outline",
					"spectre_panel",
					"toggleterm",
					"DressingSelect",
					"TelescopePrompt",
				},
				under_cursor = true,
			})
		end,
	},

	-- Breadcrumbs (show code context in winbar)
	{
		"SmiteshP/nvim-navic",
		dependencies = { "neovim/nvim-lspconfig" },
		config = function()
			require("nvim-navic").setup({
				icons = {
					File = " ",
					Module = " ",
					Namespace = " ",
					Package = " ",
					Class = " ",
					Method = " ",
					Property = " ",
					Field = " ",
					Constructor = " ",
					Enum = " ",
					Interface = " ",
					Function = " ",
					Variable = " ",
					Constant = " ",
					String = " ",
					Number = " ",
					Boolean = " ",
					Array = " ",
					Object = " ",
					Key = " ",
					Null = " ",
					EnumMember = " ",
					Struct = " ",
					Event = " ",
					Operator = " ",
					TypeParameter = " ",
				},
				highlight = true,
				separator = " > ",
				depth_limit = 0,
				depth_limit_indicator = "..",
				safe_output = true,
			})
		end,
	},

	-- Snippets
	{
		"L3MON4D3/LuaSnip",
		dependencies = {
			"rafamadriz/friendly-snippets", -- Collection of common snippets
		},
		config = function()
			require("luasnip.loaders.from_vscode").lazy_load()

			-- Jump forward/backward in snippets
			vim.keymap.set({ "i", "s" }, "<C-k>", function()
				local ls = require("luasnip")
				if ls.expand_or_jumpable() then
					ls.expand_or_jump()
				end
			end, { desc = "Snippet jump forward" })

			vim.keymap.set({ "i", "s" }, "<C-j>", function()
				local ls = require("luasnip")
				if ls.jumpable(-1) then
					ls.jump(-1)
				end
			end, { desc = "Snippet jump backward" })
		end,
	},

	-- Autocompletion
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp", -- LSP completion source
			"hrsh7th/cmp-buffer", -- Buffer completion source
			"hrsh7th/cmp-path", -- Path completion source
			"hrsh7th/cmp-cmdline", -- Command line completion
			"L3MON4D3/LuaSnip", -- Snippet engine
			"saadparwaiz1/cmp_luasnip", -- Snippet completion source
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-p>"] = cmp.mapping.select_prev_item(),
					["<C-d>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp", priority = 1000 },
					{ name = "luasnip", priority = 750 },
					{ name = "buffer", priority = 500 },
					{ name = "path", priority = 250 },
				}),
				window = {
					completion = cmp.config.window.bordered({
						border = "rounded",
						winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
					}),
					documentation = cmp.config.window.bordered({
						border = "rounded",
						winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
					}),
				},
				formatting = {
					format = function(entry, vim_item)
						-- Kind icons
						local kind_icons = {
							Text = "",
							Method = "󰆧",
							Function = "󰊕",
							Constructor = "",
							Field = "󰇽",
							Variable = "󰂡",
							Class = "󰠱",
							Interface = "",
							Module = "",
							Property = "󰜢",
							Unit = "",
							Value = "󰎠",
							Enum = "",
							Keyword = "󰌋",
							Snippet = "",
							Color = "󰏘",
							File = "󰈙",
							Reference = "",
							Folder = "󰉋",
							EnumMember = "",
							Constant = "󰏿",
							Struct = "",
							Event = "",
							Operator = "󰆕",
							TypeParameter = "󰅲",
						}
						vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind], vim_item.kind)
						vim_item.menu = ({
							nvim_lsp = "[LSP]",
							luasnip = "[Snippet]",
							buffer = "[Buffer]",
							path = "[Path]",
						})[entry.source.name]
						return vim_item
					end,
				},
			})

			-- Command line completion
			cmp.setup.cmdline("/", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
			})

			-- Integrate autopairs with cmp
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},

	-- Auto close brackets, quotes, etc.
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup({
				check_ts = true, -- Enable treesitter integration
				ts_config = {
					lua = { "string" },
					javascript = { "template_string" },
				},
				fast_wrap = {
					map = "<M-e>",
					chars = { "{", "[", "(", '"', "'" },
					pattern = [=[[%'%"%)%>%]%)%}%,]]=],
					end_key = "$",
					keys = "qwertyuiopzxcvbnmasdfghjkl",
					check_comma = true,
					highlight = "Search",
					highlight_grey = "Comment",
				},
			})
		end,
	},

	-- Function signature help
	{
		"ray-x/lsp_signature.nvim",
		event = "VeryLazy",
		config = function()
			require("lsp_signature").setup({
				bind = true,
				handler_opts = {
					border = "rounded",
				},
				floating_window = true,
				floating_window_above_cur_line = true,
				hint_enable = true,
				hint_prefix = "-> ",
				hi_parameter = "LspSignatureActiveParameter",
				max_height = 12,
				max_width = 80,
				toggle_key = "<C-s>",
				select_signature_key = "<M-n>",
			})
		end,
	},

	-- Mason + LSP config (consolidated for proper load order)
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			-- Mason must be set up before mason-lspconfig
			{
				"williamboman/mason.nvim",
				config = function()
					require("mason").setup({
						ui = {
							border = "rounded",
							icons = {
								package_installed = "✓",
								package_pending = "➜",
								package_uninstalled = "✗",
							},
						},
						max_concurrent_installers = 4,
					})
				end,
			},
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			-- Configure diagnostics display
			vim.diagnostic.config({
				virtual_text = {
					prefix = "●",
					source = "if_many",
					spacing = 4,
				},
				signs = true,
				underline = true,
				update_in_insert = false,
				severity_sort = true,
				float = {
					border = "rounded",
					source = "always",
					header = { " Diagnostics ", "FloatTitle" },
					prefix = "● ",
				},
			})

			-- Diagnostic signs
			local signs = { Error = "●", Warn = "●", Hint = "●", Info = "●" }
			for type, icon in pairs(signs) do
				local hl = "DiagnosticSign" .. type
				vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
			end

			-- Default LSP capabilities with nvim-cmp support
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Common on_attach function for all LSP servers
			local on_attach = function(client, bufnr)
				local map = function(keys, func, desc)
					vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
				end

				-- Attach navic if available
				if client.server_capabilities.documentSymbolProvider then
					local navic_ok, navic = pcall(require, "nvim-navic")
					if navic_ok then
						navic.attach(client, bufnr)
					end
				end

				-- Standard LSP keybindings (following Neovim conventions)
				map("gd", vim.lsp.buf.definition, "Go to definition")
				map("gD", vim.lsp.buf.declaration, "Go to declaration")
				map("gr", vim.lsp.buf.references, "Go to references")
				map("gI", vim.lsp.buf.implementation, "Go to implementation")
				map("gy", vim.lsp.buf.type_definition, "Go to type definition")
				map("K", function()
					local ufo_ok, ufo = pcall(require, "ufo")
					if ufo_ok then
						local winid = ufo.peekFoldedLinesUnderCursor()
						if winid then
							return
						end
					end
					vim.lsp.buf.hover()
				end, "Peek fold or hover")

				-- LSP leader group (LunarVim style: <leader>l prefix)
				map("<leader>la", vim.lsp.buf.code_action, "Code action")
				map("<leader>lr", vim.lsp.buf.rename, "Rename")
				map("<leader>li", "<cmd>LspInfo<cr>", "LSP info")
				map("<leader>lI", "<cmd>Mason<cr>", "Mason info")
				map("<leader>lj", function()
					vim.diagnostic.jump({ count = 1, float = true })
				end, "Next diagnostic")
				map("<leader>lk", function()
					vim.diagnostic.jump({ count = -1, float = true })
				end, "Prev diagnostic")
				map("<leader>ld", "<cmd>Telescope diagnostics bufnr=0<cr>", "Buffer diagnostics")
				map("<leader>lw", "<cmd>Telescope diagnostics<cr>", "Diagnostics")
				map("<leader>ls", "<cmd>Telescope lsp_document_symbols<cr>", "Document symbols")
				map("<leader>lS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "Workspace symbols")
				map("<leader>lq", vim.diagnostic.setloclist, "Quickfix")
				-- Format is available globally via <leader>f

				-- Diagnostics navigation (standard bracket mappings)
				map("[d", function()
					vim.diagnostic.jump({ count = -1, float = true })
				end, "Previous diagnostic")
				map("]d", function()
					vim.diagnostic.jump({ count = 1, float = true })
				end, "Next diagnostic")
				map("<leader>cd", vim.diagnostic.open_float, "Show diagnostic")

				-- Inlay hints (Neovim 0.10+)
				if client.supports_method and client:supports_method("textDocument/inlayHint") then
					pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })
					map("<leader>ti", function()
						local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
						vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
					end, "Toggle inlay hints")
				end
			end

			-- Server-specific settings
			local server_settings = {
				lua_ls = {
					settings = {
						Lua = {
							diagnostics = {
								globals = { "vim" },
							},
							workspace = {
								library = vim.api.nvim_get_runtime_file("", true),
								checkThirdParty = false,
							},
							telemetry = {
								enable = false,
							},
						},
					},
				},
				pyright = {
					settings = {
						python = {
							analysis = {
								typeCheckingMode = "basic",
								autoSearchPaths = true,
								useLibraryCodeForTypes = true,
							},
						},
					},
				},
				gopls = {
					settings = {
						gopls = {
							analyses = {
								unusedparams = true,
							},
							staticcheck = true,
						},
					},
				},
				rust_analyzer = {
					settings = {
						["rust-analyzer"] = {
							checkOnSave = {
								command = "clippy",
							},
						},
					},
				},
			}

			-- LSP servers to automatically install
			local ensure_installed = {
				"lua_ls", -- Lua
				"ts_ls", -- TypeScript/JavaScript
				"pyright", -- Python
				"gopls", -- Go
				"rust_analyzer", -- Rust
				"html", -- HTML
				"cssls", -- CSS
				"jsonls", -- JSON
				"yamlls", -- YAML
				"bashls", -- Bash
			}

			-- Setup mason-lspconfig
			require("mason-lspconfig").setup({
				ensure_installed = ensure_installed,
				automatic_installation = true,
				handlers = {
					-- Default handler for all servers
					function(server_name)
						local config = {
							capabilities = capabilities,
							on_attach = on_attach,
						}

						-- Merge server-specific settings if they exist
						if server_settings[server_name] then
							config = vim.tbl_deep_extend("force", config, server_settings[server_name])
						end

						require("lspconfig")[server_name].setup(config)
					end,
				},
			})

			-- Keybinding to open Mason
			vim.keymap.set("n", "<leader>cm", ":Mason<CR>", { desc = "Open Mason" })
		end,
	},

	-- Auto-install formatters/linters/DAPs via Mason
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = {
					-- Formatters
					"stylua", -- Lua
					"prettierd", -- JS/TS/JSON/CSS/HTML/MD/YAML
					"shfmt", -- Shell
					"ruff", -- Python (formatter + linter)
					-- Linters
					"eslint_d", -- JS/TS
					"shellcheck", -- Shell
				},
				auto_update = false,
				run_on_start = true,
			})
		end,
	},

	-- Conform: declarative formatting per filetype
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					lua = { "stylua" },
					javascript = { "prettierd", "prettier", stop_after_first = true },
					typescript = { "prettierd", "prettier", stop_after_first = true },
					javascriptreact = { "prettierd", "prettier", stop_after_first = true },
					typescriptreact = { "prettierd", "prettier", stop_after_first = true },
					json = { "prettierd", "prettier", stop_after_first = true },
					jsonc = { "prettierd", "prettier", stop_after_first = true },
					yaml = { "prettierd", "prettier", stop_after_first = true },
					html = { "prettierd", "prettier", stop_after_first = true },
					css = { "prettierd", "prettier", stop_after_first = true },
					markdown = { "prettierd", "prettier", stop_after_first = true },
					python = { "ruff_format", "ruff_organize_imports" },
					sh = { "shfmt" },
					bash = { "shfmt" },
					go = { "gofmt" },
					rust = { "rustfmt" },
				},
				format_on_save = function(bufnr)
					local autoformat = vim.b[bufnr].autoformat
					if autoformat == nil then
						autoformat = vim.g.autoformat
					end
					if autoformat == false then
						return
					end
					return { timeout_ms = 2000, lsp_format = "fallback" }
				end,
			})

			vim.keymap.set({ "n", "v" }, "<leader>f", function()
				require("conform").format({ async = true, lsp_format = "fallback" })
			end, { desc = "Format buffer" })
		end,
	},

	-- nvim-lint: standalone linters not provided by LSP
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPost", "BufNewFile", "BufWritePost" },
		config = function()
			local lint = require("lint")
			lint.linters_by_ft = {
				javascript = { "eslint_d" },
				typescript = { "eslint_d" },
				javascriptreact = { "eslint_d" },
				typescriptreact = { "eslint_d" },
				python = { "ruff" },
				sh = { "shellcheck" },
				bash = { "shellcheck" },
			}

			local grp = vim.api.nvim_create_augroup("nvim_lint", { clear = true })
			vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
				group = grp,
				callback = function()
					lint.try_lint()
				end,
			})
		end,
	},

	-- Flash: label-based jump motion
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {},
		keys = {
			{
				"s",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash",
			},
			{
				"S",
				mode = { "n", "x", "o" },
				function()
					require("flash").treesitter()
				end,
				desc = "Flash Treesitter",
			},
			{
				"r",
				mode = "o",
				function()
					require("flash").remote()
				end,
				desc = "Remote Flash",
			},
			{
				"R",
				mode = { "o", "x" },
				function()
					require("flash").treesitter_search()
				end,
				desc = "Treesitter Search",
			},
			{
				"<C-s>",
				mode = { "c" },
				function()
					require("flash").toggle()
				end,
				desc = "Toggle Flash Search",
			},
		},
	},

	-- Harpoon: pinned-file fast switching
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local harpoon = require("harpoon")
			harpoon:setup({})

			vim.keymap.set("n", "<leader>a", function()
				harpoon:list():add()
			end, { desc = "Harpoon: add file" })
			vim.keymap.set("n", "<C-e>", function()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end, { desc = "Harpoon: menu" })

			for i = 1, 4 do
				vim.keymap.set("n", "<leader>" .. i, function()
					harpoon:list():select(i)
				end, { desc = "Harpoon: file " .. i })
			end

			-- Cycle pinned files (avoid <leader>h* — owned by gitsigns hunks)
			vim.keymap.set("n", "<M-n>", function()
				harpoon:list():next()
			end, { desc = "Harpoon: next" })
			vim.keymap.set("n", "<M-p>", function()
				harpoon:list():prev()
			end, { desc = "Harpoon: prev" })
		end,
	},

	-- Right-side overview bar for cursor, diagnostics, git hunks, and search.
	{
		"lewis6991/satellite.nvim",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("satellite").setup({
				current_only = true,
				winblend = 0,
				zindex = 40,
				excluded_filetypes = {
					"alpha",
					"dashboard",
					"DiffviewFiles",
					"lazy",
					"mason",
					"NvimTree",
					"qf",
					"TelescopePrompt",
					"Trouble",
					"toggleterm",
				},
				handlers = {
					cursor = {
						enable = true,
						overlap = true,
						priority = 100,
						symbols = { "█" },
					},
					search = {
						enable = true,
						overlap = true,
						priority = 70,
						symbols = { "█" },
					},
					diagnostic = {
						enable = true,
						overlap = true,
						priority = 80,
						min_severity = vim.diagnostic.severity.HINT,
						signs = {
							error = { "█" },
							warn = { "█" },
							info = { "█" },
							hint = { "█" },
						},
					},
					gitsigns = {
						enable = true,
						overlap = false,
						priority = 30,
						signs = {
							add = "█",
							change = "█",
							delete = "█",
						},
					},
					marks = {
						enable = false,
					},
					quickfix = {
						enable = false,
					},
				},
			})

			local enabled = true
			vim.keymap.set("n", "<leader>tm", function()
				if enabled then
					vim.cmd("SatelliteDisable")
				else
					vim.cmd("SatelliteEnable")
				end
				enabled = not enabled
			end, { desc = "Toggle overview bar" })
			vim.keymap.set("n", "<leader>tr", "<cmd>SatelliteRefresh<cr>", { desc = "Refresh overview bar" })
		end,
	},

	-- nvim-ufo: better folding using treesitter
	{
		"kevinhwang91/nvim-ufo",
		dependencies = { "kevinhwang91/promise-async" },
		event = "BufReadPost",
		config = function()
			vim.opt.foldcolumn = "0"
			vim.opt.foldlevel = 99
			vim.opt.foldlevelstart = 99
			vim.opt.foldenable = true
			vim.opt.fillchars:append({ fold = " ", foldopen = "▾", foldclose = "▸", foldsep = " " })

			require("ufo").setup({
				provider_selector = function()
					return { "treesitter", "indent" }
				end,
			})

			vim.keymap.set("n", "zR", function()
				require("ufo").openAllFolds()
			end, { desc = "Open all folds" })
			vim.keymap.set("n", "zM", function()
				require("ufo").closeAllFolds()
			end, { desc = "Close all folds" })
			vim.keymap.set("n", "zr", function()
				require("ufo").openFoldsExceptKinds()
			end, { desc = "Open folds except kinds" })
			vim.keymap.set("n", "K", function()
				local winid = require("ufo").peekFoldedLinesUnderCursor()
				if not winid then
					vim.lsp.buf.hover()
				end
			end, { desc = "Peek fold or hover" })
		end,
	},
})

-- ============================================================================
-- Quality of Life Improvements
-- ============================================================================

-- Disable annoying beeps
vim.opt.errorbells = false
vim.opt.visualbell = true

-- Better command line completion
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"

-- Make substitution preview live
vim.opt.inccommand = "split"

-- Enable spell checking for certain file types
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "gitcommit", "markdown", "text" },
	callback = function()
		vim.opt_local.spell = true
	end,
})
