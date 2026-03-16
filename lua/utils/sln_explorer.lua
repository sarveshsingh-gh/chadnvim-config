-- Solution Explorer — VS Code style, full feature set
--
-- Node actions (context-aware by node kind):
--
--   SOLUTION  a=add project  D=remove project  n=new project  B=build  T=test  R=restore
--   PROJECT   a=add proj-ref  P=add NuGet  D=remove NuGet/ref  n=new item
--             b=build  r=run  t=test  v=project view (refs+NuGet)
--   DIR/FILE  <cr>=open  r=rename  d=delete
--   ALL       W=collapse node  E=expand node  H=toggle bin/obj  <F5>=refresh  q=close  ?=help

local M = {}

-- ── Icons ────────────────────────────────────────────────────────────────────
-- Use nvim-web-devicons (bundled with NvChad) for file icons — guaranteed
-- to work with whatever Nerd Font the user has installed.

local _dv = nil
local function dv()
  if _dv == nil then
    local ok, m = pcall(require, "nvim-web-devicons")
    _dv = ok and m or false
  end
  return _dv
end

-- nr2char with UTF-8 flag (2nd arg=1) guarantees correct bytes regardless
-- of 'encoding' setting.
local function g(cp) return vim.fn.nr2char(cp, 1) end

-- Folder icons via mini.icons if available (NvChad default), then devicons
-- directory query, then nf-custom hardcoded fallback.
local function folder_icons()
  local ok, mi = pcall(require, "mini.icons")
  if ok then
    local ic, hl = mi.get("directory", "")
    if ic and ic ~= "" then
      return ic .. " ", ic .. " ", hl, hl   -- open, close, hl_open, hl_close
    end
  end
  -- devicons: some builds expose directory icons via filetype
  local d = require("nvim-web-devicons")
  local ok2, ic2, hl2 = pcall(function()
    return d.get_icon_by_filetype("neo-tree-directory", { default = false })
  end)
  if ok2 and ic2 and ic2 ~= "" then
    return ic2 .. " ", ic2 .. " ", hl2, hl2
  end
  -- nf-custom fallback (same codepoints nvim-tree uses, UTF-8 correct)
  local fo = g(0xE5FE) .. " "
  local fc = g(0xE5FF) .. " "
  return fo, fc, "Directory", "Directory"
end

local _FO, _FC, _FO_HL, _FC_HL  -- cached at first use

local function dir_icon(collapsed)
  if not _FO then _FO, _FC, _FO_HL, _FC_HL = folder_icons() end
  return collapsed and _FC or _FO,
         collapsed and _FC_HL or _FO_HL
end

local I = {
  -- solution / project: use devicons for .slnx and .csproj files
  -- (these render with the SAME icon engine as regular files → guaranteed correct)
  solution = (function()
    local d = require("nvim-web-devicons")
    local ic = d.get_icon("solution.sln", "sln", { default = true })
    return (ic or g(0xF0E8)) .. " "
  end)(),
  project = (function()
    local d = require("nvim-web-devicons")
    local ic = d.get_icon("project.csproj", "csproj", { default = true })
    return (ic or g(0xF1B2)) .. " "
  end)(),
  project_hl = (function()
    local d = require("nvim-web-devicons")
    local _, hl = d.get_icon("project.csproj", "csproj", { default = true })
    return hl
  end)(),
  -- project type icons
  proj_web      = g(0xF484) .. " ",   -- nf-mdi-web          Web/API
  proj_lib      = g(0xF121) .. " ",   -- nf-oct-package      Class library
  proj_test     = g(0xF0C3) .. " ",   -- nf-fa-flask         Test project
  proj_console  = g(0xE615) .. " ",   -- nf-seti-console     Console app
  deps    = g(0xF0E8) .. " ",   -- nf-fa-sitemap   (binary node / hierarchy tree)
  pkg     = g(0xE616) .. " ",   -- nf-seti-nuget   (NuGet package)
  projref = g(0xF0C1) .. " ",   -- nf-fa-link      (project reference)
}

local ALWAYS_SKIP = { [".vs"] = true, [".git"] = true }
local BUILD_DIRS  = { bin = true, obj = true }
local SKIP_EXTS = { dll=true, pdb=true, exe=true, nupkg=true, cache=true, user=true, suo=true }

-- 18% of the current terminal width, minimum 30 cols
local function panel_width() return math.max(30, math.floor(vim.o.columns * 0.18)) end

-- ── State ────────────────────────────────────────────────────────────────────

local S = {
  buf             = nil,
  win             = nil,
  sln_path        = nil,
  nodes           = {},    -- { text, indent, kind, path, dir, collapsed }
  collapsed       = {},    -- paths that are collapsed
  show_build_dirs = false, -- H toggles bin/obj visibility
  job_id          = nil,   -- active terminal job (run_cmd)
  term_buf        = nil,   -- terminal buffer for the active job
  run_proj        = nil,   -- proj_path of the currently running project
}

-- ── Helpers ───────────────────────────────────────────────────────────────────

-- Returns (icon_str, hl_group_or_nil)
local function icon_for(name)
  local d = dv()
  if d then
    local ext       = name:match("%.([^./]+)$") or ""
    local icon, hl  = d.get_icon(name, ext, { default = true })
    if icon and icon ~= "" then
      return icon .. " ", hl
    end
  end
  return g(0xF15B) .. " ", nil  -- nf-fa-file fallback
end

-- Detect .csproj type from SDK/OutputType and return appropriate icon
local function proj_icon(proj_path)
  local ok, lines = pcall(vim.fn.readfile, proj_path)
  if not ok then return I.project end
  local content = table.concat(lines, "\n")
  -- Test projects: name or reference to xunit/nunit/mstest
  local name = vim.fn.fnamemodify(proj_path, ":t:r"):lower()
  if name:match("test") or name:match("spec")
    or content:match("xunit") or content:match("nunit") or content:match("mstest")
    or content:match("Microsoft%.NET%.Test%.Sdk") then
    return I.proj_test
  end
  -- Web / API: Sdk="Microsoft.NET.Sdk.Web"
  if content:match('Sdk="Microsoft%.NET%.Sdk%.Web"') or content:match("Sdk='Microsoft%.NET%.Sdk%.Web'") then
    return I.proj_web
  end
  -- Console app: OutputType Exe
  if content:match("<OutputType>Exe</OutputType>") then
    return I.proj_console
  end
  -- Default → class library
  return I.proj_lib
end

local function find_sln()
  for _, pat in ipairs({ "*.slnx", "*.sln" }) do
    local hits = vim.fn.glob(vim.fn.getcwd() .. "/" .. pat, false, true)
    if #hits > 0 then return hits[1] end
  end
  return nil
end

local function parse_projects(sln_path)
  local lines = vim.fn.readfile(sln_path)
  local dir   = vim.fn.fnamemodify(sln_path, ":h")
  local paths = {}
  if sln_path:match("%.slnx$") then
    for _, l in ipairs(lines) do
      local rel = l:match('Path="([^"]+%.c?f?sproj)"')
      if rel then
        table.insert(paths, vim.fn.fnamemodify(dir .. "/" .. rel:gsub("\\", "/"), ":p"))
      end
    end
  else
    for _, l in ipairs(lines) do
      local rel = l:match('"([^"]+%.c?f?sproj)"')
      if rel then
        table.insert(paths, vim.fn.fnamemodify(dir .. "/" .. rel:gsub("\\", "/"), ":p"))
      end
    end
  end
  return paths
end

-- Parse a .csproj for PackageReference and ProjectReference elements.
-- Returns { pkgs = {{name,version}}, projs = {{name,path}} }
local function parse_deps(proj_path)
  local result = { pkgs = {}, projs = {} }
  local ok, lines = pcall(vim.fn.readfile, proj_path)
  if not ok then return result end
  local proj_dir = vim.fn.fnamemodify(proj_path, ":h")
  for _, line in ipairs(lines) do
    local pkg = line:match('<PackageReference[^>]+Include="([^"]+)"')
    if pkg then
      local ver = line:match('Version="([^"]+)"') or ""
      table.insert(result.pkgs, { name = pkg, version = ver })
    end
    local ref = line:match('<ProjectReference[^>]+Include="([^"]+)"')
    if ref then
      local rp   = vim.fn.fnamemodify(proj_dir .. "/" .. ref:gsub("\\", "/"), ":p")
      local name = vim.fn.fnamemodify(rp, ":t:r")
      table.insert(result.projs, { name = name, path = rp })
    end
  end
  return result
