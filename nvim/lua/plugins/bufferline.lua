return {
  "akinsho/bufferline.nvim",
  opts = function(_, opts)
    opts.options = vim.tbl_extend("force", opts.options or {}, {
      always_show_bufferline = true,
    })
    local ok, ctp_bl = pcall(require, "catppuccin.groups.integrations.bufferline")
    if ok then
      opts.highlights = ctp_bl.get_theme()
    end
    return opts
  end,
}
