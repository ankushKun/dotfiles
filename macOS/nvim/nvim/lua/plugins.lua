-- Install Packer
-- git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim

--------------------------------------------------------------------
--                            PLUGINS                             --
--------------------------------------------------------------------

require('packer').startup(function()
    use 'wbthomason/packer.nvim'

    -- bottom statusline
    use { 'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons' }
    }

    -- top tabline
    use { 'akinsho/bufferline.nvim' }

    -- colorscheme
    use 'ghifarit53/tokyonight-vim'

    -- highlighting
    use 'nvim-treesitter/nvim-treesitter'

    -- LSP
    use { 'williamboman/nvim-lsp-installer',
        { 'neovim/nvim-lspconfig' }
    }
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-cmdline'
    use 'hrsh7th/nvim-cmp'
    use 'jose-elias-alvarez/null-ls.nvim'
    use 'williamboman/mason.nvim'
    use 'williamboman/mason-lspconfig.nvim'
    use 'glepnir/lspsaga.nvim'
    use 'onsails/lspkind-nvim'

    -- File explorer
    use { 'kyazdani42/nvim-tree.lua',
        requires = { 'kyazdani42/nvim-web-devicons' }
    }

    -- Startup screen
    use {
        'goolord/alpha-nvim',
        requires = { 'kyazdani42/nvim-web-devicons' }
    }

    -- Telescope
    use { 'nvim-telescope/telescope.nvim',
        requires = { 'nvim-lua/plenary.nvim' }
    }

    -- Discord RP
    use 'andweeb/presence.nvim'

    use 'github/copilot.vim'

    -- Better Commenting
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
    use "karb94/neoscroll.nvim"
    use { 'kevinhwang91/nvim-ufo', requires = 'kevinhwang91/promise-async' }
    use { 'nyoom-engineering/oxocarbon.nvim' }
end)
