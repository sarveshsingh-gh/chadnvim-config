-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "tokyonight",

	-- hl_override = {
	-- 	Comment = { italic = true },
	-- 	["@comment"] = { italic = true },
	-- },
}

-- M.nvdash = { load_on_startup = true }

M.ui = {
  tabufline = {
    modules = {
      treeOffset = function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          local ft  = vim.bo[buf].filetype
          if ft == "dotnet_explorer" or ft == "dotnet_test_explorer" or ft == "NvimTree" then
            return "%#NvimTreeNormal#" .. string.rep(" ", vim.api.nvim_win_get_width(win) + 1)
          end
        end
        return ""
      end,
    },
  },
}

return M
