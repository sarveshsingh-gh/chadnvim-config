-- User plugins loaded on top of NvChad's built-in plugin set.
-- NvChad already provides: mason, nvim-lspconfig, nvim-cmp, luasnip,
-- telescope, nvim-treesitter, gitsigns, which-key, autopairs, nvim-web-devicons.
-- We only add what NvChad does NOT include.

return {
  -- ── which-key: trigger on g / [ / ] in addition to <leader> ─────────────
  {
    "folke/which-key.nvim",
    enabled = false,
    opts = {
      delay = 300,
      win   = { border = "rounded" },
      spec = {
        -- ── General ──────────────────────────────────────────────────
        { "<M-S-p>",   desc = "Dotnet command palette" },
        { "<leader>w", desc = "File save" },
        { "<leader>q", desc = "File quit" },
        { "-",         desc = "File open parent" },
        { "<leader>?", desc = "Find keymaps" },

        -- ── F-keys: Debug ────────────────────────────────────────────
        { "<F5>",    desc = "Debug continue" },
        { "<S-F5>",  desc = "Debug stop" },
        { "<F9>",    desc = "Debug breakpoint toggle" },
        { "<F10>",   desc = "Debug step over" },
        { "<F11>",   desc = "Debug step into" },
        { "<S-F11>", desc = "Debug step out" },

        -- ── LSP standard (Neovim 0.11+ gr* style) ────────────────────
        { "gr",  group = "LSP" },
        { "grn", desc  = "Lsp rename" },
        { "gra", desc  = "Lsp code actions",       mode = { "n", "v" } },
        { "grA", desc  = "Lsp source actions",     mode = { "n", "v" } },
        { "grd", desc  = "Lsp definition" },
        { "grr", desc  = "Lsp references" },
        { "gri", desc  = "Lsp implementation" },
        { "grt", desc  = "Lsp type definition" },
        { "grq", desc  = "Lsp diagnostic quickfix" },
        { "gO",  desc  = "Lsp document symbols" },
        { "K",   desc  = "Lsp hover" },

        -- ── F-keys: Diagnostic ───────────────────────────────────────
        { "<F8>",   desc = "Diagnostic next" },
        { "<S-F8>", desc = "Diagnostic prev" },

        -- ── Prev / Next ───────────────────────────────────────────────
        { "[",  group = "Prev" },
        { "[d", desc  = "Diagnostic prev" },
        { "[e", desc  = "Diagnostic prev error" },
        { "[q", desc  = "Quickfix prev" },
        { "[h", desc  = "Git hunk prev" },
        { "]",  group = "Next" },
        { "]d", desc  = "Diagnostic next" },
        { "]e", desc  = "Diagnostic next error" },
        { "]q", desc  = "Quickfix next" },
        { "]h", desc  = "Git hunk next" },

        -- ── LSP reference group (<leader>l) ──────────────────────────
        { "<leader>l",  group = "LSP reference" },
        { "<leader>ld", desc  = "Lsp definition       [grd]" },
        { "<leader>lr", desc  = "Lsp references       [grr]" },
        { "<leader>li", desc  = "Lsp implementation   [gri]" },
        { "<leader>ln", desc  = "Lsp rename           [grn]" },
        { "<leader>la", desc  = "Lsp code actions     [gra]", mode = { "n", "v" } },
        { "<leader>lA", desc  = "Lsp source actions   [grA]" },
        { "<leader>lh", desc  = "Lsp hover            [K]" },
        { "<leader>ls", desc  = "Lsp signature help   [C-k]" },
        { "<leader>lt", desc  = "Lsp type definition  [grt]" },
        { "<leader>lo", desc  = "Lsp document symbols [gO]" },

        -- ── Code / LSP (<leader>c) ───────────────────────────────────
        { "<leader>c",  group = "Code / LSP" },
        { "<leader>cd", desc  = "Diagnostic float" },
        { "<leader>cD", desc  = "Diagnostic buffer all" },
        { "<leader>cE", desc  = "Diagnostic buffer errors" },
        { "<leader>cf", desc  = "Lsp format",             mode = { "n", "v" } },
        { "<leader>ci", desc  = "Lsp inlay hints" },
        { "<leader>cW", desc  = "Diagnostic buffer warnings" },
        { "<leader>cx", desc  = "Diagnostic workspace all" },

        -- ── Find / Telescope (<leader>f) ─────────────────────────────
        { "<leader>f",  group = "Find (Telescope)" },
        { "<leader>fb", desc  = "Find buffers" },
        { "<leader>ff", desc  = "Find files" },
        { "<leader>fg", desc  = "Find grep" },
        { "<leader>fh", desc  = "Find help tags" },
        { "<leader>fo", desc  = "Find recent files" },
        { "<leader>fS", desc  = "Find workspace symbols" },
        { "<leader>fs", desc  = "Find document symbols" },
        { "<leader>fz", desc  = "Find zoxide dirs" },

        -- ── Git (<leader>g) ──────────────────────────────────────────
        { "<leader>g",  group = "Git" },
        { "<leader>gs", desc  = "Git status" },
        { "<leader>gc", desc  = "Git commit" },
        { "<leader>gP", desc  = "Git push" },
        { "<leader>gl", desc  = "Git log" },
        { "<leader>gb", desc  = "Git blame" },
        { "<leader>gd", desc  = "Git diff view" },
        { "<leader>gD", desc  = "Git diff close" },
        { "<leader>gh", desc  = "Git file history" },
        { "<leader>gH", desc  = "Git repo history" },

        -- ── Search / Replace (<leader>s) ─────────────────────────────
        { "<leader>s",  group = "Search / Replace" },
        { "<leader>sr", desc  = "Search toggle spectre" },
        { "<leader>sw", desc  = "Search current word",    mode = { "n", "v" } },
        { "<leader>sf", desc  = "Search in file" },

        -- ── Debug / DAP (<leader>d) ──────────────────────────────────
        { "<leader>d",   group = "Debug (DAP)" },
        -- F-key shortcuts (shown here for discoverability)
        { "<F5>",        desc  = "Debug continue",          mode = { "n" } },
        { "<S-F5>",      desc  = "Debug stop",              mode = { "n" } },
        { "<F9>",        desc  = "Debug breakpoint toggle",  mode = { "n" } },
        { "<F10>",       desc  = "Debug step over",          mode = { "n" } },
        { "<F11>",       desc  = "Debug step into",          mode = { "n" } },
        { "<S-F11>",     desc  = "Debug step out",           mode = { "n" } },
        -- Leader keys (desc shows F-key shortcut)
        { "<leader>dc",  desc  = "Debug continue          [F5]" },
        { "<leader>dx",  desc  = "Debug stop              [S-F5]" },
        { "<leader>dl",  desc  = "Debug run last" },
        { "<leader>dr",  desc  = "Debug repl open" },
        { "<leader>du",  desc  = "Debug ui toggle" },
        { "<leader>dw",  desc  = "Debug watch expression", mode = { "n", "v" } },
        { "<leader>dp",  desc  = "Debug peek value",       mode = { "n", "v" } },
        -- Breakpoints sub-group
        { "<leader>db",  group = "Breakpoints" },
        { "<leader>dbt", desc  = "Debug breakpoint toggle    [F9]" },
        { "<leader>dbB", desc  = "Debug breakpoint conditional" },
        { "<leader>dbb", desc  = "Debug breakpoints list" },
        { "<leader>dbq", desc  = "Debug breakpoints quickfix" },
        { "<leader>dbc", desc  = "Debug breakpoints clear" },

        -- ── .NET (<leader>n) ─────────────────────────────────────────
        { "<leader>n",   group = ".NET" },
        { "<leader>nb",  desc  = "Dotnet build project" },
        { "<leader>nB",  desc  = "Dotnet build solution" },
        { "<leader>nQ",  desc  = "Dotnet build quickfix" },
        { "<leader>nc",  desc  = "Dotnet clean project" },
        { "<leader>nD",  desc  = "Dotnet diagnostics workspace" },
        { "<leader>nr",  desc  = "Dotnet run project" },
        { "<leader>nrp", desc  = "Dotnet run profile" },
        { "<leader>nw",  desc  = "Dotnet watch hot-reload" },
        { "<leader>nt",  desc  = "Dotnet test project" },
        { "<leader>nts", desc  = "Dotnet test solution" },
        { "<leader>nT",  desc  = "Dotnet test runner" },
        { "<leader>nR",  desc  = "Dotnet restore packages" },
        { "<leader>nS",  desc  = "Dotnet secrets user" },
        -- Packages sub-group
        { "<leader>np",  group = "Packages / NuGet" },
        { "<leader>npa", desc  = "Dotnet package add" },
        { "<leader>npr", desc  = "Dotnet package remove" },
        { "<leader>npo", desc  = "Dotnet package outdated" },
        { "<leader>npv", desc  = "Dotnet package view" },

        -- ── Quickfix (<leader>x) ─────────────────────────────────────
        { "<leader>x",  group = "Quickfix" },
        { "<leader>xo", desc  = "Quickfix open" },
        { "<leader>xc", desc  = "Quickfix close" },
      },
    },
  },

  -- ── telescope-ui-select: vim.ui.select (code actions etc.) → Telescope ────
  {
    "nvim-telescope/telescope-ui-select.nvim",
    event        = "VeryLazy",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("telescope").load_extension "ui-select"
    end,
  },

  -- ── Telescope: ignore .NET artifacts + ui-select theme ───────────────────
  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
      opts.defaults = opts.defaults or {}
      opts.defaults.path_display = function(_, path)
        local tail   = vim.fs.basename(path)
        local parent = vim.fs.basename(vim.fs.dirname(path))
        if parent == "." then return tail end
        return parent .. "/" .. tail
      end
      opts.defaults.file_ignore_patterns = {
        "^bin/", "^obj/",
        "^%.git/", "^%.vs/",
        "%.dll$", "%.pdb$", "%.exe$",
        "%.cache$", "%.nupkg$",
      }
      opts.extensions = opts.extensions or {}
      opts.extensions["ui-select"] = require("telescope.themes").get_dropdown()
    end,
  },

  -- ── Conform: code formatter ──────────────────────────────────────────────
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts  = require "configs.conform",
  },

  -- ── nvim-lspconfig: wire up LSP on_attach + extra servers ────────────────
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- ── Treesitter: add C# + extras on top of NvChad defaults ────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "c_sharp", "xml", "json", "toml",
        "regex", "bash", "markdown", "markdown_inline",
      },
    },
  },

  -- ── render-markdown: render MD headers/tables/code blocks in-buffer ───────
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft           = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {
      heading = { enabled = true },
      code    = { enabled = true, style = "full" },
      bullet  = { enabled = true },
      checkbox = { enabled = true },
      table   = { enabled = true },
    },
  },

  -- ── Mason: install Roslyn LSP + netcoredbg DAP adapter ───────────────────
  -- Uses mason-org registry + Crashdummyy's registry (adds "roslyn" package).
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      -- registries must be inside opts, not at the lazy spec level
      opts.registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry",  -- provides roslyn
      }
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "roslyn",       -- C# LSP (Microsoft Roslyn language server)
        "netcoredbg",   -- .NET DAP adapter
      })
    end,
  },

  -- ── DAP: debug adapter protocol core ─────────────────────────────────────
  {
    "mfussenegger/nvim-dap",
    lazy = true,
    config = function()
      require "configs.dap"
    end,
  },

  -- ── DAP UI: minimal — scopes panel at bottom only ────────────────────────
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap, dapui = require "dap", require "dapui"

      dapui.setup({
        expand_lines = true,
        controls     = { enabled = false },   -- no play/step toolbar
        floating     = { border = "rounded" },
        render = {
          max_type_length = 60,
          max_value_lines = 200,
        },
        layouts = {
          {
            -- Bottom: scopes (live variables) + watches (typed expressions)
            elements = {
              { id = "scopes",  size = 0.65 },
              { id = "watches", size = 0.35 },
            },
            size     = 15,
            position = "bottom",
          },
        },
      })

      -- Auto open/close with debug session
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"]     = function() dapui.close() end
    end,
  },

  -- ── telescope-dap: browse breakpoints, frames, configs via Telescope ───────
  {
    "nvim-telescope/telescope-dap.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "mfussenegger/nvim-dap",
    },
    config = function()
      require("telescope").load_extension "dap"
    end,
  },

  -- ── DAP virtual text: show variable values inline ────────────────────────
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap" },
    opts = {
      commented                   = true,
      highlight_changed_variables = true,
    },
  },

  -- ── easy-dotnet: .NET project management, test runner, NuGet, secrets ────
  -- Prerequisite: dotnet tool install -g EasyDotnet
  {
    "GustavEikaas/easy-dotnet.nvim",
    ft           = { "cs", "vb", "csproj", "sln", "slnx", "props" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require "configs.dotnet"
    end,
  },

  -- ── tiny-inline-diagnostic: beautiful inline diagnostics ─────────────────
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event    = "LspAttach",
    priority = 1000,
    config   = function()
      require "configs.tiny-inline-diagnostic"
    end,
  },

  -- ── oil.nvim: edit filesystem like a buffer ───────────────────────────────
  {
    "stevearc/oil.nvim",
    cmd          = "Oil",
    keys         = { { "-", "<cmd>Oil<cr>", desc = "Open oil (parent dir)" } },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config       = function()
      require "configs.oil"
    end,
  },

  -- ── zoxide: telescope picker for frecency-ranked directories ─────────────
  {
    "jvgrootveld/telescope-zoxide",
    keys = { { "<leader>fz", "<cmd>Telescope zoxide list<cr>", desc = "Zoxide dirs" } },
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("telescope").load_extension "zoxide"
    end,
  },

  -- ── friendly-snippets: preconfigured snippet collection for LuaSnip ───────
  {
    "rafamadriz/friendly-snippets",
    dependencies = { "L3MON4D3/LuaSnip" },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },




  -- ── nvim-spectre: project-wide find & replace ─────────────────────────────
  {
    "nvim-pack/nvim-spectre",
    cmd          = "Spectre",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts         = { open_cmd = "noswapfile vnew" },
  },

  -- ── vim-fugitive: full git workflow ──────────────────────────────────────
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G" },
  },

  -- ── diffview.nvim: side-by-side git diff + file history ──────────────────
  {
    "sindrets/diffview.nvim",
    cmd          = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts         = {},
  },
}
