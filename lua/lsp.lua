-- Server defaults come from nvim-lspconfig's lsp/*.lua files; only overrides live here.
-- Binaries come from PATH or mason (see plugins/lsp.lua for the install list).

vim.diagnostic.config {
  virtual_text = true,
  severity_sort = true,
  float = { border = "rounded" },
}

local function no_formatting(client)
  -- conform.nvim does all formatting
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false
end

local servers = {
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        workspace = { library = { vim.env.VIMRUNTIME .. "/lua", "${3rd}/luv/library" } },
      },
    },
  },
  biome = { on_init = no_formatting },
  eslint = {}, -- fix-on-save is set up in LspAttach below
  vtsls = {
    on_init = no_formatting,
    settings = {
      typescript = {
        inlayHints = { parameterNames = { enabled = "all" }, returnTypes = { enabled = true } },
      },
    },
  },
  clangd = {},
  rust_analyzer = {
    -- clippy instead of plain `cargo check`, so clippy lints show as diagnostics
    settings = { ["rust-analyzer"] = { check = { command = "clippy" } } },
  },
  tinymist = {},
  ty = {},
  ruff = {
    on_init = function(client)
      client.server_capabilities.hoverProvider = false -- ty does hover
    end,
  },
}

for name, config in pairs(servers) do
  vim.lsp.config(name, config)
  vim.lsp.enable(name)
end

-- nvim 0.12 already maps: grn rename, grr references, gri implementation,
-- gra code action, grt type definition, gO symbols, K hover, [d ]d diagnostics.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user_lsp", { clear = true }),
  callback = function(args)
    local function map(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = args.buf, desc = "LSP " .. desc })
    end
    map("gd", vim.lsp.buf.definition, "go to definition")
    map("gD", vim.lsp.buf.declaration, "go to declaration")
    map("<leader>D", vim.lsp.buf.type_definition, "go to type definition")
    map("<leader>ra", vim.lsp.buf.rename, "rename")
    map("<leader>ds", vim.diagnostic.setloclist, "diagnostics to loclist")

    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "eslint" then
      vim.api.nvim_create_autocmd("BufWritePre", { buffer = args.buf, command = "LspEslintFixAll" })
    end
    if client and client.name == "vtsls" then
      vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
    end
  end,
})
