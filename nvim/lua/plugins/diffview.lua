return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>",                desc = "Diff View" },
      { "<leader>gF", "<cmd>DiffviewFileHistory %<cr>",       desc = "File History" },
      { "<leader>gA", "<cmd>DiffviewFileHistory<cr>",         desc = "Repo History" },
      { "<leader>gx", "<cmd>DiffviewClose<cr>",               desc = "Close Diff View" },
    },
  },
}
