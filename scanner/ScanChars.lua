
local remove <const> = table.remove
local concat <const> = table.concat
local pairs <const> = pairs

local ScanChars <const> = {type = 'ScanChars'}
ScanChars.__index = ScanChars

_ENV = ScanChars

ScanChars.spaceChars = {
	[" "] = true,
	["\t"] = true
}

function ScanChars:scanMinusSign(word,char,allWords)
	return self.ScannerDriver:scanMinusSign(word,char,allWords)
end

function ScanChars:scanMathOps(word,char,allWords)
	return self.ScannerDriver:scanMathOps(word,char,allWords)
end

function ScanChars:scanSpaces(word,char,allWords)
	return self.ScannerDriver:scanSpaces(word,char,allWords)
end

function ScanChars:scanDoubleQuote(word,char)
	return self.ScannerDriver:scanDoubleQuote(word,char)
end

function ScanChars:scanSingleQuote(word,char)
	return self.ScannerDriver:scanSingleQuote(word,char)
end

function ScanChars:checkIfEndOfWordMatches(word,char)
	return word[#word] == char
end

function ScanChars:checkIfCharIsEscaped(word)
	return word[#word] == "\\" and word[#word - 1] ~= "\\"
end

function ScanChars:clearWord(word)
	while #word > 0 do
		remove(word)
	end
	return self
end

function ScanChars:addToTable(item,table)
	table[#table + 1] = item
	return self
end

function ScanChars:addCharToWordThenCreateNewWord(word,char,allWords)
	self:addToTable(char,word)
	self:createNewWord(word,allWords)
	return self
end

function ScanChars:createNewWord(word,allWords)
	if #word > 0 then
		self:addToTable(concat(word),allWords)
		self:clearWord(word)
	end
	return self
end

function ScanChars:breakWordThenAddCharToAllWords(word,char,allWords)
	self:createNewWord(word,allWords)
	self:addToTable(char,allWords)
	return self
end

function ScanChars:breakWordThenAddCharToWord(word,char,allWords)
	self:createNewWord(word,allWords)
	self:addToTable(char,word)
	return self
end

local scanTbl <const> = {
	[","] = ScanChars.breakWordThenAddCharToAllWords,
	[")"] = ScanChars.breakWordThenAddCharToAllWords,
	["("] = ScanChars.breakWordThenAddCharToAllWords,
	[";"] = ScanChars.breakWordThenAddCharToAllWords,
	["<"] = ScanChars.breakWordThenAddCharToAllWords,
	[">"] = ScanChars.breakWordThenAddCharToAllWords,
	["\n"] = ScanChars.breakWordThenAddCharToAllWords,
	["-"] = ScanChars.scanMinusSign,
	["+"] = ScanChars.scanMathOps,
	["/"] = ScanChars.scanMathOps,
	["*"] = ScanChars.scanMathOps,
	["="] = ScanChars.breakWordThenAddCharToAllWords,
	["'"] = ScanChars.scanSingleQuote,
	['"'] = ScanChars.scanDoubleQuote
}

for k in pairs(ScanChars.spaceChars) do
	scanTbl[k] = ScanChars.scanSpaces
end


function ScanChars:parseInput(word,char,allWords)
	if scanTbl[char] then
		return scanTbl[char](self,word,char,allWords) end
	self:addToTable(char,word)
	return self
end

function ScanChars.initScannerDriver(scannerDriver)
	ScanChars.ScannerDriver = scannerDriver
end

return ScanChars
