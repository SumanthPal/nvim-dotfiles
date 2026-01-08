-- LSP Configuration
require("nvchad.configs.lspconfig").defaults()

local nvlsp = require "nvchad.configs.lspconfig"

-- Fix .tpp and .hpp filetype detection FIRST
vim.filetype.add {
  extension = {
    tpp = "cpp",
    hpp = "cpp",
  },
}

-- Define server configurations using new API
local servers = {
  html = {},
  cssls = {},
  ts_ls = {
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
  pyright = {
    before_init = function(_, config)
      -- Function to find Python executable in virtual environment
      local function find_venv_python()
        local venv_patterns = { "venv", "env", ".venv", ".env", "virtualenv" }
        local workspace_root = config.root_dir or vim.fn.getcwd()

        -- Check for virtual environments in workspace root
        for _, venv in ipairs(venv_patterns) do
          local venv_path = workspace_root .. "/" .. venv
          local python_path = venv_path .. "/bin/python"

          if vim.fn.filereadable(python_path) == 1 then
            return python_path
          end
        end

        -- Fallback to system python
        return vim.fn.exepath("python3") or vim.fn.exepath("python")
      end

      local python_path = find_venv_python()
      config.settings.python.pythonPath = python_path
    end,
    settings = {
      python = {
        analysis = {
          typeCheckingMode = "basic",
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
          autoImportCompletions = true,
          diagnosticMode = "workspace",
          -- Add these for better package resolution
          extraPaths = {},
          stubPath = vim.fn.stdpath("data") .. "/lazy/python-type-stubs",
        },
      },
    },
    root_dir = vim.fs.root(0, {
      "pyproject.toml",
      "setup.py",
      "setup.cfg",
      "requirements.txt",
      "Pipfile",
      ".git",
    }),
  },
  eslint = {
    on_attach = function(client, bufnr)
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        command = "EslintFixAll",
      })
    end,
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
    python = { "black" },
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
  formatters = {
    black = {
      prepend_args = { "--fast" },
    },
  },
}

-- Python interpreter selection command
vim.api.nvim_create_user_command("PythonSetInterpreter", function()
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
  table.insert(interpreters, vim.fn.exepath("python3") or vim.fn.exepath("python"))

  vim.ui.select(interpreters, {
    prompt = "Select Python interpreter:",
  }, function(choice)
    if choice then
      -- Restart pyright with new Python path
      vim.lsp.stop_client(vim.lsp.get_clients { name = "pyright" })
      vim.defer_fn(function()
        vim.cmd "edit"
      end, 100)
      print("Python interpreter set to: " .. choice)
    end
  end)
end, { desc = "Select Python interpreter for Pyright" })

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
vim.keymap.set("n", "<leader>pi", "<cmd>PythonSetInterpreter<cr>", { desc = "Select Python interpreter" })
