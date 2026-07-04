local ui_colors = require("config.colors").ui_colors
local apply_kitty_highlights = require("config.colors").apply_kitty_highlights
local close_buffer = require("config.buffers").close_buffer

return {
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
}
