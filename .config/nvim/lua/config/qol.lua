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
