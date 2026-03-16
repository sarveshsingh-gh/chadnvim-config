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
-- Handled by seblyng/roslyn.nvim plugin — it finds the Mason binary,
-- sends solution/open, and manages the full lifecycle automatically.
vim.lsp.config("roslyn", {})

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

    -- ── Re-apply diagnostic config (Roslyn resets it after LazyDone) ────
    -- Keymaps are global — registered in lua/mappings.lua.
  end,
})
