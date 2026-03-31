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
    filetypes = { "c", "tpp", "hpp", "cpp", "objc", "objcpp", "cuda", "proto" },
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

-- Enable all servers using the new vim.lsp.enable API
for server, config in pairs(servers) do
  -- Merge with nvlsp defaults
  config.on_attach = config.on_attach or nvlsp.on_attach
  config.on_init = config.on_init or nvlsp.on_init
  config.capabilities = config.capabilities or nvlsp.capabilities

  vim.lsp.enable(server, config)
end

-- FORMATTERS CONFIGURATION
local conform = require "conform"
conform.setup {
  formatters_by_ft = {
    python = { "ruff_format" },
    javascript = { "biome" },
    typescript = { "biome" },
    javascriptreact = { "biome" },
    typescriptreact = { "biome" },
    json = { "biome" },
    jsonc = { "biome" },
    css = { "biome" },
    html = { "biome" },
    lua = { "stylua" },
    c = { "clang_format" },
    cpp = { "clang_format" },
    rust = { "rustfmt" },
    markdown = { "prettier" },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

-- Python interpreter selection command
  local venv_patterns = { "venv", "env", ".venv", ".env", "virtualenv" }
  local workspace_root = vim.fn.getcwd()
  local interpreters = {}

  -- Find all virtual environments
  for _, venv in ipairs(venv_patterns) do
    local venv_path = workspace_root .. "/" .. venv
    local python_path = venv_path .. "/bin/python"
    if vim.fn.filereadable(python_path) == 1 then
      table.insert(interpreters, python_path)
    end
  end

  -- Add system Python
  table.insert(interpreters, vim.fn.exepath "python3" or vim.fn.exepath "python")
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

-- Python interpreter keymap
