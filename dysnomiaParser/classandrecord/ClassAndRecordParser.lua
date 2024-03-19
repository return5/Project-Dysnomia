local TokenParser <const> = require('dysnomiaParser.TokenParser')
local setmetatable <const> = setmetatable
local match <const> = string.match
local concat <const> = table.concat
local remove <const> = table.remove

local ClassAndRecordParser <const> = {type = 'ClassAndRecordParser'}
ClassAndRecordParser.__index = ClassAndRecordParser

setmetatable(ClassAndRecordParser,TokenParser)

ClassAndRecordParser.tokenFuncs = {}
for token,func in pairs(TokenParser.tokenFuncs) do
	ClassAndRecordParser.tokenFuncs[token] = func
end

_ENV = ClassAndRecordParser

function ClassAndRecordParser:writeSelfInFrontOfMethodCall(i,dysText,regex,pattern)
	local prevI <const> = self:loopBackUntilMatch(dysText,i - 1,"%S",self.doNothing)
	local text <const> = dysText:getAt(prevI)
	if text ~= "." and text ~= ":" and not match(text,regex) and not match(text,pattern) then
		dysText:replaceTextAt(pattern .. dysText:getAt(i),i)
	end
	return self
end

function ClassAndRecordParser:secondPass(parserParams,name,sep)
	local regex <const> = name .. "[:%.]"
	local dysText <const> = parserParams:getDysText()
	local staticName <const> = self.classOrRecordName .. "."
	for i=self.startI,dysText:getLength(),1 do
		if self.class.methods[dysText:getAt(i)] then
			self:writeSelfInFrontOfMethodCall(i,dysText,regex,"self:")
		elseif self.class.staticMethods[dysText:getAt(i)] then
			self:writeSelfInFrontOfMethodCall(i,dysText,regex,staticName)
		end
	end
	self:writeCustomMetaMethods(sep,parserParams:getDysText())
	return self
end

function ClassAndRecordParser.writeParamAndCommaToDysText(dysText,param)
	dysText:writeTwoArgs(param,",")
end

function ClassAndRecordParser:writeParamsToDysText(dysText,params,loopFunc,endingFunc)
	if #params > 0 then
		for i=1,#params - 1,1 do
			loopFunc(dysText,params[i])
		end
	end
	endingFunc(dysText,params[#params])
	return self
end

local function clearWord(word)
	for i=1,#word,1 do
		remove(word)
	end
end

function ClassAndRecordParser:returnFunctionAddingTextToParams(params)
	return function(text,word)
		if text and #text > 0 and text ~= "," then
			word[#word + 1] = text
		elseif text and #text > 0 and text == "," then
			params[#params + 1] = concat(word)
			clearWord(word)
		end
	end
end

function ClassAndRecordParser:parseMethodName(parserParams)
	local newI <const> = self:loopUntilMatch(parserParams,parserParams:getI() + 1,"%S",self.doNothing)
	return newI,parserParams:getAt(newI)
end

function ClassAndRecordParser:parseStaticAndInstanceMethod(parserParams,sep,newI)
	parserParams:getDysText():writeFourArgs("function ",self.classOrRecordName,sep,parserParams:getAt(newI))
	parserParams:updateSetI(self,newI + 1)
	return self
end

function ClassAndRecordParser:parseMethod(parserParams)
	local newI <const>,methodName <const> =  self:parseMethodName(parserParams)
	self.class.methods[methodName] = true
	self:parseStaticAndInstanceMethod(parserParams,":",newI)
	return self
end

function ClassAndRecordParser:grabConstructorParams(parserParams)
	local openingParens <const> = self:loopUntilMatch(parserParams,parserParams:getI() + 1,"%(",self.doNothing)
	local constructorParams <const> = {}
	local closingParens <const> = self:loopUntilMatchParams(parserParams,openingParens + 1,"%)",self:returnFunctionAddingTextToParams(constructorParams))
	return closingParens,constructorParams
end

function ClassAndRecordParser:parseConstructor(parserParams)
	self.foundConstructor = true
	local closingParens <const>, constructorParams <const> = self:grabConstructorParams(parserParams)
	self:writeStartOfConstructor(parserParams,constructorParams)
	local finalI <const> = self:writeSuperConstructorIfNeed(parserParams,closingParens)
	self:writeEndOfConstructor(parserParams,constructorParams)
	parserParams:updateSetI(self,finalI + 1)
	return self
end

function ClassAndRecordParser:parseStatic(parserParams)
	local newI <const> = self:loopUntilMatch(parserParams,parserParams:getI() + 1,"%S",self.doNothing)
	parserParams:updateSetI(self,newI)
	local nextI <const>,methodName <const> = self:parseMethodName(parserParams)
	self.class.staticMethods[methodName] = true
	self:parseStaticAndInstanceMethod(parserParams,".",nextI)
	return self
end

function ClassAndRecordParser:writeCustomMetaMethods(sep,dysText)
	local strTbl <const> = {dysText:getAt(self.metaMethodsI)}
	for i=1,#self.class.metaMethods,1 do
		strTbl[#strTbl + 1] = sep
		strTbl[#strTbl + 1] = "__"
		strTbl[#strTbl + 1] = self.class.metaMethods[i]
		strTbl[#strTbl + 1] = " = "
		strTbl[#strTbl + 1] = self.classOrRecordName
		strTbl[#strTbl + 1] = "."
		strTbl[#strTbl + 1] = self.class.metaMethods[i]
	end
	dysText:replaceTextAt(concat(strTbl),self.metaMethodsI)
	return self
end

function ClassAndRecordParser:parseMetaMethod(parserParams)
	local newI <const>, methodName <const> = self:parseMethodName(parserParams)
	self.class.staticMethods[methodName] = true
	self.class.metaMethods[#self.class.metaMethods + 1] = methodName
	self:parseStaticAndInstanceMethod(parserParams,".",newI)
	return self
end

ClassAndRecordParser.tokenFuncs['method'] = ClassAndRecordParser.parseMethod
ClassAndRecordParser.tokenFuncs['static'] = ClassAndRecordParser.parseStatic
ClassAndRecordParser.tokenFuncs['constructor'] = ClassAndRecordParser.parseConstructor
ClassAndRecordParser.tokenFuncs['metamethod'] = ClassAndRecordParser.parseMetaMethod

function ClassAndRecordParser:new(returnMode,startI)
	return setmetatable({returnMode = returnMode,startI = startI,params = {}},self)
end

return ClassAndRecordParser
