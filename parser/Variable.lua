
local setmetatable <const> = setmetatable 

local Variable <const> = {}
Variable.__index = Variable

_ENV = Variable


function Variable:writeVar(text)
	text[#text + 1] = self.name
	if self.flags['const'] then
		text[#text + 1] = " <const>"
	end
	return self
end

function Variable:new(name,flags)
	return setmetatable({name = name, flags = flags},self)
end

return Variable
