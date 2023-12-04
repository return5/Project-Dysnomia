local Class <const> = require('parser.Class')
local Scanner <const> = require('scanner.Scanner')
local FileReader <const> = require('fileOperations.FileReader')
local FileWriter <const> = require('fileOperations.FileWriter')
local FileAttr <const> = require('fileOperations.FileAttr')
local ParserParameters <const> = require('parser.ParserParameters')
local TokenParser <const> = require('parser.TokenParser')
local DysText <const> = require('parser.DysText')
local io = io


local setmetatable <const> = setmetatable
local match <const> = string.match


local Parser <const> = {}
Parser.__index = Parser

_ENV = Parser

local classes <const> = {}

local function trimString(str)
	return match(str,"^%s*(.-)%s*$")
end

local function matchFunc(text,char)
	return text and match(text,char)
end

function Parser:checkEndRecord(i)
	return self:endOfFileCheck(i) and self.text[i] ~= "endRec"
end

function Parser:checkEndClass(i)
	return self:endOfFileCheck(i) and self.text[i] ~= "endClass"
end

function Parser:endOfFileCheck(i)
	return i <= #self.text
end

--  =================== looping functions ============

local function loopBack(from,toFunc,to,doFunc,text)
	local i = from
	while toFunc(text[i],to) and i > 0 do
		doFunc(text[i])
		i = i - 1
	end
	return i
end

function Parser:loopUntil(from,toFunc,to,doFunc)
	local i = from
	while toFunc(self.text[i],to) and i <= #self.text do
		doFunc(self.text[i])
		i = i + 1
	end
	return i
end


function Parser:scanForRequire()
	local i = 1
	while i <= #self.text do
		if self.text[i] == "require" then
			i = self:require(i)
		else
			i = i +1
		end
	end
end

