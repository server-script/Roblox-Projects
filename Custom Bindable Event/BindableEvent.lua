local Event = {}
Event.__index = Event
local RbxScriptSignal = require(script.RbxScriptSignal)

function Event.new(customEventName)
	customEventName = customEventName or "Event"
	local self = setmetatable({}, Event)
	self._Name = customEventName
	self[customEventName] = RbxScriptSignal.new()
	return self
end

function Event:Fire(...)
	self[self._Name]:_Signal(...)
end

function Event:Destroy()
	self[self._Name]:_Destroy()
	self[self._Name] = nil
	self._Name = nil
	self = nil
end

return Event