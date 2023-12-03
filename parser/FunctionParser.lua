local TokenParser <const> = require('parser.TokenParser')
local setmetatable <const> = setmetatable

local FunctionParser <const> = {type = 'FunctionParser'}
FunctionParser.__index = FunctionParser

setmetatable(FunctionParser,TokenParser)

_ENV = FunctionParser

function FunctionParser:parseInput(parseParameters)
	local newI <const> = self:loopBackUntil(parseParameters,parseParameters:getI() - 1, "%S+",self.doNothing)
	if  self.trimString(parseParameters:getTokenAt(newI)) == "=" then
		parseParameters:GetDysText():write('function')
	else
		parseParameters:GetDysText():write('local function')
	end
	parseParameters:update(TokenParser,1)
	return self
end


return FunctionParser
