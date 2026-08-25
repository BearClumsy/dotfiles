-- Fills a freshly created Java buffer with its `package` declaration and a type
-- skeleton, the way IntelliJ's "New Java Class" does.
--
-- Nothing in the stack does this on its own: LazyVim has no file templates, and
-- jdtls only offers a quick fix for a package declaration that is already
-- present and wrong -- never for a file that has none.
local M = {}

-- Source-root layouts, most specific first. Lua patterns are greedy, so the
-- leading `.*` makes the LAST occurrence win -- the right choice in multi-module
-- repos where a path can contain `src/main/java` more than once.
--
-- Matched against the directory with a trailing slash appended, so the capture is
-- empty exactly when the file sits in the source root itself (the default
-- package). Anchoring the root on a trailing `/` also keeps a package directory
-- that happens to be named `java` or `src` from being mistaken for the root.
local SOURCE_ROOTS = {
  "^.*/src/[^/]+/java/(.*)$", -- src/main/java, src/test/java, Gradle source sets
  "^.*/src/[^/]+/kotlin/(.*)$", -- mixed projects that keep .java under kotlin/
  "^.*/src/java/(.*)$", -- older Ant-style layout
  "^.*/java/(.*)$", -- generated roots, Bazel-style java/com/...
  "^.*/src/(.*)$", -- legacy layout with src as the source root
}

-- First segment of a Gradle/Maven layout we failed to parse (e.g. src/main/scala).
-- Guessing a package from it would produce something like `main.scala`.
local SOURCE_SET_DIRS = { main = true, test = true, resources = true }

local function is_identifier(s)
  return s:match("^[%a_$][%w_$]*$") ~= nil
end

--- Resolve the Java package for a file path.
---@param path string
---@return string|nil # dotted package, or nil for the default package / an unknown layout
function M.package_for(path)
  local dir = vim.fs.normalize(vim.fn.fnamemodify(path, ":p:h")) .. "/"

  for _, pattern in ipairs(SOURCE_ROOTS) do
    local rel = dir:match(pattern)
    if rel then
      rel = rel:gsub("/$", "")
      if rel == "" then
        return nil
      end
      local segments = vim.split(rel, "/", { plain = true })
      if SOURCE_SET_DIRS[segments[1]] then
        return nil
      end
      -- A directory like `my-module` can't be a package segment; emitting
      -- nothing beats emitting a package line that won't compile.
      for _, segment in ipairs(segments) do
        if not is_identifier(segment) then
          return nil
        end
      end
      return table.concat(segments, ".")
    end
  end

  return nil
end

-- Files whose name is not a type name: `public class package-info` is illegal,
-- and module-info.java carries a `module` declaration instead of a class.
local INFO_FILES = { ["package-info"] = true, ["module-info"] = true }

local function body_indent(buf)
  if not vim.bo[buf].expandtab then
    return "\t"
  end
  local width = vim.bo[buf].shiftwidth
  if width == 0 then
    width = vim.bo[buf].tabstop
  end
  return string.rep(" ", width)
end

--- Write the package declaration and class skeleton into an empty Java buffer.
---@param buf integer
function M.fill(buf)
  local path = vim.api.nvim_buf_get_name(buf)
  if path == "" then
    return
  end

  local name = vim.fn.fnamemodify(path, ":t:r")
  local package = M.package_for(path)

  local lines = {}
  if package then
    lines[#lines + 1] = "package " .. package .. ";"
  end

  local body_line
  if not INFO_FILES[name] and is_identifier(name) then
    if #lines > 0 then
      lines[#lines + 1] = ""
    end
    lines[#lines + 1] = "public class " .. name .. " {"
    lines[#lines + 1] = body_indent(buf)
    body_line = #lines
    lines[#lines + 1] = "}"
  end

  if #lines == 0 then
    return
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Neovim clears 'modified' once the BufNewFile/BufReadPost autocmds are done,
  -- treating whatever they wrote as part of loading the file. Without this the
  -- template would be dropped by a plain `:q` with no prompt. Nothing is written
  -- to disk, so `u` still gets the empty file back and `:q!` throws it away.
  vim.bo[buf].modified = true

  -- Land inside the class body, like IntelliJ does. `startinsert!` jumps to the
  -- end of the line before entering insert, which is the only way to sit AFTER
  -- the indent -- normal mode clamps the cursor back onto the last space, so
  -- typing there would lose a column and leave a trailing one behind.
  if body_line and vim.api.nvim_get_current_buf() == buf then
    pcall(vim.api.nvim_win_set_cursor, 0, { body_line, 0 })
    vim.cmd("startinsert!")
  end
end

function M.setup()
  -- Snacks explorer's "add file" writes a zero-byte file to disk, so opening it
  -- fires BufReadPost, not BufNewFile. Both events run the same emptiness check,
  -- which also makes re-opening a file that already has content a no-op.
  vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
    group = vim.api.nvim_create_augroup("java_new_file", { clear = true }),
    pattern = "*.java",
    callback = function(ev)
      local buf = ev.buf
      if vim.bo[buf].buftype ~= "" or not vim.bo[buf].modifiable or vim.bo[buf].readonly then
        return
      end
      if vim.api.nvim_buf_line_count(buf) ~= 1 then
        return
      end
      if vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] ~= "" then
        return
      end
      M.fill(buf)
    end,
  })
end

return M