end

local function scan_dir(dir, depth, result)
  if depth > 8 then return end
  local ok, entries = pcall(vim.fn.readdir, dir)
  if not ok then return end
  table.sort(entries, function(a, b)
    local ad = vim.fn.isdirectory(dir .. "/" .. a) == 1
    local bd = vim.fn.isdirectory(dir .. "/" .. b) == 1
    if ad ~= bd then return ad end
    return a:lower() < b:lower()
  end)
  for _, name in ipairs(entries) do
    local full   = dir .. "/" .. name
    local is_dir = vim.fn.isdirectory(full) == 1
    if is_dir then
      local skip = ALWAYS_SKIP[name] or (not S.show_build_dirs and BUILD_DIRS[name])
      if not skip then
        table.insert(result, { name=name, path=full, is_dir=true, depth=depth })
        if not S.collapsed[full] then
          scan_dir(full, depth+1, result)
        end
      end
    else
      local ext = name:match("%.([^.]+)$") or ""
      if not SKIP_EXTS[ext] then
        table.insert(result, { name=name, path=full, is_dir=false, depth=depth })
      end
    end
  end
end

-- ── Highlight namespace ────────────────────────────────────────────────────────

local HL_NS = vim.api.nvim_create_namespace("sln_explorer")

-- Arrow-bearing nodes: linked to theme colour, resolved at open time
-- Will be overridden at open time with the exact folder-icon colour from mini.icons
vim.api.nvim_set_hl(0, "SlnProject", { link = "Directory" })
vim.api.nvim_set_hl(0, "SlnFolder",  { link = "Directory" })

-- kind → highlight group
local KIND_HL = {
  solution = "Title",
  project  = "SlnProject",
  dir      = "SlnFolder",
  file     = "Normal",
  deps     = "SlnFolder",
  pkg      = "String",
  projref  = "Type",
}

-- ── Build tree ────────────────────────────────────────────────────────────────
-- node.text  = icon_str .. name   (NO arrow — arrow added in render)
-- node._ibytes = byte length of icon_str (for extmark coloring)
-- node._ihl    = devicons hl group for the icon (nil → use kind HL)

local function build_nodes()
  local nodes    = {}
  local sln      = S.sln_path
  local sln_name = vim.fn.fnamemodify(sln, ":t:r")
  local sln_coll = S.collapsed[sln] or false
  local proj_paths = parse_projects(sln)
  local n_proj   = #proj_paths
  -- "· N projects" suffix in muted colour — stored separately for hl
  local count_sfx = "  · " .. n_proj .. " project" .. (n_proj == 1 and "" or "s")

  table.insert(nodes, {
    text      = I.solution .. sln_name,
    text_sfx  = count_sfx,            -- rendered after main text, dim hl
    indent    = 0,  kind = "solution",  path = sln,
    collapsed = sln_coll,
    _ibytes   = #I.solution,  _ihl = nil,
  })

  if sln_coll then return nodes end

  for _, proj_path in ipairs(proj_paths) do
    if vim.fn.filereadable(proj_path) == 1 then
      local proj_name = vim.fn.fnamemodify(proj_path, ":t:r")
      -- Keep only the last 2 dot-segments (e.g. "A.B.C.Foo.Web" → "Foo.Web")
      local parts = vim.split(proj_name, ".", { plain = true })
      if #parts > 2 then
        proj_name = table.concat(parts, ".", #parts - 1, #parts)
      end
      local proj_dir  = vim.fn.fnamemodify(proj_path, ":h")
      local is_coll   = S.collapsed[proj_path] or false
      local pio       = proj_icon(proj_path)

      table.insert(nodes, {
        text      = pio .. proj_name,
        indent    = 1,  kind = "project",  path = proj_path,
        dir       = proj_dir,  collapsed = is_coll,
        _ibytes   = #pio,  _ihl = nil,
      })

      if not is_coll then
        -- ── Dependencies virtual node ──────────────────────────────
        local deps_path = proj_path .. "::deps"
        if S.collapsed[deps_path] == nil then S.collapsed[deps_path] = true end
        local deps_coll = S.collapsed[deps_path]
        local deps_data = parse_deps(proj_path)
        local n_deps    = #deps_data.pkgs + #deps_data.projs
        if n_deps > 0 then
          table.insert(nodes, {
            text      = I.deps .. "Dependencies",
            text_sfx  = "  · " .. n_deps,
            indent    = 2,  kind = "deps",  path = deps_path,
            collapsed = deps_coll,
            _ibytes   = #I.deps,  _ihl = nil,
          })
          if not deps_coll then
            for _, pr in ipairs(deps_data.projs) do
              table.insert(nodes, {
                text      = I.projref .. pr.name,
                indent    = 3,  kind = "projref",  path = proj_path .. "::projref::" .. pr.name,
                collapsed = false,  _ibytes = #I.projref,  _ihl = nil,
                _proj_path = proj_path,  _ref_path = pr.path,
              })
            end
            for _, pk in ipairs(deps_data.pkgs) do
              table.insert(nodes, {
                text      = I.pkg .. pk.name,
                text_sfx  = pk.version ~= "" and ("  " .. pk.version) or nil,
                indent    = 3,  kind = "pkg",  path = proj_path .. "::pkg::" .. pk.name,
                collapsed = false,  _ibytes = #I.pkg,  _ihl = nil,
                _proj_path = proj_path,  _pkg_name = pk.name,
              })
            end
          end
        end

        -- ── File tree ──────────────────────────────────────────────
        local entries = {}
        scan_dir(proj_dir, 0, entries)
        for _, e in ipairs(entries) do
          if e.is_dir then
            local ico, ico_hl = dir_icon(S.collapsed[e.path])
            table.insert(nodes, {
              text      = ico .. e.name,
              indent    = 2 + e.depth,  kind = "dir",  path = e.path,
              collapsed = S.collapsed[e.path] or false,
              _ibytes   = #ico,  _ihl = ico_hl,
            })
          else
            local ico, ihl = icon_for(e.name)
            table.insert(nodes, {
              text      = ico .. e.name,
              indent    = 2 + e.depth,  kind = "file",  path = e.path,
              collapsed = false,
              _ibytes   = #ico,  _ihl = ihl,
            })
          end
        end
      end
    end
  end

  return nodes
end

-- ── Render ────────────────────────────────────────────────────────────────────

local INDENT      = "  "
local ARROW_OPEN  = g(0x25BE) .. " "   -- ▾ small filled triangle down  (expanded)
local ARROW_CLOSE = g(0x25B8) .. " "   -- ▸ small filled triangle right (collapsed)
local LEAF_PAD    = "  "               -- leaf files — aligned under folder content

local function render()
  if not S.buf or not vim.api.nvim_buf_is_valid(S.buf) then return end
  local lines = {}

  for _, n in ipairs(S.nodes) do
    local ind   = INDENT:rep(n.indent)
    local is_leaf = n.kind == "file" or n.kind == "pkg" or n.kind == "projref"
    local arrow = is_leaf and LEAF_PAD or (n.collapsed and ARROW_CLOSE or ARROW_OPEN)
    local line  = ind .. arrow .. n.text .. (n.text_sfx or "")
    table.insert(lines, line)
    n._pfx      = #ind + #arrow
    n._name_end = #line - #(n.text_sfx or "")  -- where suffix starts
  end

  vim.bo[S.buf].modifiable = true
  vim.api.nvim_buf_set_lines(S.buf, 0, -1, false, lines)
  vim.bo[S.buf].modifiable = false

  -- Use ONLY nvim_buf_set_extmark (never add_highlight) so that priority
  -- values are the single source of truth with no ambiguity:
  --   p=50   CursorLine bg on solution row (bg only, text hl wins over it)
  --   p=100  whole-line kind colour  (Title / Function / Directory)
  --   p=200  arrow chars → Comment  (overrides line colour → dimmed)
  --   p=250  suffix "· N projects"  → Comment
  --   p=300  icon chars → devicons colour (highest → correct icon tint)
  vim.api.nvim_buf_clear_namespace(S.buf, HL_NS, 0, -1)

  for i, n in ipairs(S.nodes) do
    local row        = i - 1
    local indent_len = #INDENT * n.indent

    -- Solution: darker header background
    if n.kind == "solution" then
      pcall(vim.api.nvim_buf_set_extmark, S.buf, HL_NS, row, 0, {
        end_row = row + 1, end_col = 0,
        hl_group = "SlnHeader", hl_eol = true, priority = 50,
      })
    end

    -- Whole-line kind colour
    local lhl = KIND_HL[n.kind]
    if lhl and lhl ~= "Normal" then
      pcall(vim.api.nvim_buf_set_extmark, S.buf, HL_NS, row, 0, {
        end_col = #lines[i], hl_group = lhl, priority = 100,
      })
    end

    -- Arrow: dim with Comment (skip for leaf kinds)
    if n.kind ~= "file" and n.kind ~= "pkg" and n.kind ~= "projref" then
      pcall(vim.api.nvim_buf_set_extmark, S.buf, HL_NS, row, indent_len, {
        end_col = indent_len + 2, hl_group = "Comment", priority = 200,
      })
    end

    -- "· N projects" suffix
    if n.text_sfx and n._name_end then
      pcall(vim.api.nvim_buf_set_extmark, S.buf, HL_NS, row, n._name_end, {
        end_col = #lines[i], hl_group = "Comment", priority = 250,
      })
    end

    -- Icon colour from devicons (highest priority)
    if n._ihl and n._ibytes and n._ibytes > 0 then
      pcall(vim.api.nvim_buf_set_extmark, S.buf, HL_NS, row, n._pfx, {
        end_col = n._pfx + n._ibytes, hl_group = n._ihl, priority = 300,
      })
    end
  end
end

local function refresh()
  S.nodes = build_nodes()
  render()
end

-- ── Nearest project above cursor ──────────────────────────────────────────────

local function current_node()
  if not S.win then return nil end
  local row = vim.api.nvim_win_get_cursor(S.win)[1]
  return S.nodes[row]
end

local function nearest_project(from_row)
  for i = from_row, 1, -1 do
    local n = S.nodes[i]
    if n and n.kind == "project" then return n end
  end
  return nil
end

-- ── Floating confirm/input helpers ───────────────────────────────────────────

local function confirm(msg, cb)
  vim.ui.input({ prompt = msg .. " [y/N]: " }, function(ans)
    if ans and ans:lower() == "y" then cb() end
  end)
end

-- ── Actions ───────────────────────────────────────────────────────────────────

local function get_launch_ports(proj_path)
  local settings = vim.fn.fnamemodify(proj_path, ":h") .. "/Properties/launchSettings.json"
  local ok, lines = pcall(vim.fn.readfile, settings)
  if not ok then return {} end
  local ports = {}
  local content = table.concat(lines, "\n")
  for url in content:gmatch('"applicationUrl"%s*:%s*"([^"]+)"') do
    for port in url:gmatch(":(%d+)") do
      ports[port] = true
    end
  end
  return ports
end

local function kill_ports(ports)
  for port in pairs(ports) do
    vim.fn.system("fuser -k " .. port .. "/tcp 2>/dev/null")
  end
end

-- Kill all Neovim terminal jobs whose command contains "dotnet"
local function kill_dotnet_terminals()
  local killed = false
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buftype == "terminal" then
      local job_id = vim.b[buf].terminal_job_id
      if job_id then
        local ok, pid = pcall(vim.fn.jobpid, job_id)
        if ok and pid and pid > 0 then
          -- check if this is a dotnet process
          local name = vim.fn.system("ps -p " .. pid .. " -o comm= 2>/dev/null"):gsub("\n", "")
          if name:match("dotnet") or name:match("%.dll") then
            pcall(vim.fn.jobstop, job_id)
            killed = true
          end
        end
      end
    end
  end
  return killed
end

local function stop_running()
  local stopped = false

  -- 1. kill our tracked job
  if S.job_id then
    vim.fn.jobstop(S.job_id)
    S.job_id = nil
    stopped = true
  end

  -- 2. kill any dotnet terminal started by easy-dotnet or anything else
  if kill_dotnet_terminals() then stopped = true end

  -- 3. kill by port from launchSettings (catches daemonised / external processes)
  if S.run_proj then
    kill_ports(get_launch_ports(S.run_proj))
    S.run_proj = nil
    stopped = true
  end

  S.term_buf = nil
  vim.notify(
    stopped and "[SolnExplorer] Process stopped" or "[SolnExplorer] No running process",
    vim.log.levels.INFO
  )
end

-- Run a short-lived dotnet command (build/test/restore) fully in the background.
-- No window is ever opened. Notifies on finish; gx reveals the log buffer.
local function run_build_cmd(args, label)
  local output = {}
  local log_buf = vim.api.nvim_create_buf(false, true)
  vim.bo[log_buf].buftype   = "nofile"
  vim.bo[log_buf].bufhidden = "wipe"
  vim.api.nvim_buf_set_name(log_buf, "[" .. label .. " Log]")
  S.term_buf = log_buf

  vim.notify("[SolnExplorer] " .. label .. " started…", vim.log.levels.INFO)

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
        if vim.api.nvim_buf_is_valid(log_buf) then
          vim.bo[log_buf].modifiable = true
          vim.api.nvim_buf_set_lines(log_buf, 0, -1, false, output)
          vim.bo[log_buf].modifiable = false
        end
        if code == 0 then
          vim.notify("[SolnExplorer] " .. label .. " succeeded  (gx = log)", vim.log.levels.INFO)
        else
          vim.notify("[SolnExplorer] " .. label .. " FAILED  (gx = log)", vim.log.levels.ERROR)
        end
        refresh()
      end)
    end,
  })
