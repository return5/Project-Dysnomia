local UpdateOpParser <const> = require('dysnomiaParser.UpdateOpParser')
local VarParser <const> = require('dysnomiaParser.VarParser')
local GlobalParser <const> = require('dysnomiaParser.GlobalParser')
local FunctionParser <const> = require('dysnomiaParser.FunctionParser')
local LocalParser <const> = require('dysnomiaParser.LocalParser')
local RequireParser <const> = require('dysnomiaParser.RequireParser')
local TokenParser <const> = require('dysnomiaParser.TokenParser')
local RecordParser <const> = require('dysnomiaParser.classandrecord.RecordParser')
local ClassParser <const> = require('dysnomiaParser.classandrecord.ClassParser')
local LambdaInit <const> = require('dysnomiaParser.lambda.LambdaInit')

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

function ParserDriver:parseLocal(parserParams)
	return LocalParser:parseInput(parserParams)
end

function ParserDriver:parseRequire(parserParams)
	return RequireParser:parseInput(parserParams)
end

function ParserDriver:parseRecord(parserParams,returnMode)
	return RecordParser:new(returnMode,parserParams:getDysText():getLength()):startParsingLocalRecord(parserParams)
end

function ParserDriver:parseClass(parserParams,returnMode)
	return ClassParser:new(returnMode,parserParams:getDysText():getLength()):startParsingClass(parserParams)
end

function ParserDriver:parseLambda(parserParams,returnMode)
	return LambdaInit:startParsing(returnMode,parserParams)
end

local function postConstruct()
	TokenParser.parserDriver = ParserDriver
end

postConstruct()

return ParserDriver
