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
