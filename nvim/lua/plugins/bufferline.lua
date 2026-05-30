return {
  "akinsho/bufferline.nvim",
  opts = function(_, opts)
    opts.options = vim.tbl_extend("force", opts.options or {}, {
      always_show_bufferline = true,
      custom_filter = function(buf_number)
        if vim.fn.bufname(buf_number) == "" and not vim.bo[buf_number].modified then
          return false
        end
        return true
      end,
    })
    local ok, ctp_bl = pcall(require, "catppuccin.groups.integrations.bufferline")
    if ok then
      opts.highlights = ctp_bl.get_theme()
    end
    local ok_pal, palette = pcall(require, "catppuccin.palettes")
    if ok_pal then
      local colors = palette.get_palette()
      local bg = colors.surface1
      local overrides = {
        buffer_selected = { bg = bg, bold = true, italic = false },
        close_button_selected = { bg = bg },
        separator_selected = { bg = bg },
        indicator_selected = { bg = bg },
        numbers_selected = { bg = bg },
        modified_selected = { bg = bg },
        diagnostic_selected = { bg = bg },
        hint_selected = { bg = bg },
        hint_diagnostic_selected = { bg = bg },
        warning_selected = { bg = bg },
        warning_diagnostic_selected = { bg = bg },
        error_selected = { bg = bg },
        error_diagnostic_selected = { bg = bg },
        info_selected = { bg = bg },
        info_diagnostic_selected = { bg = bg },
      }
      if type(opts.highlights) == "function" then
        local orig = opts.highlights
        opts.highlights = function()
          return vim.tbl_deep_extend("force", orig() or {}, overrides)
        end
      else
        opts.highlights = vim.tbl_deep_extend("force", opts.highlights or {}, overrides)
      end
    end
    return opts
  end,
}
