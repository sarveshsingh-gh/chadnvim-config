-- test_runner.lua — run / debug .NET tests from code buffer and sln_explorer
--
-- From a .cs buffer:
--   t    on [Fact]/[Theory] method → run single test
--   t    on class name / body      → run whole class
--   t    anywhere else             → run whole file
--   dt   on [Fact]/[Theory] method → debug via DAP
--   gx                             → open last test log
--
-- From solution explorer (file node):
--   t    on *.cs file              → run all tests in file

local M = {}

local NS      = vim.api.nvim_create_namespace("test_runner_virt")
local _run_id = 0

-- Safe highlight groups: DiagnosticOk added in nvim 0.9; fall back to String/Error
local _hl_pass = (function()
  local ok = vim.api.nvim_get_hl(0, { name = "DiagnosticOk" })
  return (ok and next(ok)) and "DiagnosticOk" or "String"
end)()
local _hl_fail = "DiagnosticError"

-- ── Project helpers ───────────────────────────────────────────────────────────

local function find_proj(file_path)
  local dir = vim.fn.fnamemodify(file_path, ":h")
  while dir ~= "/" and dir ~= "" do
    local hits = vim.fn.glob(dir .. "/*.csproj", false, true)
    if #hits > 0 then return hits[1] end
    dir = vim.fn.fnamemodify(dir, ":h")
  end
  return nil
end

local function get_tfm(proj_path)
  local ok, lines = pcall(vim.fn.readfile, proj_path)
  if not ok then return "net10.0" end
  for _, l in ipairs(lines) do
    local tfm = l:match("<TargetFramework>([^<]+)</TargetFramework>")
    if tfm then return tfm end
  end
  return "net10.0"
end

local function get_dll(proj_path)
  local dir  = vim.fn.fnamemodify(proj_path, ":h")
  local name = vim.fn.fnamemodify(proj_path, ":t:r")
  return dir .. "/bin/Debug/" .. get_tfm(proj_path) .. "/" .. name .. ".dll"
end

-- ── Regex context (no treesitter dependency) ─────────────────────────────────
-- Returns method_name, class_name, method_sig_row(0-indexed), has_test_attr

