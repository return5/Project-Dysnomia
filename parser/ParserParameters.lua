local setmetatable <const> = setmetatable

local ParserParameters <const> = {type = 'ParserParameters'}
ParserParameters.__index = ParserParameters


_ENV = ParserParameters

function ParserParameters:updateSetI(currentMode,newI)
	self.i = newI
	self.currentMode = currentMode
	return self
end

function ParserParameters:update(currentMode,incr)
	self.i = self.i + incr
	self.currentMode = currentMode
	return self
end

function ParserParameters:new(currentMode,i,tokens,dysText)
	return setmetatable({currentMode = currentMode,i = i, tokens =tokens,dysText = dysText},self)
end

return ParserParameters
