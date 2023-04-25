
local setmetatable <const> = setmetatable

local Variable <const> = {}
Variable.__index = Variable


function Variable:writeVar(text,index)
	text[index] = self.scope .. self.name .. self.mutable
end

function Variable:new(name,line,loc)
	return setmetatable({name = name, loc = loc, line = line, scope = "local ", mutable = " <const>"},self)
end

return Variable