end

-- Run a dotnet CLI command in a hidden terminal buffer.
-- The buffer stays alive (job keeps running); reveal with gx.
local function run_cmd(args, on_exit)
  -- create buffer in a temporary window, then hide the window
  vim.cmd("botright 12new")
  S.term_buf     = vim.api.nvim_get_current_buf()
  local term_win = vim.api.nvim_get_current_win()
  local cmd      = "dotnet " .. table.concat(args, " ")

  S.job_id = vim.fn.termopen(cmd, {
    on_stdout = function(_, data, _)
      if not data then return end
      for _, line in ipairs(data) do
        -- strip ANSI colour codes before matching
        local clean = line:gsub("\27%[[%d;]*[mK]", "")
        local url   = clean:match("Now listening on: (https?://%S+)")
        if url then
          vim.schedule(function()
            vim.notify("[Run] " .. url .. "   (gx = show log, x = stop)", vim.log.levels.INFO)
          end)
        end
      end
    end,
    on_exit = function(_, code)
      S.job_id   = nil
      S.term_buf = nil
      S.run_proj = nil
      if on_exit then on_exit(code) end
      vim.schedule(refresh)
    end,
  })

  -- x works from the log window too
  vim.keymap.set("n", "x", stop_running, { buffer = S.term_buf, silent = true })

  -- hide window immediately — buffer + job stay alive in background
  vim.api.nvim_win_hide(term_win)
  if S.win and vim.api.nvim_win_is_valid(S.win) then
    vim.api.nvim_set_current_win(S.win)
  end
end

local function get_dotnet(mod)
  local ok, m = pcall(require, "easy-dotnet." .. mod)
  return ok and m or nil
end

