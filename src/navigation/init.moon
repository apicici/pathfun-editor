path = (...)\gsub(".init$", "") .. "."

colours = require path .. "colours"
editor = require path .. "editor"
global = require "global"
helpers = require "imgui_helpers"
im = require "cimgui"
tester = require path .. "tester"
view = require "view"
ffi = require "ffi"

import Polygons from require path .. "polygons"

M = {}

mode = editor
test_mode = false
crosshair = love.mouse.getSystemCursor('crosshair')

set_visibility = (pmap, bool) ->
    pmap.hidden = not bool
    pmap.decomposition.items.hidden = not bool or nil
    tester.set_visibility(pmap.name, bool)
    global.changed = true

toggle_mode = ->
    mode.clear()
    if mode == editor
        mode, test_mode, M.cursor = tester, true, nil
    else
        mode, test_mode, M.cursor = editor, false, crosshair
    mode.clear()
    M.mousemoved(love.mouse.getPosition())

M.draw = (...) ->
    mode.draw(...)
    if im.Begin("Navigation", nil, im.ImGuiWindowFlags_MenuBar)
        if im.BeginMenuBar()
            if im.BeginMenu("Edit")
                if im.MenuItem_Bool("Refresh polygon map", "R", nil, not test_mode)
                    global.pmap\refresh() if global.pmap
                if im.MenuItem_Bool("Simplify polygon map", "S", nil, not test_mode)
                    global.pmap\clean() if global.pmap
                if im.MenuItem_Bool("Subtract mode", "M", editor.poly2add.subtract, not test_mode)
                    editor.poly2add.subtract = not editor.poly2add.subtract
                if im.MenuItem_Bool("Testing mode", "T", test_mode)
                    toggle_mode()
                im.EndMenu()
            if im.BeginMenu("Options")
                helpers.color_edit("Polygon colour", colours.contour, im.ImGuiColorEditFlags_NoInputs)
                helpers.color_edit("Hole colour", colours.hole, im.ImGuiColorEditFlags_NoInputs)
                helpers.color_edit("Highlight colour", colours.highlight, im.ImGuiColorEditFlags_NoInputs)
                helpers.color_edit("Inactive colour", colours.inactive, im.ImGuiColorEditFlags_NoInputs)
                im.EndMenu()
            im.EndMenuBar()

        for i, pmap in ipairs(global.pmaps)
            bool_p = ffi.new("bool[1]", not pmap.hidden)
            changed = im.Checkbox("###{i}", bool_p)
            set_visibility(pmap, bool_p[0]) if changed and pmap.name
            if not pmap.name and im.IsItemHovered()
                im.BeginTooltip()
                im.Text("Only named polygon maps can be hidden.")
                im.EndTooltip()
            im.SameLine()
            if im.Selectable_Bool((pmap.name or "*unnamed*") .. "####{i}", global.pmap == pmap) and global.pmap ~= pmap
                if not test_mode
                    M.clear()
                global.pmap = pmap
            if im.BeginPopupContextItem()
                if test_mode
                    im.Text("No editing in Testing mode")
                else
                    if im.Button("Rename")
                        im.OpenPopup_Str("Rename")
                    if im.BeginPopup("Rename")
                        im.Text("Press enter to change")
                        im.SetKeyboardFocusHere()
                        name_p = ffi.new("char[50]", pmap.name or "")
                        if im.InputText("##pmap_name", name_p, 50, im.ImGuiInputTextFlags_EnterReturnsTrue)
                            newname = ffi.string(name_p) 
                            newname = nil if newname == "" or newname == "*unnamed*"
                            if pmap.name ~= newname
                                global.changed = true
                                pmap.name = newname
                                pmap\refresh()
                            im.CloseCurrentPopup()
                        im.EndPopup()
                    if im.Button("Delete")
                        global.changed = true
                        if global.pmap == editor.remove_pmap(i)
                            global.pmap = nil
                            M.clear()
                        im.CloseCurrentPopup()
                im.EndPopup()
                
        if im.Button("New polygon map") and not test_mode
            global.changed = true
            M.clear()
            global.pmap = editor.new_pmap()
        if test_mode and im.IsItemHovered()
            im.BeginTooltip()
            im.Text("No editing in Testing mode")
            im.EndTooltip()

    im.End()


M.mousemoved = (...) ->
    mode.mousemoved(...)

M.keypressed = (key) ->
    switch key
        when "t"
            toggle_mode()
        else
            mode.keypressed(key)

M.mousepressed = (...) ->
    mode.mousepressed(...)

M.mousereleased = (...) ->
    mode.mousereleased(...)

M.save = ->
    return [pmap.decomposition.items for pmap in *global.pmaps]

M.load = (t={}) ->
    global.pmaps = {}
    global.pmap = nil

    for i, group in ipairs(t)
        pmap = Polygons(group)
        pmap.name = group.name
        pmap.decomposition.items.name = group.name
        set_visibility(pmap, not group.hidden) if group.name
        global.pmaps[i] = pmap

    editor.clear()
    tester.clear()

M.clear = ->
    mode.clear()

M.update = ->
    mode.update() if mode.update

M.cursor = crosshair

M.reset_input = ->
    mode.reset_input() if mode.reset_input

return M