local LambdaParser <const> = require('parser.lambda.LambdaParser')

local write <const> = io.write
local setmetatable <const> = setmetatable

local SingleStatementLambdaParser <const> = {type = "SingleStatementLambdaParser"}
SingleStatementLambdaParser.__index = SingleStatementLambdaParser

setmetatable(SingleStatementLambdaParser,LambdaParser)

_ENV = SingleStatementLambdaParser

function SingleStatementLambdaParser:finishLambda(parserParams)
	parserParams:getDysText():writeTwoArgs(" end ",parserParams:getCurrentToken())
	parserParams:update(self.returnMode,1)
	return self
end

function SingleStatementLambdaParser:startParsing(parserParams)
	self:setParams(parserParams)
	self:generateFunction(parserParams)
	parserParams:getDysText():write("return ")
	parserParams:update(self,1)
	return self
end
local endingChars <const> = {
	[";"] = true,
	[","] = true,
	["\n"] = true,
	["end"] = true,
	[")"] = true
}

function SingleStatementLambdaParser:endingFunc(parserParams)
	return endingChars[parserParams:getCurrentToken()]
end

function SingleStatementLambdaParser:new(returnMode)
	return setmetatable(LambdaParser:new(returnMode),self)
end

return SingleStatementLambdaParser

