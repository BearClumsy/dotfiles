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
}
