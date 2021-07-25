path = (...)\gsub("[^%.]*$", "")

view = require "view"
pf = require "pathfun"
PFM = require "pathfun.master"
colours = require path .. "colours"
global = require "global"


import Vec2 from PFM

M = {}

nav = pf.Navigation()
path = {}
local current_poly

local source, target

draw_nav = ->
    love.graphics.setColor(colours.contour)
    for p in *nav.polygons
        if p.hidden then continue
        for i = 1, p.n
            if not p.connections[i] or p.connections[i].polygon.hidden
                A, B = p\get_edge(i)
                love.graphics.line(A.x, A.y, B.x, B.y)
    love.graphics.setColor(1,1,1)

M.draw = () ->
    view\set()
    for pmap in *global.pmaps
        pmap.decomposition\draw(true) if not pmap.hidden
    draw_nav()
    for i = 1, #path - 1
        A, B = path[i], path[i + 1]
        love.graphics.line(A.x, A.y, B.x, B.y)
    if target
        love.graphics.circle("fill", target.x, target.y, 2)
    if source
        love.graphics.circle("fill", source.x, source.y, 2)
    view\unset()
    love.graphics.setColor(1,1,1)

M.mousemoved = (x, y) ->
    target = Vec2(view\get_coordinates(x, y))
    if not source
        target = nav\_is_point_inside(target) and target or nav\_closest_boundary_point(target)
        return
    target = current_poly\is_point_inside_connected(target) and
        target or current_poly\closest_boundary_point_connected(target)
    if source and target
        path = nav\_shortest_path(source, target)


M.mousepressed = (x, y, button) ->
    X, Y = view\get_coordinates(x, y)
    switch button
        when 2
            source = Vec2(X, Y)
            current_poly = nav\_is_point_inside(source)
            if not current_poly
                source, current_poly = nav\_closest_boundary_point(source)
            path = {}
            target = nil

M.keypressed = (key) ->

M.mousereleased = -> nil

M.set_visibility = (name, bool) ->
    for p in *(nav.name_groups[name] or {})
        p.hidden = not bool
    source, target = nil
    path = {}

M.clear = ->
    nav = pf.Navigation([pmap.decomposition.items for pmap in *global.pmaps])
    for pmap in *global.pmaps
        if name = pmap.name
            M.set_visibility(name, not pmap.hidden)
    nav\initialize()
    source, target = nil
    path = {}

return M