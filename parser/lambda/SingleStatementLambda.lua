local LambdaParser <const> = require('parser.lambda.LambdaParser')

local setmetatable <const> = setmetatable

local SingleStatementLambda <const> = {type = "SingleStatementLambda"}
SingleStatementLambda.__index = SingleStatementLambda

setmetatable(SingleStatementLambda,LambdaParser)

_ENV = SingleStatementLambda

function SingleStatementLambda:parseInput(parserParams)
	if self:endingFunc(parserParams) or not parserParams:isIWithinLen() then
		return self:finishLambda(parserParams)
	end
	return LambdaParser.parseInput(self,parserParams)
end

function SingleStatementLambda:finishLambda(parserParams)
	parserParams:getDysText():write(" end ")
	parserParams:update(self.returnMode,0)
	return self
end

local endingChars <const> = {
	[";"] = true,
	[","] = true,
	["\n"] = true,
	["\r"] = true,
	["end"] = true,
	[")"] = true,
	["]"] = true,
	["}"] = true
}

function SingleStatementLambda:endingFunc(parserParams)
	return endingChars[parserParams:getCurrentToken()]
end

function SingleStatementLambda:startParsing(parserParams)
	LambdaParser.startParsing(self,parserParams)
	parserParams:getDysText():write("return ")
	parserParams:update(self,1)
	return self
end

function SingleStatementLambda:new(returnMode)
	return setmetatable(LambdaParser:new(returnMode),self)
end

return SingleStatementLambda

