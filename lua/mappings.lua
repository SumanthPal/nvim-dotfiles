require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

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
