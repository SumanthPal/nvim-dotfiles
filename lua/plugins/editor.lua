return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      defaults = {
        sorting_strategy = "ascending",
        layout_config = { horizontal = { prompt_position = "top" } },
      },
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "find files" },
      { "<leader>fa", "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<cr>", desc = "find all files" },
      { "<leader>fw", "<cmd>Telescope live_grep<cr>", desc = "live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "buffers" },
      { "<leader>fo", "<cmd>Telescope oldfiles<cr>", desc = "recent files" },
      { "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "search in buffer" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "help" },
    },
  },

  {
    "nvim-tree/nvim-tree.lua",
    lazy = false, -- so `nvim .` opens the tree (netrw is disabled)
    opts = {
      view = { width = 30 },
      renderer = { root_folder_label = false },
      actions = { open_file = { window_picker = { enable = false } } },
    },
    keys = {
      { "<C-n>", "<cmd>NvimTreeToggle<cr>", desc = "toggle file tree" },
      { "<leader>e", "<cmd>NvimTreeFocus<cr>", desc = "focus file tree" },
      { "<leader>q", "<cmd>NvimTreeClose<cr>", desc = "close file tree" },
    },
  },

  {
    -- main branch: parsers are compiled by the tree-sitter CLI (brew install tree-sitter-cli).
    -- Highlighting is started per buffer in autocmds.lua.
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      if vim.fn.executable "tree-sitter" == 0 then
        return
      end
      require("nvim-treesitter").install {
        "bash", "c", "cpp", "css", "diff", "gitcommit", "html", "javascript", "json",
        "lua", "markdown", "markdown_inline", "python", "rust", "toml", "tsx",
        "typescript", "typst", "vim", "vimdoc", "yaml",
      }
    end,
  },

  {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    opts = {
      ignored_filetypes = { "NvimTree" },
      ignored_buftypes = { "nofile" },
    },
  },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      label = { uppercase = true },
      modes = {
        search = { enabled = true }, -- jump labels while searching with / and ?
        char = { jump_labels = true }, -- labels for f/F/t/T
      },
    },
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "flash jump" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "flash treesitter select" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "flash remote" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "flash treesitter search" },
      { "<C-s>", mode = "c", function() require("flash").toggle() end, desc = "toggle flash in search" },
    },
  },
}
