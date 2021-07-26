-----------------------------------------------------------------------------------
-- Copyright (c) 2021 apicici                                                    --
-- License: Boost Software License Ver 1 (http://www.boost.org/LICENSE_1_0.txt ) --
-----------------------------------------------------------------------------------

local ffi = require "ffi"

local function vector_cdef(type, argtype)
    local s = [[
        typedef struct cl_#type# cl_#type#;
        cl_#type#* ClipperLib_#type#__new_default();
        cl_#type#* ClipperLib_#type#__new_fill(size_t, cl_#argtype#&);
        cl_#type#* ClipperLib_#type#__new_fill_default(size_t);
        cl_#type#* ClipperLib_#type#__new_copy(const cl_#type#&);
        void ClipperLib_#type#__destroy(cl_#type#*);
        //
        uint32_t ClipperLib_#type#_size(cl_#type#*);
        uint32_t ClipperLib_#type#_max_size(cl_#type#*);
        void ClipperLib_#type#_resize(cl_#type#*, size_t, cl_#argtype#&);
        void ClipperLib_#type#_resize__default(cl_#type#*, size_t);
        uint32_t ClipperLib_#type#_capacity(cl_#type#*);
        bool ClipperLib_#type#_empty(cl_#type#*);
        void ClipperLib_#type#_reserve(cl_#type#*, size_t);
        //
        cl_#argtype#& ClipperLib_#type#_at(cl_#type#*, size_t);
        void ClipperLib_#type#__setitem(cl_#type#*, size_t, cl_#argtype#);
        void ClipperLib_#type#__setitem_frompointer(cl_#type#*, size_t, cl_#argtype#*);
        cl_#argtype#& ClipperLib_#type#_front(cl_#type#*);
        cl_#argtype#& ClipperLib_#type#_back(cl_#type#*);
        //
        void ClipperLib_#type#_assign(cl_#type#*, size_t, cl_#argtype#&);
        void ClipperLib_#type#_push_back(cl_#type#*, cl_#argtype#&);
        void ClipperLib_#type#_pop_back(cl_#type#*);
        void ClipperLib_#type#_swap(cl_#type#*, cl_#type#&);
        void ClipperLib_#type#_clear(cl_#type#*);
    ]]
    local t = {type=type, argtype=argtype}
    s = s:gsub("#([^#]-)#", t)
    ffi.cdef(s)
end

ffi.cdef [[
    typedef signed long long cl_cInt;
    typedef struct cl_IntPoint {cl_cInt X; cl_cInt Y;} cl_IntPoint;
    typedef struct cl_IntRect {cl_cInt left; cl_cInt top; cl_cInt right; cl_cInt bottom;} cl_IntRect;

    //classes
    typedef struct cl_PolyNode cl_PolyNode;
    typedef struct cl_PolyTree cl_PolyTree;
    typedef struct cl_ClipperBase cl_ClipperBase;
    typedef struct cl_Clipper cl_Clipper;
    typedef struct cl_ClipperOffset cl_ClipperOffset;

    //enums
    typedef enum cl_PolyFillType cl_PolyFillType;
]]

vector_cdef("Path","IntPoint")
vector_cdef("Paths", "Path")
vector_cdef("PolyNodes", "PolyNode*")

ffi.cdef [[
    //class functions
    cl_PolyNode* ClipperLib_PolyNode__new();
    void ClipperLib_PolyNode__destroy(cl_PolyNode* p);
    cl_Path* ClipperLib_PolyNode_Contour__get(cl_PolyNode* p);
    cl_PolyNodes* ClipperLib_PolyNode_Childs__get(cl_PolyNode* p);
    cl_PolyNode* ClipperLib_PolyNode_Parent__get(cl_PolyNode* p);
    cl_PolyNode* ClipperLib_PolyNode_GetNext(cl_PolyNode* p);
    bool ClipperLib_PolyNode_IsHole(cl_PolyNode* p);
    bool ClipperLib_PolyNode_IsOpen(cl_PolyNode* p);
    int ClipperLib_PolyNode_ChildCount(cl_PolyNode* p);
    cl_PolyTree* ClipperLib_PolyTree__new();
    void ClipperLib_PolyTree__destroy(cl_PolyTree* p);
    cl_Path* ClipperLib_PolyTree_Contour__get(cl_PolyTree* p);
    cl_PolyNodes* ClipperLib_PolyTree_Childs__get(cl_PolyTree* p);
    cl_PolyNode* ClipperLib_PolyTree_Parent__get(cl_PolyTree* p);
    cl_PolyNode* ClipperLib_PolyTree_GetNext(cl_PolyTree* p);
    bool ClipperLib_PolyTree_IsHole(cl_PolyTree* p);
    bool ClipperLib_PolyTree_IsOpen(cl_PolyTree* p);
    int ClipperLib_PolyTree_ChildCount(cl_PolyTree* p);
    cl_PolyNode* ClipperLib_PolyTree_GetFirst(cl_PolyTree* p);
    void ClipperLib_PolyTree_Clear(cl_PolyTree* p);
    int ClipperLib_PolyTree_Total(cl_PolyTree* p);
    cl_Clipper* ClipperLib_Clipper__new(int initOptions);
    void ClipperLib_Clipper__destroy(cl_Clipper* p);
    bool ClipperLib_Clipper_AddPath(cl_Clipper* p, const cl_Path& pg, int PolyTyp, bool Closed);
    bool ClipperLib_Clipper_AddPaths(cl_Clipper* p, const cl_Paths& ppg, int PolyTyp, bool Closed);
    void ClipperLib_Clipper_Clear(cl_Clipper* p);
    cl_IntRect ClipperLib_Clipper_GetBounds(cl_Clipper* p);
    bool ClipperLib_Clipper_PreserveCollinear__get(cl_Clipper* p);
    void ClipperLib_Clipper_PreserveCollinear__set(cl_Clipper* p, bool v);
    bool ClipperLib_Clipper_Execute__Paths(cl_Clipper*, int, cl_Paths&, int, int);
    bool ClipperLib_Clipper_Execute__PolyTree(cl_Clipper*, int, cl_PolyTree&, int, int);
    bool ClipperLib_Clipper_ReverseSolution__get(cl_Clipper* p);
    void ClipperLib_Clipper_ReverseSolution__set(cl_Clipper* p, bool v);
    bool ClipperLib_Clipper_StrictlySimple__get(cl_Clipper* p);
    void ClipperLib_Clipper_StrictlySimple__set(cl_Clipper* p, bool v);
    cl_ClipperOffset* ClipperLib_ClipperOffset__new(double miterLimit, double roundPrecision);
    void ClipperLib_ClipperOffset__destroy(cl_ClipperOffset* p);
    void ClipperLib_ClipperOffset_AddPath(cl_ClipperOffset* p, const cl_Path& path, int joinType, int endType);
    void ClipperLib_ClipperOffset_AddPaths(cl_ClipperOffset* p, const cl_Paths& paths, int joinType, int endType);
    void ClipperLib_ClipperOffset_Execute__Paths(cl_ClipperOffset* p, cl_Paths& solution, double delta);
    void ClipperLib_ClipperOffset_Execute__PolyTree(cl_ClipperOffset* p, cl_PolyTree& solution, double delta);
    void ClipperLib_ClipperOffset_Clear(cl_ClipperOffset* p);
    double ClipperLib_ClipperOffset_MiterLimit__get(cl_ClipperOffset* p);
    void ClipperLib_ClipperOffset_MiterLimit__set(cl_ClipperOffset* p, double v);
    double ClipperLib_ClipperOffset_ArcTolerance__get(cl_ClipperOffset* p);
    void ClipperLib_ClipperOffset_ArcTolerance__set(cl_ClipperOffset* p, double v);

    //functions
    bool ClipperLib_Orientation(const cl_Path& poly);
    double ClipperLib_Area(const cl_Path& poly);
    int ClipperLib_PointInPolygon(const cl_IntPoint& pt, const cl_Path& path);
    void ClipperLib_SimplifyPolygon(const cl_Path& in_poly, cl_Paths& out_polys, int fillType);
    void ClipperLib_SimplifyPolygons__inout(const cl_Paths& in_polys, cl_Paths& out_polys, int fillType);
    void ClipperLib_SimplifyPolygons__single(cl_Paths& polys, int fillType);
    void ClipperLib_CleanPolygon__inout(const cl_Path& in_poly, cl_Path& out_poly, double distance);
    void ClipperLib_CleanPolygon__single(cl_Path& poly, double distance);
    void ClipperLib_CleanPolygons__inout(const cl_Paths& in_polys, cl_Paths& out_polys, double distance);
    void ClipperLib_CleanPolygons__single(cl_Paths& polys, double distance);
    void ClipperLib_MinkowskiSum__Path(const cl_Path& pattern, const cl_Paths& path, cl_Paths& solution, bool pathIsClosed);
    void ClipperLib_MinkowskiSum__Paths(const cl_Path& pattern, const cl_Path& paths, cl_Paths& solution, bool pathIsClosed);
    void ClipperLib_MinkowskiDiff(const cl_Path& poly1, const cl_Path& poly2, cl_Paths& solution);
    void ClipperLib_PolyTreeToPaths(const cl_PolyTree& polytree, cl_Paths& paths);
    void ClipperLib_ClosedPathsFromPolyTree(const cl_PolyTree& polytree, cl_Paths& paths);
    void ClipperLib_OpenPathsFromPolyTree(cl_PolyTree& polytree, cl_Paths& paths);
    void ClipperLib_ReversePath(cl_Path& p);
    void ClipperLib_ReversePaths(cl_Paths& p);
]]

local library_path = assert(package.searchpath("clipper", package.cpath))
local C = ffi.load(library_path)

local M = {C=C}


-- enums
local function add_enum(t)
    for k, v in pairs(t) do
        if type(k) == "string" then M[k] = v
        else M[v] = k - 1
        end
    end
end

add_enum {"ctIntersection", "ctUnion", "ctDifference", "ctXor"}
add_enum {"ptSubject", "ptClip"}
add_enum {"pftEvenOdd", "pftNonZero", "pftPositive", "pftNegative"}
add_enum {ioReverseSolution = 1, ioStrictlySimple = 2, ioPreserveCollinear = 4}
add_enum {"jtSquare", "jtRound", "jtMiter"}
add_enum {"etClosedPolygon", "etClosedLine", "etOpenButt", "etOpenSquare", "etOpenRound"}


-- IntPoint
local mt = {}
function mt:__new(x, y) return ffi.new("cl_IntPoint", {x or 0, y or 0}) end
function mt:__eq(p)
    return self.X == p.X and self.Y == p.Y
end
M.IntPoint = ffi.metatype("cl_IntPoint", mt)


-- vectors
local function wrap_vector(name, vecargtype)
    -- if the argument type is a vector itself, pass its metatable
    -- to the vecargtype argument
    local prefix = string.format("ClipperLib_%s_", name)
    local vector_mt = {}

    local function call(self, a1, a2)
        local p
        if not a1 then
            p = C[prefix .. "_new_default"]()
        elseif type(a1) == "number" then
            if a2 then
                p = C[prefix .. "_new_fill"](a1, vecargtype and a2.data or a2)
            else
                p = C[prefix .. "_new_fill_default"](a1)
            end
        else
            p = C[prefix .. "_new_copy"](a1.data)
        end
        local t = {data=ffi.gc(p, C[prefix .. "_destroy"])}
        return setmetatable(t, vector_mt)
    end

    M[name] = setmetatable(vector_mt, {__call=call})

    local methods = {}
    function methods:size() return C[prefix .. "size"](self.data) end
    function methods:max_size() return C[prefix .. "max_size"](self.data) end
    function methods:resize(n, v)
        if v then
            C[prefix .. "resize"](self.data, n, vecargtype and v.data or v)
        else
            C[prefix .. "resize__default"](self.data, n)
        end
    end
    function methods:capacity() return C[prefix .. "capacity"](self.data) end
    function methods:empty() C[prefix .. "empty"](self.data) end
    function methods:reserve(n) C[prefix .. "empty"](self.data, n) end

    function methods:at(n)
        local p =  C[prefix .. "at"](self.data, n)
        return vecargtype and setmetatable({data=p}, vecargtype) or p
    end
    function methods:front()
        local p = C[prefix .. "front"](self.data)
        return vecargtype and setmetatable({data=p}, vecargtype) or p
    end
    function methods:back()
        local p = C[prefix .. "back"](self.data)
        return vecargtype and setmetatable({data=p}, vecargtype) or p
    end

    function methods:assign(n, v) C[prefix .. "assign"](self.data, n, vecargtype and v.data or v) end
    function methods:push_back(v) C[prefix .. "push_back"](self.data, vecargtype and v.data or v) end
    function methods:pop_back() C[prefix .. "pop_back"](self.data) end
    function methods:swap(x) C[prefix .. "swap"](self.data, x.data) end
    function methods:clear() C[prefix .. "clear"](self.data) end

    function vector_mt:__index(k)
        return type(k) == "number" and methods.at(self, k) or methods[k]
    end

    function vector_mt:__newindex(k, v)
        if type(k) == "number" then
            if vecargtype then
                C[prefix .. "_setitem_frompointer"](self.data, k, v.data)
            else
                C[prefix .. "_setitem_frompointer"](self.data, k, v)
            end
        end
    end
end
wrap_vector("Path")
wrap_vector("Paths", M.Path)
wrap_vector("PolyNodes")

-- classes
-- PolyNode
M.PolyNode = function()
    local p = C["ClipperLib_PolyNode__new"]()
    return ffi.gc(p, C["ClipperLib_PolyNode__destroy"])
end

local PolyNode_methods = {}
function PolyNode_methods:GetNext() return C["ClipperLib_PolyNode_GetNext"](self) end
function PolyNode_methods:IsHole() return C["ClipperLib_PolyNode_IsHole"](self) end
function PolyNode_methods:IsOpen() return C["ClipperLib_PolyNode_IsOpen"](self) end
function PolyNode_methods:ChildCount() return C["ClipperLib_PolyNode_ChildCount"](self) end

local PolyNode_index = function(self, k)
    if k == "Contour" then
        local path = C["ClipperLib_PolyNode_Contour__get"](self)
        return setmetatable({data=path}, M.Path)
    elseif k == "Childs" then return C["ClipperLib_PolyNode_Childs__get"](self)
    elseif k == "Parent" then return C["ClipperLib_PolyNode_Parent__get"](self)
    else return PolyNode_methods[k]
    end
end

ffi.metatype("cl_PolyNode", {__index=PolyNode_index})

-- PolyTree
M.PolyTree = function()
    local p = C["ClipperLib_PolyTree__new"]()
    return ffi.gc(p, C["ClipperLib_PolyTree__destroy"])
end

local PolyTree_methods = {}
function PolyTree_methods:GetNext() return C["ClipperLib_PolyTree_GetNext"](self) end
function PolyTree_methods:IsHole() return C["ClipperLib_PolyTree_IsHole"](self) end
function PolyTree_methods:IsOpen() return C["ClipperLib_PolyTree_IsOpen"](self) end
function PolyTree_methods:ChildCount() return C["ClipperLib_PolyTree_ChildCount"](self) end
function PolyTree_methods:GetFirst() return C["ClipperLib_PolyTree_GetFirst"](self) end
function PolyTree_methods:Clear() return C["ClipperLib_PolyTree_Clear"](self) end
function PolyTree_methods:Total() return C["ClipperLib_PolyTree_Total"](self) end

local PolyTree_index = function(self, k)
    if k == "Contour" then
        local path = C["ClipperLib_PolyTree_Contour__get"](self)
        return setmetatable({data=path, M.Path})
    elseif k == "Childs" then return C["ClipperLib_PolyTree_Childs__get"](self)
    elseif k == "Parent" then return C["ClipperLib_PolyTree_Parent__get"](self)
    else return PolyTree_methods[k]
    end
end

ffi.metatype("cl_PolyTree", {__index=PolyTree_index})

-- Clipper
local prefix = "ClipperLib_Clipper"
M.Clipper = function(initOptions)
    initOptions = initOptions or 0
    local p = C["ClipperLib_Clipper__new"](initOptions)
    return ffi.gc(p, C["ClipperLib_Clipper__destroy"])
end

local Clipper_methods = {}
function Clipper_methods:AddPath(pg, PolyTyp, Closed) return C["ClipperLib_Clipper_AddPath"](self, pg.data, PolyTyp, Closed) end
function Clipper_methods:AddPaths(ppg, PolyTyp, Closed) return C["ClipperLib_Clipper_AddPaths"](self, ppg.data, PolyTyp, Closed) end
function Clipper_methods:Clear() return C["ClipperLib_Clipper_Clear"](self) end
function Clipper_methods:GetBounds() return C["ClipperLib_Clipper_GetBounds"](self) end
function Clipper_methods:PreserveCollinear(value)
    if value then return C["ClipperLib_Clipper_PreserveCollinear__set"](self, not not value)
    else return C["ClipperLib_Clipper_PreserveCollinear__get"](self)
    end
end
function Clipper_methods:Execute(clipType, solution, subjFillType, clipFillType)
    subjFillType = subjFillType or M.pftEvenOdd
    clipFillType = clipFillType or subjFillType
    if getmetatable(solution) == M.Paths then
        return C["ClipperLib_Clipper_Execute__Paths"](self, clipType, solution.data, subjFillType, clipFillType)
    elseif ffi.istype("cl_PolyTree", solution) then
        return C["ClipperLib_Clipper_Execute__PolyTree"](self, clipType, solution, subjFillType, clipFillType)
    else
        return false
    end
end
function Clipper_methods:ReverseSolution(value)
    if value then return C["ClipperLib_Clipper_ReverseSolution__set"](self, not not value)
    else return C["ClipperLib_Clipper_ReverseSolution__get"](self)
    end
end
function Clipper_methods:StrictlySimple(value)
    if value then return C["ClipperLib_Clipper_StrictlySimple__set"](self, not not value)
    else return C["ClipperLib_Clipper_StrictlySimple__get"](self)
    end
end

ffi.metatype("cl_Clipper", {__index=Clipper_methods})

-- ClipperOffset
M.ClipperOffset = function(miterLimit, roundPrecision)
    miterLimit = miterLimit or 2
    roundPrecision = roundPrecision or 0.25
    local p = C["ClipperLib_ClipperOffset__new"](miterLimit, roundPrecision)
    return ffi.gc(p, C["ClipperLib_ClipperOffset__destroy"])
end

local ClipperOffset_methods = {}
function ClipperOffset_methods:AddPath(path, joinType, endType) return C["ClipperLib_ClipperOffset_AddPath"](self, path.data, joinType, endType) end
function ClipperOffset_methods:AddPaths(paths, joinType, endType) return C["ClipperLib_ClipperOffset_AddPaths"](self, paths.data, joinType, endType) end
function ClipperOffset_methods:Execute(solution, delta)
    if getmetatable(solution) == M.Paths then
        return C["ClipperLib_ClipperOffset_Execute__Paths"](self, solution.data, delta)
    elseif ffi.istype("cl_PolyTree", solution) then
        return C["ClipperLib_ClipperOffset_Execute__PolyTree"](self, solution, delta)
    end
end
function ClipperOffset_methods:Clear() return C["ClipperLib_ClipperOffset_Clear"](self) end

local ClipperOffset_index = function(self, k)
    if k == "MiterLimit" then return C["ClipperLib_ClipperOffset_MiterLimit__get"](self)
    elseif k == "ArcTolerance" then return C["ClipperLib_ClipperOffset_ArcTolerance__get"](self)
    else return ClipperOffset_methods[k]
    end
end

local ClipperOffset_newindex = function (self, k, v)
    if k == "MiterLimit" then return C["ClipperLib_ClipperOffset_MiterLimit__set"](self, v)
    elseif k == "ArcTolerance" then return C["ClipperLib_ClipperOffset_ArcTolerance__set"](self, v)
    end
end

ffi.metatype("cl_ClipperOffset", {__index=ClipperOffset_index, __newindex=ClipperOffset_newindex})


-- functions
M.Orientation = function(poly) return C.ClipperLib_Orientation(poly.data) end
M.Area = function(poly) return C.ClipperLib_Area(poly.data) end
M.PointInPolygon = function(pt, poly) return C.ClipperLib_PointInPolygon(pt, poly.data) end
M.SimplifyPolygon = function(in_poly, out_polys, fillType)
    fillType = fillType or M.pftEvenOdd
    C.ClipperLib_SimplifyPolygon(in_poly.data, out_polys.data, fillType)
end
M.SimplifyPolygons = function(a1, a2, a3)
    if getmetatable(a2) == M.Paths then
        a3 = a3 or M.pftEvenOdd -- fillType
        C.ClipperLib_SimplifyPolygons__inout(a1.data, a2.data, a3)
    else
        a2 = a2 or M.pftEvenOdd -- fillType
        C.ClipperLib_SimplifyPolygons__single(a1.data, a2)
    end
end
M.CleanPolygon = function(a1, a2, a3)
    if getmetatable(a2) == M.Path then
        a3 = a3 or 1.415 -- distance
        C.ClipperLib_CleanPolygon__inout(a1.data, a2.data, a3)
    else
        a2 = a2 or 1.415 -- distance
        C.ClipperLib_CleanPolygon__single(a1.data, a2)
    end
end
M.CleanPolygons = function(a1, a2, a3)
    if getmetatable(a2) == M.Paths then
        a3 = a3 or 1.415 -- distance
        C.ClipperLib_CleanPolygons__inout(a1.data, a2.data, a3)
    else
        a2 = a2 or 1.415 -- distance
        C.ClipperLib_CleanPolygons__single(a1.data, a2)
    end
end
M.MinkowskiSum = function(pattern, a2, solution, pathIsClosed)
    if getmetatable(a2) == M.Path then
        C.ClipperLib_MinkowskiSum__Path(pattern.data, a2.data, solution.data, pathIsClosed)
    elseif getmetatable(a2) == M.Paths then
        C.ClipperLib_MinkowskiSum__Paths(pattern.data, a2.data, solution.data, pathIsClosed)
    end
end
M.MinkowskiDiff = function(poly1, poly2, solution) return C.ClipperLib_MinkowskiDiff(poly1.data, poly2.data, solution.data) end
M.PolyTreeToPaths = function(polytree, paths) return C.ClipperLib_PolyTreeToPaths(polytree, paths.data) end
M.ClosedPathsFromPolyTree = function(polytree, paths) return C.ClipperLib_ClosedPathsFromPolyTree(polytree, paths.data) end
M.OpenPathsFromPolyTree = function(polytree, paths) return C.ClipperLib_OpenPathsFromPolyTree(polytree, paths.data) end
M.ReversePath = function(p) return C.ClipperLib_ReversePath(p.data) end
M.ReversePaths = function(p) return C.ClipperLib_ReversePaths(p.data) end

M.C = C
return M