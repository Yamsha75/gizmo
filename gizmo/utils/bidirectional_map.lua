BiDirectionalMap = {}
BiDirectionalMap.__index = BiDirectionalMap

function BiDirectionalMap.new()
    local self = setmetatable({}, BiDirectionalMap)
    self.indexes = {} -- maps element => index
    self.elements = {} -- maps index => element
    return self
end

function BiDirectionalMap.pairs(self)
    return pairs(self.indexes)
end

function BiDirectionalMap.ipairs(self, start_index)
    local iterator = ipairs(self.elements)
    return iterator, self.elements, start_index and start_index - 1 or 0
end

function BiDirectionalMap.exists(self, element)
    return self.indexes[element] ~= nil
end

function BiDirectionalMap.append(self, element)
    local new_index = #(self.elements) + 1
    self.elements[new_index] = element
    self.indexes[element] = new_index
    return true
end

function BiDirectionalMap.appendIfExists(self, element)
    if not self:exists(element) then return self:append(element) end
end

function BiDirectionalMap.rawRemove(self, index, element)
    self.indexes[element] = nil
    table.remove(self.elements, index)
    for i, e in self:ipairs(index) do self.indexes[e] = i end
    return true
end

function BiDirectionalMap.removeIndex(self, index)
    local element = self.elements[index]
    if not index then return false end
    return rawRemove(self, index, element)
end

function BiDirectionalMap.removeElement(self, element)
    local index = self.indexes[element]
    if not index then return false end
    return rawRemove(self, index, element)
end

function BiDirectionalMap.getIndex(self, element)
    return self.indexes[element]
end

function BiDirectionalMap.getElement(self, index)
    return self.elements[index]
end
