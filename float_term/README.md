# How to create a floating terminal using neovim lua API?

## Important functions

`vim.api.nvim_create_buf()`

`vim.api.nvim_open_float()`

`vim.fn.termopen()`
Looks like `termopen()` is deprecated since v0.11. I have to use one of
following 2 functions to spawn a new terminal.
- `vim.fn.jobstart({cmd}, {opts})`
- `vim.system({cmd}, {opts}, {on_exit})` (? prefer this in Lua, unless using rpc,
  pty or term)


