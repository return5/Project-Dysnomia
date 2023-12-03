local match <const> = string.match

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

function TokenParser.loopBackUntil(tokens,from,matchFunc,to,doFunc)
	local index = from
	while index > 0 and matchFunc(tokens[index],to,index) do
		doFunc(tokens,index)
		index = index - 1
	end
	return index
end

function TokenParser:loopUntilMatch(parserParams,start,toFind,doFunc)
	local index = start
	while index <= #parserParams.tokens and not match(parserParams.tokens[index],toFind) do
		doFunc(parserParams,index)
		index = index + 1
	end
	return index
end

function TokenParser.trimString(str)
	return match(str,"^%s*(.-)%s*$")
end



local tokenFuncs <const> = {
	["+="] = TokenParser.addOp,
	["-="] = TokenParser.subOp,
	["/="] = TokenParser.divOp,
	["*="] = TokenParser.multOp,
}

function TokenParser:parseInput(parserParams)
	if tokenFuncs[parserParams.tokens[parserParams.i]] then
		return tokenFuncs[parserParams.tokens[parserParams.i]](self,parserParams)
	end
	return parserParams:update(self,1)
end

return TokenParser
