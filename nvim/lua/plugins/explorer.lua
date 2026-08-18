return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            layout = {
              layout = {
                width = function()
                  return require("config.win-size").get("explorer", 40)
                end,
              },
            },
          },
        },
      },
    },
  },
}
