-- Code review helpers for diffview (keymaps in plugins/git.lua).
local M = {}

-- Side by side needs room for two ~80-column panes plus the file list. Narrower
-- (e.g. nvim in a tmux split beside an agent): old above new, file list on top.
-- g<C-x> in a review cycles layouts if you resize mid-review.
local WIDE = 160

local function wide()
  return vim.o.columns >= WIDE
end

function M.panel()
  if wide() then
    return { position = "left", width = 32 }
  end
  return { position = "top", height = math.max(6, math.floor(vim.o.lines * 0.2)) }
end

-- Open a diffview command with the layout that fits the current width.
function M.open(cmd)
  local view = require("diffview.config").get_config().view
  local layout = wide() and "diff2_horizontal" or "diff2_vertical"
  view.default.layout = layout
  view.file_history.layout = layout
  vim.cmd(cmd)
end

local function git(...)
  local res = vim.system({ "git", ... }, { text = true }):wait()
  return res.code == 0 and vim.trim(res.stdout) or nil
end

-- Local main/master if present, else whatever origin/HEAD points to.
local function base_branch()
  for _, name in ipairs { "main", "master" } do
    if git("rev-parse", "--verify", "--quiet", "refs/heads/" .. name) then
      return name
    end
  end
  local remote = git("rev-parse", "--abbrev-ref", "origin/HEAD")
  return remote ~= "origin/HEAD" and remote or nil
end

-- Everything this branch changed since it left main. --imply-local makes the
-- right side your real files, so LSP (gd, grr, K) and <leader>a work in the diff.
function M.branch()
  local base = base_branch()
  if not base then
    return vim.notify("review: no main, master or origin/HEAD here", vim.log.levels.WARN)
  end
  if git("rev-parse", "--abbrev-ref", "HEAD") == base then
    return vim.notify("review: you're on " .. base .. "; <leader>gr reviews uncommitted changes")
  end
  M.open(("DiffviewOpen %s...HEAD --imply-local"):format(base))
end

-- Toggle the checklist (review.md, a real file you can edit) in a float.
local win
function M.checklist()
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
    win = nil
    return
  end
  local path = vim.fn.stdpath "config" .. "/review.md"
  local buf = vim.fn.bufadd(path)
  vim.fn.bufload(buf)
  local width = math.min(80, vim.o.columns - 4)
  local height = math.min(vim.api.nvim_buf_line_count(buf), vim.o.lines - 6)
  win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2) - 1,
    border = "rounded",
    title = " review checklist · <leader>g? or q to close ",
    title_pos = "center",
  })
  vim.bo[buf].bufhidden = "hide"
  vim.keymap.set("n", "q", M.checklist, { buffer = buf, desc = "close checklist" })
end

return M
