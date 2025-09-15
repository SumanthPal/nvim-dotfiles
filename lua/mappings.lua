require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("i", "jk", "<ESC>")
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "<", "<gv")
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
