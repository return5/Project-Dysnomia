local TokenParser <const> = require('parser.TokenParser')
local setmetatable <const> = setmetatable

local UpdateOpParser <const> = {type = 'UpdateOpParser'}
UpdateOpParser.__index = UpdateOpParser

setmetatable(UpdateOpParser,TokenParser)

_ENV = UpdateOpParser

function UpdateOpParser:parseUpdateOp(parserParams)
	local varI <const> = self:loopBackUntilMatch(parserParams,parserParams:getI() - 1,"%S+",self.doNothing)
	parserParams:getDysText():writeThreeArgs("= ",parserParams:getAt(varI),self.op)
	parserParams:update(TokenParser,1)
	return self
end

function UpdateOpParser:new(op)
	return setmetatable({op = op},self)
end

return UpdateOpParser
