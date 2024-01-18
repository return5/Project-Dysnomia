local TokenParser <const> = require('parser.TokenParser')
local LambdaTopLevelScope <const> = require('parser.lambda.LambdaTopLevelScope')
local LambdaScope <const> = require('parser.lambda.LambdaScope')
local StringParser <const> = require('parser.StringParser')
local BracketStringParser <const> = require('parser.BracketStringParser')
local setmetatable <const> = setmetatable

local LambdaParser <const> = {type = "LambdaParser"}
LambdaParser.__index = LambdaParser

setmetatable(LambdaParser,TokenParser)

_ENV = LambdaParser

function LambdaParser:returnDoubleQuoteStringParser(parserParams)
	parserParams:update(StringParser:new(self,'"'),1)
	return self
end

function LambdaParser:returnSingleQuoteStringParser(parserParams)
	parserParams:update(StringParser:new(self,"'"),1)
	return self
end

function LambdaParser:returnDoubleBracketStringParser(parserParams)
	parserParams:update(BracketStringParser:new(self),1)
	return self
end

local strings = {
	["'"] = LambdaParser.returnDoubleQuoteStringParser,
	["'"] = LambdaParser.returnSingleQuoteStringParser
}

function LambdaParser:parseInput(parserParams)
	local currentToken <const> = parserParams:getCurrentToken()
	if strings[currentToken] then return strings[currentToken](self,parserParams) end
	if currentToken == "[" and parserParams:isPrevToken("[") then return self:returnDoubleBracketStringParser(parserParams) end

end

function LambdaParser:startParsing(parserParams)
	-- () ->
	-- a -> a
	-- (a,b) ->
--	func(a -> b,c -> d) if true then return f -> g end statement; g -> h

end

function LambdaParser:new(returnMode)
	return setmetatable({scope = LambdaTopLevelScope:new(),returnMode = returnMode,braceCount = 0},self)
end

return LambdaParser
