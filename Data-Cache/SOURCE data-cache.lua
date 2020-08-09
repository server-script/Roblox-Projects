local cache = {}
cache.__index = cache

local function updateIndex(dictionary, index, newIndex)
	assert(typeof(newIndex) == "string", "Index argument must be a string.")
	local returnTable = {};
	local valueToChange;
	for i, v in pairs(dictionary) do
		if i == index then
			valueToChange = v;
			break;
		end
	end
	
	if typeof(index) == "number" then table.remove(dictionary, index) else rawset(dictionary, index, nil) end
	rawset(dictionary, newIndex, valueToChange);
end

local function concatDictionaryList(superDictionary, subDictionary)
	for i, v in pairs(subDictionary) do
		if typeof(i) == "string" then
			superDictionary[i] = v
		else
			superDictionary[#superDictionary+1] = v
		end
	end
	return superDictionary
end

cache.__newindex = function(t, k, v)
	warn("Attempt to modify read-only Cache object")
end

local bind = Instance.new("BindableEvent")

local function removeTableValue(dict, key)
	local indices = {}
	local values = {}
	for i, v in pairs(dict) do
		table.insert(indices, i)
		table.insert(values, v)
	end
	dict = {}
	local indexToRemove = table.find(indices, key)
	table.remove(indices, indexToRemove)
	table.remove(values, indexToRemove)
	for i = 1, #indices do
		dict[indices[i]] = values[i]
	end
	return dict
end

function cache.new()
	local self = setmetatable({}, cache)
	rawset(self, "_storage", {})
	rawset(self, "_Bindable", bind:Clone())
	return self
end

function cache:addData(data) --has to be added as a table = {dataLabel, (info)...}
	assert(typeof(data[1]) == "string", "Data doesn't have a label.")
	local label = table.remove(data, 1)
	if self._storage[label] ~= nil then
		warn("Added data into existing data cache '"..label.."'")
		rawget(self, "_Bindable"):Fire("added", data)
		rawset(self._storage, label, concatDictionaryList(rawget(self._storage, label), data))
		return
	end
	rawget(self, "_Bindable"):Fire("added", data)
	rawset(self._storage, label, data)
end

function cache:removeData(label, key) --Only include 'key' if data was in array format
	local dataPoolIntended = rawget(self._storage, label)
	if key then
		rawget(self, "_Bindable"):Fire("removed", dataPoolIntended[key])
		rawset(self._storage, label, removeTableValue(dataPoolIntended, key))
	else
		rawget(self, "_Bindable"):Fire("removed", label)
		rawset(self._storage, label, nil)
	end
end

function cache:getData(label, key)
	local dataTable = rawget(self._storage, label)
	assert(dataTable~=nil, "Data doesn't exist in cache.")
	if key then
		assert(dataTable[key]~=nil, "Data doesn't exist in cache.")
		return dataTable[key]
	end
	return dataTable
end

function cache:updateData(label, key, value)
	rawset(self._storage[label], key, value)
end

function cache:bindToAddedEvent(func)
	rawget(self, "_Bindable").Event:Connect(function(comm, ...)
		if comm == "added" then
			func(...)
		end
	end)
end

function cache:updateDataIndex(label, index, newindex)
	updateIndex(rawget(self._storage, label), index, newindex);
end

function cache:bindToRemoveEvent(func)
	rawget(self, "_Bindable").Event:Connect(function(comm, ...)
		if comm == "removed" then
			func(...)
		end
	end)
end

function cache:serializeData()
	local dataPool = rawget(self, "_storage")
	local Names = {}
	local data = {}
	
	for i, v in pairs(dataPool) do
		table.insert(Names, i)
		table.insert(data, v)
	end
	
	return {Names, data}
end

function cache.deserializeData(serializedData)
	local Names = serializedData[1]
	local data = serializedData[2]
	local NewCache = cache.new()
	
	for i, v in pairs(data) do
		rawset(NewCache._storage, Names[i], v)
	end
	
	return NewCache
end

function cache:num(label)
	local dataTable = rawget(self._storage, label)
	assert(dataTable~=nil, "Data doesn't exist in cache.")
	local num = 0
	for i, v in pairs(dataTable) do
		num = num + 1
	end
	return num
end

function cache:disposeCache()
	rawget(self, "_Bindable"):Destroy()
	rawset(self, "_Bindable", nil)
	rawset(self, "_storage", nil)
	self = nil
end

return cache
