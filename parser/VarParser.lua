local TokenParser <const> = require('parser.TokenParser')
local setmetatable <const> = setmetatable

local VarParser <const> = {type = 'VarParser'}
VarParser.__index = VarParser

setmetatable(VarParser,TokenParser)

_ENV = VarParser

local function matchVarFlags(flags)
	return function(text)
		if text and #text > 0 and text ~= "," then
			flags[text] = true
		end
	end
end

function VarParser:scrapeVarFlags(newI,parserParams,flags)
	local finalI <const> = self:loopUntilMatch(parserParams,newI + 1,"[^<=;\n]",matchVarFlags(flags))
	if flags['global'] then
		flags['local'] = false
		flags['const'] = false
	elseif flags['mutable'] then
		flags['const'] = false
	end
	return finalI + 1,flags
end

function VarParser:getFlags(newI,parserParams)
	local flags <const> = {['local'] = true, ['const'] = true}
	if parserParams.tokens[newI] == "<" then
		return self:scrapeVarFlags(newI,parserParams,flags)
	end
	return newI,flags
end

function VarParser:addToVarName(text)
	local str <const> = self.trimString(text)
	if str and #str > 0 and str ~= "," then
		self.varName[#self.varName + 1] = str
	end
	return self
end

function VarParser:parseVarNames()
	return function(parserParams,index)
		return self:addToVarName(parserParams.tokens[index])
	end
end

local function writeLocal(parserParams,flags)
	if flags['local'] then
		parserParams.dysText:write('local ')
	end
end

function VarParser:writeVars(parserParams,flags)
	writeLocal(parserParams,flags)
	if #self.varNames > 0 then
		for i=1,#self.varNames - 1,1 do
			self:writeVar(self.varNames[i],flags,parserParams)
			parserParams.dysText:write(',')
		end
		self:writeVar(self.varNames[#self.varNames],flags,parserParams)
	end
	return self
end

function VarParser:writeVar(var,flags,parserParams)
	parserParams.dysText:write(var)
	if flags['const'] then
		parserParams.dysText:write(" <const> ")
	end
	return self
end

function VarParser:parseInput(parserParams)
	self.varNames = {}
	local newI <const> = self:loopUntilMatch(parserParams,parserParams.i + 1,"[^<=;\n]",self:parseVarNames())
	local finalI <const>, flags <const> = self:getFlags(newI,parserParams)
	self:writeVars(parserParams,flags)
	parserParams:updateSetI(TokenParser,finalI)
	return self
end

return VarParser
