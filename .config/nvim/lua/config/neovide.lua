local ui_colors = require("config.colors").ui_colors

-- Neovide specific settings
if vim.g.neovide then
	-- Font configuration (matching Kitty: MesloLGS NF, size 13)
	vim.o.guifont = "MesloLGS NF:h13"

	-- Padding (minimal, like Kitty)
	vim.g.neovide_padding_top = 5
	vim.g.neovide_padding_bottom = 5
	vim.g.neovide_padding_right = 5
	vim.g.neovide_padding_left = 5

	-- Opacity (matching Kitty: 0.75 opacity with blur)
	-- Note: neovide_transparency is deprecated, use neovide_background_color alpha channel instead
	vim.g.neovide_window_blurred = true

	-- Set background color with alpha channel for transparency
	-- Format: #RRGGBBAA where AA is alpha (00 = transparent, FF = opaque)
	-- BF is roughly 75% opacity, matching Kitty's background_opacity.
	vim.g.neovide_background_color = ui_colors.bg .. "BF"

	-- Floating blur
	vim.g.neovide_floating_blur_amount_x = 2.0
	vim.g.neovide_floating_blur_amount_y = 2.0

	-- Hide mouse when typing
	vim.g.neovide_hide_mouse_when_typing = true

	-- Underline stroke scale
	vim.g.neovide_underline_stroke_scale = 1.0

	-- Theme (can be "auto", "light", or "dark")
	vim.g.neovide_theme = "auto"

	-- Refresh rate
	vim.g.neovide_refresh_rate = 60

	-- Idle refresh rate (when not focused)
	vim.g.neovide_refresh_rate_idle = 5

	-- Confirm quit
	vim.g.neovide_confirm_quit = true

	-- Fullscreen
	vim.g.neovide_fullscreen = false

	-- Remember window size
	vim.g.neovide_remember_window_size = true

	-- Cursor settings
	vim.g.neovide_cursor_animation_length = 0.13
	vim.g.neovide_cursor_trail_size = 0.3
	vim.g.neovide_cursor_antialiasing = true
	vim.g.neovide_cursor_animate_in_insert_mode = true
	vim.g.neovide_cursor_animate_command_line = true
	vim.g.neovide_cursor_vfx_mode = "railgun" -- Options: "", "railgun", "torpedo", "pixiedust", "sonicboom", "ripple", "wireframe"

	-- Scroll animation
	vim.g.neovide_scroll_animation_length = 0.15

	-- Keyboard shortcuts for Neovide
	-- Cmd+V for paste (macOS style)
	vim.keymap.set({ "n", "v", "i", "c" }, "<D-v>", function()
		if vim.fn.mode() == "i" or vim.fn.mode() == "c" then
			return "<C-r>+"
		else
			return '"+p'
		end
	end, { expr = true, desc = "Paste from system clipboard" })

	-- Cmd+C for copy (macOS style)
	vim.keymap.set("v", "<D-c>", '"+y', { desc = "Copy to system clipboard" })

	-- Cmd+= to increase font size
	vim.keymap.set("n", "<D-=>", function()
		local current_font = vim.o.guifont
		local size = tonumber(string.match(current_font, ":h(%d+)"))
		if size then
			vim.o.guifont = string.gsub(current_font, ":h%d+", ":h" .. (size + 1))
		end
	end, { desc = "Increase font size" })

	-- Cmd+- to decrease font size
	vim.keymap.set("n", "<D-->", function()
		local current_font = vim.o.guifont
		local size = tonumber(string.match(current_font, ":h(%d+)"))
		if size and size > 6 then
			vim.o.guifont = string.gsub(current_font, ":h%d+", ":h" .. (size - 1))
		end
	end, { desc = "Decrease font size" })

	-- Cmd+0 to reset font size
	vim.keymap.set("n", "<D-0>", function()
		vim.o.guifont = "MesloLGS NF:h13"
	end, { desc = "Reset font size" })
end
