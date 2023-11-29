
local remove <const> = table.remove
local concat <const> = table.concat
local pairs <const> = pairs
local io = io

local ScanChars <const> = {type = 'ScanChars'}
ScanChars.__index = ScanChars

_ENV = ScanChars

ScanChars.spaceChars = {
	[" "] = true,
	["\t"] = true
}

function ScanChars:scanComments(word,char,allWords)
	return self.ScannerDriver:scanComments(word,char,allWords)
end

function ScanChars:ScanEqualSign(word,char,allWords)
	return self.ScannerDriver:ScanEqualSign(word,char,allWords)
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
		io.write("creating new word: ",concat(word),";;;;;\n")
		self:addToTable(concat(word),allWords)
		self:clearWord(word)
	end
	return self
end

function ScanChars:breakWordThenAddCharToAllWords(word,char,allWords)
	io.write("breakWordThenAddChar: ",char, "|||\n")
	io.write("old word is: ",concat(word),"((((\n")
	self:createNewWord(word,allWords)
	self:addToTable(char,allWords)
	return self
end

function ScanChars:breakWordThenAddCharToWord(word,char,allWords)
	self:createNewWord(word,allWords)
	self:addToTable(word,char)
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
	["-"] = ScanChars.scanComments,
	--TODO fix these
--	["+"] = ScanChars.breakWordThenAddCharToAllWords,
	--["/"] = ScanChars.breakWordThenAddCharToAllWords,
--	["*"] = ScanChars.breakWordThenAddCharToAllWords,
	["="] = ScanChars.scanEqualSign,
	["'"] = ScanChars.scanSingleQuote,
	['"'] = ScanChars.scanDoubleQuote
}

for k in pairs(ScanChars.spaceChars) do
	scanTbl[k] = ScanChars.scanSpaces
end


function ScanChars:parseInput(word,char,allWords)
	io.write("char is: ",char,";;  self is: ",self.type,"\n")
	if scanTbl[char] then
		io.write("it matches\n")
		return scanTbl[char](self,word,char,allWords) end
	self:addToTable(char,word)
	return self
end

function ScanChars.initScannerDriver(scannerDriver)
	ScanChars.ScannerDriver = scannerDriver
end

return ScanChars
