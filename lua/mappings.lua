require "nvchad.mappings"

local map = vim.keymap.set

-- All which-key registrations live in lua/plugins/init.lua (spec field).
-- mappings.lua is keymaps only.

-- ── Command palette ─────────────────────────────────────────────────────────
map("n", "<C-S-p>", "<cmd>Dotnet<cr>", { desc = "Dotnet command palette" })

-- ── General ─────────────────────────────────────────────────────────────────
map("i", "jk",       "<ESC>",      { desc = "Escape insert mode" })
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
map({ "n", "v" }, ";", ":", { desc = "Command mode" })

-- Move selected lines in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep cursor centred while scrolling / searching
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n",     "nzzzv")
map("n", "N",     "Nzzzv")

-- ── Quickfix ────────────────────────────────────────────────────────────────
map("n", "<leader>xo", "<cmd>copen<cr>",  { desc = "Quickfix open" })
map("n", "<leader>xc", "<cmd>cclose<cr>", { desc = "Quickfix close" })
map("n", "]q",         "<cmd>cnext<cr>",  { desc = "Quickfix next" })
map("n", "[q",         "<cmd>cprev<cr>",  { desc = "Quickfix prev" })

-- ── Oil (file manager) ───────────────────────────────────────────────────────
-- <leader>- is also mapped inside oil buffers (see configs/oil.lua)
map("n", "-", "<cmd>Oil<cr>", { desc = "Oil  open parent dir" })

-- ── Zoxide ──────────────────────────────────────────────────────────────────
map("n", "<leader>fz", "<cmd>Telescope zoxide list<cr>", { desc = "Zoxide frecent dirs" })

-- ── LSP ─────────────────────────────────────────────────────────────────────
-- Core keymaps are registered per-buffer in LspAttach (configs/lspconfig.lua):
--   gd        → definition          gr  → references
--   gD        → declaration         gi  → implementation
--   gy        → type definition     K   → hover docs
--   <leader>cr → rename             <leader>ca → code action
--   <leader>cf → format buffer      <leader>cs → signature help
--   [d / ]d   → prev/next diag      <leader>cd → show diagnostic float

-- ── DAP — F-key one-press shortcuts (IDE-style) ─────────────────────────────
map("n", "<F5>",   function() require("dap").continue() end,          { desc = "DAP: Continue / Start" })
map("n", "<S-F5>", function() require("dap").terminate() end,         { desc = "DAP: Stop / Terminate" })
map("n", "<F9>",   function() require("dap").toggle_breakpoint() end, { desc = "DAP: Toggle breakpoint" })
map("n", "<F10>",  function() require("dap").step_over() end,         { desc = "DAP: Step over" })
map("n", "<F11>",  function() require("dap").step_into() end,         { desc = "DAP: Step into" })
map("n", "<S-F11>",function() require("dap").step_out() end,          { desc = "DAP: Step out" })

-- ── DAP — <leader>d for UI / extras ─────────────────────────────────────────
map("n", "<leader>dc", function() require("dap").continue() end,      { desc = "Continue / Start" })
map("n", "<leader>dl", function() require("dap").run_last() end,      { desc = "Run last config" })
map("n", "<leader>dr", function() require("dap").repl.open() end,     { desc = "Open REPL" })
map("n", "<leader>du", function() require("dapui").toggle() end,      { desc = "Toggle DAP UI" })
map("n", "<leader>dx", function() require("dap").terminate() end,     { desc = "Terminate session" })
map({ "n", "v" }, "<leader>dw", function() require("dapui").eval(nil, { enter = true }) end,
  { desc = "Watch expression" })
map({ "n", "v" }, "<leader>dp", function() require("dapui").eval() end,
  { desc = "Peek value under cursor" })

-- ── DAP — Breakpoints <leader>db ────────────────────────────────────────────
map("n", "<leader>dbt", function() require("dap").toggle_breakpoint() end,
  { desc = "Toggle breakpoint" })
map("n", "<leader>dbB", function()
  require("dap").set_breakpoint(vim.fn.input "Condition: ")
end, { desc = "Conditional breakpoint" })
map("n", "<leader>dbb", function()
  require("telescope").extensions.dap.list_breakpoints()
end, { desc = "List all (Telescope)" })
map("n", "<leader>dbq", function()
  require("dap").list_breakpoints() vim.cmd "copen"
end, { desc = "List all → quickfix" })
map("n", "<leader>dbc", function() require("dap").clear_breakpoints() end,
  { desc = "Clear all breakpoints" })

