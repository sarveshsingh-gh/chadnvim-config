-- Pull in NvChad's LSP defaults (sets up mason-lspconfig, cmp capabilities, etc.)
require("nvchad.configs.lspconfig").defaults()

-- virtual_text off — tiny-inline-diagnostic handles display.
-- signs stay ON as the subtle per-line indicator on non-cursor lines.
vim.diagnostic.config({
  virtual_text = false,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN]  = " ",
      [vim.diagnostic.severity.HINT]  = "󰌶 ",
      [vim.diagnostic.severity.INFO]  = " ",
    },
  },
  underline    = true,
  update_in_insert = false,
})

-- ── Roslyn (C# LSP) ──────────────────────────────────────────────────────
-- Installed via Mason using the Crashdummyy registry ("roslyn" package).
-- Mason puts the server under: stdpath("data")/mason/packages/roslyn/
local mason_pkg = vim.fn.stdpath "data" .. "/mason/packages/roslyn"

-- Locate the server DLL (glob handles version-stamped subdirs)
local server_dll = vim.fn.glob(
  mason_pkg .. "/**/Microsoft.CodeAnalysis.LanguageServer.dll",
  false, true
)[1]

if server_dll and vim.uv.fs_stat(server_dll) then
  local capabilities = vim.tbl_deep_extend(
    "force",
    vim.lsp.protocol.make_client_capabilities(),
    require("cmp_nvim_lsp").default_capabilities()
  )

  vim.lsp.config("roslyn", {
    cmd        = { "dotnet", server_dll, "--stdio" },
    filetypes  = { "cs" },
    root_dir   = function(bufnr)
      -- vim.lsp.config passes bufnr, not a filename
      return vim.fs.root(bufnr, { "*.sln", "*.slnx", "*.csproj" })
        or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
    end,
    capabilities = capabilities,
    settings = {
      ["csharp|inlay_hints"] = {
        csharp_enable_inlay_hints_for_implicit_object_creation            = true,
        csharp_enable_inlay_hints_for_implicit_variable_types             = true,
        csharp_enable_inlay_hints_for_lambda_parameter_types              = true,
        csharp_enable_inlay_hints_for_types                               = true,
        dotnet_enable_inlay_hints_for_indexer_parameters                  = true,
        dotnet_enable_inlay_hints_for_object_creation_parameters          = true,
        dotnet_enable_inlay_hints_for_other_parameters                    = true,
        dotnet_enable_inlay_hints_for_parameters                          = true,
        dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
        dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name   = true,
        dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent   = true,
      },
      ["csharp|code_lens"] = {
        dotnet_enable_references_code_lens = true,
      },
    },
  })

  vim.lsp.enable "roslyn"
else
  vim.notify(
    "[lspconfig] Roslyn not found. Run :MasonInstall roslyn",
    vim.log.levels.WARN
  )
end

-- ── Other language servers ────────────────────────────────────────────────
-- Add non-C# servers here (NvChad's mason-lspconfig will auto-install them)
local servers = {
  "marksman",   -- markdown LSP (link completion, heading navigation)
}

if #servers > 0 then
  vim.lsp.enable(servers)
end

-- ── Shared on_attach keymaps ──────────────────────────────────────────────
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("NvChadLspAttach", { clear = true }),
  callback = function(ev)
    -- Re-apply on every attach — Roslyn resets this after LazyDone
    vim.diagnostic.config({
      virtual_text = false,
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN]  = " ",
          [vim.diagnostic.severity.HINT]  = "󰌶 ",
          [vim.diagnostic.severity.INFO]  = " ",
        },
      },
    })

    local buf = ev.buf
    local function map(modes, keys, func, desc)
      vim.keymap.set(modes, keys, func, { buffer = buf, desc = desc })
    end

    -- ── Navigation (Visual Studio style) ────────────────────────────────
    map({ "n", "v" }, "<F12>",   vim.lsp.buf.definition,     "Go to definition")
    map({ "n", "v" }, "<S-F12>", function()
      require("telescope.builtin").lsp_references()
    end,                                                      "Find all references")
    map({ "n", "v" }, "<C-F12>", vim.lsp.buf.implementation, "Go to implementation")
    map({ "n", "v" }, "K",       vim.lsp.buf.hover,          "Hover docs")
    map({ "n", "v" }, "<C-Space>", vim.lsp.buf.hover,        "Hover docs")

    -- ── Code actions & rename (VS style) ─────────────────────────────────
    map({ "n", "v" }, "<F2>",   vim.lsp.buf.rename,       "Rename symbol")
    map({ "n", "v" }, "<M-.>", vim.lsp.buf.code_action, "Code actions")

    -- ── Format ───────────────────────────────────────────────────────────
    map({ "n", "v" }, "<leader>cf", function()
      require("conform").format({ async = true, lsp_fallback = true })
    end, "Format document / selection")

    -- ── Signature & hints ────────────────────────────────────────────────
    map("n", "<C-S-Space>", vim.lsp.buf.signature_help, "Parameter info")
    map("n", "<leader>ci",  function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = buf })
    end, "Toggle inlay hints")

    -- ── Symbols ──────────────────────────────────────────────────────────
    map("n", "<leader>fs", function()
      require("telescope.builtin").lsp_document_symbols()
    end, "Document symbols")
    map("n", "<leader>fS", function()
      require("telescope.builtin").lsp_workspace_symbols()
    end, "Workspace symbols")

    -- ── Diagnostics: navigate (VS: F8 / Shift+F8 for next/prev error) ────
    map("n", "<F8>",   function() vim.diagnostic.goto_next() end, "Next diagnostic")
    map("n", "<S-F8>", function() vim.diagnostic.goto_prev() end, "Prev diagnostic")
    map("n", "]d", function() vim.diagnostic.goto_next() end, "Next diagnostic")
    map("n", "[d", function() vim.diagnostic.goto_prev() end, "Prev diagnostic")

    -- ── Diagnostics: lists ───────────────────────────────────────────────
    map("n", "<leader>cd", vim.diagnostic.open_float, "Diagnostic float")
    map("n", "<leader>cD", function()
      require("telescope.builtin").diagnostics { bufnr = 0 }
    end, "All diagnostics (buffer)")
    map("n", "<leader>cE", function()
      require("telescope.builtin").diagnostics { bufnr = 0, severity = vim.diagnostic.severity.ERROR }
    end, "Errors (buffer)")
    map("n", "<leader>cW", function()
      require("telescope.builtin").diagnostics { bufnr = 0, severity = vim.diagnostic.severity.WARN }
    end, "Warnings (buffer)")
    map("n", "<leader>cx", function()
      require("telescope.builtin").diagnostics()
    end, "All diagnostics (workspace)")

    -- ── Register groups with which-key so they appear in the popup ───────
    local ok, wk = pcall(require, "which-key")
    if ok then
      wk.add({
        { "g",          buffer = buf, group = "Goto" },
        { "<leader>c",  buffer = buf, group = "Code / LSP" },
        { "<leader>f",  buffer = buf, group = "Find" },
        { "[",          buffer = buf, group = "Prev" },
        { "]",          buffer = buf, group = "Next" },
      })
    end
  end,
})
