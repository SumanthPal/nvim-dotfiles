---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "bearded-arc",
  transparency = true,
}

M.nvdash = {
  load_on_startup = true,
  header = (function()
    local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t"):upper()

    -- ── Git info ──────────────────────────────────────────────────────────
    local function git(cmd)
      local out = vim.fn.system(cmd .. " 2>/dev/null"):gsub("\n$", "")
      return out ~= "" and out or nil
    end

    local branch = git "git branch --show-current"
    local git_status = git "git status --porcelain"
    local ahead_raw = git "git rev-list --count @{u}..HEAD"
    local behind_raw = git "git rev-list --count HEAD..@{u}"
    local last_commit = git "git log -1 --format='%s' 2>/dev/null"
    local last_author = git "git log -1 --format='%an' 2>/dev/null"
    local last_date = git "git log -1 --format='%cr' 2>/dev/null"
    local commit_count = git "git rev-list --count HEAD"

    -- parse dirty/staged/untracked
    local staged, unstaged, untracked = 0, 0, 0
    if git_status then
      for line in git_status:gmatch "[^\n]+" do
        local x, y = line:sub(1, 1), line:sub(2, 2)
        if x ~= " " and x ~= "?" then
          staged = staged + 1
        end
        if y == "M" or y == "D" then
          unstaged = unstaged + 1
        end
        if x == "?" then
          untracked = untracked + 1
        end
      end
    end

    -- ── File stats ────────────────────────────────────────────────────────
    local function count_files(pattern)
      local result = vim.fn.system("fd --type f " .. pattern .. " 2>/dev/null | wc -l"):gsub("%s", "")
      return tonumber(result) or 0
    end

    local total_files = tonumber(vim.fn.system("fd --type f 2>/dev/null | wc -l"):gsub("%s", "")) or 0
    local total_dirs = tonumber(vim.fn.system("fd --type d 2>/dev/null | wc -l"):gsub("%s", "")) or 0
    local lua_files = count_files "-e lua"
    local js_files = count_files "-e js -e ts -e jsx -e tsx"
    local py_files = count_files "-e py"
    local cpp_files = count_files "-e cpp -e cc -e h -e hpp"

    -- ── Recent files (top 4) ──────────────────────────────────────────────
    local recent_raw = vim.fn.system("fd --type f 2>/dev/null | head -4"):gsub("\n$", "")

    -- ── Directory tree (top-level, dirs first) ────────────────────────────
    local all = vim.fn.systemlist "fd --max-depth 1 2>/dev/null | sort"
    local dirs, files = {}, {}
    for _, p in ipairs(all) do
      local name = p:gsub("^%./", "")
      if name ~= "" then
        if vim.fn.isdirectory(vim.fn.getcwd() .. "/" .. name) == 1 then
          table.insert(dirs, name)
        else
          table.insert(files, name)
        end
      end
    end

    -- ── Build header ──────────────────────────────────────────────────────
    local h = {}
    local function add(line)
      table.insert(h, line or " ")
    end
    local pad = "  "

    -- Title
    add "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗"
    add "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║"
    add "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║"
    add "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║"
    add "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║"
    add "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝"
    add()

    -- Project name + path
    add(pad .. "󱞩  " .. project_name)
    add(pad .. "󰉖  " .. cwd)
    add()

    -- ── Git panel ─────────────────────────────────────────────────────────
    if branch then
      add(
        pad
          .. "━━━  GIT  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      )
      add(
        pad
          .. "󰊢  Branch  : "
          .. branch
          .. (ahead_raw and tonumber(ahead_raw) > 0 and ("  󰁝 +" .. ahead_raw) or "")
          .. (behind_raw and tonumber(behind_raw) > 0 and ("  󰁅 -" .. behind_raw) or "")
      )

      -- status summary
      local status_parts = {}
      if staged > 0 then
        table.insert(status_parts, "󰐕 " .. staged .. " staged")
      end
      if unstaged > 0 then
        table.insert(status_parts, "󰝤 " .. unstaged .. " modified")
      end
      if untracked > 0 then
        table.insert(status_parts, "󰋗 " .. untracked .. " new")
      end
      local status_str = #status_parts > 0 and table.concat(status_parts, "  ") or "󰄬 clean"
      add(pad .. "   Status  : " .. status_str)

      if commit_count then
        add(pad .. "   Commits : " .. commit_count .. " total")
      end
      if last_commit then
        add(pad .. "   Last    : " .. (last_commit:sub(1, 48)))
        add(pad .. "            " .. (last_author or "?") .. "  ·  " .. (last_date or "?"))
      end
      add()
    end

    -- ── Files panel ───────────────────────────────────────────────────────
    add(
      pad
        .. "━━━  FILES  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    )
    add(pad .. string.format("󰙅  %d files   󰉋 %d dirs", total_files, total_dirs))

    -- language breakdown (only show non-zero)
    local lang_parts = {}
    if lua_files > 0 then
      table.insert(lang_parts, " lua:" .. lua_files)
    end
    if js_files > 0 then
      table.insert(lang_parts, "󰌞 js/ts:" .. js_files)
    end
    if py_files > 0 then
      table.insert(lang_parts, " py:" .. py_files)
    end
    if cpp_files > 0 then
      table.insert(lang_parts, " c++:" .. cpp_files)
    end
    if #lang_parts > 0 then
      add(pad .. "   " .. table.concat(lang_parts, "   "))
    end
    add()

    -- ── Tree panel ────────────────────────────────────────────────────────
    add(
      pad
        .. "━━━  TREE  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    )
    local shown = 0
    for _, d in ipairs(dirs) do
      if shown >= 5 then
        break
      end
      add(pad .. "  󰉋 " .. d .. "/")
      shown = shown + 1
    end
    for _, f in ipairs(files) do
      if shown >= 8 then
        break
      end
      add(pad .. "  󰈔 " .. f)
      shown = shown + 1
    end
    local remaining = (#dirs + #files) - shown
    if remaining > 0 then
      add(pad .. "  󰇘 … " .. remaining .. " more")
    end
    add()

    return h
  end)(),

  buttons = {},
}

M.ui = {
  tabufline = { lazyload = false },
}

return M
