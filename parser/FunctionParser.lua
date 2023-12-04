local TokenParser <const> = require('parser.TokenParser')

local FunctionParser <const> = {type = 'FunctionParser'}
FunctionParser.__index = FunctionParser

setmetatable(FunctionParser,TokenParser)

_ENV = FunctionParser

function FunctionParser:parseInput(parseParameters)
	local newI <const> = self:loopBackUntilMatch(parseParameters,parseParameters:getI() - 1, "%S+",self.doNothing)
	if  self.trimString(parseParameters:getTokenAtI(newI)) == "=" then
		parseParameters:getDysText():write('function')
	else
		parseParameters:getDysText():write('local function')
	end
	parseParameters:update(TokenParser,1)
	return self
end


return FunctionParser
