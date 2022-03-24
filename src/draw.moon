global = require "global"
helpers = require "imgui_helpers"
im = require "cimgui"
navigation = require "navigation"
serialization = require "serialization"
settings = require "settings"
view = require "view"
ffi = require "ffi"
help = require "help"

import round from require("pathfun.steelpan.utils").math

-- style
style = im.GetStyle()
style.FrameRounding = 4
style.WindowRounding = 4
style.WindowBorderSize = 1

-- colours
colours = helpers.colours
cols = {
    {"Border", colours.titlebgactive}
    {"Button", colours.button, 0.75}
    {"ButtonActive", colours.button2}
    {"ButtonHovered", colours.button}
    {"CheckMark", colours.checkmark}
    {"FrameBg", colours.framebg}
    {"FrameBgActive", colours.framebg2,0.9}
    {"FrameBgHovered", colours.framebg2,0.7}
    {"Header", colours.header, 0.31}
    {"HeaderActive", colours.header}
    {"HeaderHovered", colours.header, 0.8}
    {"MenuBarBg", colours.menubar}
    {"ModalWindowDimBg", colours.bg, 0.6}
    {"PopupBg", colours.bg}
    {"ResizeGrip", colours.resize, 0.25}
    {"ResizeGripActive", colours.resize, 0.95}
    {"ResizeGripHovered", colours.resize, 0.67}
    {"ScrollbarGrab", colours.scrollbar}
    {"ScrollbarGrabActive", colours.scrollbar3}
    {"ScrollbarGrabHovered", colours.scrollbar2}
    {"Separator", colours.textdisabled}
    {"SeparatorActive", colours.separator}
    {"SeparatorHovered", colours.separator, 0.78}
    {"SliderGrab", colours.slider}
    {"SliderGrabActive", colours.slider2}
    {"TextDisabled", colours.textdisabled}
    {"TextSelectedBg", colours.textselect}
    {"TitleBg", colours.titlebg}
    {"TitleBgActive", colours.titlebgactive}
    {"TitleBgCollapsed", colours.titlebg, 0.6}
    {"WindowBg", colours.bg}
    {"DockingPreview", colours.header}
    {"DragDropTarget", colours.header}
}

for t in *cols
    idx, col, a = im["ImGuiCol_" .. t[1]], t[2], t[3]
    style.Colors[idx] = a and im.ImVec4_Float(col.x, col.y, col.z, a) or col

-- scale
saved_style = im.ImGuiStyle()
ffi.copy(saved_style, style, ffi.sizeof("ImGuiStyle"))

rescale = (s) ->
    ffi.copy(style, saved_style, ffi.sizeof("ImGuiStyle"))
    style\ScaleAllSizes(s)
    settings\scale(s)
    view\update()

    io = im.GetIO()
    io.Fonts\Clear()
    config = im.ImFontConfig()
    config.SizePixels = 13*s
    io.FontDefault = io.Fonts\AddFontDefault(config)
    im.love.BuildFontAtlas()

scale_p = ffi.new("int[1]", settings.t.scale)
rescale(scale_p[0])

show = {
    bounds: false
    coordinates: false
}

show_p = {
    dump: ffi.new("bool[1]", false)
    help: ffi.new("bool[1]", true)
}

background_colour = {0,0,0}

