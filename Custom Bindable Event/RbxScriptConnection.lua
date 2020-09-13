local RbxScriptConnection = {}

function RbxScriptConnection.new(parentSignal)
	local self = setmetatable({}, {__index = RbxScriptConnection})
	self.Connected = true
	self._parent = parentSignal
	return self
end

function RbxScriptConnection:Disconnect()
    self.Connected = false
    self._parent._functions = {}
    self._parent._fired = false
    self._parent._returnValue = nil
end

return RbxScriptConnection