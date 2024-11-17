-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Example configs: https://github.com/LunarVim/starter.lvim
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

vim.opt.relativenumber = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.smarttab = true
vim.opt.background = "dark"
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.wrap = true


-- buffer nav
lvim.keys.normal_mode["{"] = ":BufferLineCyclePrev<CR>"
lvim.keys.normal_mode["}"] = ":BufferLineCycleNext<CR>"

-- nvim-tree focus
lvim.keys.normal_mode["<leader>o"] = ":NvimTreeFocus<CR>"

-- toggleterm float and horizontal
lvim.keys.normal_mode["<leader>th"] = ":ToggleTerm direction=horizontal<CR>"
lvim.keys.normal_mode["<leader>tf"] = ":ToggleTerm direction=float<CR>"

-- indentation
lvim.keys.normal_mode["<"] = "v<"
lvim.keys.normal_mode[">"] = "v>"
lvim.keys.visual_mode["<"] = "<gv"
lvim.keys.visual_mode[">"] = ">gv"

-- move lines
lvim.keys.normal_mode["<C-j>"] = ":m .+1<CR>=="
lvim.keys.normal_mode["<C-k>"] = ":m .-2<CR>=="
lvim.keys.visual_mode["<C-j>"] = ":m '>+1<CR>gv=gv"
lvim.keys.visual_mode["<C-k>"] = ":m '<-2<CR>gv=gv"

-- term mode esc to close
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>:ToggleTerm<CR>]], {})

lvim.transparent_window = true

lvim.plugins = {
  "github/copilot.vim",
  "wakatime/vim-wakatime",
  {
    "ghifarit53/tokyonight-vim",
    config = function()
      vim.g.tokyonight_enable_italic = true
      vim.g.tokyonight_transparent_background = true
      vim.cmd [[colorscheme tokyonight]]
    end
  },
  {
    "karb94/neoscroll.nvim",
    config = function()
      require('neoscroll').setup {}
    end
  },
  {
    'andweeb/presence.nvim',
    config = function()
      require("presence"):setup()
    end
  },
  {
    'akinsho/toggleterm.nvim',
    config = function()
      require("toggleterm").setup {
        float_opts = {
          border = "curved"
        }
      }
      vim.keymap.set("n", "<Leader>tf", ":ToggleTerm direction='float'<CR>", {})
      vim.keymap.set("n", "<Leader>th", ":ToggleTerm<CR>", {})
      vim.keymap.set("t", "<Esc>", [[<C-\><C-n>:ToggleTerm<CR>]], {})
    end
  }
}
