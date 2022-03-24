--The following code is based on Ivan Fratric's PolyPartition library.

--Original work Copyright (C) 2011 by Ivan Fratric

--Permission is hereby granted, free of charge, to any person obtaining a copy
--of this software and associated documentation files (the "Software"), to deal
--in the Software without restriction, including without limitation the rights
--to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--copies of the Software, and to permit persons to whom the Software is
--furnished to do so, subject to the following conditions:

--The above copyright notice and this permission notice shall be included in
--all copies or substantial portions of the Software.

--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
--THE SOFTWARE.

TPPL_CCW = 1
TPPL_CW = -1

Vec2 = require "pathfun.steelpan.vectors"
Class = require "pathfun.steelpan.class"

TPPLPoly = Class {
    __init: =>
        @clear()

    clear: =>
        @points = {}
        @hole = false

    init: (numpoints) =>
        @clear()
        @points = [Vec2() for i = 1, numpoints]

    triangle: (p1, p2, p3) =>
        @clear()
        @points = {p1, p2, p3}

    getOrientation: =>
        area = 0
        numpoints = #@points
        for i = 1, #numpoints
            j = i == numpoints and 1 or i + 1
            area += @points[i].x*@points[j].y - @points[i].y*@points[j].x
        if area > 0
            return TPPL_CCW
        elseif area < 0
            return TPPL_CW
        else return 0

    setOrientation: (orientation) =>
        if @getOrientation() ~= orientation
            @invert()

    invert: =>
        n = #@points
        for i = 1, math.floor(n/2)
            @points[i], @points[n - i + 1] = @points[n - i + 1], @points[i]

    setHole: (flag) =>
        @hole = flag

    getNumPoints: =>
        return #@points

    isHole: =>
        return @hole

    __index: (key) =>
        return @points[key]

    __newindex: (key, value) =>
        if type(key) == "number"
            @points[key] = value
        else 
            rawset(self, key, value)

    valid: =>
        return #@points > 0
}

normalize = (p) ->
    norm = p\len()
    return norm ~= 0 and p/norm or Vec2()

isConvex = (p1, p2, p3) ->
    tmp = (p3.y - p1.y)*(p2.x - p1.x) - (p3.x - p1.x)*(p2.y - p1.y)
    return  tmp > 0

isReflex = (p1, p2, p3) ->
    tmp = (p3.y - p1.y)*(p2.x - p1.x) - (p3.x - p1.x)*(p2.y - p1.y)
    return tmp < 0

inCone = (p1, p2, p3, p) ->
    if isConvex(p1, p2, p3)
        return isConvex(p1,p2,p) and isConvex(p2,p3,p)
    else
        return isConvex(p1,p2,p) or isConvex(p2,p3,p)

intersects = (p11, p12, p21, p22) ->
    if p11 == p21 or p11 == p22 or p12 == p21 or p12 == p22
        return false

    v1ort = Vec2(p12.y - p11.y, p11.x - p12.x)
    v2ort = Vec2(p22.y - p21.y, p21.x - p22.x)
    
    dot21 = Vec2.dot(p21 - p11, v1ort)
    dot22 = Vec2.dot(p22 - p11, v1ort)

    dot11 = Vec2.dot(p11 - p21, v2ort)
    dot12 = Vec2.dot(p12 - p21, v2ort)

    return dot11*dot12 <= 0 and dot21*dot22 <= 0

