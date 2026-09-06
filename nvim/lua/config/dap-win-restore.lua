-- IntelliJ-style debug UI behaviour for nvim-dap-ui:
--
--  * dap-ui still opens automatically when a session starts (LazyVim default),
--    but it is NOT closed automatically when the program stops -- it stays on
--    screen like IntelliJ's "Debug" tool window so console/REPL output remains.
--  * The editor/explorer layout from just before dap-ui opened is snapshotted,
--    and restored when dap-ui is closed manually (<leader>du, :DapUiClose, :q).
local M = {}

local group = vim.api.nvim_create_augroup("dap_win_restore", { clear = true })

-- winrestcmd() string plus the context it was captured in, so a stale snapshot
-- is never replayed onto a different window set.
local saved, saved_tab, saved_wincount

local function is_dap_ft(ft)
  return ft ~= nil and (ft:match("^dapui_") ~= nil or ft == "dap-repl")
end

local function cur_tab_wins()
  return vim.api.nvim_tabpage_list_wins(0)
end

local function dapui_windows_open()
  for _, win in ipairs(cur_tab_wins()) do
    local ok, ft = pcall(function()
      return vim.bo[vim.api.nvim_win_get_buf(win)].filetype
    end)
    if ok and is_dap_ft(ft) then
      return true
    end
  end
  return false
end

-- Record the current layout as the "pre-debug" state. No-op if we already hold a
-- snapshot or dap-ui is already on screen.
function M.snapshot()
  if saved ~= nil or dapui_windows_open() then
    return
  end
  saved = vim.fn.winrestcmd()
  saved_tab = vim.api.nvim_get_current_tabpage()
  saved_wincount = #cur_tab_wins()
end

-- Replay the snapshot once dap-ui is fully gone. No-op if there is nothing to
-- restore, dap-ui panels are still open, or the window set has changed since the
-- snapshot (a split added / explorer toggled would make winrestcmd land wrong).
function M.restore()
  if saved == nil or dapui_windows_open() then
    return
  end
  local ok_tab = vim.api.nvim_tabpage_is_valid(saved_tab)
    and vim.api.nvim_get_current_tabpage() == saved_tab
  if ok_tab and #cur_tab_wins() == saved_wincount then
    pcall(vim.cmd, saved)
  end
  saved, saved_tab, saved_wincount = nil, nil, nil
end

function M.setup()
  -- 1. Drop LazyVim's "close dap-ui when the program stops" listeners, and make
  --    the auto-open a full rebuild.
  LazyVim.on_load("nvim-dap-ui", function()
    local dap = require("dap")
    dap.listeners.before.event_terminated["dapui_config"] = nil
    dap.listeners.before.event_exited["dapui_config"] = nil

    -- dap-ui is no longer closed between sessions, so a second `<leader>dm`
    -- finds the layout already open -- and WindowLayout:open() early-returns in
    -- that case, leaving the panels bound to the finished session and the REPL
    -- window scrolled away from the new run's output. Close first so open()
    -- recreates the windows against the new session. Snapshot the sizes across
    -- that close/open so the editor window doesn't drift on every run.
    dap.listeners.after.event_initialized["dapui_config"] = function()
      local dapui = require("dapui")
      local rebuilding = dapui_windows_open()
      local sizes = rebuilding and vim.fn.winrestcmd() or nil
      dapui.close()
      dapui.open()
      if sizes then
        pcall(vim.cmd, sizes)
      end
    end
  end)

  -- 2. Snapshot the layout right before dap-ui auto-opens on session start.
  --    before.* runs ahead of LazyVim's after.event_initialized open hook.
  LazyVim.on_load("nvim-dap", function()
    require("dap").listeners.before.event_initialized["win_restore"] = function()
      M.snapshot()
    end
  end)

  -- 3. When the last dap-ui window closes (any route), restore the snapshot.
  vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    callback = function(ev)
      local win = tonumber(ev.match)
      if win == nil then
        return
      end
      local ok, ft = pcall(function()
        return vim.bo[vim.api.nvim_win_get_buf(win)].filetype
      end)
      if not (ok and is_dap_ft(ft)) then
        return
      end
      -- Let the other panels of the layout finish closing first.
      vim.schedule(M.restore)
    end,
  })
end

return M
