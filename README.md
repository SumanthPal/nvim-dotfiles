# nvim

my nvim setup for development w/ agentic focus. this setup is primarily for looking and reviewing code. i still use this to write with my configured lsps for learning purposes.

```
init.lua            leader, lazy bootstrap, loads the modules below
lua/options.lua     editor options, filetypes, mason PATH
lua/keymaps.lua     general + window/buffer keymaps
lua/autocmds.lua    checktime for agent edits, treesitter start
lua/lsp.lua         servers (vim.lsp.config/enable), diagnostics, LSP keymaps
lua/statusline.lua  global statusline
lua/agents.lua      <leader>a/A send file:line to an agent pane; target for `nvo`
lua/review.lua      <leader>g* code review with diffview; review.md is the checklist
lua/plugins/        ui, editor, lsp (mason/blink/conform), git
```

this setup needs the following: `tree-sitter-cli` (parsers), `node` (mason's npm-based servers), `rg`.
