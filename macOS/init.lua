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
vim.opt.textwidth = 9999
vim.opt.wrap = false
vim.opt.linebreak = false
vim.opt.termguicolors = true
vim.opt.showmode = false
vim.opt.scrolloff = 999
vim.opt.sidescrolloff = 10
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.smarttab = true
vim.opt.clipboard = "unnamedplus"
vim.opt.guifont = "MesloLGS NF:h14"

vim.opt.fillchars = [[eob: ,fold: ,foldopen:v,foldsep: ,foldclose:>]]

-- Neovide options
if (vim.fn.exists('neovide') == 1) then
    vim.g.neovide_transparency = 0.9
    vim.g.neovide_input_use_logo = 1
end

-- Fix pasting emojis
vim.cmd("let $LANG='en_US.UTF-8'")


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
    use { 'akinsho/bufferline.nvim' }
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
    use 'jose-elias-alvarez/null-ls.nvim'
    use { 'kyazdani42/nvim-tree.lua',
        requires = { 'kyazdani42/nvim-web-devicons' }
    }
    use {
        'goolord/alpha-nvim',
        requires = { 'kyazdani42/nvim-web-devicons' }
    }
    use { 'nvim-telescope/telescope.nvim',
        requires = { 'nvim-lua/plenary.nvim' }
    }
    use 'andweeb/presence.nvim'
    -- use 'github/copilot.vim'
    use 'JoosepAlviste/nvim-ts-context-commentstring'
    use 'tpope/vim-commentary'
    use 'hrsh7th/vim-vsnip'
    use 'wakatime/vim-wakatime'
    use { "akinsho/toggleterm.nvim", tag = 'v1.*' }
    use "seandewar/killersheep.nvim"
    use "alec-gibson/nvim-tetris"
    use "mg979/vim-visual-multi"
    use "windwp/nvim-autopairs"
    -- use 'OmniSharp/omnisharp-vim'
    use "tpope/vim-sleuth"
    use "tpope/vim-fugitive"
    use { "CRAG666/code_runner.nvim", requires = "nvim-lua/plenary.nvim" }
    use "dominikduda/vim_current_word"
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
    options = {
        globalstatus = true,
        section_seperators = '',
        component_seperators = ''
    },
})

--------------------------------------------------------------------
--                     CMP COMPLETION                             --
--------------------------------------------------------------------
vim.g.completeopt = "menu,menuone,noselect,noinsert" -- UWU
local cmp = require 'cmp'

cmp.setup({
    snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
            -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
            -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
            -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
        end,
    },
    window = {
        -- completion = cmp.config.window.bordered(),
        -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
        ['<S-Tab>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c' }),
        ['<Tab>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'vsnip' }, -- For vsnip users.
        -- { name = 'luasnip' }, -- For luasnip users.
        -- { name = 'ultisnips' }, -- For ultisnips users.
        -- { name = 'snippy' }, -- For snippy users.
    }, {
        { name = 'buffer' },
    })
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
-- capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

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
-- lspconfig.omnisharp.setup {
--     cmd = { "mono", "/Users/ankush/.local/share/nvim/lsp_servers/omnisharp/omnisharp-mono/OmniSharp.exe",
--         "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
--     root_dir = lspconfig.util.root_pattern("*.sln");
--     capabilities = capabilities,
--     use_mono = true
-- }
lspconfig.pyright.setup { capabilities = capabilities }
lspconfig.clangd.setup { capabilities = capabilities }
lspconfig.jdtls.setup { capabilities = capabilities } -- minimum java17
lspconfig.tsserver.setup { capabilities = capabilities }
lspconfig.tailwindcss.setup { capabilities = capabilities }
lspconfig.yamlls.setup { capabilities = capabilities }
lspconfig.html.setup { capabilities = capabilities }
lspconfig.cssls.setup { capabilities = capabilities }
lspconfig.svelte.setup { capabilities = capabilities }

local nls = require('null-ls')
nls.setup {
    sources = {
        nls.builtins.formatting.black,
        -- nls.builtins.formatting.prettierd
    }
}

--------------------------------------------------------------------
--                        CODE FOLDING                            --
--------------------------------------------------------------------





--------------------------------------------------------------------
--                          AUTOPAIRS                             --
--------------------------------------------------------------------
require('nvim-autopairs').setup {
    enable_check_bracket_line = true
}

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
--                         BUFFERLINE                             --
--------------------------------------------------------------------
require('bufferline').setup {
    options = {
        indicator_icon = "",
        offsets = { { filetype = "NvimTree", text = "File Explorer", text_align = "center" } },
        diagnostics = "nvim_lsp",
        diagnostics_update_in_insert = false,
        diagnostics_indicator = function(count)
            return "(" .. count .. ")"
        end,
        show_buffer_close_icons = false,
        show_close_icon = false,
        sort_by = "insert_at_end"
    }
}

--------------------------------------------------------------------
--                          NVIMTREE                              --
--------------------------------------------------------------------
require('nvim-tree').setup {
    renderer = {
        indent_markers = {
            enable = true,
            icons = {
                corner = "└ ",
                -- corner = "╰ ",
                edge = "│ ",
                item = "│ ",
                none = "  "
            }
        },
        icons = {
            glyphs = {
                default = "",
                symlink = "",
                git = {
                    unstaged = "",
                    staged = "S",
                    unmerged = "",
                    renamed = "➜",
                    deleted = "",
                    untracked = "U",
                    ignored = "◌",
                },
                folder = {
                    default = "",
                    open = "",
                    empty = "",
                    empty_open = "",
                    symlink = "",
                }
            }
        }
    }
}

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
--                           ALPHA                                --
--------------------------------------------------------------------
local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

-- Set header
dashboard.section.header.val = {
    [[     /\_____/\     ]],
    [[    /  o   o  \    ]],
    [[   ( ==  ^  == )   ]],
    [[    )         (    ]],
    [[   (           )   ]],
    [[  ( (  )   (  ) )  ]],
    [[ (__(__)___(__)__) ]]
}

dashboard.section.header.opts.hl = "Special"
-- Set menu
dashboard.section.buttons.val = {
    dashboard.button("f", " Find File", ":Telescope find_files<CR>"),
    dashboard.button("l", " Find Word", ":Telescope live_grep<CR>"),
    dashboard.button("r", " Recent", ":Telescope oldfiles<CR>"),
    dashboard.button("s", " Config", ":Config<CR>"),
    -- dashboard.button("q", " Quit NVIM", ":qa<CR>"),
}
dashboard.section.buttons.opts.hl = "Special"

alpha.setup(dashboard.opts)

-- Disable folding on alpha buffer
vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])

