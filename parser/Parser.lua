local Scope <const> = require('parser.Scope')
local setmetatable <const> = setmetatable
local match <const> = string.match
local Variable <const> = require('parser.Variable')
local io = io

local Parser <const> = {}
Parser.__index = Parser

_ENV = Parser

local GlobalScope <const> = Scope:new()

local function trimString(str)
	return match(str,"^%s*(.-)%s*$")
end

local function matchFunc(text,char)
	return match(text,char)
end

local function matchOrEmptyString(text,pat)
	return match(text,pat) or #text == 0
end

function Parser:addOp(i)

	return i + 1
end

function Parser:subOp(i)

	return i + 1
end

function Parser:divOp(i)

	return i + 1
end

function Parser:multOp(i)
	return i + 1
end

local function addToVarName()
	local varName <const> = {}
	return varName,function(text)
		local str <const> = trimString(text)
		if str and #str > 0 and str ~= "," then
			varName[#varName + 1] = str
		end
	end
end

function Parser:scrapeVarFlags(i)
	local flagNames <const> ,flagFunc <const> = addToVarName()
	local newI <const> = self:loopUntil(i + 1,match,"[^>]",flagFunc)
	io.write("new-var-I is: ",newI,"\n")
	return flagNames,newI
end

function Parser:makeVars(vars,flags)
	for i=1,#vars,1 do
		local var <const> = Variable:new(vars[i],flags)
		self.scope:addVar(var)
	end
end

function Parser:variable(i)
	local varNames <const>, varNameFunc <const> = addToVarName()
	local newI <const> = self:loopUntil(i + 1,match,"[^<=;\n]",varNameFunc)
	io.write("newI is: ",newI,"\n")
	local flags <const>, finalI <const> = self.text[newI] == "<" and self:scrapeVarFlags(newI) or {['local'] = true,['const'] = true},newI
	self:makeVars(varNames,flags)
	return finalI
end

function Parser:loopBack(from,toFunc,to)
	local i = from
	while toFunc(self.text[i],to) and i > 0 do
		i = i - 1
	end
end

function Parser:loopUntil(from,toFunc,to,doFunc)
	local i = from
	while toFunc(self.text[i],to) and i <= #self.text do
		doFunc(self.text[i])
		i = i + 1
	end
	return i
end

local functionTable <const> = {
	['var'] = Parser.variable,
	["+="] = Parser.addOp,
	["-="] = Parser.subOp,
	["/="] = Parser.divOp,
	["*="] = Parser.multOp
}

function Parser:loopText()
	local i = 1
	while i < #self.text do
		if functionTable[self.text[i]] then
			i = functionTable[self.text[i]](self,i)
		else
			i = i + 1
		end
	end
	return self.dysText
end

function Parser:new(text)
	local o <const> = setmetatable({text = text,dysText = {},scope = GlobalScope},self)
	return o
end

return Parser
