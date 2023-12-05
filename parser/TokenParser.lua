local match <const> = string.match

local TokenParser <const> = {type = 'TokenParser'}
TokenParser.__index = TokenParser

_ENV = TokenParser

TokenParser.returnMode = TokenParser

function TokenParser:addOp(parserParams)
	self.parserDriver:parseAddOp(parserParams)
	parserParams:setCurrentMode(self)
	return self
end

function TokenParser:subOp(parserParams)
	self.parserDriver:parseSubOp(parserParams)
	parserParams:setCurrentMode(self)
	return self
end

function TokenParser:divOp(parserParams)
	self.parserDriver:parseDivOp(parserParams)
	parserParams:setCurrentMode(self)
	return self
end

function TokenParser:multOp(parserParams)
	self.parserDriver:parseMultOp(parserParams)
	parserParams:setCurrentMode(self)
	return self
end

function TokenParser.doNothing() end

function TokenParser:loopBackUntilMatch(text,from,to,doFunc)
	local index = from
	while index > 0 and not match(text:getAt(index),to) do
		doFunc(text:getAt(index),index)
		index = index - 1
	end
	return index
end

function TokenParser:loopUntilMatch(parserParams,start,toFind,doFunc)
	local index = start
	local stopI <const> = #parserParams:getTokens()
	while index <= stopI and not match(parserParams:getAt(index),toFind) do
		doFunc(parserParams:getAt(index),index)
		index = index + 1
	end
	return index
end

function TokenParser.trimString(str)
	return match(str,"^%s*(.-)%s*$")
end

function TokenParser:parseVar(parserParams)
	self.parserDriver:parseVar(parserParams)
	parserParams:setCurrentMode(self)
	return self
end

function TokenParser:parseGlobal(parserParams)
	self.parserDriver:parseGlobal(parserParams)
	parserParams:setCurrentMode(self)
	return self
end

function TokenParser:parseFunction(parserParams)
	self.parserDriver:parseFunction(parserParams)
	parserParams:setCurrentMode(self)
	return self
end

function TokenParser:parseLocal(parserParams)
	self.parserDriver:parseLocal(parserParams)
	parserParams:setCurrentMode(self)
	return self
end

function TokenParser:parseRequire(parserParams)
	self.parserDriver:parseRequire(parserParams)
	parserParams:setCurrentMode(self)
	return self
end

function TokenParser:parseEndRec(parserParams)
	--parserParams:getDysText():write('endRec')
	parserParams:update(self.returnMode,1)
	return self
end

function TokenParser:parseRecord(parserParams)
	return TokenParser.parserDriver:parseRecord(parserParams,self)
end

TokenParser.tokenFuncs = {
	['var'] = TokenParser.parseVar,
	['global'] = TokenParser.parseGlobal,
	["+="] = TokenParser.addOp,
	["-="] = TokenParser.subOp,
	["/="] = TokenParser.divOp,
	["*="] = TokenParser.multOp,
	['function'] = TokenParser.parseFunction,
	['local'] = TokenParser.parseLocal,
	['require'] = TokenParser.parseRequire,
	['endRec'] = TokenParser.parseEndRec,
	['record'] = TokenParser.parseRecord
}

function TokenParser:parseInput(parserParams)
	if self.tokenFuncs[parserParams:getCurrentToken()] then
		return self.tokenFuncs[parserParams:getCurrentToken()](self,parserParams)
	end
	parserParams:getDysText():write(parserParams:getCurrentToken())
	parserParams:update(self,1)
	return self
end

return TokenParser
