local M = {}

-- Kitty-matched Tokyo Night palette.
M.ui_colors = {
	bg = "#101015",
	surface = "#15161e",
	surface_alt = "#1a1b26",
	selection = "#283457",
	border = "#7aa2f7",
	border_dim = "#292e42",
	fg = "#c0caf5",
	fg_dim = "#a9b1d6",
	muted = "#545c7e",
	blue = "#7aa2f7",
	cyan = "#7dcfff",
	green = "#9ece6a",
	yellow = "#e0af68",
	orange = "#ff9e64",
	red = "#f7768e",
	red_dark = "#db4b4b",
	purple = "#bb9af7",
	tab_fg = "#16161e",
}

function M.blend_hex(fg, bg, alpha)
	local function channel(hex, index)
		return tonumber(hex:sub(index, index + 1), 16) or 0
	end

	local function blend_channel(fg_channel, bg_channel)
		return math.floor((fg_channel * alpha) + (bg_channel * (1 - alpha)) + 0.5)
	end

	return string.format(
		"#%02x%02x%02x",
		blend_channel(channel(fg, 2), channel(bg, 2)),
		blend_channel(channel(fg, 4), channel(bg, 4)),
		blend_channel(channel(fg, 6), channel(bg, 6))
	)
end

function M.apply_kitty_highlights(hl)
	local function merge_highlight(group, opts)
		local existing = type(hl[group]) == "table" and hl[group] or {}
		hl[group] = vim.tbl_extend("force", existing, opts)
	end

	local transparent_groups = {
		"Normal",
		"NormalNC",
		"SignColumn",
		"FoldColumn",
		"LineNr",
		"CursorLineNr",
		"EndOfBuffer",
		"StatusLine",
		"StatusLineNC",
		"WinBar",
		"WinBarNC",
		"NvimTreeNormal",
		"NvimTreeNormalNC",
		"NvimTreeEndOfBuffer",
		"NvimTreeVertSplit",
		"BufferLineFill",
		"BufferLineBackground",
		"BufferLineTab",
		"BufferLineTabClose",
	}

	for _, group in ipairs(transparent_groups) do
		merge_highlight(group, { bg = "NONE" })
	end

	local surface_groups = {
		"NormalFloat",
		"FloatTitle",
		"Pmenu",
		"WhichKeyFloat",
		"LazyNormal",
		"MasonNormal",
		"TelescopeNormal",
		"TelescopePromptNormal",
		"TelescopeResultsNormal",
		"TelescopePreviewNormal",
		"TroubleNormal",
		"TroubleNormalNC",
		"DiagnosticFloatingError",
		"DiagnosticFloatingWarn",
		"DiagnosticFloatingInfo",
		"DiagnosticFloatingHint",
		"LspInfoBorder",
		"NotifyBackground",
	}

	for _, group in ipairs(surface_groups) do
		merge_highlight(group, { fg = M.ui_colors.fg, bg = "NONE" })
	end

	hl.FloatBorder = { fg = M.ui_colors.border, bg = "NONE" }
	hl.FloatTitle = { fg = M.ui_colors.blue, bg = "NONE", bold = true }
	hl.WinSeparator = { fg = M.ui_colors.border_dim, bg = "NONE" }
	hl.PmenuSel = { fg = M.ui_colors.tab_fg, bg = M.ui_colors.blue, bold = true }
	hl.PmenuSbar = { bg = "NONE" }
	hl.PmenuThumb = { bg = M.ui_colors.border_dim }
	hl.Visual = { bg = M.ui_colors.selection }
	hl.Search = { fg = M.ui_colors.tab_fg, bg = M.ui_colors.yellow }
	hl.IncSearch = { fg = M.ui_colors.tab_fg, bg = M.ui_colors.orange }
	hl.CurSearch = { fg = M.ui_colors.tab_fg, bg = M.ui_colors.orange }
	hl.CursorLine = { bg = M.ui_colors.surface }
	hl.ColorColumn = { bg = M.ui_colors.surface }

	hl.TelescopeBorder = { fg = M.ui_colors.border_dim, bg = "NONE" }
	hl.TelescopePromptBorder = { fg = M.ui_colors.blue, bg = "NONE" }
	hl.TelescopePromptTitle = { fg = M.ui_colors.blue, bg = "NONE", bold = true }
	hl.TelescopePreviewTitle = { fg = M.ui_colors.purple, bg = "NONE", bold = true }
	hl.TelescopeResultsTitle = { fg = M.ui_colors.muted, bg = "NONE" }
	hl.TelescopeSelection = { fg = M.ui_colors.fg, bg = M.ui_colors.selection, bold = true }
	hl.TelescopeMatching = { fg = M.ui_colors.cyan, bold = true }

	hl.NvimTreeRootFolder = { fg = M.ui_colors.blue, bold = true }
	hl.NvimTreeFolderName = { fg = M.ui_colors.fg_dim }
	hl.NvimTreeOpenedFolderName = { fg = M.ui_colors.blue, bold = true }
	hl.NvimTreeGitDirty = { fg = M.ui_colors.orange }
	hl.NvimTreeGitNew = { fg = M.ui_colors.green }
	hl.NvimTreeGitDeleted = { fg = M.ui_colors.red }
	hl.NvimTreeIndentMarker = { fg = M.ui_colors.border_dim }

	hl.AlphaHeader = { fg = M.ui_colors.blue }
	hl.AlphaButtons = { fg = M.ui_colors.fg }
	hl.AlphaShortcut = { fg = M.ui_colors.cyan, bold = true }
	hl.AlphaFooter = { fg = M.ui_colors.muted }

	hl.DiagnosticVirtualTextError = { fg = M.ui_colors.red, bg = "NONE" }
	hl.DiagnosticVirtualTextWarn = { fg = M.ui_colors.yellow, bg = "NONE" }
	hl.DiagnosticVirtualTextInfo = { fg = M.ui_colors.cyan, bg = "NONE" }
	hl.DiagnosticVirtualTextHint = { fg = M.ui_colors.green, bg = "NONE" }
	hl.DiagnosticSignError = { fg = M.ui_colors.red, bg = "NONE" }
	hl.DiagnosticSignWarn = { fg = M.ui_colors.yellow, bg = "NONE" }
	hl.DiagnosticSignInfo = { fg = M.ui_colors.cyan, bg = "NONE" }
	hl.DiagnosticSignHint = { fg = M.ui_colors.green, bg = "NONE" }
	hl.DiagnosticFloatingError = { fg = M.ui_colors.red, bg = "NONE" }
	hl.DiagnosticFloatingWarn = { fg = M.ui_colors.yellow, bg = "NONE" }
	hl.DiagnosticFloatingInfo = { fg = M.ui_colors.cyan, bg = "NONE" }
	hl.DiagnosticFloatingHint = { fg = M.ui_colors.green, bg = "NONE" }
	hl.LspFloatWinNormal = { fg = M.ui_colors.fg, bg = "NONE" }
	hl.LspFloatWinBorder = { fg = M.ui_colors.border, bg = "NONE" }
	hl.LspSignatureActiveParameter = { fg = M.ui_colors.tab_fg, bg = M.ui_colors.yellow, bold = true }

	hl.NotifyBackground = { bg = "NONE" }
	hl.NotifyERRORBorder = { fg = M.ui_colors.red, bg = "NONE" }
	hl.NotifyWARNBorder = { fg = M.ui_colors.yellow, bg = "NONE" }
	hl.NotifyINFOBorder = { fg = M.ui_colors.cyan, bg = "NONE" }
	hl.NotifyDEBUGBorder = { fg = M.ui_colors.muted, bg = "NONE" }
	hl.NotifyTRACEBorder = { fg = M.ui_colors.purple, bg = "NONE" }
	hl.NotifyERRORTitle = { fg = M.ui_colors.red, bg = "NONE", bold = true }
	hl.NotifyWARNTitle = { fg = M.ui_colors.yellow, bg = "NONE", bold = true }
	hl.NotifyINFOTitle = { fg = M.ui_colors.cyan, bg = "NONE", bold = true }
	hl.NotifyDEBUGTitle = { fg = M.ui_colors.muted, bg = "NONE", bold = true }
	hl.NotifyTRACETitle = { fg = M.ui_colors.purple, bg = "NONE", bold = true }
	hl.NotifyERRORIcon = { fg = M.ui_colors.red, bg = "NONE" }
	hl.NotifyWARNIcon = { fg = M.ui_colors.yellow, bg = "NONE" }
	hl.NotifyINFOIcon = { fg = M.ui_colors.cyan, bg = "NONE" }
	hl.NotifyDEBUGIcon = { fg = M.ui_colors.muted, bg = "NONE" }
	hl.NotifyTRACEIcon = { fg = M.ui_colors.purple, bg = "NONE" }

	hl.WhichKey = { fg = M.ui_colors.cyan }
	hl.WhichKeyGroup = { fg = M.ui_colors.blue }
	hl.WhichKeyDesc = { fg = M.ui_colors.fg }
	hl.WhichKeySeparator = { fg = M.ui_colors.muted }
	hl.WhichKeyValue = { fg = M.ui_colors.muted }

	hl.TroubleNormal = { fg = M.ui_colors.fg, bg = "NONE" }
	hl.TroubleNormalNC = { fg = M.ui_colors.fg_dim, bg = "NONE" }
	hl.TroubleText = { fg = M.ui_colors.fg_dim, bg = "NONE" }
	hl.TroubleCount = { fg = M.ui_colors.blue, bg = "NONE", bold = true }
	hl.TroubleIndent = { fg = M.ui_colors.border_dim, bg = "NONE" }
	hl.TroubleIndentTop = { fg = M.ui_colors.border_dim, bg = "NONE" }
	hl.TroubleIndentMiddle = { fg = M.ui_colors.border_dim, bg = "NONE" }
	hl.TroubleIndentLast = { fg = M.ui_colors.border_dim, bg = "NONE" }
	hl.TroubleIndentWs = { fg = M.ui_colors.border_dim, bg = "NONE" }
	hl.TroubleIndentFoldOpen = { fg = M.ui_colors.blue, bg = "NONE" }
	hl.TroubleIndentFoldClosed = { fg = M.ui_colors.blue, bg = "NONE" }
	hl.TroublePreview = { bg = M.ui_colors.selection }

	local satellite_colors = {
		blue = M.blend_hex(M.ui_colors.blue, M.ui_colors.bg, 0.5),
		cyan = M.blend_hex(M.ui_colors.cyan, M.ui_colors.bg, 0.5),
		green = M.blend_hex(M.ui_colors.green, M.ui_colors.bg, 0.5),
		yellow = M.blend_hex(M.ui_colors.yellow, M.ui_colors.bg, 0.5),
		orange = M.blend_hex(M.ui_colors.orange, M.ui_colors.bg, 0.5),
		red = M.blend_hex(M.ui_colors.red, M.ui_colors.bg, 0.5),
		purple = M.blend_hex(M.ui_colors.purple, M.ui_colors.bg, 0.5),
	}

	hl.SatelliteBackground = { bg = "NONE" }
	hl.SatelliteBar = { bg = "NONE" }
	hl.SatelliteCursor = { fg = satellite_colors.blue, bg = "NONE" }
	hl.SatelliteSearch = { fg = satellite_colors.yellow, bg = "NONE" }
	hl.SatelliteSearchCurrent = { fg = satellite_colors.orange, bg = "NONE" }
	hl.SatelliteDiagnosticError = { fg = satellite_colors.red, bg = "NONE" }
	hl.SatelliteDiagnosticWarn = { fg = satellite_colors.yellow, bg = "NONE" }
	hl.SatelliteDiagnosticInfo = { fg = satellite_colors.cyan, bg = "NONE" }
	hl.SatelliteDiagnosticHint = { fg = satellite_colors.green, bg = "NONE" }
	hl.SatelliteGitSignsAdd = { fg = satellite_colors.green, bg = "NONE" }
	hl.SatelliteGitSignsChange = { fg = satellite_colors.cyan, bg = "NONE" }
	hl.SatelliteGitSignsDelete = { fg = satellite_colors.red, bg = "NONE" }
	hl.SatelliteQuickfix = { fg = satellite_colors.purple, bg = "NONE" }
	hl.SatelliteMark = { fg = satellite_colors.cyan, bg = "NONE" }
end

return M
