-- LSP Configuration
require("nvchad.configs.lspconfig").defaults()

local nvlsp = require "nvchad.configs.lspconfig"

-- Fix .tpp and .hpp filetype detection FIRST
vim.filetype.add {
  extension = {
    tpp = "cpp",
    hpp = "cpp",
    typ = "typst",
  },
}

-- Define server configurations using new API
local servers = {
  biome = {
    on_attach = function(client, _)
      client.server_capabilities.documentFormattingProvider = false
    end,
    root_dir = vim.fs.root(0, { "biome.json", "biome.jsonc" }),
  },
  cssls = {},
  emmet_ls = {
    filetypes = { "html", "css", "javascriptreact", "typescriptreact" },
  },
  html = {},
  eslint = {
    on_attach = function(_, bufnr)
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        command = "EslintFixAll",
      })
    end,
  },
  clangd = {
    cmd = {
      "clangd",
      "--background-index",
      "--clang-tidy",
      "--header-insertion=iwyu",
      "--completion-style=detailed",
      "--function-arg-placeholders",
      "--fallback-style=llvm",
    },
    init_options = {
      usePlaceholders = true,
      completeUnimported = true,
      clangdFileStatus = true,
    },
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
  },
  rust_analyzer = {},
  tinymist = {
    cmd = { "tinymist" },
    filetypes = { "typst", "typ" },
  },
  ty = {
    root_dir = vim.fs.root(0, {
      "pyproject.toml",
      "setup.py",
      "setup.cfg",
      "requirements.txt",
      "Pipfile",
      ".git",
    }),
  },
  ruff = {
    on_attach = function(client, _)
      -- Disable hover in favor of pyright/ty
      client.server_capabilities.hoverProvider = false
    end,
  },
  vtsls = {
    on_attach = function(client, bufnr)
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
      if vim.lsp.inlay_hint then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      end
    end,
    settings = {
      typescript = {
        inlayHints = {
          parameterNames = { enabled = "all" },
          returnTypes = { enabled = true },
        },
      },
    },
  },
}

-- Configure and enable all servers using the new vim.lsp.config/enable API
for server, config in pairs(servers) do
  -- Merge with nvlsp defaults
  config.on_attach = config.on_attach or nvlsp.on_attach
  config.on_init = config.on_init or nvlsp.on_init
  config.capabilities = config.capabilities or nvlsp.capabilities

  vim.lsp.config(server, config)
  vim.lsp.enable(server)
end

-- FORMATTERS CONFIGURATION
local conform = require "conform"

-- Key mappings for manual formatting
vim.keymap.set({ "n", "v" }, "<leader>mp", function()
  conform.format {
    lsp_fallback = true,
    async = false,
    timeout_ms = 1000,
  }
end, { desc = "Format file or range (in visual mode)" })

vim.keymap.set("n", "<leader>mf", function()
  vim.ui.select(conform.list_formatters(0), {
    prompt = "Select formatter:",
    format_item = function(item)
      return item.name
    end,
  }, function(item)
    if item then
      conform.format { formatters = { item.name } }
    end
  end)
end, { desc = "Format with specific formatter" })
