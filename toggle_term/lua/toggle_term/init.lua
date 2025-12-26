local M = {}

M.defaults = {}

M.init = function()
  require("toggle_term.core").setup(M.settings)
end

M.setup = function(user_opts)
  M.settings = vim.tbl_deep_extend("force", M.defaults, user_opts or {})
  M.init()
  return M.settings
end

M.config = function()
  M.settings = vim.tbl_deep_extend("force", M.defaults, M.opts or {})
  M.init()
end

return M
