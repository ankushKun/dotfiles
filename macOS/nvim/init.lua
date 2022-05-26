--                        _      _        _           _         _  _            _
--                       | |    | |      | |         (_)       (_)| |          (_)
--  __      __ ___   ___ | |__  | |  ___ | |_  ___    _  _ __   _ | |_  __   __ _  _ __ ____
--  \ \ /\ / // _ \ / _ \| '_ \ | | / _ \| __|/ __|  | || '_ \ | || __| \ \ / /| || '_ ` _  \
--   \ V  V /|  __/|  __/| |_) || ||  __/| |_ \__ \  | || | | || || |_  _\ V / | || | | | | |
--    \_/\_/  \___| \___||_.__/ |_| \___| \__||___/  |_||_| |_||_| \__|(_)\_/  |_||_| |_| |_|
--
--
-- Vim options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.textwidth = 99999
vim.opt.wrap = false
vim.opt.linebreak = false
vim.opt.termguicolors = true
vim.opt.showmode = false
vim.opt.scrolloff = 5
vim.opt.sidescrolloff = 10
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.smarttab = true
vim.opt.clipboard = "unnamedplus"

-- Neovide options
if (vim.fn.exists('neovide') == 1) then
    vim.g.neovide_transparency = 0.9
    vim.g.neovide_input_use_logo = 1
    vim.opt.guifont = "MesloLGS NF"
end

-- custom command to open config
vim.cmd(':command! Config e ~/.config/nvim/init.lua')

--------------------------------------------------------------------
--                            PLUGINS                             --
--------------------------------------------------------------------
require('packer').startup(function()
    use 'wbthomason/packer.nvim'
    use { 'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons' }
    }
    use 'akinsho/bufferline.nvim'
    use 'ghifarit53/tokyonight-vim'
    use 'nvim-treesitter/nvim-treesitter'
    use { 'williamboman/nvim-lsp-installer',
        { 'neovim/nvim-lspconfig' }
    }
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-cmdline'
    use 'hrsh7th/nvim-cmp'
    use { 'kyazdani42/nvim-tree.lua',
        requires = { 'kyazdani42/nvim-web-devicons' }
    }
    use { 'romgrk/barbar.nvim',
        requires = { 'kyazdani42/nvim-web-devicons' }
    }
    use 'glepnir/dashboard-nvim'
    use { 'nvim-telescope/telescope.nvim',
        requires = { 'nvim-lua/plenary.nvim' }
    }
    -- use 'vimsence/vimsence'
    use 'andweeb/presence.nvim'
    use 'github/copilot.vim'
    use 'JoosepAlviste/nvim-ts-context-commentstring'
    use 'tpope/vim-commentary'
    use 'L3MON4D3/LuaSnip'
    use 'wakatime/vim-wakatime'
    use { "akinsho/toggleterm.nvim", tag = 'v1.*',
        config = function()  end
    }
    use { 'iamcco/markdown-preview.nvim', run = 'cd app && npm install' }
    use 'seandewar/killersheep.nvim'
    use 'alec-gibson/nvim-tetris'
    use 'mg979/vim-visual-multi'
    use 'folke/which-key.nvim'
    -- use 'OmniSharp/omnisharp-vim'
end)


--================================================================--
--                         CONFIGS                                --
--================================================================--


--------------------------------------------------------------------
--                       COLORSCHEME                              --
--------------------------------------------------------------------
vim.g.tokyonight_enable_italic = true
vim.g.tokyonight_transparent_background = true
if (vim.fn.exists('neovide') == 1) then
    vim.g.tokyonight_transparent_background = false
end
vim.cmd('colorscheme tokyonight')

--------------------------------------------------------------------
--                         LUALINE                                --
--------------------------------------------------------------------
require('lualine').setup({
    options = { globalstatus = true },
})

--------------------------------------------------------------------
--                     CMP COMPLETION                             --
--------------------------------------------------------------------
vim.g.completeopt = "menu,menuone,noselect,noinsert"
local cmp = require 'cmp'
cmp.setup({
    snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
            require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        end
    },
    mapping = cmp.mapping.preset.insert({
        --    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        --    ['<C-f>'] = cmp.mapping.scroll_docs(4),
        --    ['<C-Space>'] = cmp.mapping.complete(),
        --    ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ['<Tab>'] = function(fallback)
            local luasnip = require('luasnip')
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end,
        ['<S-Tab>'] = function(fallback)
            local luasnip = require('luasnip')
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end,
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' }
    }),
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
        { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
        { name = 'buffer' },
    })
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    })
})

