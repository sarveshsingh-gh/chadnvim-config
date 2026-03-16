-- DAP signs only — adapter + C# config are registered by easy-dotnet
-- automatically via debugger.auto_register_dap = true (see configs/dotnet.lua)
local dap = require "dap"

-- ── Signs ─────────────────────────────────────────────────────────────────────
vim.fn.sign_define("DapBreakpoint",          { text = "●", texthl = "DapBreakpoint",          linehl = "",             numhl = "" })
vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpointCondition", linehl = "",             numhl = "" })
vim.fn.sign_define("DapLogPoint",            { text = "◉", texthl = "DapLogPoint",             linehl = "",             numhl = "" })
vim.fn.sign_define("DapStopped",             { text = "▶", texthl = "DapStopped",             linehl = "DapStoppedLine", numhl = "" })
vim.fn.sign_define("DapBreakpointRejected",  { text = "○", texthl = "DapBreakpointRejected",  linehl = "",             numhl = "" })

-- ── VS-style colours ──────────────────────────────────────────────────────────
vim.api.nvim_set_hl(0, "DapBreakpoint",          { fg = "#E51400" })          -- VS red circle
vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = "#FF8C00" })          -- amber diamond
vim.api.nvim_set_hl(0, "DapLogPoint",            { fg = "#61AFEF" })          -- blue tracepoint
vim.api.nvim_set_hl(0, "DapStopped",             { fg = "#FFD700" })          -- gold arrow
vim.api.nvim_set_hl(0, "DapStoppedLine",         { bg = "#3B3800" })          -- subtle yellow line bg
vim.api.nvim_set_hl(0, "DapBreakpointRejected",  { fg = "#6D8086" })          -- grey (disabled)

-- Generic attach-to-process config (works for any language)
dap.configurations.cs = dap.configurations.cs or {}
vim.list_extend(dap.configurations.cs, {
  {
    type      = "coreclr",
    name      = "Attach to process",
    request   = "attach",
    processId = require("dap.utils").pick_process,
  },
})
