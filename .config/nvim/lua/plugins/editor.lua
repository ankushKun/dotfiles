local ui_colors = require("config.colors").ui_colors
local apply_kitty_highlights = require("config.colors").apply_kitty_highlights
local close_buffer = require("config.buffers").close_buffer

return {
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
}
