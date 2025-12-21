local M = {}

-- Cycle through available colorschemes
-- Move forward and backward  between colorschemes

local function user_notify(success, theme)
    if success then
        vim.notify("Colorscheme switched to " .. theme, vim.log.levels.INFO)
    else
        vim.notify("Failed to load colorscheme " .. theme, vim.log.levels.INFO)
    end
end

-- NOTE: For all valid lua indices: 0 < i <= highest
local function get_next_index(current_index, highest)
  if current_index < 1 or current_index > highest then
    error(string.format("Current index %d not between 1 and %d, inclusive!", current_index, highest))
  end
  return current_index == highest and 1 or (current_index + 1)
end

local function get_prev_index(current_index, highest)
  if current_index < 1 or current_index > highest then
    error(string.format("Current index %d not between 1 and %d, inclusive!", current_index, highest))
  end
  return current_index == 1 and highest or (current_index - 1)
end

local function list_index(list, value)
  for i, item in ipairs(list) do
    if item == value then
      return i
    end
  end
  return nil
end

local function next_theme()
  local colorschemes = vim.fn.getcompletion("", "color")
  local index = list_index(colorschemes, vim.g.colors_name)
  local new_colorscheme = colorschemes[get_next_index(index, #colorschemes)]
  local status, _ = pcall(vim.cmd, "colorscheme " .. new_colorscheme)
  user_notify(status, new_colorscheme)
end

local function prev_theme()
  local colorschemes = vim.fn.getcompletion("", "color")
  local index = list_index(colorschemes, vim.g.colors_name)
  local new_colorscheme = colorschemes[get_prev_index(index, #colorschemes)]
  local status, _ = pcall(vim.cmd, "colorscheme " .. new_colorscheme)
  user_notify(status, new_colorscheme)
end

--=============================================================================
-- Load last used colorscheme on startup
--=============================================================================
-- Ensure (1) our colorscheme data file exists, (2) it contains a name of a
-- colorscheme and (3) this colorscheme is available to load.
local function load_last_colorscheme(colorscheme_file, fallback)
  local available_colorschemes = vim.fn.getcompletion("", "color")
  local fallback = fallback or "default"
  local use_colorscheme = nil
  if vim.uv.fs_stat(colorscheme_file) then
    local last_colorscheme = vim.fn.readfile(colorscheme_file)[1]
    if last_colorscheme and vim.tbl_contains(available_colorschemes, last_colorscheme) then
      use_colorscheme = last_colorscheme
    end
  end
  -- vim.cmd(string.format("colorscheme %s", use_colorscheme or fallback))
  vim.cmd("colorscheme " .. (use_colorscheme or fallback))
  vim.notify("Loaded " .. vim.g.colors_name .. " colorscheme", vim.log.levels.INFO)
end


function M.setup(opts)
  opts = opts or {}
  local colorscheme_file = opts.colorscheme_file
    or vim.fn.stdpath("state") .. "/colorscheme.dat"

  vim.keymap.set({"n", "v", "o"}, opts.next or "<M-n>", next_theme,
    { noremap = true, silent = true, desc = "Switch to next colorscheme" })

  vim.keymap.set({"n", "v", "o"}, opts.prev or "<M-p>", prev_theme,
    { noremap = true, silent = true, desc = "Switch to previous colorscheme" })

  --=============================================================================
  -- Load last used colorscheme on startup
  --=============================================================================
  
  vim.api.nvim_create_autocmd("VimEnter", {
    pattern = "*",
    callback = function()
      load_last_colorscheme(colorscheme_file, opts.fallback_colorscheme)
    end,
    group = vim.api.nvim_create_augroup("LoadLastColorscheme", { clear = true }),
    desc = "Load last used colorscheme on startup"
  })

  --=============================================================================
  -- Record last used colorscheme on exit
  --=============================================================================

  vim.api.nvim_create_autocmd("VimLeave", {
    pattern = "*",
    callback = function()
      local status = vim.fn.writefile({ vim.g.colors_name }, colorscheme_file)
      if status == -1 then
        vim.notify("Failed to write colorscheme to file", vim.log.levels.ERROR)
      end
    end,
    group = vim.api.nvim_create_augroup("RecordLastColorscheme", { clear = true }),
    desc = "Record active colorscheme on exit"
  })

end

return M
