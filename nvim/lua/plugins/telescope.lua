return {
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      pickers = {
        -- telescope truncates symbol names at 25 chars by default (make_entry.lua)
        lsp_document_symbols = { symbol_width = 60 },
        lsp_dynamic_workspace_symbols = { symbol_width = 60, fname_width = 40 },
        lsp_workspace_symbols = { symbol_width = 60, fname_width = 40 },
        treesitter = { symbol_width = 60 },
      },
    },
  },
}