-- Derive the correct C# namespace for file_path given a .csproj.
-- Uses <RootNamespace> if present, otherwise the project name.
-- Appends dot-separated subfolder path relative to the project root.
local function compute_namespace(proj_path, file_path)
  local root_ns = vim.fn.fnamemodify(proj_path, ":t:r")  -- fallback = project name
  local ok, lines = pcall(vim.fn.readfile, proj_path)
  if ok then
    local content = table.concat(lines, "\n")
    local rn = content:match("<RootNamespace>([^<]+)</RootNamespace>")
    if rn then root_ns = vim.trim(rn) end
  end
  local proj_dir = vim.fn.fnamemodify(proj_path, ":h")
  local file_dir = vim.fn.fnamemodify(file_path, ":h")
  local rel      = file_dir:sub(#proj_dir + 2)  -- strip "proj_dir/"
  if rel == "" then return root_ns end
  return root_ns .. "." .. rel:gsub("/", ".")
end

-- Replace (or insert) the namespace declaration in a .cs file on disk.
local function patch_namespace(file_path, ns)
  local ok, lines = pcall(vim.fn.readfile, file_path)
  if not ok then return end
  local patched = false
  for i, l in ipairs(lines) do
    local replaced = l:gsub("^(namespace%s+)([%w%.]+)", function(kw)
      patched = true
      return kw .. ns
    end)
    lines[i] = replaced
  end
  if patched then vim.fn.writefile(lines, file_path) end
end

-- ── Solution-level actions ────────────────────────────────────────────────────

local function action_add_project()
  local sln = get_dotnet("parsers.sln-parse")
  if sln then
    coroutine.wrap(function() sln.add_project_to_solution(S.sln_path) end)()
    vim.defer_fn(refresh, 800)
  end
end

local function action_remove_project()
  local sln = get_dotnet("parsers.sln-parse")
  if sln then
    coroutine.wrap(function() sln.remove_project_from_solution(S.sln_path) end)()
    vim.defer_fn(refresh, 800)
  end
end

local function action_new_project()
  local new = get_dotnet("actions.new")
  if new then
    coroutine.wrap(function() new.new() end)()
    vim.defer_fn(refresh, 1500)
  end
end

local function action_build_solution()
  run_build_cmd({ "build", vim.fn.fnameescape(S.sln_path) }, "Build solution")
end

local function action_test_solution()
  local act = get_dotnet("actions.test")
  if act then coroutine.wrap(function() act.test_solution() end)() end
end

local function action_restore_solution()
  run_build_cmd({ "restore", vim.fn.fnameescape(S.sln_path) }, "Restore")
end

-- ── Project-level actions ─────────────────────────────────────────────────────

local function action_add_project_ref(proj_node)
  local mappings = get_dotnet("csproj-mappings")
  if mappings then
    coroutine.wrap(function()
      mappings.add_project_reference(proj_node.path, function() refresh() end)
    end)()
  end
end

local function action_add_nuget(proj_node)
  local nuget = get_dotnet("nuget")
  if nuget then
    coroutine.wrap(function()
      nuget.search_nuget(proj_node.path, false)
    end)()
    vim.defer_fn(refresh, 1000)
  end
end

-- cwd = project directory; dotnet auto-discovers the .csproj there.
local function run_remove_cmd(cmd, label, proj_dir)
  local stderr = {}
  vim.fn.jobstart(cmd, {
    cwd = proj_dir,
    on_stderr = function(_, data)
      for _, l in ipairs(data) do if l ~= "" then table.insert(stderr, l) end end
    end,
    on_exit = function(_, code)
      vim.schedule(function()
        if code ~= 0 then
          vim.notify("[SolnExplorer] " .. label .. " failed:\n" .. table.concat(stderr, "\n"), vim.log.levels.ERROR)
        else
          vim.notify("[SolnExplorer] " .. label, vim.log.levels.INFO)
          refresh()
        end
      end)
    end,
  })
end

local function action_remove_package(node)
  local proj = node._proj_path
  local pkg  = node._pkg_name
  if not proj or not pkg then return end
  local proj_dir = vim.fn.fnamemodify(proj, ":h")
  confirm("Remove package '" .. pkg .. "'?", function()
    run_remove_cmd({ "dotnet", "remove", "package", pkg }, "Removed " .. pkg, proj_dir)
  end)
end

local function action_remove_projref(node)
  local proj = node._proj_path
  local ref  = node._ref_path
  if not proj or not ref then return end
  local proj_dir = vim.fn.fnamemodify(proj, ":h")
  local name = vim.fn.fnamemodify(ref, ":t:r")
  confirm("Remove project reference '" .. name .. "'?", function()
    run_remove_cmd({ "dotnet", "remove", "reference", ref }, "Removed ref " .. name, proj_dir)
  end)
end

local function action_remove_from_project(proj_node)
  local proj_dir = vim.fn.fnamemodify(proj_node.path, ":h")
  local deps = parse_deps(proj_node.path)
  local items = {}
  for _, pk in ipairs(deps.pkgs)  do table.insert(items, { label = "pkg: " .. pk.name, kind = "pkg", name = pk.name,  proj_dir = proj_dir }) end
  for _, pr in ipairs(deps.projs) do table.insert(items, { label = "ref: " .. pr.name, kind = "ref", path = pr.path,  proj_dir = proj_dir }) end
  if #items == 0 then
    vim.notify("[SolnExplorer] No packages or references to remove", vim.log.levels.INFO)
    return
  end
  vim.ui.select(items, {
    prompt      = "Remove from " .. vim.fn.fnamemodify(proj_node.path, ":t:r") .. ":",
    format_item = function(i) return i.label end,
  }, function(item)
    if not item then return end
    if item.kind == "pkg" then
      confirm("Remove package '" .. item.name .. "'?", function()
        run_remove_cmd({ "dotnet", "remove", "package", item.name }, "Removed " .. item.name, item.proj_dir)
      end)
    else
      local name = vim.fn.fnamemodify(item.path, ":t:r")
      confirm("Remove project reference '" .. name .. "'?", function()
        run_remove_cmd({ "dotnet", "remove", "reference", item.path }, "Removed ref " .. name, item.proj_dir)
      end)
    end
  end)
end

local NEW_ITEM_TEMPLATES = {
  { value = "class",          display = "Class",                      ext = ".cs"     },
  { value = "interface",      display = "Interface",                  ext = ".cs"     },
  { value = "record",         display = "Record",                     ext = ".cs"     },
  { value = "struct",         display = "Struct",                     ext = ".cs"     },
  { value = "enum",           display = "Enum",                       ext = ".cs"     },
  { value = "apicontroller",  display = "API Controller",             ext = ".cs"     },
  { value = "mvccontroller",  display = "MVC Controller",             ext = ".cs"     },
  { value = "razorcomponent", display = "Razor Component",            ext = ".razor"  },
  { value = "page",           display = "Razor Page",                 ext = ".cshtml" },
  { value = "view",           display = "Razor View",                 ext = ".cshtml" },
  { value = "viewimports",    display = "MVC ViewImports",            ext = ".cshtml" },
  { value = "viewstart",      display = "MVC ViewStart",              ext = ".cshtml" },
  { value = "nunit-test",     display = "NUnit 3 Test Item",          ext = ".cs"     },
  { value = "buildprops",     display = "Directory.Build.props",      predefined = "Directory.Build.props"   },
  { value = "packagesprops",  display = "Directory.Packages.props",   predefined = "Directory.Packages.props" },
  { value = "buildtargets",   display = "Directory.Build.targets",    predefined = "Directory.Build.targets" },
  { value = "gitignore",      display = ".gitignore",                 predefined = ".gitignore"   },
  { value = "editorconfig",   display = ".editorconfig",              predefined = ".editorconfig" },
  { value = "globaljson",     display = "global.json",                predefined = "global.json"  },
  { value = "nugetconfig",    display = "nuget.config",               predefined = "nuget.config" },
  { value = "webconfig",      display = "web.config",                 predefined = "web.config"   },
}

local action_open_file  -- forward declaration (defined below)

local function action_new_item(proj_node, target_dir)
  local out_dir = target_dir or proj_node.dir

  vim.ui.select(NEW_ITEM_TEMPLATES, {
    prompt      = "New item (" .. vim.fn.fnamemodify(proj_node.path, ":t:r") .. "):",
    format_item = function(t) return t.display end,
  }, function(tpl)
    if not tpl then return end

    local function run(name)
      local cmd, file_path
      if tpl.predefined then
        cmd       = { "dotnet", "new", tpl.value, "-o", out_dir }
        file_path = out_dir .. "/" .. tpl.predefined
      else
        -- allow "sub/path/ClassName" → creates in out_dir/sub/path/
        local sub  = name:match("^(.+)/[^/]+$")  -- everything before last /
        local base = name:match("([^/]+)$")       -- just the class name
        local dest_abs = sub and (out_dir .. "/" .. sub) or out_dir
        vim.fn.mkdir(dest_abs, "p")
        -- Pass a relative path from the project root so dotnet can derive
        -- the correct namespace (RootNamespace + relative folder segments).
        local dest_rel = dest_abs:sub(#proj_node.dir + 2)
        local o_flag   = dest_rel ~= "" and dest_rel or "."
        cmd       = { "dotnet", "new", tpl.value, "-o", o_flag, "-n", base }
        file_path = dest_abs .. "/" .. base .. tpl.ext
      end

      local stderr = {}
      vim.fn.jobstart(cmd, {
        cwd       = proj_node.dir,   -- cwd = project dir so dotnet finds the .csproj
        on_stderr = function(_, data)
          for _, l in ipairs(data) do
            if l ~= "" then table.insert(stderr, l) end
          end
        end,
        on_exit = function(_, code)
          vim.schedule(function()
            if code ~= 0 then
              vim.notify("[SolnExplorer] dotnet new failed:\n" .. table.concat(stderr, "\n"), vim.log.levels.ERROR)
              return
            end
            if vim.fn.filereadable(file_path) == 1 and tpl.ext == ".cs" then
              local ns = compute_namespace(proj_node.path, file_path)
              patch_namespace(file_path, ns)
            end
            refresh()
            if vim.fn.filereadable(file_path) == 1 then
              action_open_file({ path = file_path, kind = "file" })
            end
          end)
        end,
      })
    end

    if tpl.predefined then
      run(nil)
    else
      vim.ui.input({ prompt = "Name (e.g. MyClass or Sub/Folder/MyClass): " }, function(name)
        if name and name ~= "" then run(name) end
      end)
    end
  end)
end

local function action_build_project(proj_node)
  local name = vim.fn.fnamemodify(proj_node.path, ":t:r")
  run_build_cmd({ "build", vim.fn.fnameescape(proj_node.path) }, "Build " .. name)
end

local function action_run_project(proj_node)
  -- kill tracked job if any
  if S.job_id then
    vim.fn.jobstop(S.job_id)
    S.job_id   = nil
    S.term_buf = nil
  end
  -- kill any process already bound to the project's ports
  local ports = get_launch_ports(proj_node.path)
  kill_ports(ports)
  if next(ports) then
    local list = table.concat(vim.tbl_keys(ports), ", ")
    vim.notify("[SolnExplorer] Freed port(s) " .. list, vim.log.levels.INFO)
  end
  S.run_proj = proj_node.path
  run_cmd({ "run", "--project", vim.fn.fnameescape(proj_node.path) })
end

local function action_test_project(proj_node)
  local name = vim.fn.fnamemodify(proj_node.path, ":t:r")
  run_build_cmd({ "test", vim.fn.fnameescape(proj_node.path) }, "Test " .. name)
end

local function action_project_view(_)
  local pv = get_dotnet("project-view")
  if pv then coroutine.wrap(pv.open_or_toggle)() end
end

-- ── File/dir actions ──────────────────────────────────────────────────────────

action_open_file = function(node)
  -- Find an existing non-explorer editor window
  local target = nil
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if w ~= S.win and vim.bo[vim.api.nvim_win_get_buf(w)].buftype ~= "nofile" then
      target = w; break
    end
  end
  if not target then
    -- No editor pane yet — open one to the right of the explorer
    local saved = vim.api.nvim_get_current_win()
    vim.cmd("botright vsplit")
    target = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(saved)
  end
  vim.api.nvim_set_current_win(target)
  vim.cmd("edit " .. vim.fn.fnameescape(node.path))
  -- focus stays in the opened file (explorer remains open in its window)
end

local function action_new_file(node)
  -- Determine target directory
  local dir = node.kind == "dir" and node.path
           or vim.fn.fnamemodify(node.path, ":h")
  vim.ui.input({ prompt = "New file name: " }, function(name)
    if not name or name == "" then return end
    local path = dir .. "/" .. name
    vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
    local f = io.open(path, "w")
    if f then
      f:close()
      vim.notify("[SolnExplorer] Created " .. name, vim.log.levels.INFO)
      refresh()
      action_open_file({ path = path, kind = "file" })
    else
      vim.notify("[SolnExplorer] Could not create " .. path, vim.log.levels.ERROR)
    end
  end)
end

local function action_rename(node)
  local old_name = vim.fn.fnamemodify(node.path, ":t")
  vim.ui.input({ prompt = "Rename to: ", default = old_name }, function(new_name)
    if not new_name or new_name == "" or new_name == old_name then return end
    local new_path = vim.fn.fnamemodify(node.path, ":h") .. "/" .. new_name
    local ok, err  = os.rename(node.path, new_path)
    if ok then
      vim.notify("[SolnExplorer] Renamed → " .. new_name, vim.log.levels.INFO)
      refresh()
    else
      vim.notify("[SolnExplorer] Rename failed: " .. (err or ""), vim.log.levels.ERROR)
    end
  end)
end

local function action_delete(node)
  local name = vim.fn.fnamemodify(node.path, ":t")
  confirm("Delete " .. name .. "?", function()
    if node.kind == "dir" then
      vim.fn.delete(node.path, "rf")
    else
      vim.fn.delete(node.path)
    end
    vim.notify("[SolnExplorer] Deleted " .. name, vim.log.levels.INFO)
    refresh()
  end)
end

-- ── Help popup ────────────────────────────────────────────────────────────────

local function show_help()
  local lines = {
    "  Solution Explorer — Keymaps",
    "  ══════════════════════════════════════════════════",
    "",
    "  ── Global (any node) ────────────────────────────",
    "  <cr>          open file  /  toggle fold",
    "  <space>       toggle fold",
    "  /             fuzzy find file in solution",
    "  W             collapse node",
    "  E             expand node (1 level)",
    "  x             stop running process",
    "  gx            show / reveal log terminal",
    "  <F5>          refresh tree",
    "  <F7>          test runner",
    "  H             toggle bin/obj dirs",
    "  q             close Solution Explorer",
    "  <M-S-p>       Dotnet command palette",
    "  ?             this help",
    "",
    "  ── Build ────────────────────────────────────────",
    "  B             build solution  (on solution node)",
    "  b             build project   (on project node)",
    "  <leader>nc    clean solution",
    "",
    "  ── SOLUTION node ────────────────────────────────",
    "  a             add existing project",
    "  D             remove project from solution",
    "  n             new project (wizard)",
    "  B             build solution",
    "  T             test  solution",
    "  R             dotnet restore",
    "",
    "  ── PROJECT node ─────────────────────────────────",
    "  a             add project reference",
    "  P             add NuGet package",
    "  D             project view → remove ref / pkg",
    "  n             new file / class in project",
    "  b             build project",
    "  r             run   project",
    "  t             test  project",
    "  v             project view (refs + NuGet)",
    "",
    "  ── FILE / DIR node ──────────────────────────────",
    "  <cr>          open file",
    "  t             run tests in file  (*.cs test files)",
    "  a             new file in this directory",
    "  r             rename",
    "  d             delete (with confirm)",
    "",
    "  ── Test Runner  (F7 to open) ────────────────────",
    "  r             run test under cursor",
    "  <leader>ta    run all tests",
    "  <leader>tf    filter failed tests",
    "  <leader>td    debug test",
    "  gf            go to test file",
    "",
    "  ── Debug  [Visual Studio style] ─────────────────",
    "  F5            continue / start         [VS: F5]",
    "  S-F5          stop                     [VS: S-F5]",
    "  F9            toggle breakpoint        [VS: F9]",
    "  F10           step over                [VS: F10]",
    "  F11           step into                [VS: F11]",
    "  S-F11         step out                 [VS: S-F11]",
    "  S-F9          QuickWatch (peek value)  [VS: S-F9]",
    "  <M-i>         add to Watch window      [VS: C-A-W]",
    "  <leader>di    Immediate window         [VS: C-A-I]",
    "  <Tab>         next panel  (in dapui)",
    "  <S-Tab>       prev panel  (in dapui)",
    "  x             stop process (in dapui)",
    "",
    "  ── Code buffer  (*.cs files) ────────────────────",
    "  t             run test at cursor",
    "               on [Fact]/[Theory] → single test",
    "               on class name      → whole class",
    "               elsewhere          → whole file",
    "  dt            debug test at cursor ([Fact] only)",
    "",
    "  ── Toggle from anywhere ─────────────────────────",
    "  <leader>ne    toggle Solution Explorer",
    "  <leader>nE    reveal current file in tree",
    "",
    "  Press  q  or  <Esc>  to close this help",
  }
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  local w = math.max(48, #lines[2] + 2)
  local h = #lines
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width    = w,
    height   = h,
    col      = math.floor((vim.o.columns - w) / 2),
    row      = math.floor((vim.o.lines - h) / 2),
    style    = "minimal",
    border   = "rounded",
    title    = " Help ",
    title_pos = "center",
  })
  vim.keymap.set("n", "q",     function() vim.api.nvim_win_close(win, true) end, { buffer=buf })
  vim.keymap.set("n", "<esc>", function() vim.api.nvim_win_close(win, true) end, { buffer=buf })
end

-- ── Context-aware dispatch ────────────────────────────────────────────────────

-- `key` pressed — dispatch based on current node kind
local DISPATCH = {
  -- ── Common ───────────────────────────────────────────────────────
  ["<cr>"] = function(node, _)
    local leaf = node.kind == "file" or node.kind == "pkg" or node.kind == "projref"
    if leaf then
      if node.kind == "file" then action_open_file(node) end
    else
      S.collapsed[node.path] = not S.collapsed[node.path]
      local row = vim.api.nvim_win_get_cursor(S.win)[1]
      refresh()
      pcall(vim.api.nvim_win_set_cursor, S.win, { row, 0 })
    end
  end,
  ["<space>"] = function(node, _)
    local leaf = node.kind == "file" or node.kind == "pkg" or node.kind == "projref"
    if not leaf then
      S.collapsed[node.path] = not S.collapsed[node.path]
      local row = vim.api.nvim_win_get_cursor(S.win)[1]
      refresh()
      pcall(vim.api.nvim_win_set_cursor, S.win, { row, 0 })
    end
  end,

  -- ── Solution ──────────────────────────────────────────────────────
  ["a"] = function(node, row)
    if     node.kind == "solution" then action_add_project()
    elseif node.kind == "project"  then action_add_project_ref(node)
    else   action_new_file(node)   -- file or dir → create new file here
    end
  end,
  ["D"] = function(node, row)
    if     node.kind == "solution" then action_remove_project()
    elseif node.kind == "project"  then action_remove_from_project(node)
    elseif node.kind == "pkg"      then action_remove_package(node)
    elseif node.kind == "projref"  then action_remove_projref(node)
    elseif node.kind == "file" or node.kind == "dir" then action_delete(node)
    end
  end,
  ["n"] = function(node, row)
    if     node.kind == "solution" then action_new_project()
    elseif node.kind == "project"  then action_new_item(node)
    else
      local proj = nearest_project(row)
      if proj then
        local target = node.kind == "dir" and node.path
                    or (node.path and vim.fn.fnamemodify(node.path, ":h"))
        action_new_item(proj, target)
      end
    end
  end,
  ["B"] = function(node, row)
    if node.kind == "solution" then action_build_solution()
    else
      local proj = nearest_project(row)
      if proj then action_build_project(proj) end
    end
  end,
  ["T"] = function(node, row)
    if node.kind == "solution" then action_test_solution()
    else
      local proj = nearest_project(row)
      if proj then action_test_project(proj) end
    end
  end,
  ["R"] = function(node, _)
    if node.kind == "solution" then action_restore_solution()
    else refresh() end
  end,

  -- ── Project ────────────────────────────────────────────────────────
  ["P"] = function(node, row)
    local proj = node.kind == "project" and node or nearest_project(row)
    if proj then action_add_nuget(proj) end
  end,
  ["b"] = function(node, row)
    local proj = node.kind == "project" and node or nearest_project(row)
    if proj then action_build_project(proj) end
  end,
  ["r"] = function(node, row)
    if node.kind == "file" or node.kind == "dir" then
      action_rename(node)
    else
      local proj = node.kind == "project" and node or nearest_project(row)
      if proj then action_run_project(proj) end
    end
  end,
  ["t"] = function(node, row)
    if node.kind == "file" and node.path:match("%.cs$") then
      require("utils.test_runner").run_file(node.path)
    else
      local proj = node.kind == "project" and node or nearest_project(row)
      if proj then action_test_project(proj) end
    end
  end,
  ["v"] = function(node, row)
    local proj = node.kind == "project" and node or nearest_project(row)
    if proj then action_project_view(proj) end
  end,

  -- ── File ───────────────────────────────────────────────────────────
  ["d"] = function(node, _)
    if node.kind == "file" or node.kind == "dir" then action_delete(node) end
  end,

  ["x"] = function(_, _) stop_running() end,

  ["gx"] = function(_, _)
    -- 1. Our tracked log/terminal buffer — reveal it
    if S.term_buf and vim.api.nvim_buf_is_valid(S.term_buf) then
      local is_term = vim.bo[S.term_buf].buftype == "terminal"
      -- already visible?
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.api.nvim_win_get_buf(win) == S.term_buf then
          vim.api.nvim_set_current_win(win)
          if is_term then vim.cmd("startinsert") end
          return
        end
      end
      -- open it in a bottom split
      vim.cmd("botright 12split")
      vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), S.term_buf)
      if is_term then vim.cmd("startinsert") end
      return
    end
    -- 2. easy-dotnet managed terminal toggle
    local ok, term = pcall(require, "easy-dotnet.terminal")
    if ok and term.toggle then
      term.toggle()
      return
    end
    -- 3. any other terminal buffer visible / hidden
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].buftype == "terminal" and win ~= S.win then
        vim.api.nvim_set_current_win(win)
        vim.cmd("startinsert")
        return
      end
    end
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.bo[buf].buftype == "terminal" and buf ~= S.buf then
        vim.cmd("botright 12split")
        vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), buf)
        vim.cmd("startinsert")
        return
      end
    end
    vim.notify("[SolnExplorer] No terminal buffer found", vim.log.levels.INFO)
  end,

  ["?"] = function(_, _) show_help() end,
  ["W"] = function(node, _)
    local leaf = node.kind == "file" or node.kind == "pkg" or node.kind == "projref"
    if not leaf then
      S.collapsed[node.path] = true
      local row = vim.api.nvim_win_get_cursor(S.win)[1]
      refresh()
      pcall(vim.api.nvim_win_set_cursor, S.win, { row, 0 })
    end
  end,
  ["E"] = function(node, _)
    local leaf = node.kind == "file" or node.kind == "pkg" or node.kind == "projref"
    if not leaf then
      S.collapsed[node.path] = false
      -- collapse direct children that have never been explicitly opened
      S.nodes = build_nodes()
      local found = false
      for _, n in ipairs(S.nodes) do
        if n.path == node.path then
          found = true
        elseif found then
          if n.indent <= node.indent then break end
          if n.indent == node.indent + 1 then
            local cl = n.kind == "file" or n.kind == "pkg" or n.kind == "projref"
            if not cl and S.collapsed[n.path] == nil then
              S.collapsed[n.path] = true
            end
          end
        end
      end
      local row = vim.api.nvim_win_get_cursor(S.win)[1]
      refresh()
      pcall(vim.api.nvim_win_set_cursor, S.win, { row, 0 })
    end
  end,
  ["H"] = function(_, _)
    S.show_build_dirs = not S.show_build_dirs
    vim.notify("[SolnExplorer] bin/obj " .. (S.show_build_dirs and "shown" or "hidden"),
      vim.log.levels.INFO)
    refresh()
  end,
}

