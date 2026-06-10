local M = {}

function M.setup()
	vim.api.nvim_create_user_command("Packs", function()
		vim.notify("TEST")
	end, {})
end
return M
