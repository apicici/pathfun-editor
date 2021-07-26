path = (...)\gsub("[^%.]*$", "")

clipper = require "clipper"
pp = require path .. "polypartition"
colours = require path .. "colours"
M = require "pathfun.master"

cl = clipper.Clipper(clipper.ioPreserveCollinear)
tree = clipper.PolyTree()

import Vec2, CyclicList from M
import clamp from M.math
import dot from Vec2

EPSILON = 10

local *

PolygonToAdd = M.class {
    __init: =>
        @clear()
        @subtract = false

    add: (x, y) =>
        @vertices[#@vertices + 1] = Vec2(x, y)

    remove: =>
        @vertices[#@vertices] = nil

    clear: =>
        @vertices = {}
        @hover = false

    hover_update: (x,y, epsilon=EPSILON) =>
        @hover = #@vertices > 1 and (Vec2(x, y) - @vertices[1])\lenS() < epsilon

    hover_reset: => @hover = false

    toggle_mode: => @subtract = not @subtract 

    len: => #@vertices

    draw: =>
        love.graphics.setColor(@subtract and colours.hole or colours.contour)
        for i = 1, #@vertices - 1
            A, B = @vertices[i], @vertices[i + 1]
            love.graphics.line(A.x, A.y, B.x, B.y)
        for v in *@vertices
            love.graphics.circle('fill', v.x, v.y, 2)
        if @hover and #@vertices > 0
            A, B = @vertices[#@vertices], @vertices[1]
            love.graphics.line(A.x, A.y, B.x, B.y)
            love.graphics.circle('line', B.x, B.y, 5)
        love.graphics.setColor(1,1,1)
}

Polygon = M.class {
    __init: (path) =>
        @n = path\size()
        vertices = [path[i - 1] for i = 1, @n]
        @vertices = CyclicList([Vec2(tonumber(v.X), tonumber(v.Y)) for v in *vertices])

    draw: (hover={}, active)=>
        line_color = active and (@parent and colours.hole or colours.contour) or colours.inactive

        for i = 1, @n
            A, B = @vertices[i], @vertices[i + 1]
            love.graphics.setColor(hover.edge == i and colours.highlight or line_color)
            love.graphics.line(A.x, A.y, B.x, B.y)
            love.graphics.setColor(line_color)

    
        for i = 1, @n
            v =  @vertices[i]
            love.graphics.circle('fill', v.x, v.y, 2)
            if i == hover.vertex
                love.graphics.circle('line', v.x, v.y, 5)
        love.graphics.setColor(1,1,1)

    distS_from_edge: (P, i) =>
        A, B = @vertices[i], @vertices[i + 1]
        u = B - A
        t = clamp(dot(P - A, u)/u\lenS(), 0, 1)
        C = A + t*u
        return (P - C)\lenS()
}

Polygons = M.class {
    __init: (vertices_table={}) =>
        paths = {}
        for vertices in *vertices_table
            path = clipper.Path(#vertices)
            path[i - 1] = clipper.IntPoint(unpack(v)) for  i, v in ipairs(vertices)
            paths[#paths + 1] = path
        @paths = paths
        @polygons = [Polygon(path) for path in *paths]
        @hover = {}
        @update_decomposition()
        @refresh()
        @name = vertices_table.name

    export: =>
        polys = {name:@name}
        for path in *@paths
            vertices = {}
            for i = 1, path\size()
                v = path[i - 1]
                vertices[i] = {tonumber(v.X), tonumber(v.Y)}
            polys[#polys + 1] = vertices

        return polys

    set_name: (name) =>
        @name = name

    add: (poly2add) =>
        path = clipper.Path(#poly2add.vertices)
        path[i - 1] = clipper.IntPoint(v.x, v.y) for i, v in ipairs(poly2add.vertices)
        if not clipper.Orientation(path) then clipper.ReversePath(path)
        clipper.CleanPolygon(path)
        new_paths = clipper.Paths()
        clipper.SimplifyPolygon(path, new_paths)

        if new_paths\size() == 0
            return

        cl\Clear()
        tree\Clear()
        for p in *@paths
            cl\AddPath(p, clipper.ptSubject, true)
        cl\AddPaths(new_paths, clipper.ptClip, true)
        cl\Execute(poly2add.subtract and clipper.ctDifference or clipper.ctUnion, tree)
        @update_all()

    refresh: =>
        cl\Clear()
        tree\Clear()
        for p in *@paths
            cl\AddPath(p, clipper.ptSubject, true)
        cl\Execute(clipper.ctUnion, tree)
        @update_all()

    process_tree: =>
        node = tree\GetFirst()
        parent_idx = {}

        while node ~= nil
            path = clipper.Path(node.Contour)
            poly = Polygon(path)
            @paths[#@paths + 1] = path
            @polygons[#@polygons + 1] = poly
            if node\IsHole()
                poly.parent = parent_idx[tostring(node.Parent)]
            else
                parent_idx[tostring(node)] = #@paths
            
            node = node\GetNext()

    update_all: () =>
        @paths = {}
        @polygons = {}
        @process_tree()
        @update_decomposition()

    update_polygon: (idx) =>
        poly = Polygon(@paths[idx])
        poly.parent = @polygons[idx].parent
        @polygons[idx] = poly

    update_decomposition: =>
        @decomposition = ConvexDecomposition(@polygons, @name)


    hover_update: (x, y, epsilon=EPSILON) =>
        P = Vec2(x, y)
        for i, p in ipairs(@polygons)
            for j, v in ipairs(p.vertices.items)
                if (v - P)\lenS() <= epsilon
                    @hover = {polygon:i, vertex:j}
                    return

        for i, p in ipairs(@polygons)
            for j = 1, p.n
                if p\distS_from_edge(P, j) <= epsilon
                    @hover = {polygon:i, edge:j}
                    return

        @hover = {}

    hover_reset: => @hover = {}
    
    move_vertex: (polygon_idx, vertex_idx, x, y) =>
        if polygon_idx > @len()
            return
        parent = @polygons[polygon_idx].parent
        is_hole = parent and true or false
        path = @paths[polygon_idx]
        path[vertex_idx - 1] = clipper.IntPoint(x, y)
        if (is_hole and clipper.Orientation(path)) or (not is_hole and not clipper.Orientation(path))
            clipper.ReversePath(path)
            vertex_idx = path\size() - vertex_idx + 1
        @update_polygon(polygon_idx)
        @update_decomposition()
        return vertex_idx

    remove_vertex: (polygon_idx, vertex_idx) =>
        if polygon_idx > @len()
            return
        vertices = @polygons[polygon_idx].vertices.items
        path = clipper.Path(#vertices - 1)
        counter = 0
        for i, v in ipairs(vertices)
            if i ~= vertex_idx
                path[counter] = clipper.IntPoint(v.x, v.y)
                counter += 1
        @paths[polygon_idx] = path
        @update_polygon(polygon_idx)
        @update_decomposition()

    add_vertex: (polygon_idx, edge_idx, x, y) =>
        if polygon_idx > @len()
            return
        vertices = @polygons[polygon_idx].vertices.items
        path = clipper.Path(#vertices + 1)
        counter = 0
        for i, v in ipairs(vertices)
            path[counter] = clipper.IntPoint(v.x, v.y)
            counter += 1
            if i == edge_idx
                path[counter] = clipper.IntPoint(x, y)
                counter += 1
        @paths[polygon_idx] = path
        @update_polygon(polygon_idx)

    clean: =>
        for p in *@paths
            clipper.CleanPolygon(p)
        @refresh()

    len: => #@paths

    draw: (active) =>
        @decomposition\draw(active)
        for i, p in ipairs(@polygons)
            p\draw(@hover.polygon == i and @hover or {}, active)

    union: (...) ->
        paths = {}
        for polys in *{...}
            for path in *polys.paths
                paths[#paths + 1] = path
        polys = Polygons()
        polys.paths = paths
        polys\clean()
        return polys
}

ConvexDecomposition = M.class {
    __init: (polygons={}, name) =>
        polylists = {}
        parents = {}
        i = 0
        for p in *polygons
            if p.n == 0 then continue
            i += 1
            poly = pp.TPPLPoly(p.n)
            poly[j] = v for j, v in ipairs(p.vertices.items)
            if idx = p.parent
                poly\setHole(true)
                list = polylists[parents[idx]]
                list[#list + 1] = poly
            else
                polylists[#polylists + 1] = {poly}
                parents[i] = #polylists

        items = {name:name}
        for i = 1, #polylists
            decomposition = pp.list_to_lua(pp.convexPartition_HM(polylists[i]))
            items[#items + 1] = poly for poly in *decomposition
        @items = items

    draw: (active) =>
        r, g, b = unpack(active and colours.contour or colours.inactive)
        a = 0.2
        love.graphics.setColor(r, g, b, a)
        for p in *@items
            vertices = {}
            for i = 1, #p
                v = p[i]
                vertices[#vertices + 1] = v[1]
                vertices[#vertices + 1] = v[2]
            if #vertices > 5
                love.graphics.polygon('fill', vertices)
        love.graphics.setColor(1,1,1)
}


return {
    PolygonToAdd: PolygonToAdd
    Polygons: Polygons
}
