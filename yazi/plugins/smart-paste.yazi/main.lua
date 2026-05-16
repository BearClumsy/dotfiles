local _active = false

local get_ctx = ya.sync(function()
	local cwd = tostring(cx.active.current.cwd)
	local yanked = {}
	for _, u in pairs(cx.yanked) do
		yanked[#yanked + 1] = tostring(u)
	end
	return { cwd = cwd, yanked = yanked }
end)

local function path_exists(path)
	local ok, _, code = os.rename(path, path)
	-- ok       → exists and accessible
	-- 13 EACCES  → exists, no write permission
	-- 17 EEXIST  → exists
	-- 66 ENOTEMPTY → exists and is a non-empty directory (macOS APFS)
	return ok or code == 13 or code == 17 or code == 66
end

local function split_name(name)
	-- don't treat dotfiles like .gitignore as having an extension
	if name:sub(1, 1) == "." and not name:find(".", 2, true) then
		return name, ""
	end
	local base, ext = name:match("^(.+)(%.[^.]+)$")
	return base or name, ext or ""
end

local function unique_copy_name(dir, name)
	local base, ext = split_name(name)
	local candidate = base .. " copy" .. ext
	if not path_exists(dir .. "/" .. candidate) then
		return candidate
	end
	local i = 2
	while true do
		candidate = base .. " copy " .. i .. ext
		if not path_exists(dir .. "/" .. candidate) then
			return candidate
		end
		i = i + 1
	end
end

return {
	entry = function(_, args)
		if _active then return end
		_active = true

		local ctx = get_ctx()
		if #ctx.yanked == 0 then
			_active = false
			return
		end

		local conflicts = {}
		for _, url_str in ipairs(ctx.yanked) do
			local name = url_str:match("([^/]+)/?$") or url_str
			if path_exists(ctx.cwd .. "/" .. name) then
				conflicts[#conflicts + 1] = { name = name, src = url_str }
			end
		end

		if #conflicts == 0 then
			ya.emit("paste", args)
			_active = false
			return
		end

		local conflict_names = {}
		for _, c in ipairs(conflicts) do
			conflict_names[#conflict_names + 1] = c.name
		end

		local value, event = ya.input {
			title = #conflicts
				.. " conflict(s): "
				.. table.concat(conflict_names, ", ")
				.. " — (r)eplace / (c)opy / (s)kip",
			value = "",
			pos = { "center", w = 70 },
		}

		if event == 1 then
			if value == "r" or value == "R" then
				-- chmod -R +w destination before replacing so read-only files
				-- (e.g. git pack objects inside tmux plugins) can be overwritten
				for _, c in ipairs(conflicts) do
					local dest = ctx.cwd .. "/" .. c.name
					Command("chmod"):arg({ "-R", "+w", dest }):output()
				end
				ya.emit("paste", { force = true })
			elseif value == "c" or value == "C" then
				for _, c in ipairs(conflicts) do
					local new_name = unique_copy_name(ctx.cwd, c.name)
					local dest = ctx.cwd .. "/" .. new_name
					Command("cp"):arg({ "-r", c.src, dest }):output()
				end
				-- paste any non-conflicting yanked items normally
				if #ctx.yanked > #conflicts then
					ya.emit("paste", args)
				end
			end
			-- 's' or anything else = skip
		end

		_active = false
	end,
}
