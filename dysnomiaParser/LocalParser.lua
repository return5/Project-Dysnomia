local TokenParser <const> = require('dysnomiaParser.TokenParser')

local LocalParser <const> = {type = 'LocalParser'}
LocalParser.__index = LocalParser

setmetatable(LocalParser,TokenParser)

_ENV = LocalParser

function LocalParser:parseInput(parserParams)
	parserParams:getDysText():write('local ')
	local nextI <const> = self:loopUntilMatch(parserParams,parserParams:getI() + 1, "%S",self.doNothing)
	if parserParams:isTokenMatch(nextI,"function") then
		parserParams:getDysText():write("function")
		parserParams:updateSetI(TokenParser,nextI + 1)
	else
		parserParams:updateSetI(TokenParser,nextI)
	end
	return self
end

return LocalParser

