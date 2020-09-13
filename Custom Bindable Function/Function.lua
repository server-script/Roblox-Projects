local Function = {}

Function.InvokeTimeOut = 3

function Function.new()
    local self = setmetatable({}, {__index = Function, __newindex = function(Func, key, value)
        if key == "OnInvoke" then
            assert(typeof(value) == "function", "OnInvoke callback must be a function!")
            rawset(Func, "_OnInvokes", value)
        end
    end})
	return self
end

function Function:Invoke(...)
	local invokes = rawget(self, "_OnInvokes")
	if invokes then
		coroutine.wrap(invokes)(...)
	else
		local countdownOver = false
		coroutine.wrap(function()
			wait(Function.InvokeTimeOut)
			countdownOver = true
		end)()
		repeat
			wait()
		until rawget(self, "_OnInvokes") ~= nil or countdownOver
		if rawget(self, "_OnInvokes") ~= nil then
			self:Invoke(...)
		else
			warn("Invoke method timeout error!")
		end
	end
end

return Function