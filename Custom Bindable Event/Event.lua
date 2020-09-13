local Event = {}

local RbxScriptSignal = require(script.RbxScriptSignal)

function Event.new()
	local self = setmetatable({}, {__index = Event})
	self.Fired = RbxScriptSignal.new(self)
	return self
end

function Event:Fire(...)
	self.Fired:_Signal(...)
end

return Event