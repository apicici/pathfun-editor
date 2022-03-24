global = require "global"
im = require "cimgui"
serialization = require "serialization"
view = require "view"
settings = require "settings"
navigation = require "navigation"

love.mousepressed = (...) ->
	x, y, button = ...
	im.love.MousePressed(button)
    if im.love.GetWantCaptureMouse() then return

	if not view.moving
		navigation.mousepressed(...)

love.mousereleased = (...) ->
	x, y, button = ...
    im.love.MouseReleased(button)
    if im.love.GetWantCaptureMouse() then return

	if not view.moving
		navigation.mousereleased(...)

love.mousemoved = (...) ->
	x, y, dx, dy = ...
	im.love.MouseMoved(x, y)
	if im.love.GetWantCaptureMouse() then return

	if love.keyboard.isDown('space') and not im.love.GetWantCaptureKeyboard() and
		love.mouse.isDown(1) and not im.love.GetWantCaptureMouse()
        view\move(-dx, -dy)
    else navigation.mousemoved(...)

love.wheelmoved = (x, y) ->
    im.love.WheelMoved(x, y)
    if im.love.GetWantCaptureMouse() then return
	
    view\zoom(y, love.mouse.getPosition())

love.keypressed = (...) ->
	key = ...
    if global.error and key == "return"
        global.error = nil
        return
    im.love.KeyPressed(key)
    if im.love.GetWantCaptureKeyboard() then return

	if view.moving then return
	switch key
		when "space"
			view.moving = true
			navigation.reset_input()
        when "s", "lctrl", "rctrl"
        	if love.keyboard.isDown("s") and love.keyboard.isDown("lctrl", "rctrl")
        		serialization.save() 
        	else
        		navigation.keypressed(...)
        when "q", "lctrl", "rctrl"
        	if love.keyboard.isDown("q") and love.keyboard.isDown("lctrl", "rctrl")
        		love.event.quit()
        	else
        		navigation.keypressed(...)
        else
        	navigation.keypressed(...)

love.keyreleased = (key) ->
    im.love.KeyReleased(key)
    if im.love.GetWantCaptureKeyboard() then return

	if key == "space"
		view.moving = false
	
love.textinput = (t) ->
    im.love.TextInput(t)
    if im.love.GetWantCaptureKeyboard() then return

love.filedropped = (file) ->
    serialization.filedropped(file)

love.resize = (...) ->
    settings\resize(...)