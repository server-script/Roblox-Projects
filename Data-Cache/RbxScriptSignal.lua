local RbxScriptSignal = {}
RbxScriptSignal.__index = RbxScriptSignal

local RbxScriptConnection = require(script.Parent.RbxScriptConnection)

function RbxScriptSignal.new()
	local self = setmetatable({}, RbxScriptSignal)
	self._functions = {}
	self._fired = false
	self._returnValue = nil
	self._Connection = RbxScriptConnection.new(self)
	return self
end

function RbxScriptSignal:Connect(func)
    table.insert(self._functions, func)
    self._Connection.Connected = true
	return self._Connection
end

function RbxScriptSignal:Wait()
	--Will implement a proper wait later. Now, I cba
	repeat
		wait() 
	until self._fired
	return unpack(self._returnValue)
end

function RbxScriptSignal:_Signal(...)
	if self._Connection.Connected then
		self._fired = true
		self._returnValue = {...}
		for _, func in ipairs(self._functions) do
			coroutine.wrap(func)(...)
		end
	end
end

function RbxScriptSignal:_Destroy()
	self._Connection:_Destroy()
	self._Connection = nil
	self._fired = nil
	self._returnValue = nil
	self._functions = nil
	self = nil
end

return RbxScriptSignal
