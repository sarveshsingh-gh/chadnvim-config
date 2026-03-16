require "nvchad.mappings"

local map = vim.keymap.set

-- All which-key registrations live in lua/plugins/init.lua (spec field).
-- mappings.lua is keymaps only.
-- desc format: "Group detail" — first word = cheatsheet group header.

-- ── Command palette ─────────────────────────────────────────────────────────
map("n", "<M-S-p>", "<cmd>Dotnet<cr>", { desc = "Dotnet command palette" })

-- ── General ─────────────────────────────────────────────────────────────────
map("i", "jk",        "<ESC>",      { desc = "Escape insert mode" })
map("n", "<leader><leader>", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
map("n", "<leader>w", "<cmd>w<cr>", { desc = "File save" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "File quit" })
map({ "n", "v" }, ";", ":",         { desc = "Editor command mode" })

-- Remove NvChad's <leader>n (toggle line number) — conflicts with Dotnet prefix
pcall(vim.keymap.del, "n", "<leader>n")
pcall(vim.keymap.del, "n", "<leader>rn")
-- Move line number toggles to <leader>un / <leader>ur
map("n", "<leader>un", "<cmd>set nu!<cr>",  { desc = "Toggle line numbers" })
map("n", "<leader>ur", "<cmd>set rnu!<cr>", { desc = "Toggle relative numbers" })

-- Searchable keymap list (fuzzy search all keymaps + descriptions)
map("n", "<leader>fk", "<cmd>Telescope keymaps<cr>", { desc = "Find keymaps" })

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
map("n", "-", "<cmd>Oil<cr>", { desc = "File open parent" })

-- ── Zoxide ──────────────────────────────────────────────────────────────────
map("n", "<leader>fz", "<cmd>Telescope zoxide list<cr>", { desc = "Find zoxide dirs" })

-- ── LSP — Standard bindings (Neovim 0.11+ gr* style) ───────────────────────
map("n",          "grn", vim.lsp.buf.rename,        { desc = "Lsp rename" })
map({ "n", "v" }, "gra", vim.lsp.buf.code_action,   { desc = "Lsp code actions" })
map({ "n", "v" }, "grA", function()
  vim.lsp.buf.code_action { context = { only = { "source" }, diagnostics = {} } }
end,                                                 { desc = "Lsp source actions" })
map("n", "grd", vim.lsp.buf.definition,              { desc = "Lsp definition" })
map("n", "grr", function() require("telescope.builtin").lsp_references() end,
                                                     { desc = "Lsp references" })
map("n", "gri", vim.lsp.buf.implementation,          { desc = "Lsp implementation" })
map("n", "grt", vim.lsp.buf.type_definition,         { desc = "Lsp type definition" })
map("n", "K",   vim.lsp.buf.hover,                   { desc = "Lsp hover" })
map("i", "<C-k>", vim.lsp.buf.signature_help,        { desc = "Lsp signature help" })
map("n", "gO",  function() require("telescope.builtin").lsp_document_symbols() end,
                                                     { desc = "Lsp document symbols" })
map("n", "grq", function() vim.diagnostic.setqflist() end,
                                                     { desc = "Lsp diagnostic quickfix" })

-- ── LSP — <leader>l (cheat-sheet: gr* shortcuts) ────────────────────────────
map("n",          "<leader>ld", vim.lsp.buf.definition,     { desc = "Lsp definition       [grd]" })
map("n",          "<leader>lr", function() require("telescope.builtin").lsp_references() end,
                                                            { desc = "Lsp references       [grr]" })
map("n",          "<leader>li", vim.lsp.buf.implementation, { desc = "Lsp implementation   [gri]" })
map({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action,    { desc = "Lsp code actions     [gra]" })
map("n",          "<leader>lA", function()
  vim.lsp.buf.code_action { context = { only = { "source" }, diagnostics = {} } }
end,                                                        { desc = "Lsp source actions   [grA]" })
map("n",          "<leader>ln", vim.lsp.buf.rename,         { desc = "Lsp rename           [grn]" })
map("n",          "<leader>lh", vim.lsp.buf.hover,          { desc = "Lsp hover            [K]" })
map("n",          "<leader>ls", vim.lsp.buf.signature_help, { desc = "Lsp signature help   [C-k]" })
map("n",          "<leader>lt", vim.lsp.buf.type_definition,{ desc = "Lsp type definition  [grt]" })
map("n",          "<leader>lo", function() require("telescope.builtin").lsp_document_symbols() end,
                                                            { desc = "Lsp document symbols [gO]" })

-- ── LSP — Format / extras ───────────────────────────────────────────────────
map({ "n", "v" }, "<leader>cf", function()
  require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Lsp format" })
map("n", "<leader>ci", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = 0 })
end, { desc = "Lsp inlay hints" })

-- ── LSP — Symbols ───────────────────────────────────────────────────────────
map("n", "<leader>fs", function() require("telescope.builtin").lsp_document_symbols() end,
  { desc = "Find document symbols" })
map("n", "<leader>fS", function() require("telescope.builtin").lsp_workspace_symbols() end,
  { desc = "Find workspace symbols" })

-- ── Diagnostic — Navigate ───────────────────────────────────────────────────
map("n", "<F8>",   function() vim.diagnostic.goto_next() end,                                          { desc = "Diagnostic next" })
map("n", "<S-F8>", function() vim.diagnostic.goto_prev() end,                                          { desc = "Diagnostic prev" })
map("n", "]d",     function() vim.diagnostic.goto_next() end,                                          { desc = "Diagnostic next" })
map("n", "[d",     function() vim.diagnostic.goto_prev() end,                                          { desc = "Diagnostic prev" })
map("n", "]e",     function() vim.diagnostic.goto_next { severity = vim.diagnostic.severity.ERROR } end, { desc = "Diagnostic next error" })
map("n", "[e",     function() vim.diagnostic.goto_prev { severity = vim.diagnostic.severity.ERROR } end, { desc = "Diagnostic prev error" })

-- ── Diagnostic — Lists ──────────────────────────────────────────────────────
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Diagnostic float" })
map("n", "<leader>cD", function() require("telescope.builtin").diagnostics { bufnr = 0 } end,
  { desc = "Diagnostic buffer all" })
map("n", "<leader>cE", function()
  require("telescope.builtin").diagnostics { bufnr = 0, severity = vim.diagnostic.severity.ERROR }
end, { desc = "Diagnostic buffer errors" })
map("n", "<leader>cW", function()
  require("telescope.builtin").diagnostics { bufnr = 0, severity = vim.diagnostic.severity.WARN }
end, { desc = "Diagnostic buffer warnings" })
map("n", "<leader>cx", function() require("telescope.builtin").diagnostics() end,
  { desc = "Diagnostic workspace all" })

-- ── Debug — F-key shortcuts (Visual Studio style) ────────────────────────────
map("n", "<F5>",    function() require("dap").continue() end,         { desc = "Debug continue" })
map("n", "<S-F5>",  function() require("dap").terminate() end,        { desc = "Debug stop" })
map("n", "<F9>",    function() require("dap").toggle_breakpoint() end, { desc = "Debug breakpoint toggle" })
map("n", "<F10>",   function() require("dap").step_over() end,         { desc = "Debug step over" })
map("n", "<F11>",   function() require("dap").step_into() end,         { desc = "Debug step into" })
map("n", "<S-F11>", function() require("dap").step_out() end,          { desc = "Debug step out" })
-- VS: Shift+F9 = QuickWatch, Alt+I = Immediate window, Ctrl+Alt+W = Watch
map({ "n", "v" }, "<S-F9>", function() require("dapui").eval() end,
  { desc = "Debug QuickWatch (peek value)  [VS: S-F9]" })
map({ "n", "v" }, "<M-i>",  function() require("dapui").eval(nil, { enter = true }) end,
  { desc = "Debug add to Watch  [VS: C-A-W]" })

-- ── Debug — <leader>d ────────────────────────────────────────────────────────
map("n", "<leader>dc", function() require("dap").continue() end,      { desc = "Debug continue          [F5]" })
map("n", "<leader>dx", function() require("dap").terminate() end,     { desc = "Debug stop              [S-F5]" })
map("n", "<leader>dl", function() require("dap").run_last() end,      { desc = "Debug run last" })
map("n", "<leader>di", function() require("dap").repl.open() end,     { desc = "Debug Immediate window  [VS: C-A-I]" })
map("n", "<leader>du", function() require("dapui").toggle() end,      { desc = "Debug ui toggle" })
map({ "n", "v" }, "<leader>dw", function() require("dapui").eval(nil, { enter = true }) end,
  { desc = "Debug add to Watch  [M-i]" })
map({ "n", "v" }, "<leader>dq", function() require("dapui").eval() end,
  { desc = "Debug QuickWatch    [S-F9]" })

-- ── Debug — Breakpoints <leader>db ──────────────────────────────────────────
map("n", "<leader>dbt", function() require("dap").toggle_breakpoint() end,
  { desc = "Debug breakpoint toggle    [F9]" })
map("n", "<leader>dbB", function()
  require("dap").set_breakpoint(vim.fn.input "Condition: ")
end, { desc = "Debug breakpoint conditional" })
map("n", "<leader>dbb", function()
  require("telescope").extensions.dap.list_breakpoints()
end, { desc = "Debug breakpoints list" })
map("n", "<leader>dbq", function()
  require("dap").list_breakpoints() vim.cmd "copen"
end, { desc = "Debug breakpoints quickfix" })
map("n", "<leader>dbc", function() require("dap").clear_breakpoints() end,
  { desc = "Debug breakpoints clear" })

-- ── .NET Test — buffer-level (active in *.cs files only) ────────────────────
local function _setup_cs_test_maps(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  if vim.bo[bufnr].filetype ~= "cs" then return end
  local o = { buffer = bufnr, nowait = true }
  vim.keymap.set("n", "t", function()
    require("utils.test_runner").run_at_cursor()
  end, vim.tbl_extend("force", o, { desc = "Test run at cursor" }))
  vim.keymap.set("n", "dt", function()
    require("utils.test_runner").debug_at_cursor()
  end, vim.tbl_extend("force", o, { desc = "Test debug at cursor" }))
  vim.keymap.set("n", "gx", function()
    require("utils.test_runner").open_log()
  end, vim.tbl_extend("force", o, { desc = "Test open log" }))
end

-- BufEnter fires for already-open buffers too (unlike FileType).
-- vim.schedule defers until after all other plugins (e.g. easy-dotnet) have
-- set their own keymaps for the same event, so ours wins.
vim.api.nvim_create_autocmd("BufEnter", {
  pattern  = "*.cs",
  callback = function(ev)
    vim.schedule(function() _setup_cs_test_maps(ev.buf) end)
  end,
})
-- Apply immediately to any cs buffer already open right now
for _, buf in ipairs(vim.api.nvim_list_bufs()) do
  vim.schedule(function() _setup_cs_test_maps(buf) end)
end

-- ── Solution Explorer ───────────────────────────────────────────────────────
map("n", "<leader>ne", function() require("utils.sln_explorer").toggle() end,
  { desc = "Dotnet solution explorer toggle" })
map("n", "<leader>nE", function() require("utils.sln_explorer").reveal() end,
  { desc = "Dotnet solution explorer reveal file" })

-- ── Dotnet — Build ──────────────────────────────────────────────────────────
map("n", "<leader>nb",  function() require("easy-dotnet").build() end,
  { desc = "Dotnet build project" })
map("n", "<leader>nB",  function() require("easy-dotnet").build_solution() end,
  { desc = "Dotnet build solution" })
map("n", "<leader>nRb", function()
  require("easy-dotnet").clean()
  vim.defer_fn(function() require("easy-dotnet").build_solution() end, 2000)
end, { desc = "Dotnet rebuild solution (clean+build)" })
map("n", "<leader>nQ", function() require("easy-dotnet").build_quickfix() end,
  { desc = "Dotnet build quickfix" })

-- ── Dotnet — Run ────────────────────────────────────────────────────────────
map("n", "<leader>nr",  function() require("easy-dotnet").run() end,
  { desc = "Dotnet run project" })
map("n", "<leader>nrp", function() require("easy-dotnet").run_profile() end,
  { desc = "Dotnet run profile" })
map("n", "<leader>nw",  function() require("easy-dotnet").watch() end,
  { desc = "Dotnet watch hot-reload" })

-- ── Dotnet — Test ───────────────────────────────────────────────────────────
map("n", "<leader>nt",  function() require("easy-dotnet").test() end,
  { desc = "Dotnet test project" })
map("n", "<leader>nts", function() require("easy-dotnet").test_solution() end,
  { desc = "Dotnet test solution" })
map("n", "<leader>nT",  function() require("easy-dotnet").testrunner() end,
  { desc = "Dotnet test runner" })

-- ── Dotnet — Maintenance ────────────────────────────────────────────────────
map("n", "<leader>nR",  function() require("easy-dotnet").restore() end,
  { desc = "Dotnet restore packages" })
map("n", "<leader>nc",  function() require("easy-dotnet").clean() end,
  { desc = "Dotnet clean project" })
map("n", "<leader>nD",  "<cmd>Dotnet diagnostic<cr>",
  { desc = "Dotnet diagnostics workspace" })
map("n", "<leader>nS",  function() require("easy-dotnet").secrets() end,
  { desc = "Dotnet secrets user" })

-- ── Dotnet — Packages (NuGet) ───────────────────────────────────────────────
map("n", "<leader>npa", function() require("easy-dotnet").add_package() end,
  { desc = "Dotnet package add" })
map("n", "<leader>npr", function() require("easy-dotnet").remove_package() end,
  { desc = "Dotnet package remove" })
map("n", "<leader>npo", function() require("easy-dotnet").outdated() end,
  { desc = "Dotnet package outdated" })
map("n", "<leader>npv", function() require("easy-dotnet").project_view() end,
  { desc = "Dotnet package view" })


-- ── Search / Replace (Spectre) ───────────────────────────────────────────────
map("n", "<leader>sr", function() require("spectre").toggle() end,                          { desc = "Search toggle spectre" })
map("n", "<leader>sw", function() require("spectre").open_visual({ select_word = true }) end, { desc = "Search current word" })
map("v", "<leader>sw", function() require("spectre").open_visual() end,                     { desc = "Search selection" })
map("n", "<leader>sf", function() require("spectre").open_file_search({ select_word = true }) end, { desc = "Search in file" })

-- ── Git: Fugitive ────────────────────────────────────────────────────────────
map("n", "<leader>gs", "<cmd>Git<cr>",               { desc = "Git status" })
map("n", "<leader>gc", "<cmd>Git commit<cr>",        { desc = "Git commit" })
map("n", "<leader>gP", "<cmd>Git push<cr>",          { desc = "Git push" })
map("n", "<leader>gl", "<cmd>Git log --oneline<cr>", { desc = "Git log" })
map("n", "<leader>gb", "<cmd>Git blame<cr>",         { desc = "Git blame" })

-- ── Git: Diffview ────────────────────────────────────────────────────────────
map("n", "<leader>gd", "<cmd>DiffviewOpen<cr>",          { desc = "Git diff view" })
map("n", "<leader>gD", "<cmd>DiffviewClose<cr>",         { desc = "Git diff close" })
map("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "Git file history" })
map("n", "<leader>gH", "<cmd>DiffviewFileHistory<cr>",   { desc = "Git repo history" })
