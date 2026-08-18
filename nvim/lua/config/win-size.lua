-- Persists window sizes (dap-ui panels, explorer sidebar) across sessions.
local M = {}

local path = vim.fn.stdpath("data") .. "/win-sizes.json"
local cache

local function load()
  if cache then
    return cache
  end
  local ok, lines = pcall(vim.fn.readfile, path)
  if ok and lines[1] then
    local decode_ok, decoded = pcall(vim.json.decode, table.concat(lines, "\n"))
    if decode_ok and type(decoded) == "table" then
      cache = decoded
      return cache
    end
  end
  cache = {}
  return cache
end

function M.get(key, default)
  local tbl = load()
  return tbl[key] or default
end

function M.save(key, value)
  local tbl = load()
  if tbl[key] == value then
    return
  end
  tbl[key] = value
  pcall(vim.fn.writefile, { vim.json.encode(tbl) }, path)
end

return M
