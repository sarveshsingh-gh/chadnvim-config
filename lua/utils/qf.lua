local M = {}

function M.format(info)
  local items = info.quickfix == 1
    and vim.fn.getqflist({ id = info.id, items = 1 }).items
    or  vim.fn.getloclist(info.winid, { id = info.id, items = 1 }).items

  local results = {}
  for i = info.start_idx, info.end_idx do
    local item = items[i]
    local fname = ""
    if item.bufnr > 0 then
      local full = vim.fn.bufname(item.bufnr)
      local parent = vim.fs.basename(vim.fs.dirname(full))
      local tail   = vim.fs.basename(full)
      fname = (parent ~= "" and parent ~= "." and parent .. "/" or "") .. tail
      fname = string.format("%-30s", fname)
    end
    local lnum = item.lnum > 0 and string.format("%4d", item.lnum) or "    "
    local text = item.text
      :gsub("^%s+", "")           -- leading whitespace
      :gsub("%s*%[.-%]%s*$", "")  -- trailing [/path/to/file] from easy-dotnet
      :gsub("%s*%(/.-%)", "")     -- trailing (/absolute/path) style refs
      :gsub("%s*/[%w/%.%-_]+%s*$", "") -- bare trailing absolute path
    table.insert(results, fname .. " |" .. lnum .. " | " .. text)
  end
  return results
end

return M
