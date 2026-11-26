-- Minimal global statusline: mode | file | git branch | diagnostics ... filetype | position
local M = {}

local modes = {
  n = "NORMAL", i = "INSERT", v = "VISUAL", V = "V-LINE", ["\22"] = "V-BLOCK",
  c = "COMMAND", R = "REPLACE", t = "TERMINAL", s = "SELECT", S = "S-LINE",
}

-- diffview's buffers have names like diffview:///repo/.git/<rev>/path; show them readably.
local function name()
  local buf = vim.api.nvim_buf_get_name(0)
  if not vim.startswith(buf, "diffview://") then
    return "%f%m%r"
  end
  if vim.bo.filetype:match "^Diffview" then
    return "review"
  end
  local rev, path = buf:match "/%.git/([^/]+)/(.+)$"
  if not rev then
    return vim.fn.fnamemodify(buf, ":t")
  end
  local label = rev == ":0:" and "index" or rev:match "^%x+$" and "@" .. rev:sub(1, 7) or "old"
  return ("%s (%s)"):format(path:gsub("%%", "%%%%"), label)
end

function M.render()
  local mode = modes[vim.fn.mode()] or vim.fn.mode()
  local branch = vim.b.gitsigns_head and ("  " .. vim.b.gitsigns_head) or ""
  local diag = vim.diagnostic.status()
  return table.concat {
    "%#StatusLineMode# ", mode, " %*",
    " ", name(),
    branch,
    diag ~= "" and ("  " .. diag) or "",
    "%=",
    vim.bo.filetype, "  %l:%c  %P ",
  }
end

function M.setup()
  local function hl()
    vim.api.nvim_set_hl(0, "StatusLineMode", { link = "CursorLineNr", default = true })
  end
  hl()
  vim.api.nvim_create_autocmd("ColorScheme", { callback = hl })
  vim.o.statusline = "%!v:lua.require'statusline'.render()"
end

return M
