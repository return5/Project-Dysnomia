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
local io = io

local Parser <const> = {}
Parser.__index = Parser

_ENV = Parser

Parser.globalScope = Scope:init()
Parser.classRead = {}

local function findRequiredFile(text)
	 return match(text,'[^"\']+')
end

local function readRequireFile(index,text,fileScanner)
	--if just a single token has both require and the file such as: require('myFile')
	local file <const> = findRequiredFile(text[index])
	fileScanner:readFile(file)
	return index
end

--we are scanning the file only for the keyword 'require' and nothing else.
function Parser:loopForRequire()
	for i=1, #self.text,1 do
		if self.text[i] == "require" then
			--when we find the require keyword, try to open that fil if it is .lua or .dys then parse it.
			readRequireFile(i + 2,self.text,self.fileScanner)
		end
	end
end

function Parser:require(i)
	return readRequireFile(i + 2,self.text,self.fileScanner)
end

function Parser:incrOp(index,op)
	local variable <const> = self.text[index - 1]
	self.text[index] = "= " .. variable .. op
	return index + 1
end

function Parser:add(index)
	return self:incrOp(index," +")
end

function Parser:sub(index)
	return self:incrOp(index," -")
end

function Parser:mult(index)
	return self:incrOp(index," *")
end

function Parser:divide(index)
	return self:incrOp(index," /")
end

function Parser:checkForEndLine(index)
	return self:checkForEnd(index) and self.text[index] ~= "\n"
end

function Parser:func(index)
	return index + 1
end

function Parser:incrI(index)
	return index + 1
end

function Parser:comment(index)
	return self:loopTokens(index,Parser.checkForEndLine,Parser.incrI) + 1
end

function Parser:checkForEnd(index)
	return index < #self.text
end

function Parser:parseToken(index)
	local token <const> = self.text[index]
	if self.tokens[token] then
		io.write(token,";\n")
		return self.tokens[token](self,index)
	end
	for pat,func in pairs(self.tokenPatterns) do
		if match(token,pat) then
			return func(self,index)
		end
	end
	return index + 1
end

function Parser:startParsing()
	self:loopTokens(1,Parser.checkForEnd,Parser.parseToken)
	FileWriter.writeFile(self.fileAttr)
	return true
end

function Parser:loopTokens(start,condFunc,tokenFunc)
	local index = start
	while condFunc(self,index) do
		io.write(self.text[index],";\n")
		index = tokenFunc(self,index)
	end
	return index
end

local tokenPatterns = {
	['^[^%-]*require'] = Parser.require,
	['%-%-'] = Parser.comment
}

local tokens = {
	['local'] = Parser.loc,
	['class'] = Parser.class,
	['record'] = Parser.record,
	["->"] = Parser.lambda,
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
	["{"] = Parser.skipTblConstruct,
	["--"] = Parser.comment
}

local function copyTokens(tbl)
	local copyTbl <const> = {}
	for k,v in pairs(tbl) do
		copyTbl[k] = v
	end
	return copyTbl
end

Parser.copyOfPatterns = copyTokens(tokenPatterns)

Parser.copyOfTokens = copyTokens(tokens)

function Parser:new(fileAttr,fileScanner)
	return setmetatable({text = fileAttr.text,fileAttr = fileAttr,fileScanner = fileScanner,varOpts = VariableOptions:new(),
						 scope = Scope:init(Parser.globalScope), classFuncs = {}, tokens = copyTokens(tokens), tokenPatterns = copyTokens(tokenPatterns)},self)
end

return Parser
