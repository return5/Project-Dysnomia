local TokenParser <const> = require('dysnomiaParser.TokenParser')
local setmetatable <const> = setmetatable
local concat <const> = table.concat
local match <const> = string.match

local LambdaParser <const> = {type = "LambdaParser"}
LambdaParser.__index = LambdaParser

setmetatable(LambdaParser,TokenParser)

_ENV = LambdaParser

function LambdaParser:balancedBrackets()
	return self.bracketCount == 0 and self.parensCount == 0 and self.bracesCount == 0
end

local countersMatches <const> = {
	["("] = function(parser) parser.parensCount = parser.parensCount + 1 end,
	[")"] = function(parser) parser.parensCount = parser.parensCount - 1 end,
	["["] = function(parser) parser.bracketCount = parser.bracketCount + 1 end,
	["]"] = function(parser) parser.bracketCount = parser.bracketCount - 1 end,
	["{"] = function(parser) parser.bracesCount = parser.bracesCount + 1 end,
	["}"] = function(parser)  parser.bracesCount = parser.bracesCount - 1 end
}

function LambdaParser:parseInput(parserParams)
	local char <const> = parserParams:getCurrentToken()
	if (self:endingFunc(char) and self:balancedBrackets()) or not parserParams:isIWithinLen() then
		return self:finishLambda(parserParams)
	end
	if countersMatches[char] then
		countersMatches[char](self)
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

local function matchNonSpaces(char)
	return match(char,"%S")
end

local function eraseDysTextUntil(dysText,charMatchFunc)
	if match(dysText:getCurrent(),"%s") then
		dysText:loopBackUntil(matchNonSpaces,dysText.eraseEndingText)
	end
	dysText:loopBackUntil(charMatchFunc,dysText.eraseEndingText)
end

local singleParamMatchers <const> = {
	[")"] = true,
	["("] = true,
	["]"] = true,
	["["] = true,
	["{"] = true,
	["}"] = true,
	["\t"] = true,
	[" "] = true,
	["\n"] = true,
	["\r"] = true,
	[";"] = true,
	[","] = true,
	["->"] = true,
	["and"] = true,
	["or"] = true,
	["="] = true
}

local multiParamMatchers <const> = {
	['('] = true
}

local function matchSingleParam(char)
	return singleParamMatchers[char]
end

local function matchMultiParam(char)
	return multiParamMatchers[char]
end

function LambdaParser:setParams(parserParams)
	local paramStartI <const> = self:loopBackUntilMatch(parserParams,parserParams:getI() - 1,"%S",self.doNothing)
	local char <const> = parserParams:getAt(paramStartI)
	if char ~= ")" then
		self:setSingleParam(char)
		eraseDysTextUntil(parserParams:getDysText(),matchSingleParam)
		return self
	end
	self:setMultiParams(parserParams,paramStartI - 1)
	eraseDysTextUntil(parserParams:getDysText(),matchMultiParam)
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

function LambdaParser:startParsing(parserParams)
	self:setParams(parserParams)
	self:generateFunction(parserParams)
	return self
end

function LambdaParser:new(returnMode)
	return setmetatable({returnMode = returnMode,parensCount = 0,bracesCount = 0,bracketCount = 0},self)
end

return LambdaParser

