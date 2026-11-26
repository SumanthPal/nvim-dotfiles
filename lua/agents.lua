-- nvim <-> coding agents running in tmux panes.
--   <leader>a  type `path:line` (or `path:start-end` in visual) into the agent you
--              focused last, then focus it so you can finish the prompt
--   <leader>A  same, but pick the agent (the pick becomes the new default)
-- The other direction is `nvo` (~/dotfiles/tmux/nvo), which finds this nvim
-- through the @nvim_socket pane option set below and calls M.open.
local M = {}

local agents_py = vim.fn.expand "~/dotfiles/tmux/agents.py"

local function tmux(...)
  local res = vim.system({ "tmux", ... }, { text = true }):wait()
  return vim.trim(res.stdout or ""), res.code
end

local function agents()
  local out = vim.system({ "python3", agents_py, "--json" }, { text = true }):wait().stdout
  local ok, list = pcall(vim.json.decode, out or "")
  if not ok or type(list) ~= "table" then
    return {}
  end
  -- This window's agents first, then this session's, then everything else.
  local session, window = tmux("display-message", "-p", "-t", vim.env.TMUX_PANE, "#{session_name}\t#{window_index}")
    :match "^(.-)\t(.*)$"
  window = window or ""
  local function rank(a)
    if a.session ~= session then
      return 2
    end
    return vim.startswith(a.loc, window .. ".") and 0 or 1
  end
  table.sort(list, function(x, y)
    if rank(x) ~= rank(y) then
      return rank(x) < rank(y)
    end
    return x.target < y.target
  end)
  return list
end

-- `path:42` or `path:42-58`, relative to the agent's working directory when possible.
local function reference(agent, first, last)
  local file = vim.api.nvim_buf_get_name(0)
  local cwd = tmux("display-message", "-p", "-t", agent.id, "#{pane_current_path}")
  local path = vim.fs.relpath(cwd, file) or file
  return path .. ":" .. (first == last and first or (first .. "-" .. last))
end

local function send(agent, first, last)
  local ref = reference(agent, first, last)
  tmux("send-keys", "-t", agent.id, "-l", ref .. " ")
  tmux("set-option", "-g", "@last_agent", agent.id)
  tmux("switch-client", "-t", agent.target)
  vim.notify(("→ %s (%s): %s"):format(agent.name, agent.target, ref))
end

local function send_range(pick, first, last)
  if vim.bo.buftype ~= "" or vim.api.nvim_buf_get_name(0) == "" then
    return vim.notify("not a file buffer", vim.log.levels.WARN)
  end
  local list = agents()
  if #list == 0 then
    return vim.notify("no agents running", vim.log.levels.WARN)
  end
  if not pick then
    local last_agent = tmux("show-option", "-gqv", "@last_agent")
    for _, a in ipairs(list) do
      if a.id == last_agent then
        return send(a, first, last)
      end
    end
    if #list == 1 then
      return send(list[1], first, last)
    end
  end
  vim.ui.select(list, {
    prompt = "Send to agent",
    format_item = function(a)
      return ("%-6s %-14s %-5s %-9s %s"):format(a.name, a.session, a.loc, a.state, a.task)
    end,
  }, function(a)
    if a then
      send(a, first, last)
    end
  end)
end

local function mapping(pick)
  return function()
    local first, last = vim.fn.line "v", vim.fn.line "."
    if vim.fn.mode():find "^[vV\22]" then
      vim.api.nvim_feedkeys(vim.keycode "<Esc>", "nx", false)
    end
    send_range(pick, math.min(first, last), math.max(first, last))
  end
end

-- Called by nvo over RPC. Scheduled so it runs outside the RPC request.
function M.open(path, line, col)
  vim.schedule(function()
    vim.cmd "stopinsert"
    -- Don't replace the file tree or other special windows.
    if vim.bo.buftype ~= "" then
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "" then
          vim.api.nvim_set_current_win(win)
          break
        end
      end
    end
    vim.cmd.edit(vim.fn.fnameescape(path))
    if line > 0 then
      pcall(vim.api.nvim_win_set_cursor, 0, { line, math.max(col - 1, 0) })
      vim.cmd "normal! zz"
    end
  end)
  return 0
end

function M.setup()
  local pane = vim.env.TMUX_PANE
  if not pane then
    return
  end
  tmux("set-option", "-p", "-t", pane, "@nvim_socket", vim.v.servername)
  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      tmux("set-option", "-p", "-u", "-t", pane, "@nvim_socket")
    end,
  })
  vim.keymap.set({ "n", "x" }, "<leader>a", mapping(false), { desc = "send location to last agent" })
  vim.keymap.set({ "n", "x" }, "<leader>A", mapping(true), { desc = "send location to an agent (pick)" })
end

return M
