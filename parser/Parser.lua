local setmetatable <const> = setmetatable
local match <const> = string.match

local io = io
local Parser <const> = {}
Parser.__index = Parser

_ENV = Parser

local function trimString(str)
	return match(str,"^%s*(.-)%s*$")
end

local function matchFunc(text,char)
	return match(text,char)
end

local function matchOrEmptyString(text,pat)
	return match(text,pat) or #text == 0
end

local keywords <const> = {
	['then'] = true,
	['do'] = true,
	['end'] = true,
	['function'] = true,
	['if'] = true,
	['elseif'] = true,
	['else'] = true,
	['while'] = true,
	['for'] = true,
	['local'] = true
}

local function matchFuncOrKeyWord(text,char)
	return matchFunc(text,char) or keywords[trimString(text)]
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

local function addToMathOps()
	local mathOps <const> = {}
	return mathOps,function(text)
		local str <const> = trimString(text)
		if str and #str > 0 then
			mathOps[#mathOps + 1] = str
		end
	end
end

function Parser:addOp(i)
	return self:updateOps(i," +")
end

function Parser:subOp(i)
	return self:updateOps(i," -")
end

function Parser:divOp(i)
	return self:updateOps(i," /")

end

function Parser:multOp(i)
	return self:updateOps(i," *")
end

local function doNothing() end

function Parser:updateOps(i,op)
	local varI <const> = self:loopBack(i - 1,matchFunc,"%s",doNothing)
	self:writeDysText("= ")
	self:writeDysText(self.text[varI])
	self:writeDysText(op)
	return i + 1
end

local function addToFlags()
	local flags <const> = {['local'] = true,['const'] = true}
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
	local newI <const> = self:loopUntil(i + 1,matchFunc,"[^>]",flagFunc)
	if flagNames['global'] then
		flagNames['local'] = false
		flagNames['const'] = false
	elseif flagNames['mutable'] then
		flagNames['const'] = false
	end
	return flagNames,newI + 1
end

function Parser:writeVar(var,flags)
	self:writeDysText(var)
	if flags['const'] then
		self:writeDysText(" <const>")
	end
end

function Parser:makeVars(vars,flags)
	if flags['local'] then
		self:writeDysText('local ')
	end
	for i=1,#vars,1 do
		self:writeVar(vars[i],flags)
		self:writeDysText(',')
	end
	self.dysText[#self.dysText] = nil
end

function Parser:variable(i)
	local varNames <const>, varNameFunc <const> = addToVarName()
	local newI <const> = self:loopUntil(i + 1,matchFunc,"[^<=;\n]",varNameFunc)
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

function Parser:loopBack(from,toFunc,to,doFunc)
	local i = from
	while toFunc(self.text[i],to) and i > 0 do
		doFunc(self.text[i])
		i = i - 1
	end
	return i
end

function Parser:functionFunc(i)
	local newI <const> = self:loopBack(i - 1, matchFunc,"%s",doNothing)
	local str <const> = trimString(self.text[newI])
	if "=" == str then
		self:writeDysText('function')
	else
		self:writeDysText('local function')
	end
	return i + 1
end

function Parser:localFunc(i)
	self:writeDysText('local ')
	local next <const> = self:loopUntil(i + 1,matchFunc,"[%s]",doNothing)
	--just skip over the function keyword.
	if self.text[next] == 'function' then
		self:writeDysText('function')
		return next + 1
	end
	return next
end

function Parser:globalFunc(i)
	local next <const> = self:loopUntil(i + 1,matchFunc,"[%s]",doNothing)
	--just skip over the keyword 'global'.
	if self.text[next] == 'function' then
		self:writeDysText('function')
		return next + 1
	end
	--otherwise write the word 'global' to the file.
	self:writeDysText('global ')
	return next
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
	["*="] = Parser.multOp,
	['global'] = Parser.globalFunc,
	['function'] = Parser.functionFunc,
	['local'] = Parser.localFunc
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
	local o <const> = setmetatable({text = text,dysText = {}},self)
	return o
end

return Parser
