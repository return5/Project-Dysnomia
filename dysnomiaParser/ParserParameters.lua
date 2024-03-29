local setmetatable <const> = setmetatable
local match <const> = string.match

local ParserParameters <const> = {type = 'ParserParameters'}
ParserParameters.__index = ParserParameters


_ENV = ParserParameters

function ParserParameters:isIWithinLen()
	return self.i <= #self.tokens
end

function ParserParameters:isTokenMatchExpression(index,expression)
	return match(self.tokens[index],expression)
end

function ParserParameters:isTokenMatch(index,toMatch)
	return self.tokens[index] == toMatch
end

function ParserParameters:isCurrentToken(toMatch)
	return self:isTokenMatch(self.i,toMatch)
end

function ParserParameters:isPrevToken(toMatch)
	return self:isTokenMatch(self.i - 1,toMatch)
end

function ParserParameters:getCurrentToken()
	return self.tokens[self.i]
end

function ParserParameters:getAt(index)
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

function ParserParameters:setI(newI)
	self.i = newI
	return self
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

function ParserParameters:setCurrentMode(currentMode)
	self.currentMode = currentMode
	return self
end

function ParserParameters:getLength()
	return #self.tokens
end

function ParserParameters:new(currentMode,i,tokens,dysText)
	return setmetatable({currentMode = currentMode,i = i, tokens = tokens,dysText = dysText},self)
end

return ParserParameters

