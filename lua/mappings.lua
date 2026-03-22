require "nvchad.mappings"

local map = vim.keymap.set

-- ── Buffer navigation ────────────────────────────────────────────────────────
local function safe_tab(dir)
  local bufs = vim.tbl_filter(function(b)
    return vim.bo[b].buflisted
  end, vim.api.nvim_list_bufs())
  if #bufs < 2 then return end
  if dir == "next" then vim.cmd "bnext"
  else vim.cmd "bprev" end
end
map("n", "<tab>",   function() safe_tab("next") end, { desc = "Buffer next" })
map("n", "<S-tab>", function() safe_tab("prev") end, { desc = "Buffer prev" })

-- ── General ──────────────────────────────────────────────────────────────────
map("n", "<leader><leader>", "<cmd>D<cr>",  { desc = "Dotnet palette" })
map("n", "<M-S-p>",          "<cmd>Dotnet<cr>", { desc = "Dotnet command palette" })
map("n", "<leader>w", "<cmd>w<cr>",         { desc = "File save" })
map("n", "<leader>q", "<cmd>q<cr>",         { desc = "File quit" })

-- ── Comment toggle (VS Code style) ───────────────────────────────────────────
map({ "n", "v" }, "<C-/>", "gcc", { desc = "Comment toggle", remap = true })

-- ── Keep visual selection when indenting ─────────────────────────────────────
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- ── Move selected lines ───────────────────────────────────────────────────────
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- ── Keep cursor centred ───────────────────────────────────────────────────────
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n",     "nzzzv")
map("n", "N",     "Nzzzv")

-- ── Remove redundant terminal splits (keep only <A-i> floating) ──────────────
pcall(vim.keymap.del, "n", "<A-h>")
pcall(vim.keymap.del, "n", "<A-v>")
pcall(vim.keymap.del, "t", "<A-h>")
pcall(vim.keymap.del, "t", "<A-v>")

-- ── Line number toggles (free up <leader>n for dotnet) ───────────────────────
pcall(vim.keymap.del, "n", "<leader>n")
pcall(vim.keymap.del, "n", "<leader>rn")
map("n", "<leader>un", "<cmd>set nu!<cr>",  { desc = "Toggle line numbers" })
map("n", "<leader>ur", "<cmd>set rnu!<cr>", { desc = "Toggle relative numbers" })

-- ── Quickfix ─────────────────────────────────────────────────────────────────
map("n", "<leader>xo", "<cmd>copen<cr>",  { desc = "Quickfix open" })
map("n", "<leader>xc", "<cmd>cclose<cr>", { desc = "Quickfix close" })
map("n", "]q",         "<cmd>cnext<cr>",  { desc = "Quickfix next" })
map("n", "[q",         "<cmd>cprev<cr>",  { desc = "Quickfix prev" })

-- ── Find ─────────────────────────────────────────────────────────────────────
map("n", "<leader>fk", "<cmd>Telescope keymaps<cr>",    { desc = "Find keymaps" })
map("n", "<leader>fz", "<cmd>Z<cr>",                   { desc = "Zoxide dirs" })
map("n", "<leader>f/", function() require("telescope.builtin").current_buffer_fuzzy_find() end, { desc = "Fuzzy find in buffer" })
map("n", "<leader>fs", function() require("telescope.builtin").lsp_document_symbols() end,  { desc = "Find document symbols" })
map("n", "<leader>fS", function() require("telescope.builtin").lsp_workspace_symbols() end, { desc = "Find workspace symbols" })

-- ── LSP — gr* (Neovim 0.11+ style) ──────────────────────────────────────────
map("n",          "grn", vim.lsp.buf.rename,      { desc = "Lsp rename" })
map({ "n", "v" }, "gra", vim.lsp.buf.code_action, { desc = "Lsp code actions" })
map({ "n", "v" }, "grA", function()
  vim.lsp.buf.code_action { context = { only = { "source" }, diagnostics = {} } }
end, { desc = "Lsp source actions" })
map("n", "grd", vim.lsp.buf.definition,   { desc = "Lsp definition" })
map("n", "grr", function() require("telescope.builtin").lsp_references() end, { desc = "Lsp references" })
map("n", "gri", vim.lsp.buf.implementation,  { desc = "Lsp implementation" })
map("n", "grt", vim.lsp.buf.type_definition, { desc = "Lsp type definition" })
map("n", "K",   vim.lsp.buf.hover,           { desc = "Lsp hover" })
map("i", "<C-k>", vim.lsp.buf.signature_help, { desc = "Lsp signature help" })
map("n", "gO",  function() require("telescope.builtin").lsp_document_symbols() end, { desc = "Lsp document symbols" })
map("n", "grq", function() vim.diagnostic.setqflist() end, { desc = "Lsp diagnostic quickfix" })