-- ── .NET — Build ────────────────────────────────────────────────────────────
map("n", "<leader>nb",  function() require("easy-dotnet").build() end,
  { desc = "Build project" })
map("n", "<leader>nB",  function() require("easy-dotnet").build_solution() end,
  { desc = "Build solution" })
map("n", "<leader>nqb", function() require("easy-dotnet").build_quickfix() end,
  { desc = "Build → quickfix list" })

-- ── .NET — Run ──────────────────────────────────────────────────────────────
map("n", "<leader>nr",  function() require("easy-dotnet").run() end,
  { desc = "Run project" })
map("n", "<leader>nrp", function() require("easy-dotnet").run_profile() end,
  { desc = "Run with launch profile" })
map("n", "<leader>nw",  function() require("easy-dotnet").watch() end,
  { desc = "Watch (hot-reload)" })

-- ── .NET — Test ─────────────────────────────────────────────────────────────
map("n", "<leader>nt",  function() require("easy-dotnet").test() end,
  { desc = "Test project" })
map("n", "<leader>nts", function() require("easy-dotnet").test_solution() end,
  { desc = "Test solution" })
map("n", "<leader>nT",  function() require("easy-dotnet").testrunner() end,
  { desc = "Test runner UI" })

-- ── .NET — Maintenance ──────────────────────────────────────────────────────
map("n", "<leader>nR",  function() require("easy-dotnet").restore() end,
  { desc = "Restore packages" })
map("n", "<leader>nc",  function() require("easy-dotnet").clean() end,
  { desc = "Clean" })
map("n", "<leader>nD",  "<cmd>Dotnet diagnostic<cr>",
  { desc = "Workspace diagnostics" })
map("n", "<leader>nS",  function() require("easy-dotnet").secrets() end,
  { desc = "User secrets" })

-- ── .NET — Packages (NuGet) ─────────────────────────────────────────────────
map("n", "<leader>npa", function() require("easy-dotnet").add_package() end,
  { desc = "Add NuGet package" })
map("n", "<leader>npr", function() require("easy-dotnet").remove_package() end,
  { desc = "Remove NuGet package" })
map("n", "<leader>npo", function() require("easy-dotnet").outdated() end,
  { desc = "Outdated packages" })
map("n", "<leader>npv", function() require("easy-dotnet").project_view() end,
  { desc = "Project dependencies" })

-- ── Trouble ──────────────────────────────────────────────────────────────────
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",            { desc = "Workspace diagnostics" })
map("n", "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer diagnostics" })
map("n", "<leader>xs", "<cmd>Trouble symbols toggle<cr>",                { desc = "Symbols" })
map("n", "<leader>xl", "<cmd>Trouble lsp toggle<cr>",                    { desc = "LSP references/defs" })
map("n", "<leader>xq", "<cmd>Trouble qflist toggle<cr>",                 { desc = "Quickfix (Trouble)" })

-- ── Spectre: find & replace ───────────────────────────────────────────────────
map("n", "<leader>sr",  function() require("spectre").toggle() end,              { desc = "Spectre toggle" })
map("n", "<leader>sw",  function() require("spectre").open_visual({ select_word = true }) end, { desc = "Search current word" })
map("v", "<leader>sw",  function() require("spectre").open_visual() end,         { desc = "Search selection" })
map("n", "<leader>sf",  function() require("spectre").open_file_search({ select_word = true }) end, { desc = "Search in file" })

-- ── Git: Fugitive ────────────────────────────────────────────────────────────
map("n", "<leader>gs",  "<cmd>Git<cr>",               { desc = "Git status" })
map("n", "<leader>gc",  "<cmd>Git commit<cr>",        { desc = "Git commit" })
map("n", "<leader>gP",  "<cmd>Git push<cr>",          { desc = "Git push" })
map("n", "<leader>gl",  "<cmd>Git log --oneline<cr>", { desc = "Git log" })
map("n", "<leader>gb",  "<cmd>Git blame<cr>",         { desc = "Git blame" })

-- ── Git: Diffview ────────────────────────────────────────────────────────────
map("n", "<leader>gd",  "<cmd>DiffviewOpen<cr>",             { desc = "Diff view" })
map("n", "<leader>gD",  "<cmd>DiffviewClose<cr>",            { desc = "Diff view close" })
map("n", "<leader>gh",  "<cmd>DiffviewFileHistory %<cr>",    { desc = "File history" })
map("n", "<leader>gH",  "<cmd>DiffviewFileHistory<cr>",      { desc = "Repo history" })
