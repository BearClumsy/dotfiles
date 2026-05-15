local _active = false

local get_ctx = ya.sync(function()
	local cwd = tostring(cx.active.current.cwd)
	local yanked = {}
	for _, u in pairs(cx.yanked) do
		yanked[#yanked + 1] = tostring(u)
	end
	return { cwd = cwd, yanked = yanked }
end)

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
			local target = ctx.cwd .. "/" .. name
			local ok, _, code = os.rename(target, target)
			if ok or code == 13 then
				conflicts[#conflicts + 1] = name
			end
		end

		if #conflicts == 0 then
			ya.emit("paste", args)
			_active = false
			return
		end

		local value, event = ya.input {
			title = "Replace " .. #conflicts .. " item(s): " .. table.concat(conflicts, ", ") .. " — type y to confirm",
			value = "",
			pos = { "center", w = 70 },
		}

		if event == 1 and (value == "y" or value == "Y") then
			ya.emit("paste", { force = true })
		end

		_active = false
	end,
}