-- ── Forward declarations (needed by WinClosed closure inside open_win) ────────

local _saved_stl    -- saved showtabline (set in M.open)
local _winbar_auID  -- WinNew autocmd id (set in M.open)
local clear_winbars     -- defined below in Public API section
local fuzzy_find_in_sln -- defined below in Public API section

-- ── Window / buffer setup ─────────────────────────────────────────────────────

local function setup_keymaps()
  local o = { noremap=true, silent=true, buffer=S.buf }

  for key, fn in pairs(DISPATCH) do
    vim.keymap.set("n", key, function()
      local row  = vim.api.nvim_win_get_cursor(S.win)[1]
      local node = S.nodes[row]
      if node then fn(node, row) end
    end, o)
  end

  vim.keymap.set("n", "/",    fuzzy_find_in_sln, o)
  vim.keymap.set("n", "<F5>", refresh,   o)
  vim.keymap.set("n", "<F7>", function() require("easy-dotnet").testrunner() end, o)
  vim.keymap.set("n", "q",    M.close,   o)
  vim.keymap.set("n", "<M-S-p>", "<cmd>Dotnet<cr>", o)
end

local function open_win()
  S.buf = vim.api.nvim_create_buf(false, true)  -- NOT listed → invisible in tabufline (like nvim-tree)
  vim.bo[S.buf].filetype   = "sln_explorer"
  vim.bo[S.buf].bufhidden  = "wipe"
  vim.bo[S.buf].modifiable = false
  vim.bo[S.buf].buftype    = "nofile"
  vim.api.nvim_buf_set_name(S.buf, "Solution Explorer")

  vim.cmd("topleft " .. panel_width() .. "vsplit")
  S.win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(S.win, S.buf)

  local wo = vim.wo[S.win]
  wo.number = false; wo.relativenumber = false
  wo.signcolumn = "no"; wo.foldcolumn = "0"
  wo.wrap = false; wo.winfixwidth = true
  wo.cursorline = true
  wo.winbar = ""
  -- Darker panel background (same as nvim-tree)
  wo.winhighlight = "Normal:NvimTreeNormal,NormalNC:NvimTreeNormalNC,CursorLine:NvimTreeCursorLine,WinSeparator:SlnExplorerSep"
  -- Hide ~ end-of-buffer markers; force │ separator
  vim.opt_local.fillchars = { vert = "│", vertright = "│", eob = " " }
  -- Define runtime highlights (theme-aware — resolved after colorscheme loads)
  vim.schedule(function()
    -- Use the same hl group as the folder icon (_FO_HL set by build_nodes via mini.icons)
    -- This guarantees separator, project text, and folder text all match the folder icon exactly.
    if _FO_HL then
      vim.api.nvim_set_hl(0, "SlnProject", { link = _FO_HL })
      vim.api.nvim_set_hl(0, "SlnFolder",  { link = _FO_HL })
    end
    local fb  = vim.api.nvim_get_hl(0, { name = "FloatBorder", link = false })
    local fg  = (_FO_HL and vim.api.nvim_get_hl(0, { name = _FO_HL }).fg) or fb.fg or 0x3e4452
    -- Dim the WinSeparator: blend fg 30% toward bg
    do
      local nt   = vim.api.nvim_get_hl(0, { name = "NvimTreeNormal", link = false })
      local norm = vim.api.nvim_get_hl(0, { name = "Normal",         link = false })
      local sbg  = nt.bg or norm.bg or 0x1e2127
      local mix  = function(a, b, t) return math.floor(a * t + b * (1 - t)) end
      local sr   = mix(math.floor(fg / 65536) % 256, math.floor(sbg / 65536) % 256, 0.30)
      local sg   = mix(math.floor(fg / 256)   % 256, math.floor(sbg / 256)   % 256, 0.30)
      local sb   = mix(fg % 256,                      sbg % 256,                     0.30)
      vim.api.nvim_set_hl(0, "SlnExplorerSep", { fg = sr * 65536 + sg * 256 + sb })
    end

    -- Tabline blank area: same bg as the explorer panel (NvimTreeNormal → Normal fallback)
    local nt = vim.api.nvim_get_hl(0, { name = "NvimTreeNormal", link = false })
    local bg = nt.bg
    if not bg then
      local norm = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
      bg = norm.bg or 0x1e2127
    end
    vim.api.nvim_set_hl(0, "SlnTabBlank", { fg = bg, bg = bg })
    -- Separator in tabline: same fg as SlnExplorerSep, panel bg
    vim.api.nvim_set_hl(0, "SlnTabSep", { fg = fg, bg = bg })
    -- Header row: darken panel bg by 25% for the solution title row
    local r      = math.floor(math.floor(bg / 65536) % 256 * 0.75)
    local g2     = math.floor(math.floor(bg / 256)   % 256 * 0.75)
    local b2     = math.floor(bg % 256 * 0.75)
    local darker = r * 65536 + g2 * 256 + b2
    vim.api.nvim_set_hl(0, "SlnHeader",  { bg = darker })
  end)

  vim.api.nvim_create_autocmd("WinClosed", {
    buffer = S.buf, once = true,
    callback = function()
      S.win = nil; S.buf = nil
      if _winbar_auID then pcall(vim.api.nvim_del_autocmd, _winbar_auID); _winbar_auID = nil end
      clear_winbars()
      if _saved_stl ~= nil then vim.o.showtabline = _saved_stl; _saved_stl = nil end
    end,
  })
