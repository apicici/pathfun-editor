PFM = require 'pathfun.master'

import round from PFM.math

view = {}
view.transform = love.math.newTransform()
view.scale = 1
view.x = 0
view.y = 0

view.update = =>
	tr = @transform
	tr\reset()
	tr\translate(@x, @y)
	tr\scale(@scale)

view.reset = =>
	@scale = 1
	@x = 0
	@y = 0
	@transform\reset()

view.zoom = (step, x, y) =>
	--increase/decrease zoom by step (should be integer)
	if step == 0 or view.scale + step <= 0
		return
	s = @scale
	@scale += step
	@x = round(((s + step)*@x - step*x)/s)
	@y = round(((s + step)*@y - step*y)/s)
	@update()

view.move = (dx, dy) =>
	@x += round(-dx)
	@y += round(-dy)
	@update()


view.get_coordinates = (x, y) =>
	return @transform\inverseTransformPoint(x, y)

view.set = =>
	love.graphics.push()
	love.graphics.applyTransform(@transform)

view.unset = =>
	love.graphics.pop()

return view