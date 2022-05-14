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
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.textwidth = 169
vim.opt.wrap = false
vim.opt.termguicolors = true
vim.opt.showmode = false
vim.opt.scrolloff = 5
vim.opt.sidescrolloff = 5
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.smarttab = true
vim.opt.clipboard = "unnamedplus"
                                                                      -- Neovide options
if (vim.fn.exists('neovide') == 1) then
  vim.g.neovide_transparency = 0.9
  vim.opt.guifont = "MesloLGS NF"
end

-- custom command to open config
vim.cmd(':command! Config e ~/.config/nvim/init.lua')

--------------------------------------------------------------------
--                            PLUGINS                             --
--------------------------------------------------------------------

                                                                      -- Packer install plugins
require('packer').startup(function()
  use 'wbthomason/packer.nvim'
  use {'nvim-lualine/lualine.nvim',
    requires = {'kyazdani42/nvim-web-devicons'}
  }
  use 'akinsho/bufferline.nvim'
  use 'ghifarit53/tokyonight-vim'
  use 'nvim-treesitter/nvim-treesitter'
  use {'williamboman/nvim-lsp-installer',
      {'neovim/nvim-lspconfig'}
  }
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/nvim-cmp'
  use {'kyazdani42/nvim-tree.lua',
    requires = {'kyazdani42/nvim-web-devicons'}
  }
  use {'romgrk/barbar.nvim',
    requires = {'kyazdani42/nvim-web-devicons'}
  }
  use 'glepnir/dashboard-nvim'
  use {'nvim-telescope/telescope.nvim',
    requires = {'nvim-lua/plenary.nvim'}
  }
  use 'arkav/lualine-lsp-progress'
  use 'vimsence/vimsence'
  use 'github/copilot.vim'
  use 'tpope/vim-commentary'
  use 'L3MON4D3/LuaSnip'
  use 'wakatime/vim-wakatime'
  -- use {'OmniSharp/omnisharp-vim'}
  use {"akinsho/toggleterm.nvim", tag = 'v1.*', config = function()
    require("toggleterm").setup()
  end}
  use {'iamcco/markdown-preview.nvim', run='cd app && npm install'}
  -- use {'ggandor/lightspeed.nvim'}
  use 'seandewar/killersheep.nvim'
  use 'alec-gibson/nvim-tetris'
end)
                                                                      -- Colorscheme config
vim.g.tokyonight_enable_italic = true
vim.g.tokyonight_transparent_background = true
if (vim.fn.exists('neovide') == 1) then
  vim.g.tokyonight_transparent_background = false
end
vim.cmd('colorscheme tokyonight')
        config = function()
            require('lualine').setup({
            options = { globalstatus = true },
            sections = { lualine_c = { 'lsp_progress' } }
        })
        end


                                                                      -- Setup nvim-cmp.
vim.g.completeopt="menu,menuone,noselect,noinsert"
local cmp = require'cmp'
cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
      -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
    end,
  },
  mapping = cmp.mapping.preset.insert({
--    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
--    ['<C-f>'] = cmp.mapping.scroll_docs(4),
--    ['<C-Space>'] = cmp.mapping.complete(),
--    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
--    { name = 'vsnip' }, -- For vsnip users.
    -- { name = 'luasnip' }, -- For luasnip users.
    -- { name = 'ultisnips' }, -- For ultisnips users.
    -- { name = 'snippy' }, -- For snippy users.
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

                                                                      -- LSP config
require('nvim-lsp-installer').setup {
  -- automatic_installation = true
}

local lspconfig = require("lspconfig")
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
lspconfig.sumneko_lua.setup {
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = {
        globals = {"vim", "use"},
        disable = {"lowercase-global"}
      }
    }
  }
}
lspconfig.pyright.setup { capabilities = capabilities }
lspconfig.omnisharp.setup {
  ---------------------------------------------
  --              Installation               --
  -- brew tap                                --
  -- brew uninstall mono                     --
  -- brew install omnisharp/omnisharp-roslyn --
  ---------------------------------------------
  filetypes = {'cs'},
  cmd = {"/usr/local/bin/omnisharp", "-lsp", "--hostPID", tostring(vim.fn.getpid())},
  root_dir = lspconfig.util.root_pattern("*.sln");
  capabilities = capabilities
}
lspconfig.tsserver.setup { capabilities = capabilities }
lspconfig.yamlls.setup { capabilities = capabilities }

                                                                    -- Treesitter config
