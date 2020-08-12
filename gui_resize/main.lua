gui_windows = {}
gui_rules = {}

default_rules = {
    -- <float or bool>; false will ignore min/max width
    fixedWidth = false,
    -- <float or bool>; false will ignore min/max height
    fixedHeight = false,

    -- <float>
    minWidth = 0,
    maxWidth = screen_w,
    minHeight = 0,
    maxHeight = screen_h,

    -- <"left", "center" or "right">; "center" will ignore left/right paddings
    horizontalAlign = false,
    -- <"top", "center" or "bottom">; "center" will ignore top/bottom paddings
    verticalAlign = false,

    -- <float>
    leftPadding = 0,
    topPadding = 0,
    rightPadding = 0,
    bottomPadding = 0,

    -- <float>
    leftMargin = 0,
    topMargin = 0,
    rightMargin = 0,
    bottomMargin = 0
}

function findGUIWindow(g_element)
    if g_element.type == "gui-window" then return g_element end
    local parent = g_element.parent
    while not (parent.type == "gui-window" or parent.type == "guiroot") do
        parent = parent.parent
    end
    if parent.type ~= "gui-window" then return false end
    return parent
end

function copyRules(rules)
    local new_rules = {}
    for property, default_value in pairs(default_rules) do
        local value = rules[property]
        if value ~= nil then
            new_rules[property] = value
        else
            new_rules[property] = default_value
        end
    end
    return new_rules
end

function addResizer(g_element, rules)
    if gui_rules[g_element] then return false end
    local g_window = findGUIWindow(g_element)
    if not g_window then
        -- g_element is not a window and is not a descendant of a window
        -- resizing event will never be fired; return
        return false
    end
    gui_rules[g_element] = copyRules(rules)
    if not gui_windows[g_window] then
        gui_windows[g_window] = true
        addEventHandler("onClientGUISize", g_window, updateGUIWindow, false)
        addEventHandler("onClientGUIMove", g_window, updateGUIWindow, false)
    end
    return true
end
