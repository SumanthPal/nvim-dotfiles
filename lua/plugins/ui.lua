return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup {
        style = "night",
        transparent = true,
        styles = {
          sidebars = "transparent",
          floats = "transparent",
        },
        on_highlights = function(hl, c)
          local blend = require("tokyonight.util").blend_bg

          -- `transparent` leaves the statusline's background; clear it too.
          hl.StatusLine = { fg = c.fg_dark, bg = "NONE" }
          hl.StatusLineNC = { fg = c.comment, bg = "NONE" }

          -- Diffs: soft tints instead of solid blocks. Changed words get a bit more.
          hl.DiffAdd = { bg = blend(c.green, 0.12) }
          hl.DiffDelete = { bg = blend(c.red, 0.12) }
          hl.DiffChange = { bg = blend(c.blue, 0.06) }
          hl.DiffText = { bg = blend(c.blue, 0.22) }
          -- Filler where one side has no lines (the ╱ hatch, see fillchars).
          hl.DiffviewDiffDelete = { fg = c.fg_gutter }
          hl.DiffviewDiffDeleteDim = { fg = c.fg_gutter }

          -- One palette for add/change/delete: gitsigns column, diffview letters, counts.
          local git = { add = c.git.add, change = c.git.change, delete = c.git.delete }
          for group, color in pairs {
            DiffviewStatusAdded = git.add,
            DiffviewStatusUntracked = git.add,
            DiffviewStatusModified = git.change,
            DiffviewStatusRenamed = git.change,
            DiffviewStatusCopied = git.change,
            DiffviewStatusTypeChanged = git.change,
            DiffviewStatusUnmerged = git.change,
            DiffviewStatusDeleted = git.delete,
            DiffviewFilePanelInsertions = git.add,
            DiffviewFilePanelDeletions = git.delete,
          } do
            hl[group] = { fg = color }
          end
          hl.DiffviewFilePanelTitle = { fg = c.blue, bold = true }
          hl.DiffviewFilePanelRootPath = { fg = c.comment }
          hl.DiffviewFilePanelPath = { fg = c.comment }
          hl.DiffviewFilePanelCounter = { fg = c.fg_dark }
        end,
      }
      vim.cmd.colorscheme "tokyonight"
    end,
  },

  { "nvim-tree/nvim-web-devicons" },

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      lsp = { signature = { enabled = false } },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
      },
    },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>f", group = "find" },
        { "<leader>h", group = "git hunk" },
        { "<leader>g", group = "review" },
      },
    },
  },
}
