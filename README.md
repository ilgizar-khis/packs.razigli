# packs.razigli

> My simple utility to get a list of installed packages 
> and disabled packages

## functions

- win_toggle() -- function to toggle of window.
- setup() -- set options of package.
- to_next() -- go to next item.
- to_prev() -- go to prev item.
- toggle_status() -- toggle status of disabled package.
- clear() -- delete all marked as minus \[-\] disabled packages.
- update() -- update list of packahes.


## default parameters

|name|value|desc|
|----|:----------:|----|
|home_buf|nil|id of home_buf|
|clear_buf|nil|id of clear_buf|
|width|160|width of win|
|height|40|height of win|
|border|single|border style of win|
|key_home_buf|1|key goto home_buf|
|key_clear_buf|2|key goto clear_buf|
|key_toggle_status|<Space>|key toggle status of prev pkg|
|key_clear|<CR>|key start delete pkgs|
|key_update|<S-u>|key update list of pkgs|
|key_to_next|<Tab>|key goto next pkg|
|key_to_prev|<S-Tab>|key goto prev pkg|
|info|nil|info str|

