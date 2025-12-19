local M = {}

local float_opts = {
  width = 80, height = 35, row = 10, col = 5,
}

function CreateFloatTerm(opts)
  if opts.row then
    float_opts.row = opts.row
  end
  if opts.col then
    float_opts.col = opts.col
  end
  if not float_opts.buf or not vim.api.nvim_buf_is_valid(float_opts.buf) then
    float_opts.buf = vim.api.nvim_create_buf(false, true)
    vim.notify("New buffer #" .. tostring(float_opts.buf) .. " created", vim.log.levels.error)
  end
  if float_opts.buf ~= 0 then
    local win_id = vim.api.nvim_open_win(float_opts.buf, true, {
      relative = "win", row = float_opts.row, col = float_opts.col, width = float_opts.width, height = float_opts.height
    })
  end
end

function M.setup(options)
  if options then
    for _, v in ipairs({"width", "height", "row", "col"}) do
      if options[v] then
        float_opts[v] = options[v]
      end
    end
  end
  vim.keymap.set("n", "<Leader>t", function() 
    CreateFloatTerm(float_opts)
  end, { noremap = true })
end

return M
