local M = {}

function M.listed_file_buffers()
	local buffers = {}
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted and vim.bo[buf].buftype == "" then
			table.insert(buffers, buf)
		end
	end
	return buffers
end

function M.open_fallback_buffer()
	if pcall(vim.cmd, "Alpha") then
		return vim.api.nvim_get_current_buf()
	end
	vim.cmd("enew")
	vim.bo.buflisted = false
	return vim.api.nvim_get_current_buf()
end

function M.close_buffer(bufnr, force)
	if bufnr == nil or bufnr == 0 then
		bufnr = vim.api.nvim_get_current_buf()
	end
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end

	if vim.bo[bufnr].modified and not force then
		vim.notify("Buffer has unsaved changes. Save it or use <leader>bD to force close.", vim.log.levels.WARN)
		return
	end

	local alternate
	local target_windows = {}

	for _, buf in ipairs(M.listed_file_buffers()) do
		if buf ~= bufnr then
			alternate = buf
			break
		end
	end

	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == bufnr then
			table.insert(target_windows, win)
		end
	end

	if alternate then
		for _, win in ipairs(target_windows) do
			vim.api.nvim_win_set_buf(win, alternate)
		end
	elseif #target_windows > 0 then
		local current_win = vim.api.nvim_get_current_win()
		vim.api.nvim_set_current_win(target_windows[1])
		local fallback = M.open_fallback_buffer()
		for i = 2, #target_windows do
			vim.api.nvim_win_set_buf(target_windows[i], fallback)
		end
		if vim.api.nvim_win_is_valid(current_win) then
			vim.api.nvim_set_current_win(current_win)
		end
	end

	pcall(vim.api.nvim_buf_delete, bufnr, { force = force or false })
end

return M
