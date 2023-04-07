local FileWriter <const> = require('fileOperations.FileWriter')
local VariableOptions <const> = require('parser.VariableOptions')
local ClassProperties <const> = require('parser.ClassProperties')
local ConstructorProperties <const> = require('parser.ConstructorProperties')
local Scope <const> = require('parser.Scope')
local Config <const> = require('config.config')

local setmetatable <const> = setmetatable
local match <const> = string.match
local pairs <const> = pairs
local gmatch <const> = string.gmatch
local insert <const> = table.insert
local gsub <const> = string.gsub

local Parser <const> = {}
Parser.__index = Parser

_ENV = Parser

Parser.globalScope = Scope:init()
Parser.classRead = {}

local function findRequiredFile(text)
	 return match(text,[[%(['"]([^'"]+)['"]%)]])
end

local function readRequireFile(index,text,fileReader)
	--if just a single token has both require and the file such as: require('myFile')
	local file <const> = findRequiredFile(text[index])
	if file then
		fileReader:readFile(file)
		return index
	end
	--if require and the files are two separate tokens such as: require ('myFile')
	local file2 <const> = findRequiredFile(text[index + 1])
	if file2 then
		fileReader:readFile(file2)
		return index + 1
	end
	--if not found then update error info
	return index
end

--we are scanning the file only for the keyword 'require' and nothing else.
function Parser:loopForRequire()
	for i=1, #self.text,1 do
		if match(self.text[i],"^require") then
			--when we find the require keyword, try to open that fil if it is .lua or .dys then parse it.
			readRequireFile(i,self.text,self.fileReader)
		end
	end
end

function Parser:require(i)
	return readRequireFile(i,self.text,self.fileReader)
end

function Parser:loc(i)
	--it isnt actually global, but since we already have a local keyword we just need to not write another one.
	self.varOpts:removeLocal()
	return i
end

function Parser:global(i)
	self.varOpts.scope = "global"
	return i
end

local function setGlobalAttr(varOpts,parser,index)
	varOpts:setGlobal()
	parser:setVarsRead(index - 1,Parser.globalVars)
end

local attributeFuncts <const> = {
	["const"] = VariableOptions.setConst,
	["global"] = setGlobalAttr,
	["mutable"] = VariableOptions.setMutable,
}

function Parser:attributes(index)
	for attr in gmatch(self.text[index],"([^<>,]+),?") do
		if attributeFuncts[attr] then
			attributeFuncts[attr](self.varOpts,self,index)
		else
			self.varOpts:setOption(attr,true)
		end
	end
	self.varOpts.varLoc = index - 1
	self.text[index] = ""
	return index
end