require('nvim-treesitter.configs').setup({
  highlight = {
    enable = true
  },
  indent = {
    enable = true
  }
})
                                                                      -- File explorer config
require('nvim-tree').setup()
                                                                      -- Bufferline config
-- require('bufferline').setup() -- gives errors
                                                                      -- Nvim lsp config
require('nvim-lsp-installer').setup()

                                                                      -- Telescope config
require('telescope').setup {
  defaults = {
    show_hidden = true,
    previewer = true,
    preview_cutoff = 1,
    shorten_path = true,
    layout_strategy = 'flex',
  }
}

                                                                      -- Dashboard config
vim.g.dashboard_default_executive = 'telescope'
vim.g['dashboard_custom_header'] = {
  [[ ]],
  [[██     ██ ███████ ███████ ██████  ██       ███████ ████████ ███████ ]],
  [[██     ██ ██      ██      ██   ██ ██       ██         ██    ██      ]],
  [[██  █  ██ █████   █████   ██████  ██       █████      ██    ███████ ]],
  [[██ ███ ██ ██      ██      ██   ██ ██       ██         ██         ██ ]],
  [[ ███ ███  ███████ ███████ ███████ ████████ ████████   ██    ███████ ]],
  [[ ]],
  [[                                ████   ██ ██    ██ ██ ████  ████    ]],
  [[                                ██ ██  ██ ██    ██ ██ ██ ████ ██    ]],
  [[                                ██  ██ ██  ██  ██  ██ ██  ██  ██    ]],
  [[                                ██   ████   ████   ██ ██      ██    ]],
  [[ ]]
}
vim.g.dashboard_custom_section = {
  a = { description = {'  Find Files      '}, command = ':Telescope find_files' },
  b = { description = {'  Recent Files   '}, command = ':Telescope oldfiles' },
  c = { description = {'  Config         '}, command = ':e ~/.config/nvim/init.lua' },
}
vim.g.dashboard_custom_footer = {'Waste 100 hours to save 1 hour - Vim Philosophy'}

                                                                      -- Markdown Preview config
vim.g.mkdp_command_for_global = 1
vim.g.mkdp_auto_close = 0
vim.g.mkdp_echo_preview_url = 1
                                                                      -- Github copilot config
vim.cmd('imap <silent><script><expr> <C-Tab> copilot#Accept("")') -- <C-Tab> works in Neovide
vim.g.copilot_no_tab_map = true
                                                                      -- Omnisharp config
-- maps Tab to <C-x><C-o> for autocompletion using Omnisharp,
-- also lets you use Tab if the cursor is on a whitespace
-- vim.g.OmniSharp_server_stdio = 1
-- vim.g.OmniSharp_server_use_mono = 1
-- vim.cmd([[autocmd FileType cs inoremap <expr> <Tab> pumvisible() ? '<C-n>' : getline('.')[col('.')-2] =~# '[[:alnum:].-_#$]' ? '<C-x><C-o>' : '<Tab>']])

--------------------------------------------------------------------
--                            KEYBINDS                            --
--------------------------------------------------------------------

vim.g.mapleader = " "                                                 -- Set <Leader> to space

-- Functional wrapper for mapping custom keybindings
function map(mode, lhs, rhs, opts)
    local options = { noremap = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

map("n", "<Leader>q", ":q<CR>")                                               -- quite current budder
map("n", "<Leader>w", ":w<CR>")                                               -- Write current buffer
map("n", "<Leader>e", ":NvimTreeToggle<CR>")                                  -- Toggle file explorer
map("n", "<Leader>ps", ":PackerSync<CR>")                                     -- Packer Sync
map("n", "<Leader>/", ":Commentary<CR>")                                      -- Comment lines (normal)
map("v", "<Leader>/", ":Commentary<CR>")                                      -- Comment lines (visual)
map("n", "<Leader>tf", ":ToggleTerm direction='float'<CR>")                   -- Open floating terminal
map("n", "<Leader>th", ":ToggleTerm<CR>")                                     -- Open horizontal terminal
map("t", "<Esc>", [[<C-\><C-n>:ToggleTerm<CR>]])                              -- Close terminal
map("n", "<Leader>h", ":noh<CR>")                                             -- No highlight
map("n", "<Leader>ld", ":lua vim.lsp.diagnostic.show_line_diagnostics()<CR>") -- code diagnostics
map("n", "<C-p>", ":MarkdownPreviewToggle<CR>")                               -- Markdown preview
map("n", "L", ":bp<CR>")                                                      -- Buffer previous
map("n", "H", ":bn<CR>")                                                      -- buffer next
