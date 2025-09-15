
# 🚀 My NvChad Neovim Configuration

my nvim setup built from NvChad for mainly python, cpp, and rust development
---

## ✨ Features

**🎨 Modern Aesthetics**

* NvChad base configuration with clean themes
* `noice.nvim` for enhanced UI notifications
* Minimal interface, multiple theme support (`<Space>th`)

**🔧 Development Tools**

* Multi-language LSP: Python (`pyright`), JS/TS (`ts_ls`), C/C++ (`clangd`), Rust (`rust_analyzer`), HTML/CSS
* Formatters: Black, Biome, Stylua, clang-format
* GitHub Copilot integration
* Terminal management via `toggleterm.nvim`
* Git workflow enhancements

**📋 Clipboard & Registers**

* `nvim-neoclip` for persistent history (1000+ items)
* Advanced buffer and register management
* System clipboard auto-sync

**🗂️ Buffer & Navigation**

* Telescope-powered buffer switching
* Number-jump buffer access (`<leader>1-9`)
* Session and layout management

**⚡ Productivity**

* Lazy loading for fast startup
* Custom keybindings for dev workflow
* Auto-completion and Treesitter syntax highlighting

---

## 📦 Plugin Stack

**Core:** NvChad, `lazy.nvim`
**LSP & Formatting:** `nvim-lspconfig`, `conform.nvim`, `nvim-treesitter`, `copilot.vim`, `copilot-cmp`
**UI & Experience:** `noice.nvim`, `nvim-notify`, `nui.nvim`
**Terminal & Clipboard:** `toggleterm.nvim`, `nvim-neoclip.lua`
**Buffer & Navigation:** `buffer_manager.nvim`, `telescope.nvim`

---

## ⌨️ Key Mappings (Highlights)

**Buffers:**

* `<S-h>/<S-l>`: Previous/Next buffer
* `<leader>1-9`: Jump to buffer by number
* `<leader>bb`: Buffer manager

**Clipboard:**

* `<leader>p`: Clipboard history
* `<leader>cy`: Copy to system clipboard

**Terminal:**

* `<C-\>`: Toggle terminal
* `<leader>tf/tv/tp/tn/gg`: Floating/vertical terminals, REPLs, Lazygit

**LSP & Formatting:**

* `<leader>mp`: Format file
* `gd/gr/K`: Go to definition / references / hover
* `<leader>ca`: Code actions

**Theme & UI:**

* `<leader>th`: Theme picker
* `<leader>uu`: Toggle transparency

---

## 🎯 Language Support

**Python:** Pyright, Black, REPL, debugger ready
**JS/TS:** ts\_ls, Biome, inlay hints, Node.js REPL
**C/C++:** clangd, clang-format, project indexing
**Systems/DevOps:** Lua/Stylua, Markdown, JSON/YAML, shell scripts

---

If you want, I can also make an **even shorter “one-page” version** that’s fully copy-paste ready for a GitHub README. It would basically be a single **screen of essentials**.

Do you want me to do that?
