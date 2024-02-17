local TokenParser <const> = require('dysnomiaParser.TokenParser')
local RecordParser <const> = require('dysnomiaParser.classandrecord.RecordParser')

local GlobalParser <const> = {type = 'GlobalParser'}

GlobalParser.__index = GlobalParser

setmetatable(GlobalParser,TokenParser)

_ENV = GlobalParser

function GlobalParser:parseInput(parserParams)
	local nextI <const> = self:loopUntilMatch(parserParams,parserParams:getI() + 1,"%S",self.doNothing)
	if parserParams:isTokenMatch(nextI,"function") then
		parserParams:getDysText():write('function')
		parserParams:updateSetI(parserParams.currentMode,nextI + 1)

	elseif parserParams:isTokenMatch(nextI,"record") then
		parserParams:setI(nextI)
		RecordParser:new(parserParams.currentMode,parserParams:getDysText():getLength()):startParsingRecord(parserParams)
		return self
	else
		parserParams:getDysText():write("global ")
		parserParams:updateSetI(parserParams.currentMode,nextI)
	end
	return self
end

return GlobalParser