-- ── LSP — <leader>l ──────────────────────────────────────────────────────────
map("n",          "<leader>ld", vim.lsp.buf.definition,   { desc = "Lsp definition       [grd]" })
map("n",          "<leader>lr", function() require("telescope.builtin").lsp_references() end, { desc = "Lsp references       [grr]" })
map("n",          "<leader>li", vim.lsp.buf.implementation,  { desc = "Lsp implementation   [gri]" })
map({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action,     { desc = "Lsp code actions     [gra]" })
map("n",          "<leader>lA", function()
  vim.lsp.buf.code_action { context = { only = { "source" }, diagnostics = {} } }
end, { desc = "Lsp source actions   [grA]" })
map("n", "<leader>ln", vim.lsp.buf.rename,         { desc = "Lsp rename           [grn]" })
map("n", "<leader>lh", vim.lsp.buf.hover,          { desc = "Lsp hover            [K]" })
map("n", "<leader>ls", vim.lsp.buf.signature_help, { desc = "Lsp signature help   [C-k]" })
map("n", "<leader>lt", vim.lsp.buf.type_definition,{ desc = "Lsp type definition  [grt]" })
map("n", "<leader>lo", function() require("telescope.builtin").lsp_document_symbols() end, { desc = "Lsp document symbols [gO]" })

-- ── LSP — Format / inlay hints ───────────────────────────────────────────────
map({ "n", "v" }, "<leader>cf", function()
  require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Lsp format" })
map("n", "<leader>ci", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = 0 })
end, { desc = "Lsp inlay hints toggle" })

