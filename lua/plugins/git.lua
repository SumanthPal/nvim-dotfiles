return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "│" },
        change = { text = "│" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
      on_attach = function(bufnr)
        local gs = require "gitsigns"
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal { "]c", bang = true }
          else
            gs.nav_hunk "next"
          end
        end, "next hunk")
        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal { "[c", bang = true }
          else
            gs.nav_hunk "prev"
          end
        end, "previous hunk")

        map("n", "<leader>hs", gs.stage_hunk, "stage hunk")
        map("n", "<leader>hr", gs.reset_hunk, "reset hunk")
        map("v", "<leader>hs", function()
          gs.stage_hunk { vim.fn.line ".", vim.fn.line "v" }
        end, "stage selection")
        map("v", "<leader>hr", function()
          gs.reset_hunk { vim.fn.line ".", vim.fn.line "v" }
        end, "reset selection")
        map("n", "<leader>hS", gs.stage_buffer, "stage buffer")
        map("n", "<leader>hR", gs.reset_buffer, "reset buffer")
        map("n", "<leader>hp", gs.preview_hunk, "preview hunk")
        map("n", "<leader>hb", function()
          gs.blame_line { full = true }
        end, "blame line")
        map("n", "<leader>hd", gs.diffthis, "diff against index")
        map("n", "<leader>hD", function()
          gs.diffthis "~"
        end, "diff against last commit")
        map({ "o", "x" }, "ih", gs.select_hunk, "select hunk")
      end,
    },
  },

  {
    -- Review: staging a hunk (<leader>hs) = approving it. Done when "Changes" is empty.
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    -- Layout and file panel position are picked per open from nvim's width (review.lua).
    opts = {
      enhanced_diff_hl = true,
      show_help_hints = false,
      file_panel = { win_config = function() return require("review").panel() end },
    },
    keys = {
      { "<leader>gr", function() require("review").open "DiffviewOpen" end, desc = "review uncommitted changes" },
      { "<leader>gb", function() require("review").branch() end, desc = "review branch vs main" },
      { "<leader>gh", function() require("review").open "DiffviewFileHistory %" end, desc = "history of this file" },
      { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "close review" },
      { "<leader>g?", function() require("review").checklist() end, desc = "review checklist" },
    },
  },
}
