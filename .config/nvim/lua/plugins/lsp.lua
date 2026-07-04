local ui_colors = require("config.colors").ui_colors
local apply_kitty_highlights = require("config.colors").apply_kitty_highlights
local close_buffer = require("config.buffers").close_buffer

return {
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
}
