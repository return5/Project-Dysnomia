local ScannerDriver <const> = require('scanner.ScannerDriver')

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

local scanTbl <const> = {
	[","] = ScanChars.breakWordThenAddCharToAllWords,
	[")"] = ScanChars.breakWordThenAddCharToAllWords,
	["("] = ScanChars.breakWordThenAddCharToAllWords,
	[";"] = ScanChars.breakWordThenAddCharToAllWords,
	["<"] = ScanChars.breakWordThenAddCharToAllWords,
	[">"] = ScanChars.breakWordThenAddCharToAllWords,
	["\n"] = ScanChars.breakWordThenAddCharToAllWords,
	["-"] = ScanChars.breakWordThenAddCharToWord,
	["+"] = ScanChars.breakWordThenAddCharToWord,
	["/"] = ScanChars.breakWordThenAddCharToWord,
	["*"] = ScanChars.breakWordThenAddCharToWord,
	["="] = ScanChars.scanEqualSign
}

for k in pairs(scanTbl) do
	scanTbl[k] = ScanChars.scanSpaces
end

function ScannerDriver:ScanEqualSign(word,char,allWords)
	return ScannerDriver:ScanEqualSign(word,char,allWords)
end

function ScanChars:scanSpaces(word,char,allWords)
	return ScannerDriver:scanSpaces(word,char,allWords)
end

function ScanChars:scanDoubleQuote(word,char)
	return ScannerDriver:handleDoubleQuote(word,char)
end

function ScanChars:scanSingleQuote(word,char)
	return ScannerDriver:handleSingleQuote(word,char)
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
	self:addToTable(word,char)
	self:createNewWord(word,allWords)
	return self
end

function ScanChars:createNewWord(word,allWords)
	if #word > 0 then
		self:addToTable(allWords,concat(word))
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
	self:addToTable(word,char)
	return self
end

function ScanChars:parseInput(word,char,allWords)
	if scanTbl[char] then return scanTbl[char](word,char,allWords) end
	self:addToTable(char,word)
	return self
end

return ScanChars
