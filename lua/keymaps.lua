local map = vim.keymap.set

map("i", "jk", "<Esc>")
map("n", "<Esc>", "<cmd>noh<cr>", { desc = "clear search highlight" })
map("n", "<C-s>", "<cmd>w<cr>", { desc = "save file" })
map("v", ">", ">gv")
map("v", "<", "<gv")
map("n", "<leader>/", "gcc", { desc = "toggle comment", remap = true })
map("v", "<leader>/", "gc", { desc = "toggle comment", remap = true })
map("t", "<C-x>", "<C-\\><C-n>", { desc = "leave terminal mode" })

-- buffers
map("n", "<Tab>", "<cmd>bnext<cr>", { desc = "next buffer" })
map("n", "<S-Tab>", "<cmd>bprevious<cr>", { desc = "previous buffer" })
map("n", "<leader>x", "<cmd>bdelete<cr>", { desc = "close buffer" })

-- windows: moves across nvim splits and tmux panes alike (smart-splits).
-- Also in terminal mode so it works from :terminal buffers.
for key, dir in pairs { h = "left", j = "down", k = "up", l = "right" } do
  map({ "n", "t" }, "<C-" .. key .. ">", function()
    require("smart-splits")["move_cursor_" .. dir]()
  end, { desc = "go to window " .. dir })
end
map("n", "<C-\\>", function() -- normal mode only: <C-\><C-n> must still leave terminal mode

  require("smart-splits").move_cursor_previous()
end, { desc = "go to previous window" })

-- Plugin keymaps live in their specs under lua/plugins/.
