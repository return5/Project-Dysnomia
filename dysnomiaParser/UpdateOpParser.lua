local TokenParser <const> = require('dysnomiaParser.TokenParser')
local Config <const> = require('dysnomiaConfig.config')
local setmetatable <const> = setmetatable
local tonumber <const> = tonumber
local tostring <const> = tostring
local concat <const> = table.concat
local substr <const> = string.sub

local UpdateOpParser <const> = {type = 'UpdateOpParser'}
UpdateOpParser.__index = UpdateOpParser

setmetatable(UpdateOpParser,TokenParser)

_ENV = UpdateOpParser

local function addVar(vars,dysText)
	return function(text)
		if text then
			dysText:eraseEndingText()
			local trimmed <const> = UpdateOpParser.trimString(text)
			if trimmed and trimmed ~= "," and trimmed ~= "" then
				vars[#vars + 1] = trimmed
			end
		end
	end
end

local function resetTempWord(tempWord)
	for i=#tempWord,1,-1 do
		tempWord[i] = nil
	end
end

local function generateTempVar(tempWord,params)
	params[#params + 1] = concat(tempWord)
end

local function countZero(text,params,tempWord)
	if text == "(" then
		tempWord[#tempWord + 1] = text
		return 1
	elseif #tempWord > 0 then
		if text ~= "," then
			tempWord[#tempWord + 1] = text
		else
			generateTempVar(tempWord,params)
			resetTempWord(tempWord)
		end
	elseif tonumber(text) then
		params[#params + 1] = text
	elseif text ~= "," then
		tempWord[#tempWord + 1] = text
	end
	return 0
end

local function countNotZero(text,params,tempWord,count)
	tempWord[#tempWord + 1] = text
	if text == "("	then return count + 1 end
	if text == ")" then
		if count == 1 then
			generateTempVar(tempWord,params)
			resetTempWord(tempWord)
			return 0
		else
			return count - 1
		end
	end
	return count
end

local function addParam(params)
	local count = 0
	local tempWord <const> = {}
	return function(text)
		if text then
			local trimmed <const> = UpdateOpParser.trimString(text)
			if trimmed and trimmed ~= "" and trimmed ~= ";" and trimmed ~= "\n" then
				if count == 0 then
					count = countZero(trimmed,params,tempWord)
				else
					count = countNotZero(trimmed,params,tempWord,count)
				end
			end
		end
	end
end

function UpdateOpParser:grabVars(parserParams)
	local vars <const> = {}
	self:loopBackUntilMatchStatement(parserParams,parserParams:getI() - 1,addVar(vars,parserParams:getDysText()))
	parserParams:setI(parserParams:getI() + 1)
	return vars
end

function UpdateOpParser:grabParams(parserParams)
	local params <const> = {}
	local endI <const> = self:loopUntilMatch(parserParams,parserParams:getI(),"[\n;]",addParam(params))
	return endI,params
end

local function writeTempVars(parserParams,params,vars)
	if #vars > #params then
		local dysText <const> = parserParams:getDysText()
		local tempVar <const> = "__tempVar" .. substr(tostring({}),8)
		dysText:writeFiveArgs("local ",tempVar, " <const> = ",params[#params],Config.newLine)
		for i=#params,#vars,1 do
			params[i] = tempVar
		end
	end
end

local function writeParams(parserParams,vars,params,op)
	local dysText <const> = parserParams:getDysText()
	local j = #vars
	for i=1,#params,1 do
		dysText:writeFiveArgs(vars[j], " = ", vars[j],op," "):writeTwoArgs(params[i],Config.newLine)
		j = j - 1
	end
	local lastParam <const> = params[#params]
	for i=#params + 1,#vars,1 do
		dysText:writeFiveArgs(vars[j], " = ", vars[j],op," "):writeTwoArgs(lastParam,Config.newLine)
		j = j - 1
	end
end

function UpdateOpParser:parseUpdateOp(parserParams)
	local vars <const> = self:grabVars(parserParams)
	local endI <const>, params <const> = self:grabParams(parserParams)
	writeTempVars(parserParams,params,vars)
	writeParams(parserParams,vars,params,self.op)
	parserParams:update(TokenParser,endI)
	return self
end

function UpdateOpParser:new(op)
	return setmetatable({op = op},self)
end

return UpdateOpParser