local function getVars(text)
	local tbl <const> = {}
	for var in gmatch(text,"([^,]+),?") do
		tbl[#tbl + 1] = var
	end
	return tbl
end

local function checkVars(scope,text)
	local tbl <const> = getVars(text)
	for i=1,#tbl,1 do
		if scope:check(tbl[i]) then
			return true
		end
	end
	return false
end

function Parser:setVarsRead(index)
	local tbl <const> = getVars(self.text[index])
	for i=1,#tbl,1 do
		if self.varOpts.scope == "global" then
			self.scope:addGlobal(tbl[i])
		else
			self.scope:add(tbl[i])
		end
	end
end

function Parser:findVarLoc(index)
	if match(self.text[index],"<[^>]*>") then
		self:attributes(index)
		return index - 1
	end
	return index
end

function Parser:parseVars(loc)
	if not match(self.text[loc],"[%].]") and not checkVars(self.scope,self.text[loc]) then
		self:setVarsRead(loc,self.varOpts)
		self.text[loc] = self.varOpts:setVar(self.text[loc])
	end
	self.varOpts:reset()
	return loc
end

function Parser:equals(index)
	--local loc <const> = self.varOpts.varLoc > 1 and self.varOpts.varLoc or index - 1
	local loc <const> = self:findVarLoc(index - 1)
	self:parseVars(loc)
	return index
end

function Parser:updateOp(index,op)
	local varLoc <const> = self:findVarLoc(index - 1)
	local varName <const> = self.text[varLoc]
	self.text[index] = "= " .. varName .. op
	return index
end

function Parser:add(index)
	return self:updateOp(index," +")
end

function Parser:sub(index)
	return self:updateOp(index," -")
end

function Parser:mult(index)
	return self:updateOp(index," *")
end

function Parser:divide(index)
	return self:updateOp(index," /")
end

local function findMatch(text,index,pat)
	local i = index
	while i <= #text and not match(text[i],pat) do
		i = i + 1
	end
	return i
end

function Parser:comments(index)
	--skip over the entire comment until we reach the newline character.
	return findMatch(self.text,index,"[\n\r]+")
end

--grab function or class name
local function grabName(text)
	return match(text,"[^(]+")
end

--grab parameters for function or class
local function grabParams(text, func)
	local funcParams <const> = match(text,"%(([^)]*)%)")
	for param in gmatch(funcParams,"([^,]*),?") do
		func(param)
	end
end

local function grabParent(text,index)
	if text[index] == ":>" then
		--return name of parent and the location of opening bracket
		return text[index + 1],index + 2
	end
	return nil,index
end

local function setClassDeclaration(text,start,stop,name)
	for i=start,stop - 1,1 do
		text[i] = ""
	end
	text[stop] = "local " .. name .. " <const> = {}" .. Config.newLine
end

local function adjustTokenTable(parser)
	parser.tokens["function"] = Parser.classFunction
	parser.tokens["}"] = Parser.endClass
end

local function checkModifiers(index,parser,name)
	if parser.text[index] == "local" then
		parser.scope:add(name)
		return true
	end
	if parser.text[index] == "global" then
		parser.text[index] = ""
		parser.scope:addGlobal(name)
		return true
	end
	parser.scope:add(name)
	parser.currentClass:addFunc(name)
	parser.tokenPatterns[name .. "%("] = Parser.checkIfClassFunction
	return false
end

local function checkEnd(i,parser)
	return i < #parser.text
end

Parser.classPatterns = {
	["init"] = true,
	["new"] = true,
}

local function checkIFConstructor(name,patterns)
	local reducedName <const> = match(name,'[^:.]+$')
	return patterns[reducedName]
end

local function checkEndScope(i,parser)
	return  i < #parser.text and not match(parser.text[i],"end[);]*")
end

function Parser:checkIfClassFunction(index)
	local funcName <const> = match(self.text[index],"[^(]+")
	if self.currentClass:findFunc(funcName) then
		--only modify it if it is preceded by a word followed by a ':' or a '.'
		if not match(self.text[index],"[.:]([^.:(]+)%(" ) then
			self.text[index] = "self:" .. self.text[index]
		end
	end
	return index
end

function Parser:super(index)
	local params <const> = {}
	grabParams(self.text[index],function(param) params[#params + 1] = param  end)
	self.text[index] = self.currentConstructor:replaceSuper(params)
	return index
end

function Parser:modifyConstructorVars(index)
	self.text[index] = gsub(self.text[index],"self",self.currentConstructor.objName)
	return index
end

function Parser:endConstructor(index)
	if not self.currentConstructor.metatableExist then
		self.text[self.currentConstructor.loc] = self.text[self.currentConstructor.loc] .. Config.newLine ..self.currentConstructor:makeMetatable()
	end
	self.text[index] = self.currentConstructor:generateConstructorReturn(self.text,index)
	self.tokenPatterns["^self%."] = nil
	self.tokenPatterns["^super%("] = nil
	self.tokens["return"] = nil
	return index
end

local function setNoReturn(parser)
	parser.currentConstructor.includeReturn = false
end

local function classConstructorSetup(parser,index,funcName)
	parser.text[index + 1] = gsub(parser.text[index + 1],funcName,parser.currentClass.name .. ":" .. funcName)
	parser.currentConstructor.constExist = true
	parser.currentClass.loc = index + 1
	parser.currentConstructor.name = funcName
	--the name for the object we are going to use in the constructor should be unique.
	parser.tokenPatterns["^self%."] = Parser.modifyConstructorVars
	parser.tokenPatterns["^super%("] = Parser.super
	parser.tokens["return"] = setNoReturn
end

local function loopThroughClassFunction(parser,index)
	parser.scope:new()
	grabParams(parser.text[index + 1],function(param) parser.scope:add(param) end)
	local newIndex <const> = parser:loopTokens(index + 2,checkEndScope)
	parser.scope:close()
	return newIndex
end

function Parser:classFunction(index)
	local funcName <const> = match(self.text[index + 1],"[^(]+")
	local isConstructor <const> = checkIFConstructor(funcName,self.classPatterns)
	if isConstructor then
		classConstructorSetup(self,index,funcName)
		local newIndex <const> = loopThroughClassFunction(self,index)
		self:endConstructor(newIndex)
		return newIndex
	elseif not checkModifiers(index - 1,self,funcName) then
		self.text[index + 1] = gsub(self.text[index + 1],"[^(]+%(",self.currentClass.name .. ":" .. funcName .. "(")
	end
	return loopThroughClassFunction(self,index)
end

function Parser:endClass(index)
	self.text[index] = ""
	if not self.currentConstructor.constExist then
		self.text[index] = self.currentConstructor:generateConstructor()
	end
	self.text[index] =self.text[index] .. self.currentClass:generateMetatable(self.currentConstructor.name)
	return index
end

--loop over the class file a second time. this time only scan for class function calls
function Parser:secondClassLoop(startIndex,endIndex)
	self.tokenPatterns = {}
	self.tokens = {}
	--new tokenPatterns should only contain patterns with the class function names.
	for k,_ in pairs(self.currentClass.funcs) do
		self.tokenPatterns[k .. "%("] = Parser.checkIfClassFunction
	end
	self:loopTokens(startIndex,function(i,_) return i < endIndex end)
	self.tokenPatterns = Parser.copyOfPatterns
	self.tokens = Parser.copyOfTokens
end

function Parser:class(index)
	local className <const> = match(self.text[index + 1],"[^(]+")
	self.classPatterns[className] = true
	local classParams <const> = {}
	grabParams(self.text[index + 1],function(param) classParams[#classParams + 1] = param end)
	local parentName <const>, bracketLoc <const> = grabParent(self.text,index + 2)
	local parent <const> = self.classRead[parentName]
	self.currentClass = ClassProperties:new(className,classParams,parent)
	self.classRead[className] = self.currentClass
	self.currentClass = self.classRead[className]
	self.currentConstructor = ConstructorProperties:new(self.currentClass)
	setClassDeclaration(self.text,index, bracketLoc,className)
	adjustTokenTable(self)
	self.scope:new()
	local newIndex <const> = self:loopTokens(index + 1,checkEnd)
	self.classPatterns[className] = nil
	self:secondClassLoop(index,newIndex)
	self.tokens = Parser.copyOfTokens
	self.tokenPatterns = Parser.copyOfPatterns
	return newIndex
end

function Parser:classConstructor(index)
	if index > 0 then
		insert(self.text,index,self.classProperties:generateConstructor())
	end
end

function Parser:setScopeOfFunc(index,name)
	--if user didnt include the local keyword and it isnt a var being assigned to a function using function keyword
	if self.text[index] ~= "local" and self.text[index] ~= "="  then
		--if user declares it a global function
		if self.text[index] == "global" then
			self.text[index] = ""
			self.scope:addGlobal(name)
			--if user  placed no modifier before and it isnt a var being assigned using function keyword then declare it local.
		elseif not match(self.text[index + 1],"function%(") and self.text[index + 2] ~= "(" then
			self.text[index + 1]	= "local " .. self.text[index + 1]
			self.scope:add(name)
		end
	else
		self.scope:add(name)
	end
end

function Parser:scanFunc(index)
	self.scope:new()
	grabParams(self.text[index],function(param) self.scope:add(param) end)
	local i <const> = self:loopTokens(index + 1,checkEndScope)
	self.scope:close()
	return i - 1
end

function Parser:func(index)
	local funName <const> = grabName(self.text[index + 1])
	self:setScopeOfFunc(index - 1,funName)
	return self:scanFunc(index + 1)
end

function Parser:conditionals(index,pat,endCond)
	local i <const> = findMatch(self.text,index + 1,pat)
	self.scope:new()
	local newIndex <const> = self:loopTokens(i,endCond)
	self.scope:close()
	return newIndex
end

function Parser:loops(index)
	return self:conditionals(index,"do",checkEndScope)
end

function Parser:fruit(index)
	self.text[index] = "for"
	return self:loops(index)
end

local function endIf(i,parser)
	return i < #parser.text and parser.text[i] ~= "elseif" and parser.text[i] ~= "else" and parser.text[i] ~= "end"
end

function Parser:ifCond(index)
	return self:conditionals(index,"then",endIf)
end

local function endElse(i,parser)
	return i < #parser.text and parser.text[i] ~= "end"
end

function Parser:elseCond(index)
	return self:conditionals(index,"[\r\n]+",endElse)
end

--when inside of table constructor, start at token after the '{' and skip over until we get to the closing '}'
function Parser:skipTblConstruct(index)
	local i = index + 1
	while i < #self.text do
		--if we find another table constructor then run this function for it. return the location of its closing '}'
		if match(self.text[i],"{") then
			--edge case of '{}'
			if not match(self.text[i],"{}") then
				i = self:skipTblConstruct(i)
			end
		elseif match(self.text[i],"}") then
			return i
		end
		i = i + 1
	end
	return index
end

function Parser:skipSpace(index)
	return index
end

function Parser:checkTokenPats(index)
	for pat,func in pairs(self.tokenPatterns) do
		if match(self.text[index],pat) then
			return func(self,index)
		end
	end
	return index
end

function Parser:startParsing()
	self:loopTokens(1,checkEnd)
	FileWriter.writeFile(self.fileAttr)
end

function Parser:loopTokens(i,endFunc)
	while endFunc(i,self) do
		if self.tokens[self.text[i]] then
			i = self.tokens[self.text[i]](self,i)
		else
			i = self:checkTokenPats(i)
		end
		i = i + 1
	end
	return i
end

local tokens = {
	['local'] = Parser.loc,
	class = Parser.class,
	['='] = Parser.equals,
	['+='] = Parser.add,
	['-='] = Parser.sub,
	['*='] = Parser.mult,
	['/='] = Parser.divide,
	["for"] = Parser.loops,
	['function'] = Parser.func,
	[""] = Parser.skipSpace,
	["if"] = Parser.ifCond,
	["else"] = Parser.elseCond,
	["elseif"] = Parser.ifCond,
	["while"] = Parser.loops,
	["fruit"] = Parser.fruit,
	["{"] = Parser.skipTblConstruct
}

local tokenPatterns = {
	['^[^%-]*require'] = Parser.require,
	["^%-%-"] = Parser.comments,
	["[(,;]*function%("] = Parser.scanFunc
}

local function copyPatterns()
	local tbl <const> = {}
	for k,v in pairs(tokenPatterns) do
		tbl[k] = v end
	return tbl
end

Parser.copyOfPatterns = copyPatterns()

local function copyTokens()
	local tbl <const> = {}
	for k,v in pairs(tokens) do
		tbl[k] = v end
	return tbl
end

Parser.copyOfTokens = copyTokens()

function Parser:new(fileAttr,fileReader)
	return setmetatable({text = fileAttr.text,fileAttr = fileAttr,fileReader = fileReader,varOpts = VariableOptions:new(),
						 tokenPatternCopy = Parser.tokenPatterns, scope = Scope:init(Parser.globalScope), classFuncs = {},
						 tokens = copyTokens(), tokenPatterns = copyPatterns() },self)
end

return Parser
