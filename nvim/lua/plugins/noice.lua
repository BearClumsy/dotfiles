return {
  -- Noice intercepts LSP hover (K), and its `hover` view ships with
  -- `border.style = "none"` -- so that float never sees `vim.o.winborder`. Give it
  -- the same rounded border the snacks picker uses.
  {
    "folke/noice.nvim",
    opts = {
      views = {
        hover = {
          border = {
            style = "rounded",
            padding = { 0, 1 },
          },
          -- The rounded border is drawn one row *outside* `position`, so Noice's
          -- default `row = 1` drops that border row onto the line K was invoked
          -- on and hides it. `row = 2` puts the border on the first row *below*
          -- that line instead. Noice's auto-anchor flip rewrites this to
          -- `-row + 1` when the popup opens above (cursor near the window bottom).
          position = { row = 2, col = 0 },
        },
      },
      lsp = {
        -- Signature help is handled by blink.cmp's own signature window (see
        -- blink.lua). Noice renders it as a standalone float with no awareness of
        -- the completion menu, so the two stack and overlap while typing
        -- arguments; blink positions its signature window relative to its own
        -- menu and steps out of the way.
        signature = { enabled = false },
      },
    },
  },
}
