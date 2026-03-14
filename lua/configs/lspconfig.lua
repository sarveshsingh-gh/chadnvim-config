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

    -- ── Navigation (n + v) ───────────────────────────────────────────────
    map({ "n", "v" }, "gd",         vim.lsp.buf.definition,     "LSP: Go to definition")
    map({ "n", "v" }, "<leader>/",  vim.lsp.buf.definition,     "LSP: Go to definition")
    map({ "n", "v" }, "gD",         vim.lsp.buf.declaration,    "LSP: Go to declaration")
    map({ "n", "v" }, "<F12>",      vim.lsp.buf.implementation, "LSP: Go to implementation")
    map({ "n", "v" }, "<C-'>",      vim.lsp.buf.implementation, "LSP: Go to implementation")
    map({ "n", "v" }, "gy",    vim.lsp.buf.type_definition, "LSP: Go to type definition")
    map({ "n", "v" }, "gr", function()
      require("telescope.builtin").lsp_references()
    end, "LSP: References (Telescope)")
    map({ "n", "v" }, "gR", function()
      vim.lsp.buf.references()
      vim.cmd "copen"
    end, "LSP: References → quickfix")
    map({ "n", "v" }, "K",         vim.lsp.buf.hover, "LSP: Hover docs")
    map({ "n", "v" }, "<C-Space>", vim.lsp.buf.hover, "LSP: Hover docs")

    -- ── Code actions (n + v) ─────────────────────────────────────────────
    map({ "n", "v" }, "<leader>cr", vim.lsp.buf.rename, "LSP: Rename symbol")
    map({ "n", "v" }, "<leader>rr",  vim.lsp.buf.rename, "LSP: Rename symbol")
    local function code_action()
      vim.lsp.buf.code_action()
    end
    map({ "n", "v" }, "<C-.>",     code_action, "LSP: Code action")
    map({ "n", "v" }, "<leader>.", code_action, "LSP: Code action")
    -- Format document (normal mode)
    map("n", "<leader>cf", function()
      require("conform").format({ async = true, lsp_fallback = true })
    end, "LSP: Format document")

    -- Format selection (visual mode)
    map("v", "<leader>cf", function()
      require("conform").format({ async = true, lsp_fallback = true })
    end, "LSP: Format selection")
    map("n", "<leader>cs", vim.lsp.buf.signature_help,              "LSP: Signature help")
    map("n", "<leader>ci", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = buf })
    end,                                                        "LSP: Toggle inlay hints")

    -- ── Symbols ─────────────────────────────────────────────────────────
    map("n", "<leader>fs", function()
      require("telescope.builtin").lsp_document_symbols()
    end, "LSP: Document symbols")
    map("n", "<leader>fS", function()
      require("telescope.builtin").lsp_workspace_symbols()
    end, "LSP: Workspace symbols")

    -- ── Diagnostics: navigate ────────────────────────────────────────────
    map("n", "[d", function()
      vim.diagnostic.goto_prev()
    end, "LSP: Prev diagnostic")
    map("n", "]d", function()
      vim.diagnostic.goto_next()
    end, "LSP: Next diagnostic")
    map("n", "[e", function()
      vim.diagnostic.goto_prev { severity = vim.diagnostic.severity.ERROR }
    end, "LSP: Prev error")
    map("n", "]e", function()
      vim.diagnostic.goto_next { severity = vim.diagnostic.severity.ERROR }
    end, "LSP: Next error")
    map("n", "[w", function()
      vim.diagnostic.goto_prev { severity = vim.diagnostic.severity.WARN }
    end, "LSP: Prev warning")
    map("n", "]w", function()
      vim.diagnostic.goto_next { severity = vim.diagnostic.severity.WARN }
    end, "LSP: Next warning")

    -- ── Diagnostics: lists ───────────────────────────────────────────────
    map("n", "<leader>cd", vim.diagnostic.open_float,               "LSP: Show diagnostic (float)")
    map("n", "<leader>cD", function()
      require("telescope.builtin").diagnostics { bufnr = 0 }
    end, "LSP: All diagnostics (buffer)")
    map("n", "<leader>cE", function()
      require("telescope.builtin").diagnostics {
        bufnr   = 0,
        severity = vim.diagnostic.severity.ERROR,
      }
    end, "LSP: Errors (buffer)")
    map("n", "<leader>cW", function()
      require("telescope.builtin").diagnostics {
        bufnr   = 0,
        severity = vim.diagnostic.severity.WARN,
      }
    end, "LSP: Warnings (buffer)")
    map("n", "<leader>cx", function()
      require("telescope.builtin").diagnostics()
    end, "LSP: All diagnostics (workspace)")

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
