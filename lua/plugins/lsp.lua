-- Tools mason installs on first start if they aren't already on PATH.
-- (clangd, rust-analyzer, ty, ruff come from Xcode / rustup / uv.)
local tools = {
  "lua-language-server", "stylua",
  "biome", "prettier", "vtsls", "eslint-lsp",
  "tinymist",
}

return {
  {
    -- Server configs (lsp/*.lua) used by vim.lsp.enable in lua/lsp.lua.
    "neovim/nvim-lspconfig",
    lazy = false,
  },

  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    event = "VeryLazy",
    config = function()
      require("mason").setup()
      local registry = require "mason-registry"
      registry.refresh(function()
        for _, name in ipairs(tools) do
          local ok, pkg = pcall(registry.get_package, name)
          if ok and not pkg:is_installed() then
            pkg:install()
          end
        end
      end)
    end,
  },

  {
    "saghen/blink.cmp",
    version = "1.*", -- release tags ship the prebuilt fuzzy matcher
    event = { "InsertEnter", "CmdlineEnter" },
    opts = {
      keymap = {
        preset = "default",
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      },
      completion = { documentation = { auto_show = true } },
      sources = { default = { "lsp", "path", "buffer" } },
    },
  },

  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    opts = {
      -- biome only where the project has a biome config; otherwise prettier.
      formatters = { biome = { require_cwd = true } },
      formatters_by_ft = {
        python = { "ruff_format" },
        javascript = { "biome", "prettier", stop_after_first = true },
        typescript = { "biome", "prettier", stop_after_first = true },
        javascriptreact = { "biome", "prettier", stop_after_first = true },
        typescriptreact = { "biome", "prettier", stop_after_first = true },
        json = { "biome", "prettier", stop_after_first = true },
        jsonc = { "biome", "prettier", stop_after_first = true },
        css = { "biome", "prettier", stop_after_first = true },
        html = { "prettier" },
        markdown = { "prettier" },
        lua = { "stylua" },
        rust = { "rustfmt" },
      },
      format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
    },
    keys = {
      {
        "<leader>mp",
        function()
          require("conform").format { lsp_format = "fallback", timeout_ms = 1000 }
        end,
        mode = { "n", "v" },
        desc = "format file or selection",
      },
      {
        "<leader>mf",
        function()
          local conform = require "conform"
          vim.ui.select(conform.list_formatters(0), {
            prompt = "Formatter:",
            format_item = function(f)
              return f.name
            end,
          }, function(f)
            if f then
              conform.format { formatters = { f.name } }
            end
          end)
        end,
        desc = "format with a chosen formatter",
      },
    },
  },
}
