-- main table
local M = {
	win = nil, -- id of win
	home_buf = nil, -- id of home_buf
	clear_buf = nil, -- id of clear_buf
	width = 160, -- width of win
	height = 40, -- height of win
	border = "single", -- border style of win
	key_home_buf = "1", -- key "goto home_buf"
	key_clear_buf = "2", -- key "goto clear_buf"
	key_toggle_status = "<Space>", -- key "toggle status of prev pkg"
	key_clear = "<CR>", -- key "start delete pkgs"
	key_update = "<S-u>", -- key "update list of pkgs"
	key_to_next = "<Tab>", -- key "goto next pkg"
	key_to_prev = "<S-Tab>", -- key "goto prev pkg"
	info = nil, -- info str
}

-- goto next pkg
function M.to_next()
	-- get datas
	local lineNr = vim.api.nvim_win_get_cursor(M.win)[1]
	local buf = vim.api.nvim_win_get_buf(M.win)
	local lines = vim.api.nvim_buf_get_lines(buf, lineNr, -1, false)
	-- iterate all lines
	for i, line in ipairs(lines) do
		-- if find line
		if string.find(line, "^%[[%+%- ]%]") then
			-- jump to next name
			vim.api.nvim_win_set_cursor(M.win, { lineNr + i, 3 })
			return
		end
	end
	-- jump to start
	vim.api.nvim_win_set_cursor(M.win, { 1, 3 })
end

-- get prev pkg_name line number
function M.get_prev_line(inc_cur) -- inc_cur = include current line?
	local lineNr = vim.api.nvim_win_get_cursor(M.win)[1]
	local buf = vim.api.nvim_win_get_buf(M.win)
	local lines = vim.api.nvim_buf_get_lines(buf, 0, lineNr, false)
	-- iterate all lines
	local start = #lines
	if not inc_cur then
		start = start - 1
	end
	for i = start, 1, -1 do
		local line = lines[i]
		-- if find line
		if string.find(line, "^%[[%+%- ]%]") then
			return i
		end
	end
	-- check from last
	local last_line = vim.api.nvim_buf_line_count(buf)
	lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	for i = last_line, 1, -1 do
		local line = lines[i]
		-- if find line
		if string.find(line, "^%[[%+%- ]%]") then
			return i
		end
	end
end

-- goto prev pkg
function M.to_prev()
	local number = M.get_prev_line()
	-- if number is exist goto number line
	if number then
		vim.api.nvim_win_set_cursor(M.win, { number, 3 })
	end
end

-- toggle status of pkg
function M.toggle_status()
	-- get current buf and checl with M.clear_buf
	local buf = vim.api.nvim_win_get_buf(M.win)
	if buf == M.clear_buf then
		-- get lineNr of prev pkg name and line
		local number = M.get_prev_line(true)
		local line = vim.api.nvim_buf_get_lines(M.clear_buf, number - 1, number, false)[1]
		-- set "[-]" to "[ ]" or "[ ]" to "[-]"
		if string.find(line, "%[%-%]") then
			line, _ = string.gsub(line, "%[%-%]", "[ ]")
		elseif string.find(line, "%[ %]") then
			line, _ = string.gsub(line, "%[ %]", "[-]")
		end
		-- set lines
		vim.api.nvim_buf_set_lines(M.clear_buf, number - 1, number, false, { line })
	end
end

-- function to clear pkgs
function M.clear()
	-- get lines from clear_buf
	local lines = vim.api.nvim_buf_get_lines(M.clear_buf, 0, -1, false)
	local to_clear = {}
	-- delete all pkgs
	for _, line in ipairs(lines) do
		if string.find(line, "^%[%-%]") then
			table.insert(to_clear, string.match(line, "^%[%-%] name = (.+)"))
		end
	end
	-- delete pkgs
	vim.pack.del(to_clear)
	-- update lists
	M.update()
end

-- function to set winbar
function M.winbar()
	-- get current buffer
	local buf = vim.api.nvim_win_get_buf(M.win)
	local winbar = ""
	-- check buffer and set bufferline text
	if buf == M.home_buf then
		winbar = "[1:home]  2:clear "
	else
		winbar = " 1:home  [2:clear]"
	end
	-- add info
	winbar = winbar .. " | " .. M.info
	-- set options
	vim.api.nvim_win_set_option(M.win, "winbar", winbar)
end

