-- main table
local M = {
	win = nil,
	home_buf = nil,
	clear_buf = nil,
	update_buf = nil,
	params = {
		width = 160,
		height = 40,
		border = "single",
	},
}

function M.update()
	local data = vim.pack.get()
	if M.home_buf then
		local lines = {}
		for _, pkg in ipairs(data) do
			table.insert(lines, "active = " .. pkg.active)
			table.insert(lines, "name = " .. pkg.spec.name)
			table.insert(lines, "src = " .. pkg.spec.src)
			table.insert(lines, "path = " .. pkg.path)
		end
		vim.api.nvim_buf_set_lines(M.home_buf, -1, -1, true, lines)
	end
end

-- function to open/close win
function M.toggle()
	-- create main buffer
	if not M.home_buf then
		M.home_buf = vim.api.nvim_create_buf(false, true)
		-- add bufferline to home_buf
		vim.api.nvim_buf_set_lines(M.home_buf, 0, 0, true, { "[1:home]  2:clear  3:update", "" })
	end
	-- calculate col and row params
	local col = math.floor((vim.api.nvim_get_option("columns") - M.params.width) / 2)
	local row = math.floor((vim.api.nvim_get_option("lines") - M.params.height) / 2)
	-- if win don't exist create new win
	if not M.win or not vim.api.nvim_win_is_valid(M.win) then
		M.win = vim.api.nvim_open_win(M.home_buf, true, {
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
		M.update()
	else
		-- close and delete win
		vim.api.nvim_win_close(M.win, true)
		M.win = nil
	end
end

-- function to setup
function M.setup(params)
	-- set params
	if params then
		for key, value in pairs(params) do
			if M.params[key] then
				M.params[key] = value
			end
		end
	end
end

return M
