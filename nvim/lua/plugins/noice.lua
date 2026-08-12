return {
  -- Noice intercepts LSP hover (K) and signature help, and its `hover` view ships with
  -- `border.style = "none"` -- so those floats never see `vim.o.winborder`. Give them the
  -- same rounded border the snacks picker uses.
  {
    "folke/noice.nvim",
    opts = {
      views = {
        hover = {
          border = {
            style = "rounded",
            padding = { 0, 1 },
          },
        },
      },
    },
  },
}
