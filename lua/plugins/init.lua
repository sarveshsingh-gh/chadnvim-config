-- User plugins loaded on top of NvChad's built-in plugin set.
-- NvChad already provides: mason, nvim-lspconfig, nvim-cmp, luasnip,
-- telescope, nvim-treesitter, gitsigns, which-key, autopairs, nvim-web-devicons.
-- We only add what NvChad does NOT include.

return {
  -- ── which-key: trigger on g / [ / ] in addition to <leader> ─────────────
  {
    "folke/which-key.nvim",
    opts = {
      delay = 300,
      win   = { border = "rounded" },
      spec = {
        -- ── General ──────────────────────────────────────────────────
        { "<M-S-p>",     desc = "Dotnet command palette" },
        { "<leader>w",   desc = "Save file" },
        { "<leader>q",   desc = "Quit" },
        { "-",           desc = "Oil: open parent dir" },

        -- ── F-keys (DAP) ─────────────────────────────────────────────
        { "<F5>",    desc = "Debug: Continue / Start" },
        { "<S-F5>",  desc = "Debug: Stop" },
        { "<F9>",    desc = "Debug: Toggle breakpoint" },
        { "<F10>",   desc = "Debug: Step over" },
        { "<F11>",   desc = "Debug: Step into" },
        { "<S-F11>", desc = "Debug: Step out" },

        -- ── LSP (standard) ───────────────────────────────────────────
        { "K",    desc = "Hover docs" },
        { "gd",   desc = "Go to definition",      mode = { "n" } },
        { "gD",   desc = "Go to declaration",     mode = { "n" } },
        { "gm",   desc = "Go to implementation",  mode = { "n" } },
        { "gy",   desc = "Go to type definition", mode = { "n" } },
        { "gr",   desc = "References (Telescope)",mode = { "n" } },
        { "ga", desc = "Code actions", mode = { "n", "v" } },

        -- ── Prev / Next ───────────────────────────────────────────────
        { "[",  group = "Prev" },
        { "[d", desc  = "Prev diagnostic" },
        { "[e", desc  = "Prev error" },
        { "[q", desc  = "Quickfix prev" },
        { "[h", desc  = "Git: Prev hunk" },
        { "]",  group = "Next" },
        { "]d", desc  = "Next diagnostic" },
        { "]e", desc  = "Next error" },
        { "]q", desc  = "Quickfix next" },
        { "]h", desc  = "Git: Next hunk" },

        -- ── Code / LSP (<leader>c) ───────────────────────────────────
        { "<leader>c",  group = "Code / LSP" },
        { "<leader>cd", desc  = "Diagnostic float" },
        { "<leader>cD", desc  = "All diagnostics (buffer)" },
        { "<leader>cE", desc  = "Errors (buffer)" },
        { "<leader>cf", desc  = "Format document / selection", mode = { "n", "v" } },
        { "<leader>ci", desc  = "Toggle inlay hints" },
        { "<leader>cs", desc  = "Signature help" },
        { "<leader>cW", desc  = "Warnings (buffer)" },
        { "<leader>cx", desc  = "All diagnostics (workspace)" },
        { "<leader>rn", desc  = "Rename symbol" },

        -- ── Find / Telescope (<leader>f) ─────────────────────────────
        { "<leader>f",  group = "Find (Telescope)" },
        { "<leader>fb", desc  = "Buffers" },
        { "<leader>ff", desc  = "Files" },
        { "<leader>fg", desc  = "Live grep" },
        { "<leader>fh", desc  = "Help tags" },
        { "<leader>fo", desc  = "Recent files" },
        { "<leader>fS", desc  = "Workspace symbols" },
        { "<leader>fs", desc  = "Document symbols" },
        { "<leader>fz", desc  = "Zoxide dirs" },

        -- ── Git (<leader>g) ──────────────────────────────────────────
        { "<leader>g",  group = "Git" },
        { "<leader>gs", desc  = "Git status" },
        { "<leader>gc", desc  = "Git commit" },
        { "<leader>gP", desc  = "Git push" },
        { "<leader>gl", desc  = "Git log" },
        { "<leader>gb", desc  = "Git blame" },
        { "<leader>gd", desc  = "Diff view open" },
        { "<leader>gD", desc  = "Diff view close" },
        { "<leader>gh", desc  = "File history" },
        { "<leader>gH", desc  = "Repo history" },

        -- ── Search / Replace (<leader>s) ─────────────────────────────
        { "<leader>s",  group = "Search / Replace" },
        { "<leader>sr", desc  = "Spectre toggle" },
        { "<leader>sw", desc  = "Search word/selection", mode = { "n", "v" } },
        { "<leader>sf", desc  = "Search in file" },

        -- ── Debug / DAP (<leader>d) ──────────────────────────────────
        { "<leader>d",   group = "Debug (DAP)" },
        { "<leader>dc",  desc  = "Continue / Start" },
        { "<leader>dl",  desc  = "Run last config" },
        { "<leader>dr",  desc  = "Open REPL" },
        { "<leader>du",  desc  = "Toggle DAP UI" },
        { "<leader>dw",  desc  = "Watch expression",          mode = { "n", "v" } },
        { "<leader>dp",  desc  = "Peek value under cursor",   mode = { "n", "v" } },
        { "<leader>dx",  desc  = "Terminate session" },
        -- Breakpoints sub-group
        { "<leader>db",  group = "Breakpoints" },
        { "<leader>dbt", desc  = "Toggle breakpoint" },
        { "<leader>dbB", desc  = "Conditional breakpoint" },
        { "<leader>dbb", desc  = "List all (Telescope)" },
        { "<leader>dbq", desc  = "List all → quickfix" },
        { "<leader>dbc", desc  = "Clear all breakpoints" },

        -- ── .NET (<leader>n) ─────────────────────────────────────────
        { "<leader>n",   group = ".NET" },
        { "<leader>nb",  desc  = "Build project" },
        { "<leader>nB",  desc  = "Build solution" },
        { "<leader>nqb", desc  = "Build → quickfix" },
        { "<leader>nc",  desc  = "Clean" },
        { "<leader>nD",  desc  = "Workspace diagnostics" },
        -- Run
        { "<leader>nr",  desc  = "Run project" },
        { "<leader>nrp", desc  = "Run with profile" },
        { "<leader>nw",  desc  = "Watch / hot-reload" },
        -- Test
        { "<leader>nt",  desc  = "Test project" },
        { "<leader>nts", desc  = "Test solution" },
        { "<leader>nT",  desc  = "Test runner UI" },
        -- Packages sub-group
        { "<leader>np",  group = "Packages / NuGet" },
        { "<leader>npa", desc  = "Add NuGet package" },
        { "<leader>npr", desc  = "Remove NuGet package" },
        { "<leader>npo", desc  = "Outdated packages" },
        { "<leader>npv", desc  = "Project dependencies" },
        -- Misc
        { "<leader>nR",  desc  = "Restore packages" },
        { "<leader>nS",  desc  = "User secrets" },

        -- ── Quickfix / Trouble (<leader>x) ───────────────────────────
        { "<leader>x",  group = "Quickfix / Trouble" },
        { "<leader>xo", desc  = "Open quickfix" },
        { "<leader>xc", desc  = "Close quickfix" },
        { "<leader>xx", desc  = "Trouble: workspace diagnostics" },
        { "<leader>xd", desc  = "Trouble: buffer diagnostics" },
        { "<leader>xs", desc  = "Trouble: symbols" },
        { "<leader>xl", desc  = "Trouble: LSP" },
        { "<leader>xq", desc  = "Trouble: quickfix" },
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

  -- ── flash.nvim: fast motion — jump anywhere with 2 chars ─────────────────
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts  = {},
    keys  = {
      { "s",     function() require("flash").jump() end,              desc = "Flash jump",             mode = { "n", "x", "o" } },
      { "S",     function() require("flash").treesitter() end,        desc = "Flash treesitter select", mode = { "n", "x", "o" } },
      { "r",     function() require("flash").remote() end,            desc = "Flash remote",            mode = "o" },
      { "R",     function() require("flash").treesitter_search() end, desc = "Flash treesitter search", mode = { "o", "x" } },
    },
  },

  -- ── mini.surround: add/change/delete surrounding chars ───────────────────
  {
    "echasnovski/mini.surround",
    event = "VeryLazy",
    opts  = {
      mappings = {
        add            = "gsa",
        delete         = "gsd",
        find           = "gsf",
        find_left      = "gsF",
        highlight      = "gsh",
        replace        = "gsr",
        update_n_lines = "gsn",
      },
    },
  },

  -- ── noice.nvim: floating cmdline + pretty notifications ──────────────────
  {
    "folke/noice.nvim",
    event        = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"]                = true,
        },
        -- hover and signature handled by our own keymaps
        hover      = { enabled = false },
        signature  = { enabled = false },
      },
      presets = {
        bottom_search        = true,   -- classic / search stays at bottom
        command_palette      = true,   -- position cmdline + popupmenu together
        long_message_to_split = true,  -- long messages go to split
        inc_rename           = false,
      },
      messages  = { enabled = true },
      notify    = { enabled = true },
    },
  },

  -- ── trouble.nvim: pretty diagnostics / quickfix panel ────────────────────
  {
    "folke/trouble.nvim",
    cmd  = "Trouble",
    opts = { focus = true },
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
