local ui_colors = require("config.colors").ui_colors
local apply_kitty_highlights = require("config.colors").apply_kitty_highlights
local close_buffer = require("config.buffers").close_buffer

return {
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
}
