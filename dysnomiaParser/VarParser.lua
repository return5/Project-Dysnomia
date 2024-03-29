local TokenParser <const> = require('dysnomiaParser.TokenParser')

local VarParser <const> = {type = 'VarParser'}
VarParser.__index = VarParser

setmetatable(VarParser,TokenParser)

_ENV = VarParser

 function VarParser:matchVarFlags()
	return function(text)
		if text and #text > 0 and text ~= "," then
			self.flags[text] = true
		end
	end
end

function VarParser:scrapeVarFlags(newI,parserParams)
	local finalI <const> = self:loopUntilMatch(parserParams,newI + 1,"[>=;\n]",self:matchVarFlags())
	if self.flags['global'] then
		self.flags['local'] = false
		self.flags['const'] = false
	elseif self.flags['mutable'] then
		self.flags['const'] = false
	end
	return finalI + 1
end

function VarParser:getFlags(newI,parserParams)
	self.flags = {['local'] = true, ['const'] = true}
	if parserParams:isTokenMatch(newI,"<") then
		return self:scrapeVarFlags(newI,parserParams)
	end
	return newI
end

function VarParser:addToVarNames(text)
	local str <const> = self.trimString(text)
	if str and #str > 0 and str ~= "," then
		self.varNames[#self.varNames + 1] = str
	end
	return self
end

function VarParser:parseVarNames()
	return function(token)
		return self:addToVarNames(token)
	end
end

function VarParser:writeLocal(parserParams)
	if self.flags['local'] then
		parserParams:getDysText():write('local ')
	end
end

function VarParser:writeVarNames(parserParams)
	if #self.varNames > 0 then
		for i=1,#self.varNames - 1,1 do
			self:writeVar(i,parserParams)
			parserParams:getDysText():write(',')
		end
		self:writeVar(#self.varNames,parserParams)
	end
	return self
end

function VarParser:writeVars(parserParams)
	self:writeLocal(parserParams)
	self:writeVarNames(parserParams)
	return self
end

function VarParser:writeVar(i,parserParams)
	parserParams:getDysText():write(self.varNames[i])
	if self.flags['const'] then
		parserParams:getDysText():write(" <const> ")
	end
	return self
end

function VarParser:parseInput(parserParams)
	self.varNames = {}
	local newI <const> = self:loopUntilMatch(parserParams,parserParams:getI() + 1,"[<=;\n]",self:parseVarNames())
	local finalI <const> = self:getFlags(newI,parserParams)
	self:writeVars(parserParams)
	parserParams:updateSetI(TokenParser,finalI)
	return self
end

return VarParser

