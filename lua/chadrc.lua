-- NvChad UI config — mirrors nvconfig.lua structure
-- Full options: https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "vscode_dark",           -- catppuccin mocha feel inside NvChad
  transparency = false,

  hl_override = {
    Comment = { italic = true },
    ["@comment"] = { italic = true },
  },
}

M.ui = {
  statusline = {
    theme           = "default",
    separator_style = "round",
    -- Inject easy-dotnet job indicator after the mode segment
    order = { "mode", "file", "git", "dotnet_jobs", "%=", "lsp_msg", "%=", "diagnostics", "lsp", "cwd", "cursor" },
    modules = {
      dotnet_jobs = function()
        local ok, jobs = pcall(require, "easy-dotnet.ui-modules.jobs")
        if not ok or not jobs.lualine then return "" end
        local str = jobs.lualine()
        if not str or str == "" then return "" end
        return " " .. str .. " "
      end,
    },
  },
  tabufline = {
    lazyload = false,
  },
  cmp = {
    icons_left   = true,
    lspkind_text = true,
    style        = "default",
  },
}

M.nvdash = { load_on_startup = false }

return M