local function get_context()
  local cur   = vim.api.nvim_win_get_cursor(0)[1]   -- 1-indexed
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  -- Scan a window around the cursor: 5 lines up, 2 lines down.
  -- Within that window find [Fact]/[Theory] and the method signature.
  local win_s = math.max(1, cur - 5)
  local win_e = math.min(#lines, cur + 2)

  local method_name, method_row0, has_attr = nil, nil, false
  for i = win_s, win_e do
    local l = lines[i]
    if l:match("%[Fact%]") or l:match("%[Theory%]") then
      has_attr = true
    end
    -- method signature: "public [modifiers] ReturnType Name("
    if not method_name then
      local name = l:match("public%s+.-%s+([%a_][%w_]*)%s*%(")
      if name and name ~= "class" and name ~= "void"
                and name ~= "Task" and name ~= "async" then
        method_name = name
        method_row0 = i - 1   -- 0-indexed for extmark
      end
    end
  end

  -- Class: search backward from cursor
  local class_name
  for i = cur, 1, -1 do
    local name = lines[i]:match("class%s+([%a_][%w_]*)")
    if name then class_name = name ; break end
  end

  return method_name, class_name, method_row0, has_attr
end

-- ── Virtual text ──────────────────────────────────────────────────────────────

-- pending_mark: { bufnr, row } set before job starts; cleared on completion
local _pending = nil
local _log_buf = nil

local function set_virt(bufnr, row, passed)
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  vim.api.nvim_buf_clear_namespace(bufnr, NS, row, row + 1)
  local icon = passed and "  ✓" or "  ✗"
  local hl   = passed and _hl_pass or _hl_fail
  pcall(vim.api.nvim_buf_set_extmark, bufnr, NS, row, 0, {
    virt_text          = { { icon, hl } },
    virt_text_pos      = "eol",
    priority           = 200,
  })
end

-- Parse output and set ✓/✗ on every test method line found in bufnr
local function set_virts_from_output(bufnr, output)
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  -- Build method_name → 0-indexed row map for this buffer
  local method_rows = {}
  for i, l in ipairs(lines) do
    local name = l:match("public%s+.-%s+([%a_][%w_]*)%s*%(")
    if name and name ~= "class" and name ~= "void"
              and name ~= "Task" and name ~= "async" then
      method_rows[name] = i - 1
    end
  end

  -- Parse "  Passed Some.Namespace.Class.MethodName [N ms]"
  -- or    "  Failed Some.Namespace.Class.MethodName [N ms]"
  for _, l in ipairs(output) do
    local verdict, fqn = l:match("^%s*(Passed)%s+(%S+)"),
                         l:match("^%s*Passed%s+(%S+)")
    local passed
    if l:match("^%s*Passed%s+") then
      passed = true
      fqn = l:match("^%s*Passed%s+(%S+)")
    elseif l:match("^%s*Failed%s+") then
      passed = false
      fqn = l:match("^%s*Failed%s+(%S+)")
    end
    if fqn then
      fqn = fqn:gsub("%[.*", ""):gsub("%s", "")   -- strip trailing [N ms]
      local method = fqn:match("%.([%a_][%w_]*)$") or fqn
      local row = method_rows[method]
      if row then set_virt(bufnr, row, passed) end
    end
  end
end

-- Show spinner on the method line while running
local SPINNER     = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
local _spin_timer  = nil
local _spin_active = false   -- flag checked by queued callbacks so they don't
                             -- overwrite the final ✓/✗ after stop_spinner()

local function start_spinner(bufnr, row)
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  _spin_active = true
  local i = 0
  _spin_timer = vim.uv.new_timer()
  _spin_timer:start(0, 100, vim.schedule_wrap(function()
    if not _spin_active then return end          -- already stopped — bail out
    if not vim.api.nvim_buf_is_valid(bufnr) then return end
    i = (i + 1) % #SPINNER
    pcall(vim.api.nvim_buf_set_extmark, bufnr, NS, row, 0, {
      id            = 1,
      virt_text     = { { "  " .. SPINNER[i + 1], "Comment" } },
      virt_text_pos = "eol",
      priority      = 200,
    })
  end))
end

local function stop_spinner()
  _spin_active = false     -- must be set BEFORE closing timer so any queued
                           -- schedule_wrap callbacks see it and return early
  if _spin_timer then
    _spin_timer:stop()
    _spin_timer:close()
    _spin_timer = nil
  end
end

-- ── Background runner ─────────────────────────────────────────────────────────

local function run_bg(args, label, mark, source_buf)
  -- mark      = { bufnr, row } for single-test tick; nil for class/file runs
  -- source_buf = buffer to scan for multi-test ticks when mark is nil
  local output = {}

  local log_buf = vim.api.nvim_create_buf(false, true)
  vim.bo[log_buf].buftype   = "nofile"
  vim.bo[log_buf].bufhidden = "hide"
  _log_buf = log_buf                   -- set BEFORE name so it survives any error below
  vim.g._test_runner_log_buf = log_buf -- persist across module reloads
  -- use buf handle (always unique per session) to avoid E95
  pcall(vim.api.nvim_buf_set_name, log_buf,
        "[Test:" .. label .. ":" .. log_buf .. "]")

  -- share with sln_explorer gx
  pcall(function() require("utils.sln_explorer")._set_term_buf(log_buf) end)

  -- spinner on method line (if we know it)
  if mark then
    start_spinner(mark.bufnr, mark.row)
  end

  local function collect(_, data)
    if not data then return end
    for _, line in ipairs(data) do
      if line ~= "" then table.insert(output, line) end
    end
  end

  vim.fn.jobstart({ "dotnet", unpack(args) }, {
    on_stdout = collect,
    on_stderr = collect,
    on_exit   = function(_, code)
      vim.schedule(function()
        stop_spinner()

        if vim.api.nvim_buf_is_valid(log_buf) then
          vim.bo[log_buf].modifiable = true
          vim.api.nvim_buf_set_lines(log_buf, 0, -1, false, output)
          vim.bo[log_buf].modifiable = false
        end

        local passed = code == 0

        -- virtual text: single-test mark OR scan all methods in source buffer
        if mark and vim.api.nvim_buf_is_valid(mark.bufnr) then
          set_virt(mark.bufnr, mark.row, passed)
        elseif source_buf then
          set_virts_from_output(source_buf, output)
        end

        if passed then
          local n = "passed"
          for _, l in ipairs(output) do
            local m = l:match("Passed:%s*(%d+)")
            if m then n = m .. " passed" ; break end
          end
          vim.notify("[Test] " .. label .. "  ✓ " .. n .. "  (gx = log)", vim.log.levels.INFO)
        else
          -- Try to surface: "Failed: N" summary, else "No test matches", else raw last line
          local msg = label .. " FAILED"
          for _, l in ipairs(output) do
            local clean = l:gsub("^%s+", "")
            if clean:match("^Failed:") or clean:match("No test matches") then
              msg = clean ; break
            end
          end
          vim.notify("[Test] " .. msg .. "  (gx = log)", vim.log.levels.ERROR)
        end
      end)
    end,
  })
end

-- ── Log window ────────────────────────────────────────────────────────────────

function M.open_log()
  -- recover from module reload via vim.g fallback
  if not _log_buf or not vim.api.nvim_buf_is_valid(_log_buf) then
    local g = vim.g._test_runner_log_buf
    if g and vim.api.nvim_buf_is_valid(g) then
      _log_buf = g
    end
  end
  if not _log_buf or not vim.api.nvim_buf_is_valid(_log_buf) then
    vim.notify("[Test] No test log yet", vim.log.levels.INFO)
    return
  end
  -- already visible?
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_buf(win) == _log_buf then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
  vim.cmd("botright 12split")
  vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), _log_buf)
