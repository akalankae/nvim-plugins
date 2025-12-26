-- ────────────────────────────────────────────────────────────────────────────
-- Launch toggable terminal session below running neovim instance
-- ────────────────────────────────────────────────────────────────────────────
-- user/autocmd.lua: "TermOpen" disables line numbers
-- :term or :terminal opens a terminal session on a new buffer
-- You will initially be in normal mode (i.e. you cannot enter text into the
-- terminal).  Press "i", "I", "a", "A" or :startinsert to enter Terminal mode.
-- (cursor moves to end of shell prompt) In Terminal mode all keystrokes go to
-- underlying program, EXCEPT when CTRL-\ is entered.
-- When you press CTRL-\ + CTRL-n you enter normal mode,
-- when you press CTRL-\ + CTRL-o you enter normal mode for ONE command only
-- and then go straight back to Terminal mode.
-- Any other key pressed after CTRL-\ go to the underlying program.
--
--

local M = {
  term_buf = nil,
  term_win = nil,
  orig_win = nil,
}

-- `term_buf` is a required argument
local function open_vsplit_term_win(term_buf, opts)
  local term_opts = { height = 0.4, relativenumber = false }
  local win_opts = vim.tbl_deep_extend("force", term_opts, opts or {})
  vim.cmd.split()
  term_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(term_win, term_buf)
  if win_opts.height then
    if win_opts.height < 1 then
      vim.api.nvim_win_set_height(term_win, math.floor(win_opts.height * vim.o.lines))
    else
      vim.api.nvim_win_set_height(term_win, win_opts.height)
    end
    win_opts.height = nil
  end
  for opt, opt_value in pairs(win_opts) do
    vim.api.nvim_set_option_value(opt, opt_value, { win = term_win })
  end
  return term_win
end

-- Toggle "integrated" terminal
local function toggle_term(opts)
  -- save win ID of current window
  local curr_win = vim.api.nvim_get_current_win()

  -- If current window is the terminal window close it
  if M.term_win and curr_win == M.term_win then
    vim.api.nvim_win_close(M.term_win, false)
    M.term_win = nil
    if M.last_win and vim.api.nvim_win_is_valid(M.last_win) then
      vim.api.nvim_set_current_win(M.last_win)
    end
    return
  end

  M.last_win = curr_win

  -- If we got a valid terminal buffer AND terminal window AND current window is not a
  -- terminal window, launch this terminal window
  if M.term_buf and vim.api.nvim_buf_is_valid(M.term_buf) then
    if M.term_win and vim.api.nvim_win_is_valid(M.term_win) then
      vim.api.nvim_set_current_win(M.term_win)
    -- If terminal window is closed, create a new split window and load terminal buffer in
    -- this vertical split window
    else
      M.term_win = open_vsplit_term_win(M.term_buf)
    end
  -- If we haven't got a terminal buffer, create one along with a terminal window and spin
  -- up a new shell session in this window
  else
    M.term_buf = vim.api.nvim_create_buf(true, false)
    M.term_win = open_vsplit_term_win(M.term_buf)
    vim.fn.termopen(vim.o.shell)
  end
  -- Once terminal window is opened with the shell session, go to insert mode
  vim.cmd.startinsert()
end

function M.setup(opts)
  opts = opts or {}

  -- vim.keymap.set("n", "<Leader>t", function() toggle_term(opts) end, { remap = false })
  vim.keymap.set("n", "<Leader>t", toggle_term,  { remap = false })

end

return M
