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

-- Sidebar-style keys must never claim more than this share of the screen. A
-- larger value (e.g. left over from the old dap-ui resize bug) is treated as
-- corruption: never read back, never written.
local clamped_keys = { explorer = true, dapui_sidebar = true }

local function too_wide(key, value)
  return clamped_keys[key]
    and type(value) == "number"
    and value > math.floor(vim.o.columns * 0.45)
end

function M.get(key, default)
  local tbl = load()
  local v = tbl[key]
  if v == nil or too_wide(key, v) then
    return default
  end
  return v
end

function M.save(key, value)
  if too_wide(key, value) then
    return
  end
  local tbl = load()
  if tbl[key] == value then
    return
  end
  tbl[key] = value
  pcall(vim.fn.writefile, { vim.json.encode(tbl) }, path)
end

return M
