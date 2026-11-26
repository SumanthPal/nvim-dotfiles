local o, opt = vim.o, vim.opt

o.number = true
o.relativenumber = true
o.numberwidth = 2
o.cursorline = true
o.cursorlineopt = "number"
o.signcolumn = "yes"
o.laststatus = 3 -- one statusline for all windows
o.showtabline = 0 -- no tab bar (diffview opens reviews in a tab)
o.showmode = false -- mode is in the statusline
o.ruler = false
opt.fillchars = { eob = " ", diff = "╱" } -- ╱ hatches diff filler lines
opt.shortmess:append "sI" -- no intro screen

o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.softtabstop = 2
o.smartindent = true

o.ignorecase = true
o.smartcase = true
o.mouse = "a"
o.clipboard = "unnamedplus"
o.splitbelow = true
o.splitright = true
o.splitkeep = "screen"
o.timeoutlen = 400
o.updatetime = 250 -- also drives CursorHold (checktime) and gitsigns
o.undofile = true
opt.whichwrap:append "<>[]hl"

vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- binaries installed by mason.nvim
vim.env.PATH = vim.fn.stdpath "data" .. "/mason/bin:" .. vim.env.PATH

vim.filetype.add {
  extension = { tpp = "cpp", typ = "typst" },
}