removeHoles = (polys) ->
    --check for trivial case (no holes)
    hasholes = false
    for p in *polys
        if p.hole
            hasholes = true
            break
    if not hasholes
        return polys

    local holepoly, holepointindex, bestpolypoint
    local polypointindex, poly

    while true
        --find the hole point with the largest x
        hasholes = false
        for p in *polys
            if not p.hole or p.skip
                continue

            if not hasholes
                hasholes = true
                holepoly = p
                holepointindex = 1

            for i = 1, p\getNumPoints()
                if p[i].x > holepoly[holepointindex].x
                    holepoly = p
                    holepointindex = i

        if not hasholes
            break
        holepoint = holepoly[holepointindex]

        pointfound = false
        for p in *polys
            if p.hole or p.skip
                continue
            n = p\getNumPoints()
            for i = 1, n
                if p[i].x <= holepoint.x
                    continue
                if not inCone(p[i > 1 and i - 1 or n],
                              p[i],
                              p[i < n and i + 1 or 1],
                              holepoint)
                    continue
                polypoint = p[i]
                if pointfound
                    v1 = normalize(polypoint - holepoint)
                    v2 = normalize(bestpolypoint - holepoint)
                    if v2.x > v1.x
                        continue
                pointvisible = true
                for p2 in *polys
                    if p2.hole
                        continue
                    m = p2\getNumPoints()
                    for j = 1, m
                        linep1 = p2[j]
                        linep2 = p2[j < m and j + 1 or 1]
                        if intersects(holepoint, polypoint, linep1, linep2)
                            pointvisible = false
                            break
                    if not pointvisible
                        break
                if pointvisible
                    pointfound = true
                    bestpolypoint = polypoint
                    poly = p
                    polypointindex = i

        if not pointfound
            return false

        newpoly = TPPLPoly()
        newpoly\init(holepoly\getNumPoints() + poly\getNumPoints() + 2)

        n = 1
        for i = 1, polypointindex
            newpoly[n] = poly[i]
            n += 1

        holesize = holepoly\getNumPoints()
        for i = 0, holesize
            k = holepointindex + i
            k = k > holesize and k - holesize or k
            newpoly[n] = holepoly[k]
            n += 1

        for i = polypointindex, poly\getNumPoints()
            newpoly[n] = poly[i]
            n += 1

        polys[#polys + 1] = newpoly
        holepoly.skip = true
        poly.skip = true

    outpolys = {}
    for p in *polys
        if not p.skip
            outpolys[#outpolys + 1] = p
    return outpolys

isInside = (p1, p2, p3, p) ->
    if isConvex(p1, p, p2) then return false
    if isConvex(p2, p, p3) then return false
    if isConvex(p3, p, p1) then return false
    return true

updateVertex = (v, vertices) ->
    v1, v3 = v.previous, v.next
    v.isConvex = isConvex(v1.p, v.p, v3.p)

    vec1 = normalize(v1.p - v.p)
    vec3 = normalize(v3.p - v.p)
    v.angle = Vec2.dot(vec1, vec3)

    if v.isConvex
        v.isEar = true
        for i = 1, #vertices
            w = vertices[i]
            if w.p == v.p or w.p == v1.p or w.p == v3.p
                continue
            if isInside(v1.p, v.p, v3.p, w.p)
                v.isEar = false
                break
    else
        v.isEar = false

triangulate_EC = (tbl) ->
    if not tbl.__class
        polys = removeHoles(tbl)
        result = {}

        if not polys then return nil

        for poly in *polys
            triangles = triangulate_EC(poly)
            if not triangles then return nil
            for triangle in *triangles
                result[#result + 1] = triangle

        return result
    else
        poly = tbl
        numvertices = poly\getNumPoints()

        if not poly\valid() or numvertices < 3
            return nil

        if numvertices == 3
            return {poly}

        vertices = [{} for i = 1, numvertices]
        for i = 1, numvertices
            v = vertices[i]
            v.isActive = true
            v.p = poly[i]
            v.next = vertices[i == numvertices and 1 or i + 1]
            v.previous = vertices[i == 1 and numvertices or i - 1]
        for i = 1, numvertices
            updateVertex(vertices[i], vertices)

        local ear
        triangles = {}

        for i = 1, numvertices - 3
            earfound = false
            --find the most extruded ear
            for j = 1, numvertices
                v = vertices[j]
                if not v.isActive then continue
                if not v.isEar then continue
                if not earfound
                    earfound = true
                    ear = v
                elseif v.angle > ear.angle
                    ear = v
            
            if not earfound
                return nil

            triangle = TPPLPoly()
            triangle\triangle(ear.previous.p, ear.p, ear.next.p)
            triangles[#triangles + 1] = triangle

            ear.isActive = false
            ear.previous.next = ear.next
            ear.next.previous = ear.previous

            if i == numvertices - 3
                break

            updateVertex(ear.previous, vertices)
            updateVertex(ear.next, vertices)

        for i = 1, numvertices
            v = vertices[i]
            if v.isActive
                triangle = TPPLPoly()
                triangle\triangle(v.previous.p, v.p, v.next.p)
                triangles[#triangles + 1] = triangle
                break

        return triangles

convexPartition_HM = (tbl) ->
    if not tbl.__class
        polys = removeHoles(tbl)
        result = {}

        if not polys then return nil

        for poly in *polys
            parts = convexPartition_HM(poly)
            if not parts then return nil
            for part in *parts
                result[#result + 1] = part

        return result
    else
        poly = tbl
        if not poly\valid() then return nil

        parts = {}

        numreflex = 0
        numvertices = poly\getNumPoints()

        for i11 = 1, numvertices
            i12 = i11 == 1 and numvertices or i11 - 1
            i13 = i11 == numvertices and 1 or i11 + 1
            if isReflex(poly[i12], poly[i11], poly[i13])
                numreflex = 1
                break

        if numreflex == 0
            return {poly}

        triangles = triangulate_EC(poly)
        if not triangles then return nil

        local poly1, num1, poly2, num2
        local i11, i12, i21, i22
        for idx1 = 1, #triangles
            poly1 = triangles[idx1]
            if poly1.skip then continue
            num1 = poly1\getNumPoints()
            i11 = 0
            while i11 < num1
                i11 += 1
                d1 = poly1[i11]
                i12 = i11 == num1 and 1 or i11 + 1
                d2 = poly1[i12]

                isdiagonal = false
                for p in *triangles
                    if p.skip or p == poly1 then continue
                    poly2 = p
                    num2 = poly2\getNumPoints()
                    for i = 1, num2
                        i21 = i
                        if d2 ~= poly2[i21] then continue
                        i22 = i21 == num2 and 1 or i21 + 1
                        if d1 ~= poly2[i22] then continue
                        isdiagonal = true
                        break

                    if isdiagonal then break

                if not isdiagonal then continue

                p2 = poly1[i11]
                i13 = i11 == 1 and num1 or i11 - 1
                p1 = poly1[i13]
                i23 = i22 == num2 and 1 or i22 + 1
                p3 = poly2[i23]

                if not isConvex(p1, p2, p3) then continue

                p2 = poly1[i12]
                i13 = i12 == num1 and 1 or i12 + 1
                p3 = poly1[i13]
                i23 = i21 == 1 and num2 or i21 - 1
                p1 = poly2[i23]

                if not isConvex(p1, p2, p3) then continue

                newpoly = TPPLPoly()
                newpoly\init(num1 + num2 - 2)
                k = 1
                j = i12
                while j ~= i11
                    newpoly[k] = poly1[j]
                    k += 1
                    j = j == num1 and 1 or j + 1
                j = i22
                while j ~= i21
                    newpoly[k] = poly2[j]
                    k += 1
                    j = j == num2 and 1 or j + 1

                triangles[idx1] = newpoly
                poly1 = newpoly
                num1 = newpoly\getNumPoints()
                poly2.skip = true
                i11 = 0

        for poly in *triangles
            if not poly.skip
                parts[#parts + 1] = poly

        return parts

list_to_lua = (polys) ->
    result = {}
    for poly in *(polys or {})
        vertices = {}
        for i = 1, poly\getNumPoints()
            v = poly[i]
            vertices[i] = {v.x, v.y}
        result[#result + 1] = vertices
    return result

return {
    :TPPLPoly
    :convexPartition_HM
    :list_to_lua
}
