local match <const> = string.match
local io = io

local TokenParser <const> = {type = 'TokenParser'}
TokenParser.__index = TokenParser

_ENV = TokenParser

function TokenParser:addOp(parserParams)
	return self.parserDriver:parseAddOp(parserParams)
end

function TokenParser:subOp(parserParams)
	return self.parserDriver:parseSubOp(parserParams)
end

function TokenParser:divOp(parserParams)
	return self.parserDriver:parseDivOp(parserParams)
end

function TokenParser:multOp(parserParams)
	return self.parserDriver:parseMultOp(parserParams)
end

function TokenParser.doNothing()

end

function TokenParser:loopBackUntilMatch(parserParams,from,to,doFunc)
	local index = from
	while index > 0 and not match(parserParams:getTokenAtI(index),to) do
		doFunc(parserParams:getTokenAtI(index),index)
		index = index - 1
	end
	return index
end

function TokenParser:loopUntilMatch(parserParams,start,toFind,doFunc)
	io.write("loop until match: ",toFind,"\n")
	local index = start
	local stopI <const> = #parserParams:getTokens()
	while index <= stopI and not match(parserParams:getTokenAtI(index),toFind) do
		io.write("token is: ",parserParams:getTokenAtI(index),":::\n")
		doFunc(parserParams:getTokenAtI(index),index)
		index = index + 1
	end
	return index
end

function TokenParser.trimString(str)
	return match(str,"^%s*(.-)%s*$")
end

function TokenParser:parseVar(parserParams)
	return self.parserDriver:parseVar(parserParams)
end

function TokenParser:parseGlobal(parserParams)
	return self.parserDriver:parseGlobal(parserParams)
end

function TokenParser:parseFunction(parserParams)
	return self.parserDriver:parseFunction(parserParams)
end

function TokenParser:parseLocal(parserParams)
	return self.parserDriver:parseLocal(parserParams)
end

function TokenParser:parseRequire(parserParams)
	return self.parserDriver:parseRequire(parserParams)
end

local tokenFuncs <const> = {
	['var'] = TokenParser.parseVar,
	['global'] = TokenParser.parseGlobal,
	["+="] = TokenParser.addOp,
	["-="] = TokenParser.subOp,
	["/="] = TokenParser.divOp,
	["*="] = TokenParser.multOp,
	['function'] = TokenParser.parseFunction,
	['local'] = TokenParser.parseLocal,
	['require'] = TokenParser.parseRequire
}

function TokenParser:parseInput(parserParams)
	if tokenFuncs[parserParams:getCurrentToken()] then
		return tokenFuncs[parserParams:getCurrentToken()](self,parserParams)
	else
		parserParams:getDysText():write(parserParams:getCurrentToken())
	end
	parserParams:update(TokenParser,1)
	return self
end

return TokenParser
