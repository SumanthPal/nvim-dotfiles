-- LSP Configuration
require("nvchad.configs.lspconfig").defaults()

local servers = {
  -- Web Development
  "html",
  "cssls",
  "ts_ls", -- TypeScript/JavaScript (replaces tsserver)
  -- Systems Programming
  "clangd", -- C/C++
  "rust_analyzer", -- Rust
  -- Python
  "pyright", -- or "pylsp" if you prefer python-lsp-server
}

vim.lsp.enable(servers)

local lspconfig = require "lspconfig"

-- Python: Pyright setup
lspconfig.pyright.setup {
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic", -- or "strict" for more checking
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        autoImportCompletions = true,
      },
    },
  },
}

-- TypeScript/JavaScript: Enhanced settings
lspconfig.ts_ls.setup {
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
  },
}

-- ESLint setup
lspconfig.eslint.setup {
  on_attach = function(client, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = "EslintFixAll",
    })
  end,
}

-- C/C++: Clangd with compile commands
lspconfig.clangd.setup {
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
}

-- FORMATTERS CONFIGURATION
-- Configure conform.nvim for formatting
local conform = require "conform"

conform.setup {
  formatters_by_ft = {
    -- Python
    python = { "black" },

    -- JavaScript/TypeScript
    javascript = { "biome" },
    typescript = { "biome" },
    javascriptreact = { "biome" },
    typescriptreact = { "biome" },

    -- JSON
    json = { "biome" },
    jsonc = { "biome" },

    -- CSS/HTML (if you want biome for these too)
    css = { "biome" },
    html = { "biome" },

    -- Lua
    lua = { "stylua" },

    -- C/C++
    c = { "clang_format" },
    cpp = { "clang_format" },

    -- Rust (rustfmt is usually handled by rust_analyzer)
    rust = { "rustfmt" },

    -- Markdown
    markdown = { "prettier" }, -- or remove if you don't want markdown formatting
  },

  -- Format on save
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },

  -- Formatters configuration
  formatters = {
    black = {
      prepend_args = { "--fast" },
    },
    biome = {
      -- Biome will use biome.json config if present
    },
    stylua = {
      -- Will use .stylua.toml or stylua.toml if present
    },
    clang_format = {
      -- Will use .clang-format file if present
    },
  },
}

-- Key mappings for manual formatting
vim.keymap.set({ "n", "v" }, "<leader>mp", function()
  conform.format {
    lsp_fallback = true,
    async = false,
    timeout_ms = 1000,
  }
end, { desc = "Format file or range (in visual mode)" })

-- Alternative: Format with specific formatter
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
