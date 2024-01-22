local TokenParser <const> = require('parser.TokenParser')
local LambdaTopLevelScope <const> = require('parser.lambda.LambdaTopLevelScope')
local LambdaScope <const> = require('parser.lambda.LambdaScope')
local StringParser <const> = require('parser.StringParser')
local BracketStringParser <const> = require('parser.BracketStringParser')
local setmetatable <const> = setmetatable
local concat <const> = table.concat
local match <const> = string.match
local write <const> = io.write

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

function LambdaParser:balancedBrackets()
	return self.parenCount == 0 and self.braceCount == 0 and self.bracketCount == 0
end

local strings = {
	["'"] = LambdaParser.returnDoubleQuoteStringParser,
	["'"] = LambdaParser.returnSingleQuoteStringParser
}

function LambdaParser:parseInput(parserParams)
	local currentToken <const> = parserParams:getCurrentToken()
	if strings[currentToken] then return strings[currentToken](self,parserParams) end
	--TODO implement double bracket strings
--	if currentToken == "[" and parserParams:isPrevToken("[") then return self:returnDoubleBracketStringParser(parserParams) end
	if self:endingFunc(parserParams) or not parserParams:isIWithinLen() and self:balancedBrackets() then
		return self:finishLambda(parserParams)
	end
	return TokenParser.parseInput(self,parserParams)

end

function LambdaParser:setSingleParam(parameter)
	self.params = {parameter}
	return self
end

function LambdaParser:addToParams()
	self.params = {}
	return function(param)
		self.params[#self.params + 1] = param
	end
end

function LambdaParser:setMultiParams(parserParams,startI)
	self:loopBackUntilMatch(parserParams,startI,"%(",self:addToParams())
end

local function eraseDysTextUntil(dysText,charMatch)
	if match(dysText:getCurrent(),"%s") then
		dysText:loopBackUntil("%S",dysText.eraseEndingText)
	end
	dysText:loopBackUntil(charMatch,dysText.eraseEndingText)
end

function LambdaParser:setParams(parserParams)
	write("setting params\n")
	local paramStartI <const> = self:loopBackUntilMatch(parserParams,parserParams:getI() - 1,"%S",self.doNothing)
	local char <const> = parserParams:getAt(paramStartI)
	write("char is: ",char,"\n")
	if char ~= ")" then
		self:setSingleParam(char)
		eraseDysTextUntil(parserParams:getDysText(),"%s")
		return self
	end
	self:setMultiParams(parserParams,paramStartI - 1)
	eraseDysTextUntil(parserParams:getDysText(),"%(")
	parserParams:getDysText():eraseEndingText()
	return self
end

local function iterateParams(params,lambda)
	for i=#params,1,-1 do
		lambda[#lambda + 1] = params[i]
	end
	lambda[#lambda + 1] = ") "
end

function LambdaParser:generateFunction(parserParams)
	local funcStr <const> = {"function("}
	iterateParams(self.params,funcStr)
	parserParams:getDysText():write(concat(funcStr))
	return self
end

function LambdaParser:new(returnMode)
	return setmetatable({scope = LambdaTopLevelScope:new(),returnMode = returnMode,braceCount = 0,bracketCount = 0,parenCount = 0},self)
end

return LambdaParser
