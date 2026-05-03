return {
  {
    "yetone/avante.nvim",
    opts = {
      provider = "claude",
      providers = {
        claude = {
          endpoint = "https://api.anthropic.com",
          model = "claude-sonnet-4-20250514",
          timeout = 30000,
          -- Все доп. параметры теперь СТРОГО здесь:
          extra_request_body = {
            temperature = 0.75,
            max_tokens = 4096,
          },
        },
        -- Add Haiku model as a separate provider configuration
        ["claude-haiku"] = {
          endpoint = "https://api.anthropic.com",
          model = "claude-3-5-haiku-20250514", -- Фикс для Haiku
          timeout = 30000,
          extra_request_body = {
            temperature = 0.75,
            max_tokens = 4096,
          },
        },
        -- Add Opus model as a separate provider configuration
        ["claude-opus"] = {
          endpoint = "https://api.anthropic.com",
          model = "claude-opus-4-20250514",
          timeout = 30000,
          extra_request_body = {
            temperature = 0.75,
            max_tokens = 4096,
          },
        },
      },
    },
  },
}
