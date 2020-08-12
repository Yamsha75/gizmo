-- gui creation
g_list_selector = {}

local gui = g_list_selector

local function createGUI()
    gui.window = guiCreateWindow(
        screen_w - 400, (screen_h - 500) / 2, 400, 500, "Nearby elements selector",
            false
    )
    gui.window.visible = false

    gui.label = guiCreateLabel(0, 0, 0, 0, "Selection radius:", false, gui.window)

    gui.edit = guiCreateEdit(0, 0, 0, 0, "16", false, gui.window)
    gui.edit.maxLength = 6

    gui.gridlist = guiCreateGridList(0, 0, 1000, 0, false, gui.window)
    gui.gridlist.selectionMode = 0
    gui.gridlist:addColumn("Type", 0.2)
    gui.gridlist:addColumn("Name", 0.5)
    gui.gridlist:addColumn("Distance", 0.2)

    gui.button = guiCreateButton(0, 0, 0, 0, "Confirm", false, gui.window)

    addResizer(
        gui.window, {
            minWidth = 300,
            minHeight = 350,
            leftMargin = 8,
            topMargin = 24,
            rightMargin = 8,
            bottomMargin = 8
        }
    )
    addResizer(
        gui.label, {
            fixedHeight = 20,
            fixedWidth = 100,
            verticalAlign = "top",
            horizontalAlign = "left"
        }
    )
    addResizer(
        gui.edit, {
            fixedHeight = 20,
            fixedWidth = 100,
            leftPadding = 108,
            verticalAlign = "top",
            horizontalAlign = "left"
        }
    )
    addResizer(
        gui.gridlist, {
            topPadding = 28,
            bottomPadding = 28,
            verticalAlign = "center",
            horizontalAlign = "center"
        }
    )
    addResizer(
        gui.button, {
            fixedHeight = 20,
            fixedWidth = 100,
            verticalAlign = "bottom",
            horizontalAlign = "left"
        }
    )

    initWindow(gui.window)

    addEventHandler("onClientGUIFocus", gui.window, onGUIFocusHandler)
    addEventHandler("onClientGUIBlur", gui.window, onGUIBlurHandler)
    addEventHandler("onClientMouseWheel", root, updateMouseWheel)

    addEventHandler("onClientGUIAccepted", gui.edit, updateRadius, false)

    addEventHandler("onClientGUIDoubleClick", gui.gridlist, chooseElement, false)
    addEventHandler("onClientGUIClick", gui.button, chooseElement, false)

    gui.colShape = createColSphere(0, 0, 0, tonumber(gui.edit.text))
    attachElements(gui.colShape, localPlayer)
end
addEventHandler("onClientResourceStart", resourceRoot, createGUI)

-- gui controller functions
local function toggleGUI()
    local enabled = not gui.window.visible
    gui.window.visible = enabled
    setCursorVisible("g_list_selector", enabled)
end
addCommandHandler("listselector", toggleGUI)
bindKey("L", "down", toggleGUI)

function updateRadius()
    local new_radius = tonumber(gui.edit.text)
    if not (new_radius and new_radius > 0 and new_radius <= 1000) then
        outputChatBox("Invalid radius! 0 < radius <= 1000")
        return
    end
    gui.colShape:destroy()
    gui.colShape = createColSphere(0, 0, 0, new_radius)
    attachElements(gui.colShape, localPlayer)
end

local focus = false
function onGUIFocusHandler()
    print("got focoos")
    focus = true
end
function onGUIBlurHandler()
    print("lost focoos")
    focus = false
end

function updateMouseWheel(direction)
    if not focus then return end
    local n_rows = gui.gridlist.rowCount
    if n_rows == 0 then return end
    local row, column = gui.gridlist:getSelectedItem()
    if row < 0 then
        if direction == -1 then
            gui.gridlist:setSelectedItem(0, 1)
        else
            gui.gridlist:setSelectedItem(n_rows - 1, 1)
        end
    else
        local row = (row - direction) % n_rows
        gui.gridlist:setSelectedItem(row, 1)
    end
end

function chooseElement(button)
    if button == "left" then
        local row, column = gui.gridlist:getSelectedItem()
        if not (row >= 0 and column >= 0) then
            outputChatBox("No element chosen from list!")
            return
        end
        local chosen_element = gui.gridlist:getItemData(row, 1)
        triggerEvent("gizmo:onSelectElement", chosen_element)
    end
end

local elements_map = BiDirectionalMap.new()
local selected_item_index = 0

local function refreshGUI()
    if gui.window.visible then
        -- check elements already in list
        for index, element in elements_map:ipairs() do
            if isElement(element) and isElementWithinColShape(element, gui.colShape) then
                -- update row
                gui.gridlist:setItemText(index - 1, 1, element.type, false, false)
                gui.gridlist:setItemText(
                    index - 1, 2, element.id or inspect(element), false, false
                )
                gui.gridlist:setItemText(
                    index - 1, 3, (localPlayer.position - element.position):getLength(),
                        false, true
                )
            else
                -- remove row
                elements_map:rawRemove(index, element)
                gui.gridlist:removeRow(index - 1)
            end
        end

        -- check new elements
        local elements = getElementsWithinColShape(gui.colShape)
        for _, element in ipairs(elements) do
            if element.type ~= "player" then
                if elements_map:appendIfExists(element) then
                    local row_index = gui.gridlist:addRow(
                        element.type, element.id or inspect(element),
                            (localPlayer.position - element.position):getLength()
                    )
                    gui.gridlist:setItemData(row_index, 1, element)
                end
            end
        end
    end
end
setTimer(refreshGUI, 500, 0)
