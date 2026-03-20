require "nvchad.autocmds"       -- NvChad built-in autocommands

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Kill native virtual_text after ALL plugins finish loading.
-- tiny-inline-diagnostic.nvim is the sole diagnostic renderer.
-- LazyDone is the last event in the startup chain, so nothing
-- can re-enable virtual_text after this.
autocmd("User", {
  pattern  = "LazyDone",
  once     = true,
  callback = function()
    vim.diagnostic.config({ virtual_text = false })
  end,
})


-- Highlight on yank
autocmd("TextYankPost", {
  group    = augroup("YankHighlight", { clear = true }),
  callback = function() vim.highlight.on_yank() end,
})

-- Trim trailing whitespace on save (skip binary / diff files)
autocmd("BufWritePre", {
  group   = augroup("TrimWhitespace", { clear = true }),
  pattern = { "*.cs", "*.lua", "*.json", "*.xml", "*.md" },
  callback = function()
    local save = vim.fn.winsaveview()
    vim.cmd [[keeppatterns %s/\s\+$//e]]
    vim.fn.winrestview(save)
  end,
})


-- Auto-format C# on save via LSP (Roslyn supports it)
autocmd("BufWritePre", {
  group   = augroup("CSharpFormat", { clear = true }),
  pattern = "*.cs",
  callback = function()
    vim.lsp.buf.format({ async = false, timeout_ms = 3000 })
  end,
})
