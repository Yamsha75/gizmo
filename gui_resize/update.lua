screen_w, screen_h = guiGetScreenSize()

function clamp(x, min, max)
    return x > min and (x < max and x or max) or min
end

function refreshGUIWindow(g_element)
    if not gui_windows[g_element] then return false end
    local rules = gui_rules[g_element]
    if rules then
        -- old position and size
        local x0, y0 = g_element:getPosition(false)
        local w0, h0 = g_element:getSize(false)

        -- new position and size
        local x, y = x0, y0
        local w, h = w0, h0

        -- parent size
        local parent_w, parent_h = screen_w, screen_h

        -- size calculations
        w = rules.fixedWidth or clamp(w, rules.minWidth, rules.maxWidth)
        h = rules.fixedHeight or clamp(h, rules.minHeight, rules.maxHeight)

        -- position calculations
        if rules.horizontalAlign == "left" then
            x = rules.leftPadding
        elseif rules.horitzontalAlign == "center" then
            x = (parent_w + rules.leftPadding - rules.rightPadding - w) / 2
        elseif rules.horizontalAlign == "right" then
            x = parent_w - (w + rules.rightPadding)
        end

        if rules.verticalAlign == "top" then
            y = rules.topPadding
        elseif rules.verticalAlign == "center" then
            y = (parent_h + rules.topPadding - rules.bottomPadding - h) / 2
        elseif rules.verticalAlign == "bottom" then
            y = parent_h - (h + rules.bottomPadding)
        end

        -- applying changes
        -- ! setSize() & setPosition() will trigger onClientGUISize & onClientGUIMove !
        -- ! events which will call this function with the same arguments, causing an !
        -- ! overflow; "gui_windows[g_element] = false" will disable this behaviour   !
        gui_windows[g_element] = false
        if x ~= x0 or y ~= y0 then g_element:setPosition(x, y, false) end
        if w ~= w0 or h ~= h0 then g_element:setSize(w, h, false) end
        gui_windows[g_element] = true
    end
    -- call refresh on every child of this gui element
    for _, child in ipairs(getElementChildren(g_element)) do
        refreshGUIElement(child, g_element)
    end
end

function refreshGUIElement(g_element, parent)
    local rules = gui_rules[g_element]
    if rules then
        -- old position and size
        local x0, y0 = g_element:getPosition(false)
        local w0, h0 = g_element:getSize(false)

        -- new position and size
        local x, y = x0, y0
        local w, h = w0, h0

        -- parent size
        local parent_w, parent_h = parent:getSize(false)

        parent_rules = gui_rules[parent] or default_rules

        -- size calculations
        w = rules.fixedWidth or math.min(
            rules.maxWidth,
                parent_w - (parent_rules.leftMargin + parent_rules.rightMargin)
                    - (rules.leftPadding + rules.rightPadding)
        )
        h = rules.fixedHeight or math.min(
            rules.maxHeight,
                parent_h - (parent_rules.topMargin + parent_rules.bottomMargin)
                    - (rules.topPadding + rules.bottomPadding)
        )

        -- position calculations
        if rules.horizontalAlign == "left" then
            x = parent_rules.leftMargin + rules.leftPadding
        elseif rules.horizontalAlign == "center" then
            x = (parent_w + (parent_rules.leftMargin + rules.leftPadding)
                    - (parent_rules.rightMargin + rules.rightPadding) - w) / 2
        elseif rules.horizontalAlign == "right" then
            x = parent_w - (w + parent_rules.rightMargin + rules.rightPadding)
        end
        if rules.verticalAlign == "top" then
            y = parent_rules.topMargin + rules.topPadding
        elseif rules.verticalAlign == "center" then
            y = (parent_h + (parent_rules.topMargin + rules.topPadding)
                    - (parent_rules.bottomMargin + rules.bottomPadding) - h) / 2
        elseif rules.verticalAlign == "bottom" then
            y = parent_h - (h + parent_rules.bottomMargin + rules.bottomPadding)
        end

        -- applying changes
        if x ~= x0 or y ~= y0 then g_element:setPosition(x, y, false) end
        if w ~= w0 or h ~= h0 then g_element:setSize(w, h, false) end
    end
    -- call refresh on every child of this gui element
    for _, child in ipairs(getElementChildren(g_element)) do
        refreshGUIElement(child, g_element)
    end
end

function updateGUIWindow()
    refreshGUIWindow(source)
end

initWindow = refreshGUIWindow