-- ── Diagnostic ───────────────────────────────────────────────────────────────
map("n", "<F8>",   function() vim.diagnostic.goto_next() end, { desc = "Diagnostic next" })
map("n", "<S-F8>", function() vim.diagnostic.goto_prev() end, { desc = "Diagnostic prev" })
map("n", "]d",     function() vim.diagnostic.goto_next() end, { desc = "Diagnostic next" })
map("n", "[d",     function() vim.diagnostic.goto_prev() end, { desc = "Diagnostic prev" })
map("n", "]e",     function() vim.diagnostic.goto_next { severity = vim.diagnostic.severity.ERROR } end, { desc = "Diagnostic next error" })
map("n", "[e",     function() vim.diagnostic.goto_prev { severity = vim.diagnostic.severity.ERROR } end, { desc = "Diagnostic prev error" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Diagnostic float" })
map("n", "<leader>cD", function() require("telescope.builtin").diagnostics { bufnr = 0 } end, { desc = "Diagnostic buffer all" })
map("n", "<leader>cE", function()
  require("telescope.builtin").diagnostics { bufnr = 0, severity = vim.diagnostic.severity.ERROR }
end, { desc = "Diagnostic buffer errors" })
map("n", "<leader>cW", function()
  require("telescope.builtin").diagnostics { bufnr = 0, severity = vim.diagnostic.severity.WARN }
end, { desc = "Diagnostic buffer warnings" })
map("n", "<leader>cx", function() require("telescope.builtin").diagnostics() end, { desc = "Diagnostic workspace all" })

-- ── Debug — F-keys (Visual Studio style) ─────────────────────────────────────
map("n", "<F5>",    function() require("dap").continue() end,          { desc = "Debug continue" })
map("n", "<S-F5>",  function() require("dap").terminate() end,         { desc = "Debug stop" })
map("n", "<F9>",    function() require("dap").toggle_breakpoint() end,  { desc = "Debug breakpoint toggle" })
map("n", "<F10>",   function() require("dap").step_over() end,          { desc = "Debug step over" })
map("n", "<F11>",   function() require("dap").step_into() end,          { desc = "Debug step into" })
map("n", "<S-F11>", function() require("dap").step_out() end,           { desc = "Debug step out" })
map({ "n", "v" }, "<S-F9>", function() require("dapui").eval() end,          { desc = "Debug QuickWatch" })
map({ "n", "v" }, "<M-i>",  function() require("dapui").eval(nil, { enter = true }) end, { desc = "Debug add to Watch" })

-- ── Debug — <leader>d ────────────────────────────────────────────────────────
map("n", "<leader>dc", function() require("dap").continue() end,   { desc = "Debug continue       [F5]" })
map("n", "<leader>dx", function() require("dap").terminate() end,  { desc = "Debug stop           [S-F5]" })
map("n", "<leader>dl", function() require("dap").run_last() end,   { desc = "Debug run last" })
map("n", "<leader>di", function() require("dap").repl.open() end,  { desc = "Debug REPL / Immediate" })
map("n", "<leader>du", function() require("dapui").toggle() end,   { desc = "Debug UI toggle" })
map({ "n", "v" }, "<leader>dw", function() require("dapui").eval(nil, { enter = true }) end, { desc = "Debug add to Watch  [M-i]" })
map({ "n", "v" }, "<leader>dq", function() require("dapui").eval() end, { desc = "Debug QuickWatch  [S-F9]" })
map("n", "<leader>dbt", function() require("dap").toggle_breakpoint() end, { desc = "Debug breakpoint toggle    [F9]" })
map("n", "<leader>dbB", function()
  require("dap").set_breakpoint(vim.fn.input "Condition: ")
end, { desc = "Debug breakpoint conditional" })
map("n", "<leader>dbb", function() require("telescope").extensions.dap.list_breakpoints() end, { desc = "Debug breakpoints list" })
map("n", "<leader>dbq", function() require("dap").list_breakpoints(); vim.cmd "copen" end,     { desc = "Debug breakpoints quickfix" })
map("n", "<leader>dbc", function() require("dap").clear_breakpoints() end, { desc = "Debug breakpoints clear" })

-- ── Harpoon 7-9 (1-6 are in plugin spec keys) ────────────────────────────────
map("n", "<leader>7", function() require("harpoon"):list():select(7) end, { desc = "Harpoon file 7" })
map("n", "<leader>8", function() require("harpoon"):list():select(8) end, { desc = "Harpoon file 8" })
map("n", "<leader>9", function() require("harpoon"):list():select(9) end, { desc = "Harpoon file 9" })

-- ── Copilot Chat ─────────────────────────────────────────────────────────────
map("n", "<leader>cc", "<cmd>CopilotChatToggle<cr>",  { desc = "Copilot chat toggle" })
map("n", "<leader>ce", "<cmd>CopilotChatExplain<cr>", { desc = "Copilot explain" })
map("n", "<leader>ct", "<cmd>CopilotChatTests<cr>",   { desc = "Copilot generate tests" })
map("n", "<leader>cr", "<cmd>CopilotChatReview<cr>",  { desc = "Copilot review" })
map("v", "<leader>cc", "<cmd>CopilotChatToggle<cr>",  { desc = "Copilot chat selection" })
map("v", "<leader>ce", "<cmd>CopilotChatExplain<cr>", { desc = "Copilot explain selection" })

-- ── Terminal toggle ───────────────────────────────────────────────────────────
map("n", "<M-t>", function()
  local term_wins = vim.tbl_filter(function(w)
    return vim.bo[vim.api.nvim_win_get_buf(w)].buftype == "terminal"
  end, vim.api.nvim_tabpage_list_wins(0))
  if #term_wins > 0 then
    for _, w in ipairs(term_wins) do pcall(vim.api.nvim_win_hide, w) end
  else
    local term_bufs = vim.tbl_filter(function(b)
      return vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buftype == "terminal"
    end, vim.api.nvim_list_bufs())
    if #term_bufs > 0 then
      table.sort(term_bufs, function(a, b)
        return vim.fn.getbufinfo(a)[1].lastused > vim.fn.getbufinfo(b)[1].lastused
      end)
      vim.cmd "bo sp"
      vim.api.nvim_win_set_buf(0, term_bufs[1])
      vim.api.nvim_win_set_height(0, math.floor(vim.o.lines * 0.35))
    end
  end
end, { desc = "Terminal toggle" })

-- ── Misc ─────────────────────────────────────────────────────────────────────
map("n", "<leader>uT", "<cmd>TSBufToggle highlight<cr>", { desc = "Toggle treesitter highlight" })
