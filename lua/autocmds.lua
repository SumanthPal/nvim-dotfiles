require "nvchad.autocmds"

-- Pick up external file changes promptly (claude-code / opencode writing files)
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = vim.api.nvim_create_augroup("CheckTimeExternalChanges", { clear = true }),
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd "checktime"
    end
  end,
})
