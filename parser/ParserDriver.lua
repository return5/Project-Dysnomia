local UpdateOpParser <const> = require('parser.UpdateOpParser')
local VarParser <const> = require('parser.VarParser')
local GlobalParser <const> = require('parser.GlobalParser')
local FunctionParser <const> = require('parser.FunctionParser')
local LocalParser <const> = require('parser.LocalParser')
local RequireParser <const> = require('parser.RequireParser')
local TokenParser <const> = require('parser.TokenParser')

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

function ParserDriver:parseVar(parserParams)
	return VarParser:parseInput(parserParams)
end

function ParserDriver:parseGlobal(parserParams)
	return GlobalParser:parseInput(parserParams)
end

function ParserDriver:parseFunction(parserParams)
	return FunctionParser:parseInput(parserParams)
end

function LocalParser:parseLocal(parserParams)
	return LocalParser:parseInput(parserParams)
end

function LocalParser:parseRequire(parserParams)
	return RequireParser:parseInput(parserParams)
end

local function postConstruct()
	TokenParser.parserDriver = ParserDriver
end

postConstruct()

return ParserDriver
