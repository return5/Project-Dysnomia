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

local function addToFlags()
	local flags <const> = {['local'] = true}
	return flags,function(text)
		local str <const> = trimString(text)
		if str and #str > 0 and str ~= "," then
			flags[str] = true
		end
	end
end

function Parser:writeDysText(text)
	self.dysText[#self.dysText + 1] = text
end

function Parser:scrapeVarFlags(i)
	local flagNames <const> ,flagFunc <const> = addToFlags()
	local newI <const> = self:loopUntil(i + 1,match,"[^>]",flagFunc)
	if flagNames['global'] then flagNames['local'] = false end
	return flagNames,newI + 1
end

function Parser:makeVars(vars,flags)
	if flags['local'] then
		self:writeDysText('local ')
	end
	for i=1,#vars,1 do
		local var <const> = Variable:new(vars[i],flags)
		self.scope:addVar(var)
		var:writeVar(self.dysText)
		self:writeDysText(',')
	end
	self.dysText[#self.dysText] = nil
end

function Parser:variable(i)
	local varNames <const>, varNameFunc <const> = addToVarName()
	local newI <const> = self:loopUntil(i + 1,match,"[^<=;\n]",varNameFunc)
	local finalI = newI
	if self.text[newI] == "<" then
		local flags
		flags,finalI = self:scrapeVarFlags(newI)
		self:makeVars(varNames,flags)
	else
		self:makeVars(varNames,{['local'] = true, ['const'] = true})
	end
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
			self.dysText[#self.dysText + 1] = self.text[i]
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
