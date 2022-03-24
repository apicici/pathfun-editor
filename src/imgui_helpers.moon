im = require "cimgui"
ffi = require "ffi"

M = {}

M.colours = {
    bg: im.ImVec4_Float(0.08,0.04,0,1)
    titlebg: im.ImVec4_Float(0.46,0.28,0,1)
    titlebgactive: im.ImVec4_Float(0.62,0.37,0,1)
    menubar: im.ImVec4_Float(0.66,0.44,0.06,1)
    redbar: im.ImVec4_Float(0.8,0.353,0.24,1)
    button: im.ImVec4_Float(0.65,0.43,0.19,1)
    button2: im.ImVec4_Float(0.79,0.49,0.16,1)
    closebutton: im.ImVec4_Float(0.82,0.56,0.23,0.5)
    resize: im.ImVec4_Float(1,0.67,0.26,1)
    framebg: im.ImVec4_Float(0.71,0.41,0.01,0.54)
    framebg2: im.ImVec4_Float(0.77,0.45,0,1)
    checkmark: im.ImVec4_Float(0.72,0.75,0.24,0.73)
    textdisabled: im.ImVec4_Float(0.59,0.52,0.46,1)
    scrollbar: im.ImVec4_Float(0.38,0.29,0.22,1)
    scrollbar2: im.ImVec4_Float(0.48,0.35,0.24,1)
    scrollbar3: im.ImVec4_Float(0.61,0.42,0.28,1)
    textselect: im.ImVec4_Float(0.98,0.79,0.26,0.35)
    header: im.ImVec4_Float(0.72,0.75,0.24,1)
    slider: im.ImVec4_Float(0.61,0.64,0.19,1)
    slider2: im.ImVec4_Float(0.75,0.78,0.22,1)
    separator: im.ImVec4_Float(0.58,0.75,0.10,1)
}

M.search = {}

M.color_button = (label, hue, alpha, ...) ->
    im.PushStyleColor_Vec4(im.ImGuiCol_Button, im.ImColor.HSV(hue,0.6,0.6,alpha).Value)
    im.PushStyleColor_Vec4(im.ImGuiCol_ButtonHovered, im.ImColor.HSV(hue,0.5,0.7,alpha).Value)
    im.PushStyleColor_Vec4(im.ImGuiCol_ButtonActive, im.ImColor.HSV(hue,0.5,0.8,alpha).Value)
    out = im.Button(label, ...)
    im.PopStyleColor(3)
    return out

M.color_edit = (label, col_table, flags) ->
    if #col_table == 4
        col = ffi.new("float[4]", col_table)
        if im.ColorEdit4(label, col, flags)
            col_table[i] = col[i - 1] for i = 1, 4
    else
        col = ffi.new("float[3]", col_table)
        if im.ColorEdit3(label, col, flags)
            col_table[i] = col[i - 1] for i = 1, 3

                
M.help_marker = (text) ->
    im.TextDisabled("(?)")
    if im.IsItemHovered()
        im.BeginTooltip()
        im.PushTextWrapPos(im.GetFontSize()*30)
        im.TextUnformatted(text)
        im.PopTextWrapPos()
        im.EndTooltip()

M.BeginOverlay = (id) ->
    im.SetNextWindowBgAlpha(0.3)
    im.Begin("###{id}", nil, im.love.WindowFlags("NoTitleBar", "NoResize", "AlwaysAutoResize"))

M.EndOverlay = ->
    im.End()

return M
