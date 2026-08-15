require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

-- tmux-aware window/pane navigation (see ~/.tmux.conf smart-splits integration)
-- mapped in both normal and terminal mode so it also works from inside
-- embedded terminal buffers (opencode, claudecode, lazygit, toggleterm, etc.)
map({ "n", "t" }, "<C-h>", function()
  require("smart-splits").move_cursor_left()
end, { desc = "switch window left" })
map({ "n", "t" }, "<C-j>", function()
  require("smart-splits").move_cursor_down()
end, { desc = "switch window down" })
map({ "n", "t" }, "<C-k>", function()
  require("smart-splits").move_cursor_up()
end, { desc = "switch window up" })
map({ "n", "t" }, "<C-l>", function()
  require("smart-splits").move_cursor_right()
end, { desc = "switch window right" })

map("i", "jk", "<ESC>")
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("n", "<leader>tr", "<cmd>TypstPreview<cr>", { desc = "Typst Preview" })
map("n", "<leader>pv", ":Telescope file_browser<CR>", { desc = "Telescope File Browser (Root)" })
map(
  "n",
  "<leader>pe",
  ":Telescope file_browser path=%:p:h select_buffer=true<CR>",
  { desc = "Telescope File Browser (Current File)" }
)

map("n", "<leader>q", "<cmd>NvimTreeClose<CR>", { desc = "Close NvimTree" })
