return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },
  {
    "amitds1997/remote-nvim.nvim",
    version = "*", -- Pin to GitHub releases
    dependencies = {
      "nvim-lua/plenary.nvim", -- For standard functions
      "MunifTanjim/nui.nvim", -- To build the plugin UI
      "nvim-telescope/telescope.nvim", -- For picking b/w different remote methods
    },
    config = true,
  },
  {
    "kaarmu/typst.vim",
    ft = "typst",
    lazy = false,
  },
  {
    "chomosuke/typst-preview.nvim",
    ft = "typst",
    build = function()
      require("typst-preview").update()
    end,
    config = function()
      require("typst-preview").setup()
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-cmdline",
    },
    config = function()
      local cmp = require "cmp"

      -- `:` cmdline completion (Ex commands, paths, etc.)
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })

      -- Optional: `/` and `?` search completion from current buffer
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })
    end,
  },
  {
    "hrsh7th/cmp-cmdline",
    lazy = true,
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
      },
      -- This is the key part - disable signature help override
      lsp = {
        signature = {
          enabled = false, -- This fixes tab completion issues
        },
      },
      -- Or alternatively, configure it properly:
      views = {
        cmdline_popup = {
          position = {
            row = 5,
            col = "50%",
          },
          size = {
            width = 60,
            height = "auto",
          },
        },
      },
    },
  },
  --
  -- {
  --   "folke/noice.nvim",
  --   event = "VeryLazy",
  --   opts = {
  --   },
  --   dependencies = {
  --   "MunifTanjim/nui.nvim",
  --   "rcarriga/nvim-notify",
  --
  --   }
  -- },
  {
    "harenome/vim-mipssyntax",
    ft = { "mips", "asm" },
    config = function()
      vim.api.nvim.create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = { "*.s", "*.asm" },
        callback = function()
          vim.bo.filetype = "mips"
        end,
      })
    end,
  },

  {
    "github/copilot.vim",
    event = "InsertEnter",
  },
  {
    "greggh/claude-code.nvim",
    cmd = { "ClaudeCode", "ClaudeCodeContinue", "ClaudeCodeResume", "ClaudeCodeVerbose" },
    dependencies = {
      "nvim-lua/plenary.nvim", -- Required for git operations
    },
    config = function()
      require("claude-code").setup()
    end,
  },

  {
    "zbirenbaum/copilot-cmp",
    event = "InsertEnter",
    dependencies = { "github/copilot.vim" },
    config = function()
      require("copilot_cmp").setup()
    end,
  },
  -- Add this to your plugins table
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("toggleterm").setup {
        -- Terminal settings
        size = function(term)
          if term.direction == "horizontal" then
            return 15
          elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
          end
        end,
        open_mapping = [[<C-\>]], -- Quick toggle with Ctrl+\
        hide_numbers = true,
        shade_filetypes = {},
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        terminal_mappings = true,
        persist_size = true,
        persist_mode = true,
        direction = "horizontal", -- 'vertical' | 'horizontal' | 'tab' | 'float'
        close_on_exit = true,
        shell = vim.o.shell,
        auto_scroll = true,
        -- Floating terminal settings
        float_opts = {
          border = "curved", -- Matches NvChad style
          winblend = 0,
          highlights = {
            border = "Normal",
            background = "Normal",
          },
        },
      }

      -- Custom terminals for different purposes
      local Terminal = require("toggleterm.terminal").Terminal

      -- Floating terminal
      local float_term = Terminal:new {
        direction = "float",
        float_opts = {
          border = "curved",
        },
        hidden = true,
      }

      -- Compilation terminal
      local compile_term = Terminal:new {
        direction = "horizontal",
        hidden = true,
      }

      -- Python REPL
      local python_repl = Terminal:new {
        cmd = "python3",
        direction = "vertical",
        hidden = true,
      }

      -- Node.js REPL
      local node_repl = Terminal:new {
        cmd = "node",
        direction = "vertical",
        hidden = true,
      }

      -- Git lazygit integration (if you have lazygit installed)
      local lazygit = Terminal:new {
        cmd = "lazygit",
        dir = "git_dir",
        direction = "float",
        float_opts = {
          border = "curved",
          width = function()
            return math.floor(vim.o.columns * 0.9)
          end,
          height = function()
            return math.floor(vim.o.lines * 0.9)
          end,
        },
        hidden = true,
        on_open = function(term)
          vim.cmd "startinsert!"
          vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
        end,
      }

      -- Keymaps that integrate with NvChad
      local map = vim.keymap.set

      -- Terminal toggles (using leader key like NvChad)
      -- Language-specific terminals
      map("n", "<leader>tp", function()
        python_repl:toggle()
      end, { desc = "Toggle Python REPL" })
      map("n", "<leader>tn", function()
        node_repl:toggle()
      end, { desc = "Toggle Node REPL" })

      -- Git integration
      map("n", "<leader>gg", function()
        lazygit:toggle()
      end, { desc = "Toggle Lazygit" })

      -- Quick compile and run
      map("n", "<leader>cr", function()
        vim.cmd "w" -- Save file first
        local ft = vim.bo.filetype
        local file = vim.fn.expand "%"
        local cmd = ""

        -- Compilation commands for different languages
        if ft == "c" then
          local output = vim.fn.expand "%:r"
          cmd = string.format("gcc %s -o %s && ./%s", file, output, output)
        elseif ft == "cpp" then
          local output = vim.fn.expand "%:r"
          cmd = string.format("g++ %s -o %s && ./%s", file, output, output)
        elseif ft == "rust" then
          cmd = "cargo run"
        elseif ft == "go" then
          cmd = "go run " .. file
        elseif ft == "python" then
          cmd = "python3 " .. file
        elseif ft == "javascript" then
          cmd = "node " .. file
        elseif ft == "lua" then
          cmd = "lua " .. file
        elseif ft == "java" then
          local classname = vim.fn.expand "%:r"
          cmd = string.format("javac %s && java %s", file, classname)
        else
          print("No compile command for " .. ft)
          return
        end

        compile_term:send(cmd)
        compile_term:open()
      end, { desc = "Compile and run current file" })

      -- Quick compile only
      map("n", "<leader>cb", function()
        vim.cmd "w"
        local ft = vim.bo.filetype
        local file = vim.fn.expand "%"
        local cmd = ""

        if ft == "c" then
          cmd = string.format("gcc %s -o %s", file, vim.fn.expand "%:r")
        elseif ft == "cpp" then
          cmd = string.format("g++ %s -o %s", file, vim.fn.expand "%:r")
        elseif ft == "rust" then
          cmd = "cargo build"
        elseif ft == "go" then
          cmd = "go build " .. file
        elseif ft == "java" then
          cmd = "javac " .. file
        else
          print("No compile command for " .. ft)
          return
        end

        compile_term:send(cmd)
        compile_term:open()
      end, { desc = "Compile current file" })

      -- Terminal navigation (works in terminal mode)
      function _G.set_terminal_keymaps()
        local opts = { buffer = 0 }
        map("t", "<esc>", [[<C-\><C-n>]], opts) -- Easy escape from terminal
        map("t", "jk", [[<C-\><C-n>]], opts) -- Alternative escape
        map("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts) -- Navigate left
        map("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts) -- Navigate down
        map("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts) -- Navigate up
        map("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts) -- Navigate right
      end

      -- Apply terminal keymaps when entering terminal
      vim.cmd "autocmd! TermOpen term://* lua set_terminal_keymaps()"
    end,
  },
  {
    "nvim-pack/nvim-spectre",
    keys = {
      { "<leader>S", '<cmd>lua require("spectre").toggle()<CR>', desc = "Toggle Spectre" },
      { "<leader>sw", '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', desc = "Search current word" },
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    ---@module "ibl"
    ---@type ibl.config
    opts = {},
  },
  {
    "AckslD/nvim-neoclip.lua",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
      "kkharji/sqlite.lua", -- required for persistent history
    },
    config = function()
      require("neoclip").setup {
        history = 1000,
        enable_persistent_history = true,
      }
      require("telescope").load_extension "neoclip"
    end,
    keys = {
      { "<leader>p", "<cmd>Telescope neoclip<cr>", desc = "Clipboard history" },
    },
  },
  {
    "gennaro-tedesco/nvim-peekup",
    config = true,
    keys = {
      { '"', mode = { "n", "x" } },
      { "<c-r>", mode = "i" },
    },
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
  },

  -- Git signs - inline git integration
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    config = function()
      require("gitsigns").setup {
        signs = {
          add = { text = "│" },
          change = { text = "│" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
          untracked = { text = "┆" },
        },
        signs_staged = {
          add = { text = "│" },
          change = { text = "│" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
          untracked = { text = "┆" },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local map = vim.keymap.set

          -- Navigation
          map("n", "]h", function()
            if vim.wo.diff then
              return "]c"
            end
            vim.schedule(function()
              gs.next_hunk()
            end)
            return "<Ignore>"
          end, { expr = true, buffer = bufnr, desc = "Next git hunk" })

          map("n", "[h", function()
            if vim.wo.diff then
              return "[c"
            end
            vim.schedule(function()
              gs.prev_hunk()
            end)
            return "<Ignore>"
          end, { expr = true, buffer = bufnr, desc = "Prev git hunk" })

          -- Actions
          map("n", "<leader>hs", gs.stage_hunk, { buffer = bufnr, desc = "Stage hunk" })
          map("n", "<leader>hr", gs.reset_hunk, { buffer = bufnr, desc = "Reset hunk" })
          map("v", "<leader>hs", function()
            gs.stage_hunk { vim.fn.line ".", vim.fn.line "v" }
          end, { buffer = bufnr, desc = "Stage hunk" })
          map("v", "<leader>hr", function()
            gs.reset_hunk { vim.fn.line ".", vim.fn.line "v" }
          end, { buffer = bufnr, desc = "Reset hunk" })
          map("n", "<leader>hS", gs.stage_buffer, { buffer = bufnr, desc = "Stage buffer" })
          map("n", "<leader>hu", gs.undo_stage_hunk, { buffer = bufnr, desc = "Undo stage hunk" })
          map("n", "<leader>hR", gs.reset_buffer, { buffer = bufnr, desc = "Reset buffer" })
          map("n", "<leader>hp", gs.preview_hunk, { buffer = bufnr, desc = "Preview hunk" })
          map("n", "<leader>hb", function()
            gs.blame_line { full = true }
          end, { buffer = bufnr, desc = "Blame line" })
          map("n", "<leader>hd", gs.diffthis, { buffer = bufnr, desc = "Diff this" })
          map("n", "<leader>hD", function()
            gs.diffthis "~"
          end, { buffer = bufnr, desc = "Diff this ~" })

          -- Text object
          map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { buffer = bufnr, desc = "Select hunk" })
        end,
      }
    end,
  },

  -- Flash - lightning fast navigation
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      labels = "asdfghjklqwertyuiopzxcvbnm",
      search = {
        multi_window = true,
        forward = true,
        wrap = true,
        mode = "exact",
      },
      jump = {
        jumplist = true,
        pos = "start",
        history = false,
        register = false,
        nohlsearch = false,
        autojump = false,
      },
      label = {
        uppercase = true,
        rainbow = {
          enabled = false,
          shade = 5,
        },
      },
      modes = {
        search = {
          enabled = true,
        },
        char = {
          enabled = true,
          jump_labels = true,
        },
      },
    },
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash",
      },
      {
        "R",
        mode = { "o", "x" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "Treesitter Search",
      },
      {
        "<c-s>",
        mode = { "c" },
        function()
          require("flash").toggle()
        end,
        desc = "Toggle Flash Search",
      },
    },
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
}
