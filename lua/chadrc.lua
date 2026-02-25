---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "tokyonight",
  transparency = true,
}

-- Helper function to gather project intel
local function get_project_stats()
  local stats = {}

  -- 1. Get Directory & Git Info
  local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
  local git_branch = vim.fn.system("git branch --show-current 2>/dev/null"):gsub("\n", "")

  -- 2. Count Files by Type (Info-heavy)
  local file_count = vim.fn.split(vim.fn.glob "*", "\n")
  local cpp_count = #vim.fn.glob("*.cpp", false, true) + #vim.fn.glob("*.hpp", false, true)
  local py_count = #vim.fn.glob("*.py", false, true)

  -- 3. Get mini-tree (first 6 items)
  local handle = io.popen "ls -F | head -n 6"
  local tree = handle:read "*a"
  handle:close()

  table.insert(stats, "󰉖  PROJECT: " .. cwd)
  table.insert(stats, "󰊢  BRANCH : " .. (git_branch ~= "" and git_branch or "no git"))
  table.insert(stats, "󰚗  ASSETS : " .. #file_count .. " items (" .. cpp_count .. " C++, " .. py_count .. " Py)")
  table.insert(stats, " ")
  table.insert(stats, "󰙅  FILE TREE")
  table.insert(stats, "   " .. string.rep("─", 25))

  for line in tree:gmatch "([^\n]*)\n?" do
    if line ~= "" then
      local icon = line:match "/$" and "󰉋 " or "󰈔 "
      table.insert(stats, "   ├── " .. icon .. line)
    end
  end
  table.insert(stats, "   " .. string.rep("─", 25))

  return stats
end

M.nvdash = {
  load_on_startup = true,
  header = (function()
    local header = {
      " ",
      "  󱗼  N E O V I M 󱗼 ",
      " ",
    }
    vim.list_extend(header, get_project_stats())
    return header
  end)(),

  -- Buttons used as a functional "Help Menu"
  buttons = {
    { txt = "  Find File", keys = "󱁐  ff", cmd = "Telescope find_files" },
    { txt = "󰈚  Recent", keys = "󱁐  fo", cmd = "Telescope oldfiles" },
    {
      txt = "󰊢  Lazygit",
      keys = "󱁐  gg",
      cmd = "lua require('toggleterm.terminal').Terminal:new({cmd='lazygit', direction='float'}):toggle()",
    },
    { txt = "  Config", keys = "󱁐  ch", cmd = "nvchad update" },
  },
}

M.ui = {
  tabufline = { lazyload = false },
}

return M
