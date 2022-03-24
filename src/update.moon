im = require "cimgui"
global = require "global"
view = require "view"
navigation = require "navigation"

default_cursor = love.mouse.getCursor()
hand_cursor = love.mouse.getSystemCursor('hand')

love.update = (dt) ->   
    im.love.Update(dt)
    im.NewFrame()

    navigation\update(dt)

    io = im.GetIO()    
    if not im.love.GetWantCaptureMouse()
        io.ConfigFlags = bit.bor(io.ConfigFlags, im.ImGuiConfigFlags_NoMouseCursorChange)
        if view.moving
            love.mouse.setCursor(hand_cursor)
        else
            love.mouse.setCursor(navigation.cursor)

    else
        io.ConfigFlags = bit.band(io.ConfigFlags, bit.bnot(im.ImGuiConfigFlags_NoMouseCursorChange))
