require("nvchad.configs.lspconfig").defaults()

-- ── Full-stack .NET: C# + Web (HTML/CSS/JS/TS/JSON/Tailwind) ─────────────────
local servers = {
  "html",          -- HTML
  "cssls",         -- CSS / SCSS / LESS
  "ts_ls",         -- TypeScript / JavaScript
  "eslint",        -- ESLint linting
  "jsonls",        -- JSON + JSON schema
  "tailwindcss",   -- Tailwind CSS class completion
}
vim.lsp.enable(servers)

-- Tailwind: also activate in Razor / C# files (for Blazor)
vim.lsp.config("tailwindcss", {
  filetypes = {
    "html", "css", "javascript", "typescript",
    "javascriptreact", "typescriptreact",
    "razor", "cshtml",
  },
})

-- ESLint: auto-fix on save
vim.lsp.config("eslint", {
  on_attach = function(_, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer   = bufnr,
      callback = function() vim.cmd("EslintFixAll") end,
    })
  end,
})
