-- Install Packer
-- git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim

--------------------------------------------------------------------
--                            PLUGINS                             --
--------------------------------------------------------------------

require('packer').startup(function()
    use 'wbthomason/packer.nvim'

    -- Indent lines
    use "lukas-reineke/indent-blankline.nvim"

    -- Which Key
    use "folke/which-key.nvim"

    -- bottom statusline
    use { 'nvim-lualine/lualine.nvim', requires = 'kyazdani42/nvim-web-devicons' }
    use 'arkav/lualine-lsp-progress'

    -- top tabline
    use 'akinsho/bufferline.nvim'

    -- colorscheme
    use 'ghifarit53/tokyonight-vim'
    use 'norcalli/nvim-colorizer.lua'

    -- Treesitter, indentation, highlighting, etc
    use 'nvim-treesitter/nvim-treesitter'
    use 'windwp/nvim-ts-autotag'
    use "tpope/vim-sleuth"

    -- LSP
    use {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        requires = {
            --- Uncomment these if you want to manage LSP servers from neovim
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },

            -- LSP Support
            { 'neovim/nvim-lspconfig' },
            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'L3MON4D3/LuaSnip' },
        }
    }
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-cmdline'
    use 'hrsh7th/nvim-cmp'
    use 'jose-elias-alvarez/null-ls.nvim'
    use 'williamboman/mason.nvim'
    use 'williamboman/mason-lspconfig.nvim'
    use 'jay-babu/mason-null-ls.nvim'
    use 'neovim/nvim-lspconfig'
    use { 'glepnir/lspsaga.nvim' }
    use 'onsails/lspkind-nvim'

    -- Rust
    use 'simrat39/rust-tools.nvim'

    -- File explorer
    use { 'kyazdani42/nvim-tree.lua', requires = 'kyazdani42/nvim-web-devicons' }

    -- Startup screen
    use { 'goolord/alpha-nvim', requires = 'kyazdani42/nvim-web-devicons' }

    -- Telescope
    use { 'nvim-telescope/telescope.nvim', requires = 'nvim-lua/plenary.nvim' }

    -- Discord RP
    use 'andweeb/presence.nvim'

    use 'github/copilot.vim'

    -- Better Commenting
    use 'JoosepAlviste/nvim-ts-context-commentstring'
    use 'tpope/vim-commentary'

    -- Snippets
    use 'hrsh7th/vim-vsnip'

    -- Time tracking
    use 'wakatime/vim-wakatime'

    -- Floating terminal
    use "akinsho/toggleterm.nvim"

    -- Games
    use "seandewar/killersheep.nvim"
    use "alec-gibson/nvim-tetris"

    -- Multiple cursors
    use "mg979/vim-visual-multi"

    -- Autopair brackets
    use "windwp/nvim-autopairs"

    -- C# lsp
    -- use 'OmniSharp/omnisharp-vim'

    -- Git stuff
    use 'lewis6991/gitsigns.nvim'
    use "tpope/vim-fugitive"

    -- To execute code
    use { "CRAG666/code_runner.nvim", requires = "nvim-lua/plenary.nvim" }

    -- Current word highlight
    use "dominikduda/vim_current_word"

    -- Smooth scroll
    use "karb94/neoscroll.nvim"

    -- Better code folding
    use { 'kevinhwang91/nvim-ufo', requires = 'kevinhwang91/promise-async' }

    -- svelte highlighting
    use 'othree/html5.vim'
    use 'pangloss/vim-javascript'
    use 'evanleck/vim-svelte'

    -- php laravel
    -- use {
    --     "adalessa/laravel.nvim",
    --     dependencies = {
    --         "nvim-telescope/telescope.nvim",
    --         "tpope/vim-dotenv",
    --         "MunifTanjim/nui.nvim",
    --     },
    --     cmd = { "Sail", "Artisan", "Composer", "Npm", "Yarn", "Laravel" },
    --     keys = {
    --         { "<leader>la", ":Laravel artisan<cr>" },
    --         { "<leader>lr", ":Laravel routes<cr>" },
    --         {
    --             "<leader>lt",
    --             function()
    --                 require("laravel.tinker").send_to_tinker()
    --             end,
    --             mode = "v",
    --             desc = "Laravel Application Routes",
    --         },
    --     },
    --     event = { "VeryLazy" },
    --     config = function()
    --         require("laravel").setup()
    --         require("telescope").load_extension "laravel"
    --     end,
    -- }
end)
