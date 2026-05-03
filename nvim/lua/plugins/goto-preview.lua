return {
  {
    "rmagatti/goto-preview",
    event = "BufEnter",
    opts = {
      width = 120,
      height = 25,
      border = { "↖", "─", "╮", "│", "╯", "─", "╰", "│" },
      default_mappings = false,
      opacity = nil,
      resizing_mappings = false,
      post_open_hook = nil,
      references = { telescope = require("telescope.themes").get_dropdown({ hide_preview = false }) },
      focus_on_open = true,
      dismiss_on_move = false,
      force_close = true,
      bufhidden = "wipe",
    },
    keys = {
      { "gpd", function() require("goto-preview").goto_preview_definition() end,      desc = "Preview Definition" },
      { "gpi", function() require("goto-preview").goto_preview_implementation() end,  desc = "Preview Implementation" },
      { "gpr", function() require("goto-preview").goto_preview_references() end,      desc = "Preview References" },
      { "gpt", function() require("goto-preview").goto_preview_type_definition() end, desc = "Preview Type Definition" },
      { "gpq", function() require("goto-preview").close_all_win() end,               desc = "Close Preview Windows" },
    },
  },
}
