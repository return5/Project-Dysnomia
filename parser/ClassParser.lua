local ClassAndRecordParser <const> = require('parser.ClassAndRecordParser')
local setmetatable <const> = setmetatable
local match <const> = string.match

local ClassParser <const> = {type = 'ClassParser'}
ClassParser.__index = ClassParser

setmetatable(ClassParser,ClassAndRecordParser)

_ENV = ClassParser


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

function ClassParser:startParsingClass(parentParams)

end

function ClassParser:new(returnMode,startI)
	local o <const> = setmetatable(ClassAndRecordParser:new(returnMode,startI),self)
	o.tokenFuncs['endClass'] = ClassParser.parseEndClass
	o.foundConstructor = false
	return o
end


return ClassParser
