-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Open dashboard when last real buffer is closed
vim.api.nvim_create_autocmd("BufDelete", {
  callback = function(event)
    local deleted = event.buf
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
        for _, b in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_valid(b) and vim.bo[b].filetype == "snacks_dashboard" then
            dash_buf = b
            break
          end
        end
        if not dash_buf then return end
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local win_buf = vim.api.nvim_win_get_buf(win)
          if vim.fn.bufname(win_buf) == ""
            and not vim.bo[win_buf].modified
            and vim.bo[win_buf].filetype ~= "snacks_dashboard"
          then
            pcall(vim.api.nvim_win_set_buf, win, dash_buf)
          end
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
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local win_buf = vim.api.nvim_win_get_buf(win)
        if win_buf ~= buf then
          local ok, ft = pcall(function() return vim.bo[win_buf].filetype end)
          if ok and ft == "snacks_dashboard" then
            pcall(vim.api.nvim_win_close, win, true)
          end
        end
      end
    end)
  end,
})
