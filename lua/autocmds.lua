local autocmd = vim.api.nvim_create_autocmd
local group = vim.api.nvim_create_augroup("user", { clear = true })

-- Pick up file changes made outside nvim (agents in other tmux panes) promptly.
autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = group,
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd "checktime"
    end
  end,
})

-- nvim-treesitter's main branch doesn't start highlighting itself.
-- pcall: a no-op for filetypes whose parser isn't installed.
autocmd("FileType", {
  group = group,
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})