function Parser:loopText(i,untilFunc)
	local j = i
	while untilFunc(self,j) do
		if Parser.functionTable[self.text[j]] then
			j = Parser.functionTable[self.text[j]](self,j)
		else
			self.dysText[#self.dysText + 1] = self.text[j]
			j = j + 1
		end
	end
	return j
end

function Parser:loopUntilClosing(start,opening,closing,func)
	local count = 1
	local i = start
	while count > 0 and i < #self.text do
		if self.text[i] == opening then
			count = count + 1
		elseif self.text[i] == closing then
			count = count - 1
		end
		func(self.text[i])
		i = i + 1
	end
	return i
end

--function Parser:loopStartStop(start,stop,func)
--	for i=start,stop,1 do
--		func(self,self.text[i])
--	end
--end

local function doNothing() end

--function Parser:localFunc(i)
--	self:writeDysText('local ')
--	local next <const> = self:loopUntil(i + 1,matchFunc,"[%s]",doNothing)
--	--just skip over the function keyword.
--	if self.text[next] == 'function' then
--		self:writeDysText('function')
--		return next + 1
--	end
--	return next
--end

local function superParams()
	local params <const> = {}
	return params,function(text)
		if text and #text > 0 then
			params[#params + 1] = text
		end
	end
end

--function Parser:require(i)
--	local prevNewLine <const> = loopBack(i - 1,matchFunc,"[^\n]",doNothing,self.text)
--	local prevNonSpace <const> = loopBack(prevNewLine - 1,matchFunc,"^%s*$",doNothing,self.text)
--	if prevNewLine > 0 and prevNonSpace > 0 and match(self.text[prevNonSpace],"#skipRequire") then
--		return i + 1
--	end
--	local parenI <const> = self:loopUntil(i + 1,matchFunc,"[^(]",doNothing)
--	local requireFile <const>, requireFunc <const> = superParams()
--	local endParenI <const> = self:loopUntil(parenI + 1,matchFunc,"[^)]",requireFunc)
--	self:loopStartStop(i,endParenI,Parser.writeDysText)
--	local openingChar <const> = match(requireFile[1],"^[\"']")
--	local fileName <const> = match(requireFile[1],"^" .. openingChar .. "(.+)" .. openingChar .."$")
--	local fileAttr <const>, isLuaFile <const> = FileReader:new(fileName):readFile()
--	if fileAttr then
--		local scanner <const> = Scanner:new(fileAttr)
--		local scanned <const> = scanner:scanFile()
--		local parser <const> = Parser:new(scanned,fileAttr.filePath)
--		if isLuaFile then
--			parser:scanForRequire()
--		else
--			parser:beginParsing()
--		end
--	end
--	return endParenI + 1
--end

--local function addToVarName()
--	local varName <const> = {}
--	return varName,function(text)
--		local str <const> = trimString(text)
--		if str and #str > 0 and str ~= "," then
--			varName[#varName + 1] = str
--		end
--	end
--end

--function Parser:addOp(i)
--	return self:updateOps(i," +")
--end
--
--function Parser:subOp(i)
--	return self:updateOps(i," -")
--end
--
--function Parser:divOp(i)
--	return self:updateOps(i," /")
--
--end
--
--function Parser:multOp(i)
--	return self:updateOps(i," *")
--end
--

--function Parser:updateOps(i,op)
--	local varI <const> = loopBack(i - 1,matchFunc,"^%s*$",doNothing,self.text)
--	self:writeDysText("= ")
--	self:writeDysText(self.text[varI])
--	self:writeDysText(op)
--	return i + 1
--end

--local function addToFlags()
--	local flags <const> = {['local'] = true,['const'] = true}
--	return flags,function(text)
--		if text and #text > 0 and text ~= "," then
--			flags[text] = true
--		end
--	end
--end

function Parser:writeDysText(text)
	self.dysText[#self.dysText + 1] = text
end

--function Parser:scrapeVarFlags(i)
--	local flagNames <const> ,flagFunc <const> = addToFlags()
--	local newI <const> = self:loopUntil(i + 1,matchFunc,"[^>]",flagFunc)
--	if flagNames['global'] then
--		flagNames['local'] = false
--		flagNames['const'] = false
--	elseif flagNames['mutable'] then
--		flagNames['const'] = false
--	end
--	return flagNames,newI + 1
--end

--function Parser:writeVar(var,flags)
--	self:writeDysText(var)
--	if flags['const'] then
--		self:writeDysText(" <const> ")
--	end
--end

--function Parser:makeVars(vars,flags)
--	if flags['local'] then
--		self:writeDysText('local ')
--	end
--	for i=1,#vars,1 do
--		self:writeVar(vars[i],flags)
--		self:writeDysText(',')
--	end
--	self.dysText[#self.dysText] = nil
--end

--function Parser:variable(i)
--	local varNames <const>, varNameFunc <const> = addToVarName()
--	local newI <const> = self:loopUntil(i + 1,matchFunc,"[^<=;\n]",varNameFunc)
--	local finalI = newI
--	if self.text[newI] == "<" then
--		local flags
--		flags,finalI = self:scrapeVarFlags(newI)
--		self:makeVars(varNames,flags)
--	else
--		self:makeVars(varNames,{['local'] = true, ['const'] = true})
--	end
--	return finalI
--end

local function recordParams(dysText)
	local params <const> = {}
	return params,function(text)
		local str <const> = trimString(text)
		if str and #str > 0 then
			dysText[#dysText + 1] = str
			if str ~= "," then
				params[#params + 1] = str
			end
		end
	end
end

function Parser:writeRecordParams(params,recName)
	self:writeDysText(")\n	local ")
	self:writeDysText(recName)
	self:writeDysText(" <const> = {")
	for j=1,#params,1 do
		self:writeDysText(params[j])
		self:writeDysText(" = ")
		self:writeDysText(params[j])
		self:writeDysText(",")
	end
	self.dysText[#self.dysText] = "}\n"
end

function Parser:writeEndRecord(recName)
	self:writeDysText(" return setmetatable({},{__index = ")
	self:writeDysText(recName)
	self:writeDysText(",__newindex = function() end,__len = function() return #")
	self:writeDysText(recName)
	self:writeDysText(" end}) end")
end

function Parser:startRecord(i)
	if self.dysText[#self.dysText] ~= "local " then
		local prevI <const> = loopBack(i - 1,matchFunc,"^%s*$",doNothing,self.text)
		if self.text[prevI] ~= "global" then self:writeDysText("local ") end
	end
	--find the index for the record name.
	local newI <const> = self:loopUntil(i + 1,matchFunc,"^%s*$",doNothing)
	local recordName <const> = self.text[newI]
	self:writeDysText("function ")
	self:writeDysText(recordName)
	self:writeDysText("(")
	--find index for the opening parenthesis.
	local startParenth <const> = self:loopUntil(newI + 1,matchFunc,"[^(]",doNothing)
	--paramFunc will add record parameters to params table.
	local params <const>, paramsFunc <const> = recordParams(self.dysText)
	--find index to closing parenthesis while also filling the params table.
	local endI <const> = self:loopUntil(startParenth + 1,matchFunc,"[^)]",paramsFunc)
	local tempRecName <const> = "__" .. recordName .. "__"
	return tempRecName,params,endI
end

--go over the code written for a record and add a 'self:' in front of all method calls if they do not have it already.
function Parser:recordSecondPass(start,stop)
	local regex <const> = self.recName .. "[:%.]"
	for i=start,stop,1 do
		if self.methods[self.dysText[i]] then
			local prevI <const> = loopBack(i - 1, matchFunc,"^%s*$",doNothing,self.dysText)
			if self.dysText[prevI] ~= "." and self.dysText[prevI] ~= ":" and not match(self.dysText[prevI],regex) then
				self.dysText[i] = "self:" .. self.dysText[i]
			end
		end
	end
end

function Parser:record(i)
	local tempRecName <const>, params <const>, endI <const> = self:startRecord(i)
	local recNameCpy <const> = self.recName
	local startRecDysText <const> = #self.dysText
	self:writeRecordParams(params,tempRecName)
	self.recName = tempRecName
	local copyMethods <const> = self.methods
	self.methods = {}
	local endRecI <const> = self:loopText(endI + 1,Parser.checkEndRecord)
	self:writeEndRecord(tempRecName)
	self:recordSecondPass(startRecDysText,#self.dysText)
	self.recName = recNameCpy
	self.methods = copyMethods
	return endRecI + 1
end

-- ==================== classes ===========================

function Parser:findParentClass(i)
	local newI <const> = self:loopUntil(i + 1, matchFunc,"^%s*$",doNothing)
	if self.text[newI] == ":" then
		local nextI <const> = self:loopUntil(newI + 1, matchFunc,"^%s*$",doNothing)
		if self.text[nextI] == ">" then
			local parentI <const> = self:loopUntil(nextI + 1,matchFunc,"^%s*$",doNothing)
			return parentI,self.text[parentI]
		end
	end
	return i,nil
end

local function classParams()
	local params <const> = {}
	return params,function(text)
		local str <const> = trimString(text)
		if str and #str > 0 and str ~= "," then
			params[#params + 1] = str
		end
	end
end

function Parser:startClass(i)
	local newI <const> = self:loopUntil(i + 1, matchFunc,"^%s*$",doNothing)
	local className <const> = self.text[newI]
	local paramsI <const> = self:loopUntil(i + 1,matchFunc,"[^(]",doNothing)
	local params <const>, paramsFunc <const> = classParams()
	--find index to closing parenthesis while also filling the params table.
	local endI <const> = self:loopUntil(paramsI + 1,matchFunc,"[^)]",paramsFunc)
	local parentI <const>, parentClass <const> = self:findParentClass(endI)
	local class <const> = Class:new(className,params,classes[parentClass])
	classes[className] = class
	return class,parentI
end

function Parser:writeFirstPartOfClass(class)
	self:writeDysText("\nlocal setmetatable <const> = setmetatable\nlocal ")
	self:writeDysText(class.name)
	self:writeDysText(" <const> = {}\n")
	self:writeDysText(class.name)
	self:writeDysText(".__index = ")
	self:writeDysText(class.name)
	self:writeDysText("\n")
	if class.parent then
		self:writeDysText("setmetatable(")
		self:writeDysText(class.name)
		self:writeDysText(",")
		self:writeDysText(class.parent.name)
		self:writeDysText(")\n")
	end
end

function Parser:writeParams(params)
	if params and #params > 0 then
		for i=1,#params,1 do
			self:writeDysText(params[i])
			self:writeDysText(",")
		end
		self.dysText[#self.dysText] = nil
	end
end

function Parser:writeClassParams(params)
	if params and #params > 0 then
		for i=1,#params,1 do
			self:writeDysText(params[i])
			self:writeDysText(" = ")
			self:writeDysText(params[i])
			self:writeDysText(",")
		end
		self.dysText[#self.dysText] = nil
	end
end

function Parser:writeChildParams(childParams,parentParams)
	if parentParams and #parentParams > 0 then
		local parentPramsDict <const> = {}
		for i=1,#parentParams,1 do
			parentPramsDict[parentParams[i]] = true
		end
		for i=1,#childParams,1 do
			if not parentPramsDict[childParams[i]] then
				self:writeDysText("\t__obj__.")
				self:writeDysText(childParams[i])
				self:writeDysText(" = ")
				self:writeDysText(childParams[i])
				self:writeDysText("\n")
			end
		end
	end
end

function Parser:writeClassConstructParent(class)
	self:writeDysText("\tlocal __obj__ = setmetatable(")
	self:writeDysText(class.parent.name)
	self:writeDysText(":new(")
	self:writeParams(class.parent.params)
	self:writeDysText("),self)\n")
	self:writeChildParams(class.params,class.parent.params)
	self:writeDysText("\treturn __obj__\nend\n")
end

function Parser:writeClassConstructNoParent(class)
	self:writeDysText("\treturn setmetatable({")
	self:writeClassParams(class.params)
	self:writeDysText("},self)\nend\n")
end

function Parser:writeClassConstructor(class)
	self:writeDysText("function ")
	self:writeDysText(class.name)
	self:writeDysText(":new(")
	self:writeParams(class.params)
	self:writeDysText(")\n")
	if class.parent then
		self:writeClassConstructParent(class)
	else
		self:writeClassConstructNoParent(class)
	end
end

function Parser:writeEndClass(class)
	if not class.foundConstructor then
		self:writeClassConstructor(class)
	end
	self:writeDysText("return ")
	self:writeDysText(class.name)
end

function Parser:class(i)
	local inClassCopy <const> = self.inClass
	self.inClass = true
	local class <const>, newI <const> = self:startClass(i)
	self.methods = {}
	self:writeFirstPartOfClass(class)
	local startRecDysText <const> = #self.dysText
	local classNameCpy <const> = self.recName
	self.recName = class.name
	local endClassI <const> = self:loopText(newI + 1,Parser.checkEndClass)
	self:recordSecondPass(startRecDysText,#self.dysText)
	self:writeEndClass(class)
	self.recName = classNameCpy
	self.inClass = inClassCopy
	return endClassI + 1
end

-- =================== class constructor ==================

function Parser:writeStartOfConstructor(params)
	self:writeDysText("function ")
	self:writeDysText(self.recName)
	self:writeDysText(":new(")
	self:writeParams(params)
	self:writeDysText(")\n")
	self:writeDysText("\t\tlocal __obj__ = setmetatable(")
end

function Parser:writeSuperConstructor(endParen)
	local parentParams <const>,parentPramFunc <const> = superParams()
	local parenI <const> = self:loopUntil(endParen + 1,matchFunc,"[^(]",doNothing)
	local endSuperI <const> = self:loopUntilClosing(parenI + 1,"(",")",parentPramFunc)
	parentParams[#parentParams] = nil
	self:writeDysText(classes[self.recName].parent.name)
	self:writeDysText(":new(")
	for i=1,#parentParams,1 do
		self:writeDysText(parentParams[i])
	end
	self:writeDysText("),self)\n")
	return endSuperI
end

function Parser:writeEndOfConstructor(params)
	self:writeDysText("\t\t__obj__:__constructor__(")
	self:writeParams(params)
	self:writeDysText(")\n\t\treturn __obj__\n\tend\n\nfunction ")
	self:writeDysText(self.recName)
	self:writeDysText(":__constructor__(")
	self:writeParams(params)
	self:writeDysText(")\n")
end

function Parser:constructor(i)
	if not self.inClass then return i + 1 end
	local newI <const> = self:loopUntil(i + 1,matchFunc,"^%s*$",doNothing)
	classes[self.recName].foundConstructor = true
	local params <const>, paramFunc <const> = classParams()
	local endParen <const> = self:loopUntil(newI + 1,matchFunc,"[^)]",paramFunc)
	self:writeStartOfConstructor(params)
	if classes[self.recName].parent then
		local endSuper <const> = self:writeSuperConstructor(endParen)
		self:writeEndOfConstructor(params)
		return endSuper + 1
	else
		self:writeDysText("{}),self)\n")
		self:writeEndOfConstructor(params)
		return endParen + 1
	end
end


function Parser:method(i)
	local newI <const> = self:loopUntil(i + 1,matchFunc,"^%s*$",doNothing)
	self.methods[self.text[newI]] = true
	self:writeDysText("function ")
	self:writeDysText(self.recName)
	self:writeDysText(":")
	self:writeDysText(self.text[newI])
	return self:loopUntil(newI + 1,matchFunc,"[^(]",doNothing)
end

--function Parser:functionFunc(i)
--	local newI <const> = loopBack(i - 1, matchFunc,"^%s*$",doNothing,self.text)
--	local str <const> = trimString(self.text[newI])
--	if "=" == str then
--		self:writeDysText('function')
--	else
--		self:writeDysText('local function')
--	end
--	return i + 1
--end

--function Parser:globalFunc(i)
--	local next <const> = self:loopUntil(i + 1,matchFunc,"[%s]",doNothing)
--	--just skip over the keyword 'global'.
--	if self.text[next] == 'function' then
--		self:writeDysText('function')
--		return next + 1
--	end
--	if self.text[next] == "record" then
--		return next
--	end
--	--otherwise write the word 'global' to the file.
--	self:writeDysText('global ')
--	return next
--end

--function Parser:beginParsing()
----	self:loopText(1,Parser.endOfFileCheck)
--	local fileWriter <const> = FileWriter:new(FileAttr:new(self.filePath,self.dysText))
	--fileWriter:writeFile()
--end

Parser.functionTable = {
	--['var'] = Parser.variable,
	--["+="] = Parser.addOp,
	--["-="] = Parser.subOp,
	--["/="] = Parser.divOp,
	--["*="] = Parser.multOp,
	--['global'] = Parser.globalFunc,
	--['function'] = Parser.functionFunc,
	--['local'] = Parser.localFunc,
	['record'] = Parser.record,
	['method'] = Parser.method,
	['class'] = Parser.class,
	['constructor'] = Parser.constructor,
--	['require'] = Parser.require
}


function Parser:beginParsing()
	local parserParameters <const> = ParserParameters:new(TokenParser,1,self.text,DysText:new())
	local index = 1
	while index <= #self.text do
	--	io.write("current token: ",parserParameters:getCurrentToken(),";;;\n")
		parserParameters.currentMode:parseInput(parserParameters)
		index = parserParameters:getI()
	end
	local fileWriter <const> = FileWriter:new(FileAttr:new(self.filePath,parserParameters:getDysText():getDysText()))
	fileWriter:writeFile()
end

function Parser:new(text,filePath)
	local o <const> = setmetatable({filePath = filePath,text = text,methods = {},inClass = false},self)
	return o
end

return Parser
