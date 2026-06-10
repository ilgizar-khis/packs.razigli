-- main table
local M = {
	win = nil,
	home_buf = nil,
	clear_buf = nil,
	update_buf = nil,
	width = 160,
	height = 40,
	border = "single",
	key_home_buf = "1",
	key_clear_buf = "2",
	key_clear = "<CR>",
	key_update = "<S-u>",
	info = nil,
}

function M.clear()
	-- get lines from clear_buf
	local lines = vim.api.nvim_buf_get_lines(M.clear_buf, 2, -1, false)
	local to_clear = {}
	-- delete all pkgs
	for _, line in ipairs(lines) do
		if string.find(line, "^%[%-%]") then
			table.insert(to_clear, string.match(line, "^%[%-%] name = (.+)"))
		end
	end
	vim.pack.del(to_clear)
	M.update()
end

function M.update()
	-- get all datas
	local data = vim.pack.get()
	-- get all pkgs
	local lines = {}
	for _, pkg in ipairs(data) do
		local status = pkg.active and "[+]" or "[-]"
		table.insert(lines, status .. " name = " .. pkg.spec.name)
		table.insert(lines, "\tsrc = " .. pkg.spec.src)
	end
	-- get list of disables pkgs
	local to_clear_lines = {}
	local to_clear_count = 0
	for _, pkg in ipairs(data) do
		if not pkg.active then
			to_clear_count = to_clear_count + 1
			table.insert(to_clear_lines, "[-] name = " .. pkg.spec.name)
			table.insert(to_clear_lines, "\tsrc = " .. pkg.spec.src)
		end
	end
	M.info = #data .. "([+]:" .. #data - to_clear_count .. ", [-]:" .. to_clear_count .. ")"
	local winbar = vim.api.nvim_win_get_option(M.win, "winbar")
	vim.api.nvim_win_set_option(M.win, "winbar", winbar .. " | " .. M.info)
	-- append data tp home_buf
	if M.home_buf then
		vim.api.nvim_buf_set_lines(M.home_buf, 0, -1, true, lines)
	end
	-- append data tp clear_buf
	if M.clear_buf then
		vim.api.nvim_buf_set_lines(M.clear_buf, 0, -1, true, to_clear_lines)
	end
end

-- function to open/close win
function M.toggle()
	-- create home buffer
	if not M.home_buf then
		M.home_buf = vim.api.nvim_create_buf(false, true)
		-- add bufferline to home_buf
		-- vim.api.nvim_buf_set_lines(M.home_buf, 0, 0, true, { , "" })
		-- keymap to jump clear_buf
		vim.keymap.set("n", M.key_clear_buf, function()
			vim.api.nvim_win_set_buf(M.win, M.clear_buf)
			vim.api.nvim_win_set_option(M.win, "winbar", " 1:home   [2:clear]" .. " | " .. M.info)
		end, { buffer = M.home_buf })
		-- update data
		vim.keymap.set("n", M.key_update, function()
			M.update()
		end, { buffer = M.home_buf })
	end
	-- create clear buffer
	if not M.clear_buf then
		M.clear_buf = vim.api.nvim_create_buf(false, true)
		-- keymap to jump home_buf
		vim.keymap.set("n", M.key_home_buf, function()
			vim.api.nvim_win_set_buf(M.win, M.home_buf)
			vim.api.nvim_win_set_option(M.win, "winbar", "[1:home]  2:clear" .. " | " .. M.info)
		end, { buffer = M.clear_buf })
		-- keymap to clear
		vim.keymap.set("n", M.key_clear, function()
			M.clear()
		end, { buffer = M.clear_buf })
		-- keymap to update
		vim.keymap.set("n", M.key_update, function()
			M.update()
		end, { buffer = M.clear_buf })
	end
	-- calculate col and row params
	local col = math.floor((vim.api.nvim_get_option("columns") - M.width) / 2)
	local row = math.floor((vim.api.nvim_get_option("lines") - M.height) / 2)
	-- if win don't exist create new win
	if not M.win or not vim.api.nvim_win_is_valid(M.win) then
		M.win = vim.api.nvim_open_win(M.home_buf, true, {
			relative = "editor",
			width = M.width,
			height = M.height,
			col = col,
			row = row,
			border = M.border,
		})
		-- delet signcolumn and numberline
		vim.api.nvim_win_set_option(M.win, "number", false)
		vim.api.nvim_win_set_option(M.win, "relativenumber", false)
		vim.api.nvim_win_set_option(M.win, "signcolumn", "no")
		-- add bufferline to winbar
		vim.api.nvim_win_set_option(M.win, "winbar", "[1:home]  2:clear")
		M.update()
		-- goto start of list
		vim.api.nvim_win_set_cursor(M.win, { 4, 3 })
	else
		-- close and delete win
		vim.api.nvim_win_close(M.win, true)
		M.win = nil
	end
end

-- function to setup
function M.setup(opts)
	-- set params
	if opts then
		for key, value in pairs(opts) do
			if M[key] then
				M[key] = value
			end
		end
	end
end

return M
