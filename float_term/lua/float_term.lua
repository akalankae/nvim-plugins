local M = {}

function LaunchFloatingWindow(buf, opts)
  if not vim.api.nvim_buf_is_valid(buf) then
    vim.notify(
    "Creating Buffer #" .. tostring(buf),
    vim.log.levels.INFO
  )
  else
    vim.notify(
      "Buffer #" .. tostring(buf) .. " was found",
      vim.log.levels.INFO
    )
  end
  -- if not vim.api.nvim_buf_is_valid(buf) then
  --   buf = vim.api.nvim_create_buf(false, true)
  -- else
  --   vim.notify("Buffer #" .. tostring(buf) .. " was found",
  --   vim.log.levels.INFO)
  -- end
  -- return buf
end







function M.setup(opts)
  local buf = vim.api.nvim_create_buf(false, true)

  -- setup the keymappings
  vim.keymap.set("n", "<Leader>t", function()
    LaunchFloatingWindow(buf, opts)
  end,
  { noremap = true })
end


return M