end

-- ── Public run API ────────────────────────────────────────────────────────────

function M.run_at_cursor()
  local file = vim.api.nvim_buf_get_name(0)
  local proj = find_proj(file)
  if not proj then
    vim.notify("[Test] No .csproj found", vim.log.levels.WARN)
    return
  end

  local method_name, class_name, method_row0, has_attr = get_context()
  local args, label, mark

  local cur_buf = vim.api.nvim_get_current_buf()

  if method_name and has_attr then
    mark  = { bufnr = cur_buf, row = method_row0 }
    local filter = class_name and (class_name .. "." .. method_name) or method_name
    args  = { "test", proj, "--verbosity", "normal", "--filter", "FullyQualifiedName~" .. filter }
    label = method_name

  elseif class_name then
    args  = { "test", proj, "--verbosity", "normal", "--filter", "FullyQualifiedName~" .. class_name }
    label = class_name

  else
    local cls = vim.fn.fnamemodify(file, ":t:r")
    args  = { "test", proj, "--verbosity", "normal", "--filter", "FullyQualifiedName~" .. cls }
    label = cls
  end

  run_bg(args, label, mark, cur_buf)
end

function M.run_file(file_path)
  local proj = find_proj(file_path)
  if not proj then
    vim.notify("[Test] No .csproj found for " .. file_path, vim.log.levels.WARN)
    return
  end
  local cls = vim.fn.fnamemodify(file_path, ":t:r")
  local bufnr = vim.fn.bufnr(file_path)
  local sbuf  = (bufnr ~= -1 and vim.api.nvim_buf_is_valid(bufnr)) and bufnr or nil
  run_bg({ "test", proj, "--verbosity", "normal", "--filter", "FullyQualifiedName~" .. cls }, cls, nil, sbuf)
end

-- ── Debug at cursor ───────────────────────────────────────────────────────────

function M.debug_at_cursor()
  local file = vim.api.nvim_buf_get_name(0)
  local proj = find_proj(file)
  if not proj then
    vim.notify("[Test] No .csproj found", vim.log.levels.WARN)
    return
  end

  local method_node, method_name, class_name = get_context()
  if not (method_name and is_test_method(method_node)) then
    vim.notify("[Test] Cursor is not on a [Fact]/[Theory] method", vim.log.levels.WARN)
    return
  end

  local filter = (class_name and (class_name .. "." .. method_name)) or method_name
  local dll    = get_dll(proj)

  vim.notify("[Test] Building for debug…", vim.log.levels.INFO)

  vim.fn.jobstart({ "dotnet", "build", proj, "--nologo", "-q" }, {
    on_exit = function(_, code)
      if code ~= 0 then
        vim.notify("[Test] Build failed — cannot debug", vim.log.levels.ERROR)
        return
      end
      vim.schedule(function()
        local ok, dap = pcall(require, "dap")
        if not ok then return end
        dap.run({
          type    = "coreclr",
          name    = "Debug: " .. method_name,
          request = "launch",
          program = dll,
          args    = { "--filter", filter },
          cwd     = vim.fn.fnamemodify(proj, ":h"),
          env     = { DOTNET_ENVIRONMENT = "Test" },
        })
      end)
    end,
  })
end

return M
