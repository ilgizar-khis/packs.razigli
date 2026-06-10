-- main table
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

-- function to open/close win
function M.toggle()
	-- create main buffer
	if not M.main_buf then
		M.main_buf = vim.api.nvim_create_buf(false, true)
	end
	-- add bufferline to main_buf
	vim.api.nvim_buf_set_lines(M.main_buf, 0, 0, false, { "[home]  clear  list" })
	-- calculate col and row params
	local col = math.floor((vim.api.nvim_get_option("columns") - M.params.width) / 2)
	local row = math.floor((vim.api.nvim_get_option("lines") - M.params.height) / 2)
	-- if win don't exist create new win
	if not M.win or not vim.api.nvim_win_is_valid(M.win) then
		M.win = vim.api.nvim_open_win(M.main_buf, true, {
			relative = "editor",
			width = M.params.width,
			height = M.params.height,
			col = col,
			row = row,
			border = M.params.border,
		})
		-- delet signcolumn and numberline
		vim.api.nvim_win_set_option(M.win, "number", false)
		vim.api.nvim_win_set_option(M.win, "relativenumber", false)
		vim.api.nvim_win_set_option(M.win, "signcolumn", "no")
	else
		-- close and delete win
		vim.api.nvim_close_win(M.win)
		M.win = nil
	end
end

-- function to setup
function M.setup(params)
	-- set params
	for key, value in pairs(params) do
		if M.params[key] then
			M.params[key] = value
		end
	end
end

return M
