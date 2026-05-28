return {
  {
    "tpope/vim-fugitive",
    lazy = true,
  },
  {
    "rbong/vim-flog",
    cmd = { "Flog", "Flogsplit" },
    dependencies = { "tpope/vim-fugitive" },
    keys = {
      { "<leader>gl", "<cmd>Flog<cr>", desc = "Git Log Tree" },
    },
  },
}
