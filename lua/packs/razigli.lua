local M = {
	win = nil,
	main_buf = nil,
	clear_buf = nil,
	list_buf = nil,
	update_buf = nil,
	params = {},
}

function M.open()
	if not M.main_buf then
		M.main_buf = vim.api.nvim_create_buf(false, true)
	end
end

function M.setup() end

return M