end

-- ── Public API ────────────────────────────────────────────────────────────────

local NVCHAD_TABLINE = "%!v:lua.require('nvchad.tabufline.modules')()"
-- winbar expression: %{%...%} so the returned string is itself parsed for % items
local TABS_WINBAR    = "%{%v:lua.require('nvchad.tabufline.modules')()%}"

-- Apply tabs winbar to every editor window; explorer window stays ""
local function apply_winbars()
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if w ~= S.win and vim.api.nvim_win_is_valid(w) then
      -- only real file-editing windows get the tab winbar
      local bt = vim.bo[vim.api.nvim_win_get_buf(w)].buftype
      vim.wo[w].winbar = (bt == "") and TABS_WINBAR or ""
    end
  end
end

-- Remove the tabs winbar from all windows (called on close)
clear_winbars = function()
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_is_valid(w) then
      vim.wo[w].winbar = ""
    end
  end
end

function M.close()
  if S.win and vim.api.nvim_win_is_valid(S.win) then
    vim.api.nvim_win_close(S.win, true)
  end
  S.win = nil; S.buf = nil
  if _winbar_auID then
    pcall(vim.api.nvim_del_autocmd, _winbar_auID)
    _winbar_auID = nil
  end
  clear_winbars()
  if _saved_stl ~= nil then
    vim.o.showtabline = _saved_stl
    _saved_stl = nil
  end
