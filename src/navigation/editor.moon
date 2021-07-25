path = (...)\gsub("[^%.]*$", "")

global = require "global"
im = require "cimgui"
M = require "pathfun.master"
view = require "view"

import Polygons, PolygonToAdd from require path .. "polygons"
import Set from M
import round from M.math


M = {}

poly2add = PolygonToAdd()
M.poly2add = poly2add
moving = false

M.update = ->
    if im.GetWantCaptureMouse()
        moving = false
        global.pmap.hover = {} if global.pmap

M.draw = ->
    view\set()
    for pmap in *global.pmaps
        if pmap ~= global.pmap and not pmap.hidden
            pmap\draw()
    global.pmap\draw(true) if global.pmap and not global.pmap.hidden
    poly2add\draw()
    view\unset()

M.mousemoved = (x, y) ->
    if not global.pmap then return
    pmap = global.pmap
    X, Y = view\get_coordinates(x, y)
    if not pmap.hidden and moving
        x, y = round(X), round(Y)
        if pmap.hover.vertex
            pmap.hover.vertex = pmap\move_vertex(pmap.hover.polygon, pmap.hover.vertex, x, y)
            global.changed = true
    else
        poly2add\hover_update(X, Y)
        if poly2add\len() == 0
            pmap\hover_update(X, Y)

M.keypressed = (key) ->
    switch key
        when 'm'
            poly2add\toggle_mode()
        when 'r'
            if global.pmap and not moving
                global.pmap\refresh()
                global.changed = true
                M.mousemoved(love.mouse.getPosition())
        when 's'
            if global.pmap and not moving
                global.pmap\clean() 
                global.changed = true
                M.mousemoved(love.mouse.getPosition())

M.mousepressed = (x, y, button) ->
    if not global.pmap then return
    pmap = global.pmap
    X, Y = view\get_coordinates(x, y)
    switch button
        when 1
            if poly2add.hover
                -- close polygons
                global.changed = true
                pmap\add(poly2add)
                poly2add\clear()
                pmap\hover_update(X, Y)
            elseif pmap.hover.vertex
                moving = true
            elseif pmap.hover.edge
                x, y = round(X), round(Y)
                pmap\add_vertex(pmap.hover.polygon, pmap.hover.edge, x, y)
                if poly2add\len() == 0
                    pmap\hover_update(x, y)
                moving = true
                global.changed = true
            else
                poly2add\add(round(X), round(Y))
        when 2
            if poly2add\len() > 0
                poly2add\remove()
                M.mousemoved(x, y)
            elseif pmap.hover.vertex and not moving
                pmap\remove_vertex(pmap.hover.polygon, pmap.hover.vertex)
                M.mousemoved(x, y)
                global.changed = true

M.mousereleased = (x, y, button) ->
    switch button
        when 1
            moving = false

M.clear = ->
    global.pmap\refresh() if global.pmap
    poly2add\clear()
    moving = false

M.reset_input = ->
    moving = false
    global.pmap.hover = {} if global.pmap

M.remove_pmap = (idx) ->
    table.remove(global.pmaps, idx)

M.new_pmap = ->
    pmap = Polygons()
    global.pmaps[#global.pmaps + 1] = pmap
    return pmap

return M