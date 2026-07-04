local ui_colors = require("config.colors").ui_colors
local apply_kitty_highlights = require("config.colors").apply_kitty_highlights
local close_buffer = require("config.buffers").close_buffer

return {
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
}
