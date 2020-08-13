BiMap = {}
BiMap.__index = BiMap

function BiMap.new()
    local self = setmetatable({}, BiMap)
    self.indexes = {} -- maps value => index
    self.values = {} -- maps index => value
    return self
end

function BiMap.pairs(self)
    return pairs(self.indexes)
end

function BiMap.ipairs(self, start_index)
    local iterator = ipairs(self.values)
    return iterator, self.values, start_index and start_index - 1 or 0
end

function BiMap.exists(self, value)
    return self.indexes[value] ~= nil
end

function BiMap.append(self, value)
    local new_index = #(self.values) + 1
    self.values[new_index] = value
    self.indexes[value] = new_index
    return true
end

function BiMap.appendIfExists(self, value)
    if not self:exists(value) then return self:append(value) end
end

function BiMap.rawRemove(self, index, value)
    self.indexes[value] = nil
    table.remove(self.values, index)
    for i, e in self:ipairs(index) do self.indexes[e] = i end
    return true
end

function BiMap.removeIndex(self, index)
    local value = self.values[index]
    if not index then return false end
    return self:rawRemove(index, value)
end

function BiMap.removeValue(self, value)
    local index = self.indexes[value]
    if not index then return false end
    return self:rawRemove(index, value)
end

function BiMap.getIndex(self, value)
    return self.indexes[value]
end

function BiMap.getValue(self, index)
    return self.values[index]
end