--------------------------------------------------------------------
--                      MARKDOWN PREVIEW                          --
--------------------------------------------------------------------
-- vim.g.mkdp_command_for_global = 1
-- vim.g.mkdp_auto_close = 0
-- vim.g.mkdp_echo_preview_url = 1

--------------------------------------------------------------------
--                      GITHUB COPILOT                            --
--------------------------------------------------------------------
-- if (vim.fn.exists('neovide') == 1) then
--     vim.cmd('imap <silent><script><expr> <C-Tab> copilot#Accept("")') -- <C-Tab> to accept - only in neovide
-- else
--     vim.cmd('imap <silent><script><expr> <C-x> copilot#Accept("")') -- <C-x> to accept
-- end
-- vim.g.copilot_no_tab_map = true

--------------------------------------------------------------------
--                        TOGGLETERM                              --
--------------------------------------------------------------------
require("toggleterm").setup{
    float_opts = {
        -- border = "curved"
    }
}

--------------------------------------------------------------------
--                      CODE RUNNER                               --
--------------------------------------------------------------------
require('code_runner').setup({
    -- put here the commands by filetype
    filetype = {
        java = "cd $dir && javac $fileName && java $fileNameWithoutExt",
        python = "python3 -u",
        cpp = "cd $dir; g++ $fileName -o $fileNameWithoutExt; ./$fileNameWithoutExt",
        javascript = "node"
    },
    -- mode = "toggleterm",
    -- focus = false
})

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
map("n", "<Leader>c", ":bd<CR>") -- Close buffer
map("n", "<Leader>e", ":NvimTreeToggle<CR>") -- Toggle file explorer
map("n", "<Leader>ps", ":PackerSync<CR>") -- Packer Sync
map("n", "<Leader>tf", ":ToggleTerm direction='float'<CR>") -- Open floating terminal
map("n", "<Leader>th", ":ToggleTerm<CR>") -- Open horizontal terminal
map("t", "<Esc>", [[<C-\><C-n>:ToggleTerm<CR>]]) -- Close terminal
map("n", "<Leader>h", ":noh<CR>") -- No highlight

map("n", "<Leader>lf", ":lua vim.lsp.buf.formatting()<CR>") -- format code
map("n", "gd", ":lua vim.lsp.diagnostic.show_line_diagnostics()<CR>") -- line diagnostics
map("n", "gD", ":lua vim.lsp.buf.definition()<CR>") -- goto definition
map("n", "K", ":lua vim.lsp.buf.hover()<CR>") -- hover

-- map("n", "<C-p>", ":MarkdownPreviewToggle<CR>") -- Markdown preview
map("n", "L", ":BufferLineCycleNext<CR>") -- Buffer previous
map("n", "H", ":BufferLineCyclePrev<CR>") -- buffer next

map("n", "fo", ":foldopen<CR>") -- foldopen
map("n", "fc", ":foldclose<CR>") -- foldclose

map("n", "<Leader>r", ":RunCode<CR>") -- run code

