local M = {
	win = nil,
	main_buf = nil,
	clear_buf = nil,
	list_buf = nil,
	update_buf = nil,
	params = {
		width = 160,
		height = 40,
		border = "single",
	},
}

function M.toggle()
	if not M.main_buf then
		M.main_buf = vim.api.nvim_create_buf(false, true)
	end

	local col = math.floor((vim.api.nvim_get_option("columns") - M.width) / 2)
	local row = math.floor((vim.api.nvim_get_option("lines") - M.height) / 2)

	if not M.win or not vim.api.nvim_win_is_valid(M.win) then
		M.win = vim.api.nvim_open_win(M.main_buf, true, {
			relative = "editor",
			width = M.width,
			height = M.height,
			col = col,
			row = row,
			border = M.border,
		})
	else
		vim.api.nvim_close_win(M.win)
		M.win = nil
	end
end

function M.setup() end

return M
