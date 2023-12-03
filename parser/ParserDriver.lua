local UpdateOpParser <const> = require('parser.UpdateOpParser')

local ParserDriver <const> = {type = 'ParserDriver'}
ParserDriver.__index = ParserDriver

_ENV = ParserDriver

local addUpOp <const> = UpdateOpParser:new(" +")
local subUpOp <const> = UpdateOpParser:new(" -")
local multUpOp <const> = UpdateOpParser:new(" *")
local divUpOp <const> = UpdateOpParser:new(" /")

function ParserDriver:parseAddOp(parserParams)
	return addUpOp:parseUpdateOp(parserParams)
end

function ParserDriver:parseSubOp(parserParams)
	return subUpOp:parseUpdateOp(parserParams)
end

function ParserDriver:parseDivOp(parserParams)
	return divUpOp:parseUpdateOp(parserParams)
end

function ParserDriver:parseMultOp(parserParams)
	return multUpOp:parseUpdateOp(parserParams)
end


return ParserDriver
