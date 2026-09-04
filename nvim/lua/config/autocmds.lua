-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Disable markdownlint-cli2 diagnostics without touching marksman LSP
-- diagnostics on the same buffers
do
  local lint_ok, lint = pcall(require, "lint")
  if lint_ok then
    vim.diagnostic.enable(false, { ns_id = lint.get_namespace("markdownlint-cli2") })
  end
end

-- Persist dap-ui panel and explorer sidebar sizes across sessions
do
  local win_size = require("config.win-size")

  local dapui_sidebar_fts = {
    dapui_scopes = true,
    dapui_breakpoints = true,
    dapui_stacks = true,
    dapui_watches = true,
  }
  local dapui_bottom_fts = {
    dapui_repl = true,
    dapui_console = true,
  }

  vim.api.nvim_create_autocmd("WinResized", {
    group = vim.api.nvim_create_augroup("win_size_memory", { clear = true }),
    callback = function()
      for _, win in ipairs(vim.v.event.windows) do
        if vim.api.nvim_win_is_valid(win) then
          local ok, ft = pcall(function() return vim.bo[vim.api.nvim_win_get_buf(win)].filetype end)
          ft = ok and ft or nil
          if dapui_sidebar_fts[ft] then
            win_size.save("dapui_sidebar", vim.api.nvim_win_get_width(win))
          elseif dapui_bottom_fts[ft] then
            win_size.save("dapui_bottom", vim.api.nvim_win_get_height(win))
          elseif ft == "snacks_picker_list" then
            local get_ok, pickers = pcall(function() return Snacks.picker.get({ source = "explorer" }) end)
            if get_ok and pickers then
              for _, picker in ipairs(pickers) do
                if picker.list.win.win == win then
                  win_size.save("explorer", vim.api.nvim_win_get_width(win))
                end
              end
            end
          end
        end
      end
    end,
  })
end

-- Open dashboard when last real buffer is closed
local DASHBOARD_AUGROUP = "snacks_dashboard"

local function is_dashboard_buf(b)
  return vim.api.nvim_buf_is_valid(b) and vim.bo[b].filetype == "snacks_dashboard"
end

-- Wipe a dashboard buffer *without* running snacks' own buffer-local
-- BufWipeout/BufDelete cleanup. snacks reuses a single augroup name -- and so a
-- single augroup id -- for every dashboard instance, so that cleanup would fire a
-- global SnacksDashboardClosed at whichever dashboard is currently live and delete
-- the augroup it is using; a second wipe would then hit the already-deleted id and
-- raise E367 from inside a nested callback, where pcall cannot catch it.
local function wipe_dashboard_buf(b)
  if not vim.api.nvim_buf_is_valid(b) then return end
  pcall(vim.api.nvim_clear_autocmds, { buffer = b, event = { "BufWipeout", "BufDelete" } })
  pcall(vim.api.nvim_buf_delete, b, { force = true })
end

-- Deliberately drop the shared augroup, for the paths where no dashboard is left
-- on screen and the stale global autocmds really should go away.
local function drop_dashboard_augroup()
  pcall(vim.api.nvim_del_augroup_by_name, DASHBOARD_AUGROUP)
end

-- Is any dashboard buffer still on screen, in any tabpage?
local function dashboard_is_visible()
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if is_dashboard_buf(b) and #vim.fn.win_findbuf(b) > 0 then return true end
  end
  return false
end

