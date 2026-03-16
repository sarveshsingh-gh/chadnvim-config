-- easy-dotnet.nvim configuration.
-- Full option reference: https://github.com/GustavEikaas/easy-dotnet.nvim
require("easy-dotnet").setup({
  -- Let easy-dotnet register the DAP adapter + config automatically.
  -- Uses prepare_debugger() which builds the project, picks a launch
  -- profile, starts netcoredbg, and returns the port for DAP to attach.
  debugger = {
    auto_register_dap = true,
    console           = "integratedTerminal",
  },

  -- Auto-insert file-scoped namespace when creating new .cs files
  auto_bootstrap_namespace = {
    type    = "file_scoped",   -- "file_scoped" | "block_scoped"
    enabled = true,
  },

  -- Extra keymaps on .csproj buffer (add/remove refs, packages, etc.)
  csproj_mappings = true,

  -- Test runner
  test_runner = {
    viewmode                     = "split",   -- "split" | "vsplit" | "float" | "buf"
    enable_buffer_test_execution = true,
    noBuild                      = false,
    icons = {
      passed  = "",
      skipped = "",
      failed  = "",
      success = "",
      reload  = "",
      test    = "",
      sln     = "󰘐",
      project = "󰘐",
      dir     = "",
      package = "",
    },
    mappings = {
      run_test_from_buffer = { lhs = "r",           desc = "Run test under cursor" },
      filter_failed_tests  = { lhs = "<leader>tf", desc = "Filter failed tests" },
      debug_test           = { lhs = "<leader>td", desc = "Debug test" },
      go_to_file           = { lhs = "gf",         desc = "Go to test file" },
      run_all              = { lhs = "<leader>ta", desc = "Run all tests" },
    },
  },
})
