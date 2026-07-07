# packs.razigli

> My simple utility to get a list of installed packages 
> and disabled packages

## functions

|name|desc|
|----|----|
|win_toggle() |function to toggle of window.
|setup() |set options of package.
|to_next() |go to next item.
|to_prev() |go to prev item.
|toggle_status() |toggle status of disabled package.
|clear() |delete all marked as minus \[-\] disabled packages.
|update() |update list of packahes.


## default parameters

|name|value|desc|
|----|:----------:|----|
|width|160|width of win|
|height|40|height of win|
|border|single|border style of win|
|key_home_buf|1|key goto home_buf|
|key_clear_buf|2|key goto clear_buf|
|key_toggle_status|\<Space>|key toggle status of prev pkg|
|key_clear|\<CR>|key start delete pkgs|
|key_update|\<S-u>|key update list of pkgs|
|key_to_next|\<Tab>|key goto next pkg|
|key_to_prev|\<S-Tab>|key goto prev pkg|

## variables

|name|value|desc|
|----|-----|----|
|win | nil | id of win, if nil => win is not exists |
|home_buf | nil | id of home_buf, if nil => buf is not exists|
|clear_buf | nil | id of clear_buf, if nil => buf is not exists|

## usage example: vim.pack

```lua
vim.pack.add({
	{
		src = "https://github.com/ilgizar-khis/packs.razigli.git",
		version = "main",
	},
})

local packs = require("packs.razigli")
packs.setup({
    width = 130,
})

vim.api.nvim_create_user_command("Packs", function()
	packs.toggle_win()
end, {})
```
