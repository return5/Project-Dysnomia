
local setmetatable <const> = setmetatable 

local Variable <const> = {}
Variable.__index = Variable

_ENV = Variable

function Variable:new(name,flags)
	return setmetatable({name = name, flags = flags},self)
end

return Variable
