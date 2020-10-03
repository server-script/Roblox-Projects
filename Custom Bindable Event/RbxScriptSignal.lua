local RbxScriptSignal = {}
RbxScriptSignal.__index = RbxScriptSignal

local RbxScriptConnection = require(script.Parent.RbxScriptConnection)

function RbxScriptSignal.new()
	local self = setmetatable({}, RbxScriptSignal)
	self._functions = {}
	self._fired = false
	self._yielded = {}
	self._Connection = RbxScriptConnection.new(self)
	return self
end

function RbxScriptSignal:Connect(func)
    	table.insert(self._functions, func)
   	self._Connection.Connected = true
	return self._Connection
end

function RbxScriptSignal:Wait()
	table.insert(self._yielded, coroutine.running())
	return coroutine.yield()
end

function RbxScriptSignal:_Signal(...)
	if self._Connection.Connected then
		self._fired = true
		for _, func in ipairs(self._functions) do
			coroutine.wrap(func)(...)
		end
		for _, coro in ipairs(self._yielded) do
			coroutine.resume(coro, ...)
		end
	end
end

function RbxScriptSignal:_Destroy()
	self._Connection:_Destroy()
	self._Connection = nil
	self._fired = nil
	self._yielded = nil
	self._functions = nil
	self = nil
end

return RbxScriptSignal