love.draw = ->
    rescale_needed = false
    file_loaded = not not global.filename
    file_changed = not not global.changed

    modal_button_size = im.ImVec2_Float(15*4, 0)*scale_p[0]

    love.graphics.setBackgroundColor(background_colour)
    
    -- display warning messages
    if err = global.error
        w, h = love.graphics.getDimensions()
        im.SetNextWindowPos(im.ImVec2_Float(w/2, h/2), nil, im.ImVec2_Float(0.5, 0.5))
        im.SetNextWindowSize(im.ImVec2_Float(500*scale_p[0], 0))
        im.OpenPopup_Str("Warning")
        if im.BeginPopupModal("Warning", nil, im.love.WindowFlags("AlwaysAutoResize", "NoCollapse"))
            im.TextWrapped(err)
            im.Spacing()
            im.Spacing()
            if helpers.color_button("OK", .2083, 1, modal_button_size)
                global.error = nil
            im.EndPopup()

    -- ask for confirmation before closing if there are unsaved changes
    if global.signals.quit
        w, h = love.graphics.getDimensions()
        im.SetNextWindowPos(im.ImVec2_Float(w/2, h/2), nil, im.ImVec2_Float(0.5, 0.5))
        im.SetNextWindowSize(im.ImVec2_Float(500*scale_p[0], 0))
        im.OpenPopup_Str("Warning##quit")
        if im.BeginPopupModal("Warning##quit", nil, im.love.WindowFlags("AlwaysAutoResize", "NoCollapse"))
            im.TextWrapped("Save changes before closing?")
            im.Spacing()
            im.Spacing()
            if helpers.color_button("Save", .2083, 1, modal_button_size)
                global.signals.quit = false
                if serialization.save()
                    love.event.quit()
            im.SameLine()
            if helpers.color_button("Cancel", .1389, 1)
                global.signals.quit = false
            im.SameLine()
            if helpers.color_button("Close without saving", .0794, 1)
                global.changed = false
                love.event.quit()
            im.EndPopup()

    -- ask for confirmation before loading if there are unsaved changes
    if global.signals.load
        w, h = love.graphics.getDimensions()
        im.SetNextWindowPos(im.ImVec2_Float(w/2, h/2), nil, im.ImVec2_Float(0.5, 0.5))
        im.SetNextWindowSize(im.ImVec2_Float(500*scale_p[0], 0))
        im.OpenPopup_Str("Warning##load")
        if im.BeginPopupModal("Warning##load", nil, im.love.WindowFlags("AlwaysAutoResize", "NoCollapse"))
            im.TextWrapped("Save changes before loading new file?")
            im.Spacing()
            im.Spacing()
            if helpers.color_button("Save", .2083, 1)
                global.signals.load = false
                if serialization.save()
                    serialization.load()
            im.SameLine()
            if helpers.color_button("Cancel", .1389, 1)
                global.signals.load = false
            im.SameLine()
            if helpers.color_button("Load without saving", .0794, 1)
                global.signals.load = false
                serialization.load()
            im.EndPopup()

    -- menu
    im.PushStyleColor_Vec4(im.ImGuiCol_MenuBarBg, colours.redbar) if global.changed
    style_pushed = global.changed
    im.PushStyleVar_Float(im.ImGuiStyleVar_WindowBorderSize, 0)
    if im.BeginMainMenuBar()
        if im.BeginMenu("File")
            if im.BeginMenu("Open recent")
                for entry in *(settings.t.recent or {})
                    if im.Selectable_Bool(entry)
                        serialization.open_file(entry)
                im.Separator()
                if im.Selectable_Bool("Clear history")
                    settings\clear_history()
                im.EndMenu()
            if im.MenuItem_Bool("Save", "Ctrl+S", false, file_changed and file_loaded)
                serialization.save()
            if im.MenuItem_Bool("Quit", "Ctrl+Q")
                love.event.quit()
            im.EndMenu()
        if im.BeginMenu("View")
            if im.MenuItem_Bool("Reset view", nil, false, file_loaded)
                view\reset()
            im.Separator()
            im.MenuItem_BoolPtr("Show help window", nil, show_p.help, file_loaded)
            if im.MenuItem_Bool("Show coordinates", nil, show.coordinates, file_loaded)
                show.coordinates = not show.coordinates
            im.MenuItem_BoolPtr("Show output table", nil, show_p.dump, file_loaded)
            im.EndMenu()
        if im.BeginMenu("Options")
            helpers.color_edit("Background colour", background_colour, im.ImGuiColorEditFlags_NoInputs)
            if im.InputInt("Global scale", scale_p)
                if scale_p[0] < 1
                    scale_p[0] = 1
                else
                    rescale_needed = true
            im.EndMenu()
        im.EndMainMenuBar()
    im.PopStyleVar()
    im.PopStyleColor() if style_pushed

    if file_loaded
        -- output table
        if show_p.dump[0]
            if im.Begin("Output table", show_p.dump, im.ImGuiWindowFlags_HorizontalScrollbar)
                serialization.update_table()
                im.TextUnformatted(serialization.dump)
            im.End()

        if show.coordinates
            helpers.BeginOverlay("coordinates")
            x,y = view\get_coordinates(love.mouse.getPosition())
            im.Text("(#{round(x)}, #{round(y)})")
            helpers.EndOverlay()

        if show_p.help[0]
            if im.Begin("Help", show_p.help, im.ImGuiWindowFlags_HorizontalScrollbar)
                help()
            im.End()
        
        navigation\draw()
    
    im.Render()
    im.love.RenderDrawLists()

    rescale(scale_p[0]) if rescale_needed
    