--------------------------------------------------------------------
--                           LSP                                  --
--------------------------------------------------------------------
require('nvim-lsp-installer').setup {
    automatic_installation = true
}

local lspconfig = require("lspconfig")
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
lspconfig.sumneko_lua.setup {
    capabilities = capabilities,
    settings = {
        Lua = {
            diagnostics = {
                globals = { "vim", "use" },
                disable = { "lowercase-global" }
            }
        }
    }
}
lspconfig.pyright.setup { capabilities = capabilities }
lspconfig.omnisharp.setup {
    cmd = {"mono", "/Users/ankush/.local/share/nvim/lsp_servers/omnisharp/omnisharp-mono/OmniSharp.exe", "--languageserver", "--hostPID", tostring(vim.fn.getpid())},
    root_dir = lspconfig.util.root_pattern("*.sln");
    capabilities = capabilities,
    use_mono = true
}
lspconfig.tsserver.setup { capabilities = capabilities }
lspconfig.yamlls.setup { capabilities = capabilities }
lspconfig.html.setup { capabilities = capabilities }
lspconfig.cssls.setup { capabilities = capabilities }

--------------------------------------------------------------------
--                        TREESITTER                              --
--------------------------------------------------------------------
require('nvim-treesitter.configs').setup({
    highlight = {
        enable = true
    },
    indent = {
        enable = true
    },
    context_commentstring = {
        enable = true,
        config = {
            javascript = {
                __default = '// %s',
                jsx_element = '{/* %s */}',
                jsx_fragment = '{/* %s */}',
                jsx_attribute = '// %s',
                comment = '// %s'
            },
            csharp = {
                __default = '// %s',
                comment = '// %s'
            },
        }
    }
})

--------------------------------------------------------------------
--                          NVIMTREE                              --
--------------------------------------------------------------------
require('nvim-tree').setup()

--------------------------------------------------------------------
--                         BUFFERLINE                             --
--------------------------------------------------------------------
require('bufferline').setup() -- gives errors


--------------------------------------------------------------------
--                         TELESCOPE                              --
--------------------------------------------------------------------
require('telescope').setup {
    defaults = {
        show_hidden = true,
        previewer = true,
        preview_cutoff = 1,
        shorten_path = true,
        layout_strategy = 'flex',
    }
}

