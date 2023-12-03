local TokenParser <const> = require('TokenParser')

local UpdateOpParser <const> = {type = 'UpdateOpParser'}
UpdateOpParser.__index = UpdateOpParser

setmetatable(UpdateOpParser,TokenParser)

_ENV = UpdateOpParser

function UpdateOpParser:parseUpdateOp(parserParams)
	local varI <const> = self.loopBackUntil(parserParams,parserParams:getI() - 1,self.matchText,"%^s*$",self.doNothing)
	parserParams:getDysText():writeThreeArgs("= ",parserParams:getTokenAtI(varI),self.op)
	parserParams:update(TokenParser,1)
	return self
end

function UpdateOpParser:new(op)
	return setmetatable({op = op},self)
end

return UpdateOpParser
