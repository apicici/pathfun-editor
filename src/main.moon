local im

love.load = () ->
    -- add the source base directory to package.cpath to accees shared libraries from there
    assert(jit, "This applications requires LÖVE to use LuaJIT.")
    extension = jit.os == "Windows" and "dll" or jit.os == "Linux" and "so" or jit.os == "OSX" and "dylib" or nil
    assert(extension, "This application is only supported on Linux, macOS, and Windows.") 
    base_dir = love.filesystem.getSourceBaseDirectory()
    package.cpath = string.format("%s/?.%s;%s", base_dir, extension, package.cpath)

    require "settings"
    im = require "cimgui"
    im.love.Init()

    require "input"
    require "draw"
    require "update"
    serialization = require "serialization"
    serialization.program_load()

love.quit = ->
    global = require "global"

    if global.modal_open
        return true

    if global.changed
        global.signals.quit = true
        return true
        
    else
        im.love.Shutdown()