--------------------------------------------------------------------
--                        DASHBOARD                               --
--------------------------------------------------------------------
vim.g.dashboard_default_executive = 'telescope'
vim.g.dashboard_custom_header = {
    [[                       .,,uod8B8bou,,.                                ]],
    [[              ..,uod8BBBBBBBBBBBBBBBBRPFT?l!i:.                       ]],
    [[         ,=m8BBBBBBBBBBBBBBBRPFT?!||||||||||||||                      ]],
    [[         !...:!TVBBBRPFT||||||||||!!^^""'   ||||                      ]],
    [[         !.......:!?|||||!!^^""'            ||||                      ]],
    [[         !.........||||                     ||||                      ]],
    [[         !.........||||  ## >_              ||||                      ]],
    [[         !.........||||                     ||||                      ]],
    [[         !.........||||                     ||||                      ]],
    [[         !.........||||                     ||||                      ]],
    [[         !.........||||                     ||||                      ]],
    [[         `.........||||                    ,||||                      ]],
    [[          .;.......||||               _.-!!|||||                      ]],
    [[   .,uodWBBBBb.....||||       _.-!!|||||||||!:'                       ]],
    [[!YBBBBBBBBBBBBBBb..!|||:..-!!|||||||!iof68BBBBBb....                  ]],
    [[!..YBBBBBBBBBBBBBBb!!||||||||!iof68BBBBBBRPFT?!::   `.                ]],
    [[!....YBBBBBBBBBBBBBBbaaitf68BBBBBBRPFT?!:::::::::     `.              ]],
    [[!......YBBBBBBBBBBBBBBBBBBBRPFT?!::::::;:!^"`;:::       `.            ]],
    [[!........YBBBBBBBBBBRPFT?!::::::::::^''...::::::;         iBBbo.      ]],
    [[`..........YBRPFT?!::::::::::::::::::::::::;iof68bo.      WBBBBbo.    ]],
    [[  `..........:::::::::::::::::::::::;iof688888888888b.     `YBBBP^'   ]],
    [[    `........::::::::::::::::;iof688888888888888888888b.     `        ]],
    [[      `......:::::::::;iof688888888888888888888888888888b.            ]],
    [[        `....:::;iof688888888888888888888888888888888899fT!           ]],
    [[          `..::!8888888888888888888888888888888899fT|!^"'             ]],
    [[            `' !!988888888888888888888888899fT|!^"'                   ]],
    [[                `!!8888888888888888899fT|!^"'                         ]],
    [[                  `!988888888899fT|!^"'                               ]],
    [[                    `!9899fT|!^"'                                     ]],
    [[                      `!^"'                                           ]] }

vim.g.dashboard_custom_section = {
    a = { description = { '  Find Files     ' }, command = ':Telescope find_files' },
    b = { description = { '  Recent Files   ' }, command = ':Telescope oldfiles' },
    c = { description = { '  Config         ' }, command = ':e ~/.config/nvim/init.lua' },
}
vim.g.dashboard_custom_footer = { 'Waste 100 hours to save 1 hour - Vim Philosophy' }

--------------------------------------------------------------------
--                      MARKDOWN PREVIEW                          --
--------------------------------------------------------------------
vim.g.mkdp_command_for_global = 1
vim.g.mkdp_auto_close = 0
vim.g.mkdp_echo_preview_url = 1

--------------------------------------------------------------------
--                      GITHUB COPILOT                            --
--------------------------------------------------------------------
vim.cmd('imap <silent><script><expr> <C-Tab> copilot#Accept("")') -- <C-Tab> works in Neovide
vim.g.copilot_no_tab_map = true

--------------------------------------------------------------------
--                        TOGGLETERM                              --
--------------------------------------------------------------------
require("toggleterm").setup()

--------------------------------------------------------------------
--                       OMNISHARP                                --
--------------------------------------------------------------------
-- maps Tab to <C-x><C-o> for autocompletion using Omnisharp,
-- also lets you use Tab if the cursor is on a whitespace
-- vim.g.OmniSharp_server_stdio = 1
-- vim.g.OmniSharp_server_use_mono = 1
-- vim.cmd([[autocmd FileType cs inoremap <expr> <Tab> pumvisible() ? '<C-n>' : getline('.')[col('.')-2] =~# '[[:alnum:].-_#$]' ? '<C-x><C-o>' : '<Tab>']])

--================================================================--
--                            KEYBINDS                            --
--================================================================--

vim.g.mapleader = " " -- Set <Leader> to space

-- Functional wrapper for mapping custom keybindings
function map(mode, lhs, rhs, opts)
    local options = { noremap = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

map("n", "<Leader>q", ":q<CR>") -- quite current budder
map("n", "<Leader>w", ":w<CR>") -- Write current buffer
map("n", "<Leader>c", ":BufferClose<CR>") -- Close buffer
map("n", "<Leader>e", ":NvimTreeToggle<CR>") -- Toggle file explorer
map("n", "<Leader>ps", ":PackerSync<CR>") -- Packer Sync
map("n", "<Leader>tf", ":ToggleTerm direction='float'<CR>") -- Open floating terminal
map("n", "<Leader>th", ":ToggleTerm<CR>") -- Open horizontal terminal
map("t", "<Esc>", [[<C-\><C-n>:ToggleTerm<CR>]]) -- Close terminal
map("n", "<Leader>h", ":noh<CR>") -- No highlight
map("n", "<Leader>ld", ":lua vim.lsp.diagnostic.show_line_diagnostics()<CR>") -- code diagnostics
map("n", "<Leader>lf", ":lua vim.lsp.buf.formatting()<CR>") -- format code
map("n", "<Leader>lD", ":lua vim.lsp.buf.definition()<CR>") -- goto definition
map("n", "<C-p>", ":MarkdownPreviewToggle<CR>") -- Markdown preview
map("n", "L", ":BufferNext<CR>") -- Buffer previous
map("n", "H", ":BufferPrevious<CR>") -- buffer next