-- get all pkgs
function M.parse_all_pkgs(data)
	-- create basic vars
	local lines = {}
	-- iterate data
	for _, pkg in ipairs(data) do
		-- append list and increment count
		local status = pkg.active and "[+]" or "[-]"
		table.insert(lines, status .. " name = " .. pkg.spec.name)
		table.insert(lines, "\tsrc = " .. pkg.spec.src)
	end
	-- return list of lines
	return lines
end

-- parse to_clear pkgs
function M.parse_to_clear_pkgs(data)
	-- create basic vars
	local to_clear_lines = {}
	local to_clear_count = 0
	-- iterate data
	for _, pkg in ipairs(data) do
		-- check to pkg is disabled
		if not pkg.active then
			-- append list and increment count
			to_clear_count = to_clear_count + 1
			table.insert(to_clear_lines, "[-] name = " .. pkg.spec.name)
			table.insert(to_clear_lines, "\tsrc = " .. pkg.spec.src)
		end
	end
	-- return list and count
	return to_clear_lines, to_clear_count
end

-- function to update lists of pkgs
function M.update()
	-- get all datas
	local data = vim.pack.get()
	-- get all pkgs
	local lines = M.parse_all_pkgs(data)
	-- get list of disables pkgs
	local to_clear_lines, to_clear_count = M.parse_to_clear_pkgs(data)
	M.info = "[" .. #data .. ", +" .. #data - to_clear_count .. ", -" .. to_clear_count .. "]"
	M.winbar()
	-- append data tp home_buf
	if M.home_buf then
		vim.api.nvim_buf_set_lines(M.home_buf, 0, -1, true, lines)
	end
	-- append data tp clear_buf
	if M.clear_buf then
		vim.api.nvim_buf_set_lines(M.clear_buf, 0, -1, true, to_clear_lines)
	end
end

-- home_buf setup function
function M.home_buf_setup()
	if not M.home_buf or not vim.api.nvim_buf_is_valid(M.home_buf) then
		M.home_buf = vim.api.nvim_create_buf(false, true)
		-- keymap to jump clear_buf
		vim.keymap.set("n", M.key_clear_buf, function()
			vim.api.nvim_win_set_buf(M.win, M.clear_buf)
			M.winbar()
		end, { buffer = M.home_buf })
		-- update data
		vim.keymap.set("n", M.key_update, function()
			M.update()
		end, { buffer = M.home_buf })
		-- goto next
		vim.keymap.set("n", M.key_to_next, function()
			M.to_next()
		end, { buffer = M.home_buf })
		-- goto prev
		vim.keymap.set("n", M.key_to_prev, function()
			M.to_prev()
		end, { buffer = M.home_buf })
	end
end

-- clear_buf_setup function
function M.clear_buf_setup()
	if not M.clear_buf or not vim.api.nvim_buf_is_valid(M.clear_buf) then
		M.clear_buf = vim.api.nvim_create_buf(false, true)
		-- keymap to jump home_buf
		vim.keymap.set("n", M.key_home_buf, function()
			vim.api.nvim_win_set_buf(M.win, M.home_buf)
			M.winbar()
		end, { buffer = M.clear_buf })
		-- keymap to clear
		vim.keymap.set("n", M.key_clear, function()
			M.clear()
		end, { buffer = M.clear_buf })
		-- keymap to update
		vim.keymap.set("n", M.key_update, function()
			M.update()
		end, { buffer = M.clear_buf })
		-- goto next
		vim.keymap.set("n", M.key_to_next, function()
			M.to_next()
		end, { buffer = M.clear_buf })
		-- goto prev
		vim.keymap.set("n", M.key_to_prev, function()
			M.to_prev()
		end, { buffer = M.clear_buf })
		-- toggle status
		vim.keymap.set("n", M.key_toggle_status, function()
			M.toggle_status()
		end, { buffer = M.clear_buf })
	end
end

-- function to setup win
function M.win_setup()
	-- calculate col and row params
	local col = math.floor((vim.api.nvim_get_option("columns") - M.width) / 2)
	local row = math.floor((vim.api.nvim_get_option("lines") - M.height) / 2)
	-- create and save the win
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
	-- preupdate
	M.update()
end

-- function to open/close win
function M.toggle_win()
	-- create home buffer
	M.home_buf_setup()
	-- create clear buffer
	M.clear_buf_setup()
	-- if win don't exist create new win
	if not M.win or not vim.api.nvim_win_is_valid(M.win) then
		M.win_setup()
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
