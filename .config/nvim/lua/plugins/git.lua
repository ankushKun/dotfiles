local ui_colors = require("config.colors").ui_colors
local apply_kitty_highlights = require("config.colors").apply_kitty_highlights
local close_buffer = require("config.buffers").close_buffer

return {
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
}