vim.api.nvim_create_autocmd("BufDelete", {
  callback = function(event)
    local deleted = event.buf
    -- The wipes below fire BufDelete and would re-enter this handler; the
    -- current-buffer guard further down only catches that when focus happens to
    -- sit on the dashboard.
    if is_dashboard_buf(deleted) then return end
    vim.schedule(function()
      local real_bufs = vim.tbl_filter(function(b)
        return b ~= deleted
          and vim.api.nvim_buf_is_valid(b)
          and vim.bo[b].buflisted
          and vim.fn.bufname(b) ~= ""
      end, vim.api.nvim_list_bufs())
      if #real_bufs > 0 then return end
      if vim.bo[vim.api.nvim_get_current_buf()].filetype == "snacks_dashboard" then return end

      Snacks.dashboard.open()

      -- Redirect any [No Name] window to the dashboard buffer so it doesn't linger behind
      vim.schedule(function()
        local dash_buf = nil
        local dashboards = {}
        for _, b in ipairs(vim.api.nvim_list_bufs()) do
          if is_dashboard_buf(b) then
            dashboards[#dashboards + 1] = b
            if not dash_buf and #vim.fn.win_findbuf(b) > 0 then
              dash_buf = b
            end
          end
        end

        -- Orphaned dashboard buffers (no window shows them) are left over from
        -- earlier instances. Sweep all of them -- no early `break`, or orphans
        -- with a buffer handle above the live one would never be reached. The
        -- augroup itself stays: Snacks.dashboard.open() just re-created it for
        -- the live instance, and wipe_dashboard_buf keeps snacks' own teardown
        -- (which would delete that very augroup) out of the way.
        for _, b in ipairs(dashboards) do
          if b ~= dash_buf then wipe_dashboard_buf(b) end
        end

        if not dash_buf then return end

        -- The dashboard's own window is floating (relative == "editor"), so
        -- snacks.nvim can close *it* out from under itself (e.g. running a
        -- dashboard action) without wiping the buffer or its augroup. If we
        -- also point a regular window at the same buffer below, that window
        -- keeps the buffer "alive" after the float closes, so snacks' still
        -- globally-registered WinEnter/WinResized/VimResized autocmds keep
        -- firing against a now-nil internal window handle and crash. Once
        -- the floating window itself closes, immediately tear down any
        -- leftover window(s) and wipe the buffer so that dangling augroup
        -- goes away instead of lingering as a zombie.
        local primary_win = vim.fn.win_findbuf(dash_buf)[1]
        local is_float = primary_win and vim.api.nvim_win_get_config(primary_win).relative ~= ""

        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local win_buf = vim.api.nvim_win_get_buf(win)
          if vim.fn.bufname(win_buf) == ""
            and not vim.bo[win_buf].modified
            and vim.bo[win_buf].filetype ~= "snacks_dashboard"
          then
            pcall(vim.api.nvim_win_set_buf, win, dash_buf)
          end
        end

        if is_float then
          vim.api.nvim_create_autocmd("WinClosed", {
            pattern = tostring(primary_win),
            once = true,
            callback = function()
              vim.schedule(function()
                if not vim.api.nvim_buf_is_valid(dash_buf) then return end
                for _, w in ipairs(vim.fn.win_findbuf(dash_buf)) do
                  pcall(vim.api.nvim_win_close, w, true)
                end
                wipe_dashboard_buf(dash_buf)
                -- Nothing should be left on screen here, so this path does want
                -- the shared augroup gone -- but only once nothing is actually
                -- using it, or we would strip a dashboard opened in the meantime.
                if not dashboard_is_visible() then
                  drop_dashboard_augroup()
                end
              end)
            end,
          })
        end
      end)
    end)
  end,
})

-- When a real file opens, close any dashboard window not showing that file
vim.api.nvim_create_autocmd("BufWinEnter", {
  callback = function(ev)
    local buf = ev.buf
    if vim.fn.bufname(buf) == "" or vim.bo[buf].buftype ~= "" then return end
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(buf) then return end
      local wiped = false
      -- Only this tabpage: nvim_list_wins() spans every tab, so opening a file
      -- in one tab would otherwise destroy a dashboard living in another.
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        -- Closing one window can invalidate later entries in this snapshot.
        local win_ok, win_buf = pcall(vim.api.nvim_win_get_buf, win)
        if win_ok and win_buf ~= buf then
          local ok, ft = pcall(function() return vim.bo[win_buf].filetype end)
          if ok and ft == "snacks_dashboard" then
            pcall(vim.api.nvim_win_close, win, true)
            -- If no window shows this dashboard buffer anymore, wipe it so it
            -- doesn't linger as a zombie.
            if vim.api.nvim_buf_is_valid(win_buf) and #vim.fn.win_findbuf(win_buf) == 0 then
              wipe_dashboard_buf(win_buf)
              wiped = true
            end
          end
        end
      end
      -- No dashboard opens on this path, so once the last visible one is gone
      -- its global autocmds are stale -- drop them rather than leave them armed.
      if wiped and not dashboard_is_visible() then
        drop_dashboard_augroup()
      end
    end)
  end,
})

-- Give new Java files a package declaration + class skeleton, like IntelliJ
require("config.java-new-file").setup()