end

-- Hide the "No Name" startup buffer from the tabufline WITHOUT deleting it.
-- Deleting it would collapse the editor split — instead just unlist it.
local function hide_empty_bufs()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= S.buf
      and vim.bo[buf].buflisted
      and vim.api.nvim_buf_get_name(buf) == ""
      and not vim.bo[buf].modified then
      vim.bo[buf].buflisted = false   -- vanishes from tabufline, window stays open
    end
  end
end

function M.open()
  S.sln_path = find_sln()
  if not S.sln_path then
    vim.notify("[SolnExplorer] No .slnx / .sln found in " .. vim.fn.getcwd(), vim.log.levels.WARN)
    return
  end
  -- Hide tabline so explorer fills to top; show tabs as per-window winbar on editor wins
  _saved_stl = vim.o.showtabline
  vim.o.showtabline = 0
  open_win()
  -- Apply winbar to existing editor windows (explorer already has winbar="" from open_win)
  vim.schedule(apply_winbars)
  -- Apply winbar to any new windows opened while explorer is active
  _winbar_auID = vim.api.nvim_create_autocmd("WinNew", {
    callback = function()
      vim.schedule(apply_winbars)
    end,
  })
  setup_keymaps()
  refresh()
  vim.schedule(hide_empty_bufs)
end

function M.toggle()
  if S.win and vim.api.nvim_win_is_valid(S.win) then M.close()
  else M.open() end
end

function M.reveal()
  if not S.win or not vim.api.nvim_win_is_valid(S.win) then M.open() end
  local cur = vim.api.nvim_buf_get_name(
    vim.api.nvim_win_get_buf(vim.api.nvim_get_current_win()))
  for i, n in ipairs(S.nodes) do
    if n.path == cur then
      vim.api.nvim_win_set_cursor(S.win, { i, 0 })
      return
    end
  end
end

