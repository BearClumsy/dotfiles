return {
  -- Use blink.cmp's built-in signature help instead of Noice's. Noice's version
  -- is a separate float with no knowledge of the completion menu, so the two
  -- overlap while typing arguments (see noice.lua). blink positions its signature
  -- window relative to its own menu and flips out of the way when the menu is
  -- there.
  {
    "saghen/blink.cmp",
    opts = {
      signature = {
        enabled = true,
        window = {
          border = "rounded",
          -- prefer below the edited line; blink falls back to above when there's
          -- no room or the completion menu is already there
          direction_priority = { "s", "n" },
          show_documentation = false,
        },
      },
    },
  },
}
