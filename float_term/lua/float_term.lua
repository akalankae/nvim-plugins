local M = {}

local float = { win = -1, buf = -1 }

function LaunchFloatingWindow(opts)

  if not vim.api.nvim_buf_is_valid(float.buf) then
    float.buf = vim.api.nvim_create_buf(false, true)
    if float.buf == 0 then
      error("Could not create a buffer for floating window!")
      return
    end
    print("Buffer " .. float.buf .. " was created successfully")
  else
    print("Buffer " .. float.buf .. " already exists")
  end

  -- Create window using nvim_open_win(buf, true, {opts})
  if not vim.api.nvim_win_is_valid(float.win) then
    local win_id = vim.api.nvim_open_win(float.buf, true, opts)
    if win_id == 0 then
      error("Could not create a new window!")
      return
    else
      vim.notify("Created new window #" .. win_id, vim.log.levels.INFO)
    end
  else
    float.win = win_id
    print("Window ID #" .. float.win .. " is a valid window")
  end

end


function M.setup(opts)

  local config = vim.tbl_extend("keep", opts or {}, {
   relative = "editor", width = 60, height = 25, col = 5, row = 5
  })


  -- setup the keymappings
  vim.keymap.set("n", "<Leader>t", function()
    LaunchFloatingWindow(config)
    print("Current Mode: " .. vim.fn.mode())
  end,
  { noremap = true })

  vim.keymap.set("t", "<Leader>t", function()
    vim.api.nvim_win_hide(float.win)
  end,
  { noremap = true })

end

return M
