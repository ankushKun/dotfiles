return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	config = function()
        require("neo-tree").setup({
            close_if_last_window = true,
            popup_border_style = "rounded",
            enable_git_status = true,
        })

		vim.keymap.set("n", "<Leader>e", ":Neotree filesystem toggle left<CR>", {})
		vim.keymap.set("n", "<Leader>E", ":Neotree filesystem toggle float<CR>", {})
		vim.keymap.set("n", "<Leader>o", ":Neotree focus<CR>", {})
	end,
}
