screen_w, screen_h = guiGetScreenSize()

enabled_guis = {}

-- wrappers for exports from other resources
function addResizer(...)
    return exports.gui_resize:addResizer(unpack(arg))
end

function initWindow(...)
    return exports.gui_resize:initWindow(unpack(arg))
end

-- synchronizing stuff between different windows
function setCursorVisible(gui, visible)
    enabled_guis[gui] = visible
    if not visible then
        for gui, enabled in pairs(enabled_guis) do if enabled then return end end
        showCursor(false, false)
    elseif not isCursorShowing() then
        showCursor(true, false)
    end
end
