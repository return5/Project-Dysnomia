local LambdaParser <const> = require('parser.lambda.LambdaParser')

local setmetatable <const> = setmetatable


local MultiStatementLambda <const> = {type = "MultiStatementLambda"}
MultiStatementLambda.__index = MultiStatementLambda

setmetatable(MultiStatementLambda,LambdaParser)

_ENV = MultiStatementLambda

function MultiStatementLambda:finishLambda(parserParams)
	parserParams:getDysText():write(" end ")
	parserParams:update(self.returnMode,1)
	return self
end

local endingChars <const> = {
	["}"] = true,
}

function MultiStatementLambda:endingFunc(char)
	return endingChars[char]
end

function MultiStatementLambda:startParsing(parserParams,bodyStartI)
	LambdaParser.startParsing(self,parserParams)
	parserParams:updateSetI(self,bodyStartI + 1)
	return self
end

function MultiStatementLambda:new(returnMode)
	return setmetatable(LambdaParser:new(returnMode),self)
end

return MultiStatementLambda

