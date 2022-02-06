serpent = require "serialization.serpent"

M = {}

chunk, errormsg = love.filesystem.load("config.lua")
M.t = not errormsg and chunk() or {}

recent = M.t.recent or {}
M.t.recent = [recent[i] for i = 1, math.min(#recent, 10)]

width, height = if window = M.t.window
	window.w, window.h
else
	800, 600

M.t.scale = type(M.t.scale) == "number" and math.floor(M.t.scale) or 1

flags = {
	resizable: true
}

love.window.setMode(width, height, flags)
love.window.setTitle("pathfun editor")

M.save = =>
	data = "return " .. serpent.block(@t, {comment:false})
	love.filesystem.write("config.lua", data)

M.add_filename = (filename) =>
	for i, entry in ipairs(@t.recent)
		if filename == entry
			table.remove(@t.recent, i)
			break
	table.insert(@t.recent, 1, filename)
	@t.recent[11] = nil
	@save()

M.clear_history = =>
	@t.recent = {}
	@save()

M.resize = (w, h) =>
	@t.window = {:w, :h, fullscreen:{love.window.getFullscreen()}}
	@save()

M.scale = (scale) =>
	@t.scale = scale
	@save()
	
return M
