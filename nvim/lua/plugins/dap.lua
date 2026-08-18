return {
  {
    "mfussenegger/nvim-dap",
    -- stylua: ignore
    keys = {
      -- IntelliJ's "Drop Frame": pops the current stack frame so execution
      -- returns to the call site in the caller. Useful after accidentally
      -- stepping *into* a method — lets you re-enter it without restarting
      -- the session. LazyVim's dap.core extra binds everything else under
      -- <leader>d but leaves restart_frame unbound.
      { "<leader>dF", function() require("dap").restart_frame() end, desc = "Drop Frame (Restart Frame)" },
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    opts = function(_, opts)
      local win_size = require("config.win-size")
      opts.layouts = {
        {
          elements = {
            { id = "scopes", size = 0.25 },
            { id = "breakpoints", size = 0.25 },
            { id = "stacks", size = 0.25 },
            { id = "watches", size = 0.25 },
          },
          size = win_size.get("dapui_sidebar", 40),
          position = "left",
        },
        {
          elements = { "repl", "console" },
          size = win_size.get("dapui_bottom", 10),
          position = "bottom",
        },
      }
      return opts
    end,
  },
}
