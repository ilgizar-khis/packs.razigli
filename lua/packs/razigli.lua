local M = {
	win = nil,
	clear_buf = nil,
	list_buf = nil,
	update_buf = nil,
	params = {},
}

function M.open()
	if not M.clear_buf then
		M.clear_buf = vim.api.nvim_create_buf(false, true)
	end

	if not M.list_buf then
		M.list_buf = vim.api.nvim_create_buf(false, true)
	end
end

function M.setup() end

return M
