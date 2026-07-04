local ui_colors = require("config.colors").ui_colors
local apply_kitty_highlights = require("config.colors").apply_kitty_highlights
local close_buffer = require("config.buffers").close_buffer

return {
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
}
