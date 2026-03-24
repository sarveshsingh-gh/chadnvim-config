return {

  -- ── LuaSnip: load custom snippets from luasnippets/ ──────────────────────
  {
    "L3MON4D3/LuaSnip",
    config = function()
      require("luasnip.loaders.from_lua").lazy_load({
        paths = vim.fn.stdpath("config") .. "/luasnippets",
      })
    end,
  },

  -- ── blink.cmp: HTTP header completions for .http / .rest files ───────────
  {
    "saghen/blink.cmp",
    version = "v0.*",  -- pin to stable release so prebuilt binary is always available
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      opts.sources.providers = opts.sources.providers or {}
      -- Register http headers source
      opts.sources.providers.http_headers = {
        name   = "HTTP Headers",
        module = "configs.http_blink_source",
      }
      -- Enable it only for http/rest files
      opts.sources.per_filetype = opts.sources.per_filetype or {}
      opts.sources.per_filetype.http = { "http_headers", "luasnip", "snippets" }
      return opts
    end,
  },

  -- ── Mason: auto-install LSP servers + formatters + linters ──────────────
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- C#
        "csharpier",
        -- Web LSPs
        "typescript-language-server",
        "eslint-lsp",
        "json-lsp",
        "tailwindcss-language-server",
        -- Formatters
        "prettierd",
      },
    },
  },

  -- ── conform.nvim: formatters for all languages ────────────────────────────
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        cs         = { "csharpier" },
        javascript = { "prettierd" },
        typescript = { "prettierd" },
        html       = { "prettierd" },
        css        = { "prettierd" },
        scss       = { "prettierd" },
        json       = { "prettierd" },
        jsonc      = { "prettierd" },
      },
    },
  },

  -- ── nvim-treesitter: add web language parsers ─────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "css", "scss",
        "javascript", "typescript", "tsx",
        "json", "jsonc",
        "html",
      },
    },
  },

  -- ── nvim-notify: beautiful notification popups ───────────────────────────
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    opts  = {
      render          = "wrapped-compact",
      stages          = "slide",
      timeout         = 3000,
      max_width       = 60,
      icons = {
        ERROR = " ",
        WARN  = " ",
        INFO  = " ",
        DEBUG = " ",
        TRACE = "✎ ",
      },
    },
    config = function(_, opts)
      local notify = require("notify")
      notify.setup(opts)
      vim.notify = notify
    end,
  },

  -- ── noice.nvim: beautiful cmdline, popupmenu, LSP progress ───────────────
  {
    "folke/noice.nvim",
    event        = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    opts = {
      cmdline = {
        enabled = true,
        view    = "cmdline_popup",
        format  = {
          cmdline   = { icon = ">" },
          search_down = { icon = " " },
          search_up   = { icon = " " },
          filter      = { icon = "$" },
          lua         = { icon = "" },
          help        = { icon = "?" },
        },
      },
      messages = {
        enabled      = true,
        view         = "notify",
        view_error   = "notify",
        view_warn    = "notify",
        view_history = "messages",
      },
      popupmenu = {
        enabled  = true,
        backend  = "nui",
      },
      lsp = {
        progress = {
          enabled = true,
          view    = "mini",
        },
        hover          = { enabled = false },  -- use Neovim's built-in K
        signature      = { enabled = false },  -- use blink.cmp signature
        message        = { enabled = true },
      },
      presets = {
        bottom_search         = true,   -- classic bottom search bar
        command_palette       = true,   -- cmdline popup centered with autocomplete
        long_message_to_split = true,   -- long messages go to split
        inc_rename            = false,
      },
      routes = {
        -- send "written" messages to mini (bottom right, no popup)
        { filter = { event = "msg_show", find = "written" },   opts = { skip = true } },
        { filter = { event = "msg_show", find = "%d+L, %d+B" }, opts = { skip = true } },
      },
    },
  },

  -- ── blink.cmp: faster completion (replaces nvim-cmp) ─────────────────────
  { import = "nvchad.blink.lazyspec" },

  -- ── telescope: parent/filename path display + show hidden/ignored files ──────
  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
      opts.defaults = opts.defaults or {}
      -- Show only "ParentDir/filename.ext" instead of full path
      opts.defaults.path_display = function(_, path)
        -- strip the common company prefix anywhere in the path
        local cleaned     = path:gsub("Deloitte%.UK%.ComplexApps%.EForms%.", "")
        local tail        = vim.fs.basename(cleaned)
        local parent      = vim.fs.basename(vim.fs.dirname(cleaned))
        local grandparent = vim.fs.basename(vim.fs.dirname(vim.fs.dirname(cleaned)))
        if grandparent == nil or grandparent == "." or grandparent == "" then
          return parent .. "/" .. tail
        end
        return grandparent .. "/" .. parent .. "/" .. tail
      end
      -- Always show hidden files (.gitignore, .env, etc.) and files ignored by git
      opts.defaults.find_command = {
        "rg", "--files", "--hidden", "--no-ignore",
        "--glob", "!**/.git/*",
        "--glob", "!**/obj/*",
        "--glob", "!**/bin/*",
        "--glob", "!**/Debug/*",
        "--glob", "!**/Release/*",
      }
      return opts
    end,
  },

  -- ── telescope-ui-select: use telescope for vim.ui.select (code actions etc) ─
  {
    "nvim-telescope/telescope-ui-select.nvim",
    event        = "VeryLazy",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("telescope").setup({
        extensions = { ["ui-select"] = require("telescope.themes").get_dropdown() },
      })
      require("telescope").load_extension("ui-select")
    end,
  },

  -- ── dotnet.nvim prerequisites (not in NvChad by default) ──────────────────
  { "mfussenegger/nvim-dap" },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "nvim-neotest/nvim-nio" },
    opts = {},
  },

  -- ── dotnet.nvim meta-plugin: full .NET IDE in one line ────────────────────
  {
    "sarveshsingh-gh/dotnet-plugin",
    name   = "dotnet.nvim",
    import = "dotnet.lazy",
  },

  -- ── harpoon2: quick file bookmarks ────────────────────────────────────────
  {
    "ThePrimeagen/harpoon",
    branch       = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config       = function() require("harpoon"):setup() end,
    keys = {
      { "<leader>ha", function() require("harpoon"):list():add() end,                                desc = "Harpoon add" },
      { "<leader>hh", function() local h = require("harpoon") h.ui:toggle_quick_menu(h:list()) end, desc = "Harpoon menu" },
      { "<leader>1",  function() require("harpoon"):list():select(1) end, desc = "Harpoon file 1" },
      { "<leader>2",  function() require("harpoon"):list():select(2) end, desc = "Harpoon file 2" },
      { "<leader>3",  function() require("harpoon"):list():select(3) end, desc = "Harpoon file 3" },
      { "<leader>4",  function() require("harpoon"):list():select(4) end, desc = "Harpoon file 4" },
      { "<leader>5",  function() require("harpoon"):list():select(5) end, desc = "Harpoon file 5" },
      { "<leader>6",  function() require("harpoon"):list():select(6) end, desc = "Harpoon file 6" },
    },
  },

  -- ── copilot: inline suggestions ───────────────────────────────────────────
  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    opts  = {
      suggestion = {
        enabled      = true,
        auto_trigger = true,
        keymap = {
          accept      = "<M-l>",   -- NvChad uses Tab for completion, avoid conflict
          accept_word = "<C-Right>",
          accept_line = "<C-Down>",
          next        = "<M-]>",
          prev        = "<M-[>",
          dismiss     = "<C-e>",
        },
      },
      panel     = { enabled = false },
      filetypes = { ["*"] = true },
    },
  },

  -- ── diffview: side-by-side git diff + file history ────────────────────────
  {
    "sindrets/diffview.nvim",
    cmd          = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts         = {},
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>",          desc = "Git diff view" },
      { "<leader>gD", "<cmd>DiffviewClose<cr>",         desc = "Git diff close" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Git file history" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>",   desc = "Git repo history" },
    },
  },

  -- ── render-markdown: render MD headers/tables/code in-buffer ──────────────
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft           = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {
      heading  = { enabled = true },
      code     = { enabled = true, style = "full" },
      bullet   = { enabled = true },
      checkbox = { enabled = true },
      table    = { enabled = true },
    },
  },

  -- ── tiny-inline-diagnostic: beautiful inline diagnostics ──────────────────
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event    = "LspAttach",
    priority = 1000,
    opts     = {},
  },

  -- ── oil.nvim: edit filesystem like a buffer ───────────────────────────────
  {
    "stevearc/oil.nvim",
    cmd          = "Oil",
    keys         = { { "-", "<cmd>Oil<cr>", desc = "Open oil (parent dir)" } },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts         = {},
  },

  -- ── telescope-zoxide: frecency-ranked directory picker ────────────────────
  {
    "jvgrootveld/telescope-zoxide",
    cmd  = { "Z" },
    keys = { { "<leader>fz", "<cmd>Z<cr>", desc = "Zoxide dirs" } },
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").load_extension("zoxide")
      vim.api.nvim_create_user_command("Z", function(opts)
        if opts.args == "" then
          require("telescope").extensions.zoxide.list()
        else
          local path = vim.trim(vim.fn.system("zoxide query " .. vim.fn.shellescape(opts.args)))
          if vim.fn.isdirectory(path) == 1 then
            vim.cmd("cd " .. vim.fn.fnameescape(path))
            vim.notify("cd " .. path)
          else
            vim.notify("zoxide: no match for " .. opts.args, vim.log.levels.WARN)
          end
        end
      end, { nargs = "?", desc = "Zoxide cd" })
    end,
  },

  -- ── CopilotChat: agent mode / chat ────────────────────────────────────────
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    event        = "VeryLazy",
    dependencies = { "zbirenbaum/copilot.lua", "nvim-lua/plenary.nvim" },
    opts = {
      model  = "gpt-4o",
      window = { layout = "vertical", width = 0.35 },
    },
  },

  -- ── mini.bracketed: ]a/[a jump between text objects ───────────────────────
  { "nvim-mini/mini.bracketed", event = "VeryLazy", opts = {} },

  -- ── vim-be-good: Vim motion practice ──────────────────────────────────────
  { "ThePrimeagen/vim-be-good", cmd = "VimBeGood" },

  -- ── nvim-spectre: project-wide find & replace ─────────────────────────────
  {
    "nvim-pack/nvim-spectre",
    cmd          = "Spectre",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts         = { open_cmd = "noswapfile vnew" },
    keys = {
      { "<leader>sr", function() require("spectre").toggle() end,                                 desc = "Search toggle spectre" },
      { "<leader>sw", function() require("spectre").open_visual({ select_word = true }) end,      desc = "Search current word" },
      { "<leader>sf", function() require("spectre").open_file_search({ select_word = true }) end, desc = "Search in file" },
    },
  },

  -- ── lazygit: full git TUI inside neovim ──────────────────────────────────
  {
    "kdheepak/lazygit.nvim",
    cmd          = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter", "LazyGitFilterCurrentFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gs", "<cmd>LazyGit<cr>",                    desc = "LazyGit" },
      { "<leader>gf", "<cmd>LazyGitCurrentFile<cr>",         desc = "LazyGit current file" },
      { "<leader>gl", "<cmd>LazyGitFilter<cr>",              desc = "LazyGit log" },
      { "<leader>gc", "<cmd>LazyGitFilterCurrentFile<cr>",   desc = "LazyGit file log" },
    },
  },

  -- ── vim-dadbod: SQL client ────────────────────────────────────────────────
  { "tpope/vim-dadbod", lazy = true },
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = { "tpope/vim-dadbod", "kristijanhusak/vim-dadbod-completion" },
    cmd  = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    keys = { { "<leader>D", "<cmd>DBUIToggle<cr>", desc = "DB UI toggle" } },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_save_location  = vim.fn.expand("~/.local/share/db_ui")
    end,
  },
  {
    "kristijanhusak/vim-dadbod-completion",
    lazy   = true,
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern  = { "sql", "mysql", "plsql" },
        callback = function()
          require("cmp").setup.buffer({ sources = { { name = "vim-dadbod-completion" } } })
        end,
      })
    end,
  },

  -- ── nvim-dap-virtual-text: variable values inline while debugging ──────────
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap" },
    opts = { commented = true, highlight_changed_variables = true },
  },

  -- ── telescope-dap: browse breakpoints/frames via Telescope ────────────────
  {
    "nvim-telescope/telescope-dap.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "mfussenegger/nvim-dap" },
    config = function() require("telescope").load_extension("dap") end,
  },

}
