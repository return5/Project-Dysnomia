local TokenParser <const> = require('dysnomiaParser.TokenParser')

local GlobalParser <const> = {type = 'GlobalParser'}
GlobalParser.__index = GlobalParser

setmetatable(GlobalParser,TokenParser)

_ENV = GlobalParser

function GlobalParser:parseInput(parserParams)
	local nextI <const> = self:loopUntilMatch(parserParams,parserParams:getI() + 1,"%S",self.doNothing)
	if parserParams:isTokenMatch(nextI,"function") then
		parserParams:getDysText():write('function')
		parserParams:updateSetI(TokenParser,nextI + 1)

	elseif parserParams:isTokenMatch(nextI,"record") then
		parserParams:updateSetI(TokenParser,nextI)

	else
		parserParams:getDysText():write("global ")
		parserParams:updateSetI(TokenParser,nextI)
	end
	return self
end

return GlobalParser
