addEvent("gizmo:onSelectElement")

local selected = false

function setSelected()
    selected = source
end
addEventHandler("gizmo:onSelectElement", root, setSelected)

function drawSelected()
    if not (selected and isElement(selected) and isElementStreamedIn(selected)) then
        return
    end
    drawBoundingBox(selected)
end
addEventHandler("onClientPreRender", root, drawSelected)
