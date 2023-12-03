local setmetatable <const> = setmetatable
local match <const> = string.match

local ParserParameters <const> = {type = 'ParserParameters'}
ParserParameters.__index = ParserParameters


_ENV = ParserParameters


function ParserParameters:isTokenMatchExpression(index,expression)
	return match(self.tokens[index],expression)
end

function ParserParameters:isTokenMatch(index,toMatch)
	return self.tokens[index] == toMatch
end

function ParserParameters:getCurrentToken()
	return self.tokens[self.i]
end

function ParserParameters:getTokenAtI(index)
	return self.tokens[index]
end

function ParserParameters:updateSetI(currentMode,newI)
	self.i = newI
	self.currentMode = currentMode
	return self
end

function ParserParameters:getI()
	return self.i
end

function ParserParameters:getTokens()
	return self.tokens
end

function ParserParameters:update(currentMode,incr)
	self.i = self.i + incr
	self.currentMode = currentMode
	return self
end

function ParserParameters:getDysText()
	return self.dysText
end

function ParserParameters:new(currentMode,i,tokens,dysText)
	return setmetatable({currentMode = currentMode,i = i, tokens = tokens,dysText = dysText},self)
end

return ParserParameters