-- Standalone new-item: works without the explorer open.
-- Auto-detects the project from the current buffer; falls back to a picker.
function M.new_item()
  local sln = S.sln_path or find_sln()
  if not sln then
    vim.notify("[SolnExplorer] No .sln found in cwd", vim.log.levels.WARN)
    return
  end
  if not S.sln_path then S.sln_path = sln end

  local proj_paths = parse_projects(sln)
  if #proj_paths == 0 then
    vim.notify("[SolnExplorer] No projects found in solution", vim.log.levels.WARN)
    return
  end

  -- Match current buffer to a project
  local cur_file = vim.api.nvim_buf_get_name(0)
  for _, pp in ipairs(proj_paths) do
    local pd = vim.fn.fnamemodify(pp, ":h")
    if cur_file ~= "" and cur_file:sub(1, #pd + 1) == pd .. "/" then
      local target = vim.fn.fnamemodify(cur_file, ":h")
      action_new_item({ path = pp, dir = pd }, target)
      return
    end
  end

  -- No match — let user pick a project first
  vim.ui.select(proj_paths, {
    prompt      = "Select project:",
    format_item = function(pp) return vim.fn.fnamemodify(pp, ":t:r") end,
  }, function(pp)
    if pp then
      action_new_item({ path = pp, dir = vim.fn.fnamemodify(pp, ":h") })
    end
  end)
end

-- Fix the namespace declaration in the current .cs buffer to match its
-- actual location relative to the project root.
function M.fix_namespace()
  local file_path = vim.api.nvim_buf_get_name(0)
  if file_path == "" or not file_path:match("%.cs$") then
    vim.notify("[SolnExplorer] Not a .cs file", vim.log.levels.WARN)
    return
  end
  local sln = S.sln_path or find_sln()
  if not sln then
    vim.notify("[SolnExplorer] No .sln found", vim.log.levels.WARN)
    return
  end
  if not S.sln_path then S.sln_path = sln end
  for _, pp in ipairs(parse_projects(sln)) do
    local pd = vim.fn.fnamemodify(pp, ":h")
    if file_path:sub(1, #pd + 1) == pd .. "/" then
      local ns = compute_namespace(pp, file_path)
      -- Replace in the live buffer (no disk write needed — LSP sees it immediately)
      local buf = vim.api.nvim_get_current_buf()
      local line_count = vim.api.nvim_buf_line_count(buf)
      for i = 0, line_count - 1 do
        local line = vim.api.nvim_buf_get_lines(buf, i, i + 1, false)[1]
        local new_line = line:gsub("^(namespace%s+)([%w%.]+)", "%1" .. ns)
        if new_line ~= line then
          vim.api.nvim_buf_set_lines(buf, i, i + 1, false, { new_line })
          vim.notify("[SolnExplorer] Namespace → " .. ns, vim.log.levels.INFO)
          return
        end
      end
      vim.notify("[SolnExplorer] No namespace declaration found", vim.log.levels.WARN)
      return
    end
  end
  vim.notify("[SolnExplorer] File not in any solution project", vim.log.levels.WARN)
end

-- Expand collapsed ancestors and scroll to target_path in the tree.
local function reveal_path(target_path)
  if not S.sln_path then return end
  if not S.win or not vim.api.nvim_win_is_valid(S.win) then M.open() end

  local proj_paths = parse_projects(S.sln_path)
  local proj_dir   = nil
  for _, pp in ipairs(proj_paths) do
    local pd = vim.fn.fnamemodify(pp, ":h")
    if target_path:sub(1, #pd + 1) == pd .. "/" then
      S.collapsed[S.sln_path] = false
      S.collapsed[pp]         = false
      proj_dir = pd
      break
    end
  end
  if not proj_dir then return end

  -- Uncollapse every ancestor dir between proj_dir and the file
  local dir = vim.fn.fnamemodify(target_path, ":h")
  while #dir > #proj_dir do
    S.collapsed[dir] = false
    local parent = vim.fn.fnamemodify(dir, ":h")
    if parent == dir then break end
    dir = parent
  end

  refresh()

  for i, n in ipairs(S.nodes) do
    if n.path == target_path then
      vim.api.nvim_win_set_cursor(S.win, { i, 0 })
      return
    end
  end
end

-- Collect every non-skipped file across all projects (ignores collapsed state).
local function collect_sln_files()
  if not S.sln_path then return {} end
  local files    = {}
  local proj_paths = parse_projects(S.sln_path)
  for _, pp in ipairs(proj_paths) do
    local proj_dir = vim.fn.fnamemodify(pp, ":h")
    local function scan(d, depth)
      if depth > 8 then return end
      local ok, entries = pcall(vim.fn.readdir, d)
      if not ok then return end
      for _, name in ipairs(entries) do
        local full   = d .. "/" .. name
        local is_dir = vim.fn.isdirectory(full) == 1
        if is_dir then
          if not ALWAYS_SKIP[name] and not BUILD_DIRS[name] then
            scan(full, depth + 1)
          end
        else
          local ext = name:match("%.([^.]+)$") or ""
          if not SKIP_EXTS[ext] then
            table.insert(files, { path = full, rel = full:sub(#proj_dir + 2) })
          end
        end
      end
    end
    scan(proj_dir, 0)
  end
  return files
end

-- Fuzzy-find files in the solution and reveal the chosen one in the tree.
fuzzy_find_in_sln = function()
  if not S.sln_path then
    vim.notify("Solution Explorer: no solution loaded", vim.log.levels.WARN)
    return
  end
  local files = collect_sln_files()
  if #files == 0 then
    vim.notify("Solution Explorer: no files found", vim.log.levels.WARN)
    return
  end

  local ok_tel, pickers    = pcall(require, "telescope.pickers")
  local ok_fin, finders    = pcall(require, "telescope.finders")
  local ok_cfg, conf       = pcall(require, "telescope.config")
  local ok_act, actions    = pcall(require, "telescope.actions")
  local ok_ast, act_state  = pcall(require, "telescope.actions.state")
  if not (ok_tel and ok_fin and ok_cfg and ok_act and ok_ast) then
    vim.notify("Telescope not available", vim.log.levels.WARN)
    return
  end

  pickers.new({}, {
    prompt_title = "Solution Files",
    finder = finders.new_table({
      results     = files,
      entry_maker = function(e)
        return { value = e.path, display = e.rel, ordinal = e.rel }
      end,
    }),
    sorter = conf.values.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local sel = act_state.get_selected_entry()
        if sel then reveal_path(sel.value) end
      end)
      return true
    end,
  }):find()
end

M.stop = stop_running

-- Read /proc/<pid>/cmdline and format as a human-readable string.
local function read_cmdline(pid)
  local f = io.open("/proc/" .. tostring(pid) .. "/cmdline", "r")
  if not f then return nil end
  local s = f:read("*a"); f:close()
  return s:gsub("%z", " "):gsub("%s+$", "")
end

-- Collect every terminal buffer that has an active job.
local function collect_jobs()
  local seen   = {}
  local result = {}

  local function add(buf, job_id, label)
    if seen[job_id] then return end
    seen[job_id] = true
    -- try to get a richer command from /proc
    local ok, pid = pcall(vim.fn.jobpid, job_id)
    local cmd = (ok and pid and read_cmdline(pid)) or label or ("job " .. job_id)
    table.insert(result, { job_id = job_id, buf = buf, cmd = cmd })
  end

  -- 1. Our tracked run job
  if S.job_id then add(S.term_buf, S.job_id, "dotnet run") end

  -- 2. Every loaded terminal buffer
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "terminal" then
      local jid = vim.b[buf].terminal_job_id
      if jid then add(buf, jid, vim.api.nvim_buf_get_name(buf)) end
    end
  end

  return result
end

-- Telescope picker: list running jobs, preview their output, stop on select.
function M.list_jobs()
  local jobs = collect_jobs()
  if #jobs == 0 then
    vim.notify("[SolnExplorer] No running processes", vim.log.levels.INFO)
    return
  end

  local ok_p,  pickers    = pcall(require, "telescope.pickers")
  local ok_f,  finders    = pcall(require, "telescope.finders")
  local ok_c,  conf       = pcall(require, "telescope.config")
  local ok_a,  actions    = pcall(require, "telescope.actions")
  local ok_as, act_state  = pcall(require, "telescope.actions.state")
  local ok_pr, previewers = pcall(require, "telescope.previewers")
  if not (ok_p and ok_f and ok_c and ok_a and ok_as and ok_pr) then
    vim.notify("Telescope not available", vim.log.levels.WARN)
    return
  end

  local previewer = previewers.new_buffer_previewer({
    title = "Output",
    define_preview = function(self, entry)
      local pbuf = self.state.bufnr
      local src  = entry.value.buf
      if src and vim.api.nvim_buf_is_valid(src) then
        -- copy last 200 lines of the terminal buffer into the preview
        local line_count = vim.api.nvim_buf_line_count(src)
        local start      = math.max(0, line_count - 200)
        local lines      = vim.api.nvim_buf_get_lines(src, start, line_count, false)
        vim.api.nvim_buf_set_lines(pbuf, 0, -1, false, lines)
        vim.bo[pbuf].filetype = "log"
        -- scroll preview to bottom
        local pwin = self.state.winid
        if pwin and vim.api.nvim_win_is_valid(pwin) then
          pcall(vim.api.nvim_win_set_cursor, pwin, { #lines, 0 })
        end
      else
        vim.api.nvim_buf_set_lines(pbuf, 0, -1, false, { "(no output buffer)" })
      end
    end,
  })

  pickers.new({}, {
    prompt_title = "Running Processes  (Enter = stop)",
    finder = finders.new_table({
      results     = jobs,
      entry_maker = function(j)
        return { value = j, display = j.cmd, ordinal = j.cmd }
      end,
    }),
    sorter  = conf.values.generic_sorter({}),
    previewer = previewer,
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local sel = act_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if not sel then return end
        local j = sel.value
        pcall(vim.fn.jobstop, j.job_id)
        if j.job_id == S.job_id then
          S.job_id  = nil
          S.term_buf = nil
        end
        vim.notify("[SolnExplorer] Stopped: " .. j.cmd, vim.log.levels.INFO)
      end)
      return true
    end,
  }):find()
end

-- Allow test_runner.lua to share its log buffer with gx
function M._set_term_buf(buf)
  S.term_buf = buf
end

return M
