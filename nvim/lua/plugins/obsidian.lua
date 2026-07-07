local function obsidian_workspaces()
  local config_path = vim.fn.expand("~/Library/Application Support/obsidian/obsidian.json")
  local f = io.open(config_path, "r")
  if not f then return {} end
  local content = f:read("*a")
  f:close()
  local ok, data = pcall(vim.json.decode, content)
  if not ok or not data.vaults then return {} end
  local workspaces = {}
  for _, vault in pairs(data.vaults) do
    local name = vim.fn.fnamemodify(vault.path, ":t"):lower():gsub("%s+", "-")
    table.insert(workspaces, { name = name, path = vault.path })
  end
  return workspaces
end

return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  cmd = { "ObsidianNew", "ObsidianSearch", "ObsidianWorkspace", "ObsidianToday", "ObsidianOpen" },
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    workspaces = obsidian_workspaces(),
    picker = { name = "telescope.nvim" },
    ui = { enable = false },
  },
}
