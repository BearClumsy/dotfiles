return {
  -- Configure LazyVim colorscheme with auto theme switching
  {
    "LazyVim/LazyVim",
    opts = {
      -- Set default colorscheme - this will be overridden by auto-switching
      colorscheme = "catppuccin",
    },
  },

  -- Catppuccin theme as primary colorscheme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    init = function()
      require("config.auto-theme").init()
    end,
    opts = {
      flavour = "mocha",
      transparent_background = true,
      float = {
        transparent = true,
      },
      integrations = {
        bufferline = true,
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        neotree = true,
        treesitter = true,
        snacks = {
          enabled = true,
          indent_scope_color = "",
        },
        notify = false,
        mini = {
          enabled = true,
          indentscope_color = "",
        },
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
          },
          underlines = {
            errors = { "underline" },
            hints = { "underline" },
            warnings = { "underline" },
            information = { "underline" },
          },
        },
        telescope = true,
        which_key = true,
      },
    },
  },

  -- Keep Tokyo Night as alternative option
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {
      style = "night",
      styles = {
        sidebars = "dark",
        floats = "dark",
      },
    },
  },

  { "f-person/auto-dark-mode.nvim", enabled = false },
}
