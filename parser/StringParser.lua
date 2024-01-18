local TokenParser <const> = require('parser.TokenParser')
local setmetatable <const> = setmetatable

local StringParser <const> = {type = "StringParser"}
StringParser.__index = StringParser

setmetatable(StringParser,TokenParser)

_ENV = StringParser

function StringParser:parseInput(parserParams)
	if parserParams:isCurrentToken(self.endChar) and not parserParams:isPrevToken("\\") then
		parserParams:update(self.returnMode,1)
	else
		parserParams:update(self,1)
	end
	return self
end

function StringParser:new(returnMode,endChar)
	return setmetatable({returnMode = returnMode,endChar},self)
end

return StringParser
