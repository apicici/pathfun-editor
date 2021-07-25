path = (...)\gsub(".init$", "") .. "."

global = require "global"
navigation = require "navigation"
serpent = require path .. "serpent"
settings = require "settings"
view = require "view"

nofile_error = "Drag an existing file or an empty file into the window to start. " ..
    "The file will be used when saving!"

output_format = (tag, head, body, tail, level) ->
    indent1 = "\n" .. ("%s%s")\rep(3) .. "+([^%s])"
    indent2 = "\n" .. ("%s%s")\rep(2) .. "}"
    body = body\gsub(indent1, "%1")
    body = body\gsub(indent2, "}")

    return tag .. head .. body .. tail

options = {
    comment: false
    custom: output_format
}

local newfilename

M = {}

M.filedropped = (file) ->
    if global.error and global.error ~= nofile_error then return
    global.error = nil
    filename = file\getFilename()
    if love.system.getOS() == "Windows"
        filename = filename\gsub("\\","/")
    M.open_file(filename)

M.open_file = (filename) ->
    newfilename = filename
    if global.changed
        global.signals.load = true
    else
        M.load()

M.program_load = ->
    if latest = settings.t.recent[1]
        M.open_file(latest)
        return if not global.error   
    global.error = nofile_error


M.update_table = ->
    t = navigation.save()
    M.dump = serpent.block(t, options)

M.save = ->
    M.update_table()
    if global.filename
        f = io.open(global.filename, "w")
        if f
            f\write("return " .. M.dump)
            f\close()
            global.changed = false
            return true
        else
            global.error = "Could not open the file for writing."
            return false
        
M.load = ->
    err, filename = true, newfilename
    local t
    while filename
        f = io.open(filename, "r")
        if not f then break
        data = f\read("*all")
        f\close()
        ok, t = serpent.load(data)
        if not ok then break
        err = false
        break
    if err
        global.error = "File not valid or not accessible."
    else
        global.filename = filename
        global.directory = filename\gsub("[^/]*$","")

        love.window.setTitle("pathfun editor - " .. filename\gsub(".-([^/]*)$","%1"))

        settings\add_filename(filename)
        
        navigation.load(t)
        
        global.changed = false
        view\reset()
        return true


return M